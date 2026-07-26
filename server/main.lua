-- ============================================================
-- SERVER STATE
-- ============================================================

Core = nil
local playerJobDataCache  = {}
local isDatabaseReady     = false
local activeJobSessions   = {}
local discordAvatarCache  = {}
local paymentCooldowns    = {}
local activeIllegalSessions = {}

-- Start Job Session Tracking
RegisterServerEvent("peak-trucking:StartJob")
AddEventHandler("peak-trucking:StartJob", function(missionId)
  local playerId = source
  if not missionId then
    activeJobSessions[playerId] = nil
    activeIllegalSessions[playerId] = nil
    return
  end

  activeJobSessions[playerId] = missionId
end)

RegisterServerEvent("peak-trucking:CancelJob")
AddEventHandler("peak-trucking:CancelJob", function(reason)
  local playerId = source
  activeJobSessions[playerId] = nil
  activeIllegalSessions[playerId] = nil

  if Config.Debug then
    print(("[peak-trucking] Player %s cancelled trucking job. Reason: %s"):format(playerId, tostring(reason or "unknown")))
  end
end)

AddEventHandler("playerDropped", function()
  local playerId = source
  activeJobSessions[playerId] = nil
  activeIllegalSessions[playerId] = nil
end)

-- Core Initialization
CreateThread(function()
  while Core == nil do
    Wait(0)
  end

  Core = GetCore()
  Config.Framework = select(2, GetCore())

  -- Register callback for checking mission unlock status
  RegisterCallback("peak-trucking:CheckMissionUnlocked", function(playerId, cb, missionId)
    local playerData = GetPlayerJobData(playerId)
    if playerData and playerData.unlockedMissions then
      cb(playerData.unlockedMissions[tostring(missionId)] or false)
    else
      cb(false)
    end
  end)

  -- Cached Leaderboard Callback (Refreshed every 60s from DB)
  local leaderboardCache = nil
  local lastLeaderboardFetch = 0

  RegisterCallback("peak-trucking:GetLeaderboard", function(playerId, cb)
    local currentTime = os.time()
    if leaderboardCache and (currentTime - lastLeaderboardFetch) < 60 then
      cb(leaderboardCache)
      return
    end

    local results = ExecuteSql("SELECT identifier, points, history, avatar, name, unlockedMissions, dailymissions, totalEarnings, completedJobs, xp, level FROM peak_trucking ORDER BY level DESC, xp DESC LIMIT 8")
    local leaderboardData = { data = {} }

    for _, row in ipairs(results) do
      if type(row.unlockedMissions) == "string" then row.unlockedMissions = json.decode(row.unlockedMissions) end
      if type(row.dailymissions) == "string" then row.dailymissions = json.decode(row.dailymissions) end
      if type(row.history) == "string" then row.history = json.decode(row.history) end
      if type(row.points) == "string" then row.points = json.decode(row.points) end
      table.insert(leaderboardData.data, row)
    end

    leaderboardCache = leaderboardData
    lastLeaderboardFetch = currentTime
    cb(leaderboardCache)
  end)

  isDatabaseReady = true
end)

-- ============================================================
-- DATABASE & PLAYER DATA HELPERS (O(1) Hash Map)
-- ============================================================

--- Returns the cached job data for a player (lazy loaded from DB), or false if not found.
--- @param playerId number
--- @return table|false
function GetPlayerJobData(playerId)
    local identifier = GetIdentifier(playerId)
    if not identifier then return false end

    if playerJobDataCache[identifier] then
        return playerJobDataCache[identifier]
    end

    -- Lazy load from database if not yet cached
    local result = ExecuteSql('SELECT * FROM peak_trucking WHERE identifier = :id', { id = identifier })
    if result and result[1] then
        local playerRecord = result[1]
        playerRecord.unlockedMissions = type(playerRecord.unlockedMissions) == 'string' and json.decode(playerRecord.unlockedMissions) or playerRecord.unlockedMissions or {}
        playerRecord.dailymissions    = type(playerRecord.dailymissions) == 'string' and json.decode(playerRecord.dailymissions) or playerRecord.dailymissions or {}
        playerRecord.history          = type(playerRecord.history) == 'string' and json.decode(playerRecord.history) or playerRecord.history or {}
        playerRecord.points           = type(playerRecord.points) == 'string' and json.decode(playerRecord.points) or playerRecord.points or {}
        playerJobDataCache[identifier] = playerRecord
        return playerRecord
    end

    return false
