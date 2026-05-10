-- ============================================================
-- SERVER STATE
-- ============================================================

Core = nil
local playerJobDataCache  = {}
local isDatabaseReady     = false
local activeJobSessions   = {}
local discordAvatarCache  = {}
local paymentCooldowns    = {}

-- Start Job Session Tracking
RegisterServerEvent("peak-trucking:StartJob")
AddEventHandler("peak-trucking:StartJob", function(missionId)
  local playerId = source
  activeJobSessions[playerId] = missionId
end)

AddEventHandler("playerDropped", function()
  local playerId = source
  activeJobSessions[playerId] = nil
end)

-- Core Initialization
CreateThread(function()
  Config.Framework = select(2, GetCore())
  Core = GetCore()

  while Core == nil do
    Wait(0)
  end

  -- Register callback for checking mission unlock status
  RegisterCallback("peak-trucking:CheckMissionUnlocked", function(playerId, cb, missionId)
    local playerData = GetPlayerJobData(playerId)
    if playerData then
      cb(playerData.unlockedMissions[tostring(missionId)])
    else
      cb(false)
    end
  end)

  -- Load all player data from database
  local allPlayerData = ExecuteSql("SELECT * FROM peak_trucking")

  for _, playerRecord in pairs(allPlayerData) do
    playerRecord.unlockedMissions = json.decode(playerRecord.unlockedMissions)
    playerRecord.dailymissions = json.decode(playerRecord.dailymissions)
    playerRecord.history = json.decode(playerRecord.history)
    playerRecord.points = json.decode(playerRecord.points)
    table.insert(playerJobDataCache, playerRecord)
  end

  -- Register callback for leaderboard
  RegisterCallback("peak-trucking:GetLeaderboard", function(playerId, cb)
    table.sort(playerJobDataCache, function(a, b)
      return a.level > b.level
    end)

    local identifier = GetIdentifier(playerId)
    local leaderboardData = { data = {} }

    for index, playerData in pairs(playerJobDataCache) do
      if index <= 8 then
        table.insert(leaderboardData.data, playerData)
      end
    end

    cb(leaderboardData)
  end)

  isDatabaseReady = true
end)

-- ============================================================
-- DATABASE & PLAYER DATA HELPERS
-- ============================================================

--- Blocks until the database cache is fully loaded.
function waitDatabase()
    while not isDatabaseReady do
        Wait(0)
    end
end

--- Returns the cached job data for a player, or false if not found.
--- @param playerId number
--- @return table|false
function GetPlayerJobData(playerId)
    waitDatabase()
    local identifier = GetIdentifier(playerId)
    for _, playerData in pairs(playerJobDataCache) do
        if playerData.identifier == identifier then
            return playerData
        end
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

-- ============================================================
-- DISCORD AVATAR
-- ============================================================
function DiscordRequest(method, endpoint, body)
  local response = nil
  local token = ServerConfig and ServerConfig.DiscordBotToken or ''
  if token == '' then
    return { data = nil, code = 0, headers = {} }
  end

  local authHeader = "Bot " .. token

  PerformHttpRequest("https://discordapp.com/api/" .. endpoint, function(code, data, headers)
    response = {
      data = data,
      code = code,
      headers = headers
    }
  end, method, #body > 0 and json.encode(body) or "", {
    ["Content-Type"] = "application/json",
    ["Authorization"] = authHeader
  })

  while response == nil do
    Citizen.Wait(0)
  end

  return response
end