end

RegisterServerEvent("peak-trucking:LoadPlayerData")
AddEventHandler("peak-trucking:LoadPlayerData", function()
  local playerId = source
  LoadPlayerData(playerId)
end)

--- Sends a single player-data key update to the client.
--- @param playerId number
--- @param key string
--- @param value any
function SyncPlayerDataByKey(playerId, key, value)
    TriggerClientEvent('peak-trucking:SyncPlayerDataByKey', playerId, key, value)
end

--- Sends all player-data in a single consolidated network payload to the client.
--- @param playerId number
--- @param playerData table
function SyncAllPlayerData(playerId, playerData)
    if not playerData then return end
    TriggerClientEvent('peak-trucking:SyncAllPlayerData', playerId, playerData)
end

-- ============================================================
-- DISCORD AVATAR (Asynchronous & Non-Blocking)
-- ============================================================
function DiscordRequest(method, endpoint, body, cb)
  local token = ServerConfig and ServerConfig.DiscordBotToken or ''
  if token == '' then
    if cb then cb({ data = nil, code = 0, headers = {} }) end
    return
  end

  local authHeader = "Bot " .. token

  PerformHttpRequest("https://discordapp.com/api/" .. endpoint, function(code, data, headers)
    if cb then
      cb({ data = data, code = code, headers = headers })
    end
  end, method, #body > 0 and json.encode(body) or "", {
    ["Content-Type"] = "application/json",
    ["Authorization"] = authHeader
  })
end

function GetDiscordAvatar(playerId)
  local discordId = nil
  for _, identifier in ipairs(GetPlayerIdentifiers(playerId)) do
    if string.match(identifier, "discord:") then
      discordId = string.gsub(identifier, "discord:", "")
      break
    end
  end

  if discordId then
    if discordAvatarCache[discordId] ~= nil then
      return discordAvatarCache[discordId] or Config.DefaultImage
    end

    -- Perform non-blocking async request
    DiscordRequest("GET", string.format("users/%s", discordId), {}, function(response)
      local avatarUrl = nil
      if response and response.code == 200 and response.data then
        local userData = json.decode(response.data)
        if userData and userData.avatar then
          local firstChar = userData.avatar:sub(1, 1)
          local secondChar = userData.avatar:sub(2, 2)
          if firstChar and secondChar == "_" then
            avatarUrl = "https://media.discordapp.net/avatars/" .. discordId .. "/" .. userData.avatar .. ".gif"
          else
            avatarUrl = "https://media.discordapp.net/avatars/" .. discordId .. "/" .. userData.avatar .. ".png"
          end
        end
      end

      avatarUrl = avatarUrl or Config.DefaultImage
      discordAvatarCache[discordId] = avatarUrl

      local pData = GetPlayerJobData(playerId)
      if pData and pData.avatar ~= avatarUrl then
        pData.avatar = avatarUrl
        SyncPlayerDataByKey(playerId, "avatar", avatarUrl)
        ExecuteSqlAsync("UPDATE peak_trucking SET `avatar` = :avatar WHERE `identifier` = :identifier", {
          avatar = avatarUrl,
          identifier = pData.identifier
        })
      end
    end)
  end

  return discordAvatarCache[discordId] or Config.DefaultImage
end

-- ============================================================
-- MISSION MANAGEMENT
-- ============================================================
RegisterServerEvent("peak-trucking:UnlockMission")
AddEventHandler("peak-trucking:UnlockMission", function(missionData)
  local playerId = source
  local playerData = GetPlayerJobData(playerId)

  if playerData then
    local missionIdStr = tostring(missionData.id)

    -- Check if already unlocked
    if playerData.unlockedMissions[missionIdStr] then
      TriggerClientEvent("peak-trucking:createNotification", playerId, Config.Language.already_unlocked)
      return
    end

    local companyIndexStr = tostring(missionData.companyIndex)
    local currentPoints = playerData.points[companyIndexStr] or 0

    -- Check if player has enough points
    if missionData.reqPoint <= currentPoints then
      playerData.points[companyIndexStr] = currentPoints - missionData.reqPoint
      playerData.unlockedMissions[missionIdStr] = true

      SyncPlayerDataByKey(playerId, "points", playerData.points)
      SyncPlayerDataByKey(playerId, "unlockedMissions", playerData.unlockedMissions)

      ExecuteSqlAsync(
          'UPDATE peak_trucking SET `unlockedMissions` = :missions, `points` = :points WHERE `identifier` = :id',
          {
              missions = json.encode(playerData.unlockedMissions),
              points   = json.encode(playerData.points),
              id       = playerData.identifier,
          }
      )
    else
      TriggerClientEvent('peak-trucking:createNotification', playerId, Config.Language.not_enough_points)
    end
  end
end)

-- ============================================================
-- HISTORY & PLAYER LIFECYCLE
-- ============================================================

--- Appends a completed-job entry to a player's history and persists it.
function AddToHistory(playerId, label, supply, earnings)
  local playerData = GetPlayerJobData(playerId)

  if playerData then
    table.insert(playerData.history, {
      label = label,
      supply = supply,
      earn = earnings,
      date = os.time()
    })

    ExecuteSqlAsync(
        'UPDATE peak_trucking SET `history` = :history WHERE `identifier` = :id',
        { history = json.encode(playerData.history), id = playerData.identifier }
    )
    SyncPlayerDataByKey(playerId, 'history', playerData.history)
  end
end

-- Create New Player Data
function CreatePlayerData(playerId)
  local identifier = GetIdentifier(playerId)
  if not identifier then return end

  local playerData = GetPlayerJobData(playerId)
  local avatarUrl = GetDiscordAvatar(playerId)

  -- If player already exists in cache, just update avatar if missing
  if playerData then
    if not playerData.avatar then
      playerData.avatar = avatarUrl or Config.DefaultImage
      SyncPlayerDataByKey(playerId, "avatar", avatarUrl)
      ExecuteSqlAsync("UPDATE peak_trucking SET `avatar` = :avatar WHERE `identifier` = :identifier", {
        avatar = playerData.avatar or Config.DefaultImage,
        identifier = playerData.identifier
      })
    end
    return
  end

  -- Initialize unlocked missions (mission 1 unlocked by default)
  local unlockedMissions = {}
  for i = 1, 16 do
    unlockedMissions[tostring(i)] = (i == 1)
  end

  -- Initialize company points
  local companyPoints = {}
  for i = 0, 7 do
    companyPoints[tostring(i)] = 0
  end

  -- Create new player record
  local newPlayerData = {
    identifier = identifier,
    points = companyPoints,
    history = {},
    avatar = avatarUrl,
    name = GetPlayerRPName(playerId),
    unlockedMissions = unlockedMissions,
    dailymissions = {
      data = CreateDailyMission(),
      resetAt = os.time() + 86400
    },
    totalEarnings = 0,
    completedJobs = 0,
    xp = 0,
    level = 1
  }

  -- Check if player already exists in database
  local existingData = ExecuteSql(
      'SELECT identifier FROM peak_trucking WHERE identifier = :identifier',
      { identifier = identifier }
  )
  if existingData[1] then
      if Config.Debug then
          print('[peak-trucking] Player ' .. identifier .. ' already exists in database — skipping insert.')
      end
      return
  end

  -- Add to cache index by identifier
  playerJobDataCache[identifier] = newPlayerData

  ExecuteSqlAsync(
  "INSERT INTO peak_trucking (identifier, points, unlockedMissions, dailymissions, xp, level, totalEarnings, completedJobs, name, avatar, history) VALUES (:identifier, :points, :unlockedMissions, :dailymissions, :xp, :level, :totalEarnings, :completedJobs, :name, :avatar, :history)",
    {
      identifier = newPlayerData.identifier,
      points = json.encode(newPlayerData.points),
      unlockedMissions = json.encode(newPlayerData.unlockedMissions),
      dailymissions = json.encode(newPlayerData.dailymissions),
      xp = newPlayerData.xp,
      level = newPlayerData.level,
      totalEarnings = newPlayerData.totalEarnings,
      completedJobs = newPlayerData.completedJobs,
      name = newPlayerData.name,
      avatar = newPlayerData.avatar or Config.DefaultImage,
      history = json.encode(newPlayerData.history)
    })

  LoadPlayerData(playerId)