function GetDiscordAvatar(playerId)
  local discordId = nil
  local avatarUrl = nil

  for _, identifier in ipairs(GetPlayerIdentifiers(playerId)) do
    if string.match(identifier, "discord:") then
      discordId = string.gsub(identifier, "discord:", "")
      break
    end
  end

  if discordId then
    -- Check cache first
    if discordAvatarCache[discordId] == nil then
      local endpoint = string.format("users/%s", discordId)
      local response = DiscordRequest("GET", endpoint, {})

      if response.code == 200 then
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
      else
        return Config.DefaultImage
      end

      discordAvatarCache[discordId] = avatarUrl
    else
      avatarUrl = discordAvatarCache[discordId]
    end
  end

  if avatarUrl == nil or avatarUrl == false then
    avatarUrl = Config.DefaultImage
  end

  return avatarUrl
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
    local currentPoints = playerData.points[companyIndexStr]

    -- Check if player has enough points
    if missionData.reqPoint <= currentPoints then
      playerData.points[companyIndexStr] = currentPoints - missionData.reqPoint
      playerData.unlockedMissions[missionIdStr] = true

      SyncPlayerDataByKey(playerId, "points", playerData.points)
      SyncPlayerDataByKey(playerId, "unlockedMissions", playerData.unlockedMissions)

      ExecuteSql(
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

    ExecuteSql(
        'UPDATE peak_trucking SET `history` = :history WHERE `identifier` = :id',
        { history = json.encode(playerData.history), id = playerData.identifier }
    )
    SyncPlayerDataByKey(playerId, 'history', playerData.history)
  end
end

-- Create New Player Data
function CreatePlayerData(playerId)
  local identifier = GetIdentifier(playerId)
  local playerData = GetPlayerJobData(playerId)
  local avatarUrl = GetDiscordAvatar(playerId)

  -- If player already exists in cache, just update avatar if missing
  if playerData then
    if not playerData.avatar then
      playerData.avatar = avatarUrl or Config.DefaultImage
      SyncPlayerDataByKey(playerId, "avatar", avatarUrl)
      ExecuteSql("UPDATE peak_trucking SET `avatar` = :avatar WHERE `identifier` = :identifier", {
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
      'SELECT * FROM peak_trucking WHERE identifier = :identifier',
      { identifier = identifier }
  )
  if existingData[1] then
      if Config.Debug then
          print('[peak-trucking] Player ' .. identifier .. ' already exists in database — skipping insert.')
      end
      return
  end

  -- Add to cache and database
  table.insert(playerJobDataCache, newPlayerData)

  ExecuteSql(
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
    SyncPlayerDataByKey(playerId, "identifier", playerData.identifier)
    SyncPlayerDataByKey(playerId, "points", playerData.points)
    SyncPlayerDataByKey(playerId, "history", playerData.history)
    SyncPlayerDataByKey(playerId, "unlockedMissions", playerData.unlockedMissions)
    SyncPlayerDataByKey(playerId, "dailymissions", playerData.dailymissions)
    SyncPlayerDataByKey(playerId, "xp", playerData.xp)
    SyncPlayerDataByKey(playerId, "name", playerData.name)
    SyncPlayerDataByKey(playerId, "totalEarnings", playerData.totalEarnings)
    SyncPlayerDataByKey(playerId, "completedJobs", playerData.completedJobs)
    SyncPlayerDataByKey(playerId, "level", playerData.level)
    SyncPlayerDataByKey(playerId, "avatar", GetDiscordAvatar(playerId))
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
      if loadedIllegal then
        local hasIllegalItem = HasItem(playerId, {
          name = Config.IllegalNPC.item_name,
          amount = 10
        })

        if hasIllegalItem then
          finalPay = finalPay + Config.IllegalNPC.money
          RemoveItem(playerId, Config.IllegalNPC.item_name, 10)
        else
          TriggerClientEvent("peak-trucking:createNotification", playerId, Config.Language.not_enough_illegal_box)
        end
      else
          if Config.Debug then
              print('[peak-trucking] loadedIllegal is false — skipping illegal item check.')
          end
      end

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
      ExecuteSql(
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
RegisterServerEvent("peak-trucking:GiveIllegalItem")
AddEventHandler("peak-trucking:GiveIllegalItem", function()
  local playerId = source
  AddInventoryItem(playerId, Config.IllegalNPC.item_name, 1)
end)