end

-- Load Player Data
function LoadPlayerData(playerId)
  local playerData = GetPlayerJobData(playerId)

  if playerData then
    playerData.avatar = GetDiscordAvatar(playerId)
    SyncAllPlayerData(playerId, playerData)
  else
    CreatePlayerData(playerId)
  end
end

-- Finish Job Handler
RegisterServerEvent("peak-trucking:FinishJob")
AddEventHandler("peak-trucking:FinishJob", function(missionId, vehicleHealth, loadedIllegal, routeLabel)
  local playerId = source
  missionId = tonumber(missionId)
  vehicleHealth = tonumber(vehicleHealth) or 0

  if not missionId or type(routeLabel) ~= 'string' then
      if Config.Debug then
          print('[peak-trucking] Player ' .. playerId .. ' sent invalid FinishJob payload — rejected.')
      end
      return
  end

  -- Anti-spam check
  if paymentCooldowns[playerId] then
      if Config.Debug then
          print('[peak-trucking] Player ' .. playerId .. ' triggered payment too fast — throttled.')
      end
      return
  end

  -- Verify job session
  if activeJobSessions[playerId] ~= missionId then
      if Config.Debug then
          print('[peak-trucking] Player ' .. playerId .. ' submitted wrong mission ID — rejected.')
      end
      return
  end

  -- Set cooldown
  paymentCooldowns[playerId] = true
  SetTimeout(5000, function()
    paymentCooldowns[playerId] = false
  end)

  activeJobSessions[playerId] = nil

  local player = GetPlayer(playerId)
  local playerData = GetPlayerJobData(playerId)

  if playerData then
    local missionData = GetMissionById(missionId)

    if missionData then
      local companyIndex = missionData.companyIndex

      local historyEntry = {
        label = missionData.header,
        supply = missionData.requirementsLabel[1].label
      }

      -- Clamp vehicle health
      if vehicleHealth > 100 then vehicleHealth = 100 end
      if vehicleHealth < 0 then vehicleHealth = 0 end

      -- Calculate damage penalty
      local damagePercent = 100 - vehicleHealth
      local basePay = missionData.payment
      local damagePenalty = math.floor((basePay * damagePercent) / 100)
      local finalPay = basePay - damagePenalty

      -- Check for illegal cargo bonus
      local serverSideIllegal = activeIllegalSessions[playerId]
      if loadedIllegal and serverSideIllegal and serverSideIllegal.boxesLoaded >= 10 then
        -- No longer checking inventory items, relying purely on server-side tracking
        finalPay = finalPay + Config.IllegalNPC.money
        
        -- Add XP bonus
        if Config.IllegalNPC.xp_bonus then
          AddXP(playerId, Config.IllegalNPC.xp_bonus)
        end
      elseif loadedIllegal then
          -- If client says illegal but server doesn't agree
          TriggerClientEvent("peak-trucking:createNotification", playerId, Config.Language.illegal_validation_failed or "Illegal cargo verification failed.")
          if Config.Debug then
              print('[peak-trucking] Illegal validation failed for ' .. playerId .. '. Server boxes: ' .. (serverSideIllegal and serverSideIllegal.boxesLoaded or 0))
          end
      end

      -- Clean up illegal session
      activeIllegalSessions[playerId] = nil

      -- Check for route extra payment
      local routeData = GetRouteByLabel(missionData.routes, routeLabel)
      local extraPayment = false

      if routeData and routeData.extraPayment then
        extraPayment = routeData.extraPayment
      end

      if extraPayment then
        finalPay = finalPay + extraPayment
      end

      -- Pay the player
      addMoney(playerId, finalPay)

      -- Notify about damage penalty
      if damagePenalty > 0 then
        TriggerClientEvent("peak-trucking:createNotification", playerId,
          string.format(Config.Language.you_charged, damagePenalty))
      end

      -- Update player stats
      local companyIndexStr = tostring(companyIndex)
      playerData.points[companyIndexStr] = playerData.points[companyIndexStr] + 1
      playerData.totalEarnings = playerData.totalEarnings + finalPay
      playerData.completedJobs = playerData.completedJobs + 1

      SyncPlayerDataByKey(playerId, "points", playerData.points)
      SyncPlayerDataByKey(playerId, "totalEarnings", playerData.totalEarnings)
      SyncPlayerDataByKey(playerId, "completedJobs", playerData.completedJobs)

      -- Add XP
      AddXP(playerId, math.random(Config.GiveXP.min, Config.GiveXP.max))

      -- Save to database
      ExecuteSqlAsync(
          'UPDATE peak_trucking SET `totalEarnings` = :earnings, `points` = :points, `completedJobs` = :jobs WHERE `identifier` = :id',
          {
              earnings = playerData.totalEarnings,
              points   = json.encode(playerData.points),
              jobs     = playerData.completedJobs,
              id       = playerData.identifier,
          }
      )

      -- Add to history
      AddToHistory(playerId, historyEntry.label, historyEntry.supply, finalPay)
    end
  end
end)

-- ============================================================
-- UTILITY LOOKUPS
-- ============================================================

--- Returns a route table matching the given label, or false.
--- @param routes table
--- @param label  string
--- @return table|false
function GetRouteByLabel(routes, label)
  for _, route in pairs(routes) do
    if route.label == label then
      return route
    end
  end
  return false
end

--- Returns a mission table matching the given numeric ID, or false.
--- @param missionId number
--- @return table|false
function GetMissionById(missionId)
  for _, mission in pairs(Config.Missions) do
    if mission.id == missionId then
      return mission
    end
  end
  return false
end

-- ============================================================
-- ILLEGAL CARGO
-- ============================================================
RegisterServerEvent("peak-trucking:AcceptIllegalDeal")
AddEventHandler("peak-trucking:AcceptIllegalDeal", function()
  local playerId = source
  if activeJobSessions[playerId] then
    activeIllegalSessions[playerId] = {
      boxesLoaded = 0
    }
  end
end)

RegisterServerEvent("peak-trucking:GiveIllegalItem")
AddEventHandler("peak-trucking:GiveIllegalItem", function()
  local playerId = source
  
  -- Security check: Verify the player actually has an active illegal session
  local session = activeIllegalSessions[playerId]
  if session and activeJobSessions[playerId] then
    if session.boxesLoaded < 10 then
      session.boxesLoaded = session.boxesLoaded + 1
    else
      if Config.Debug then
        print('[peak-trucking] Player ' .. playerId .. ' attempted to get more than 10 illegal items.')
      end
    end
  else
    if Config.Debug then
      print('[peak-trucking] Player ' .. playerId .. ' attempted to get illegal item without active illegal session.')
    end
  end
end)
