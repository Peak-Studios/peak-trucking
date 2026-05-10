-- ============================================================
-- DAILY MISSIONS — Reset and progress tracking
-- ============================================================

--- Builds a fresh daily-mission progress table from Config.DailyMissions.
--- @return table  Map of mission keys to mission data with process = 0
function CreateDailyMission()
    local missions = {}
    for key, mission in pairs(Config.DailyMissions) do
        missions[key] = json.decode(json.encode(mission))
        missions[key].process = 0
    end
    return missions
end

-- ============================================================
-- ANTI-SPAM
-- ============================================================

local spamDailyMissionPlayer = {}

-- ============================================================
-- EVENT HANDLERS
-- ============================================================

--- Increments a player's daily mission progress by one step.
--- Awards XP when the mission is fully completed.
RegisterServerEvent('peak-trucking:AddDailyMissionProcess')
AddEventHandler('peak-trucking:AddDailyMissionProcess', function(key)
    local src        = source
    local identifier = GetIdentifier(src)
    local playerData = GetPlayerJobData(src)

    if not playerData then return end

    if spamDailyMissionPlayer[src] then
        if Config.Debug then
            print('[peak-trucking] Player ' .. src .. ' triggered daily mission too fast — throttled.')
        end
        return
    end

    spamDailyMissionPlayer[src] = true
    SetTimeout(5000, function()
        spamDailyMissionPlayer[src] = false
    end)

    local missionData = playerData.dailymissions.data[key]
    if missionData.process < missionData.max then
        missionData.process = missionData.process + 1
    end

    if missionData.process == missionData.max then
        AddXP(src, missionData.xp)
    end

    SyncPlayerDataByKey(src, 'dailymissions', playerData.dailymissions)
    ExecuteSql(
        'UPDATE peak_trucking SET `dailymissions` = :missions WHERE `identifier` = :id',
        { missions = json.encode(playerData.dailymissions), id = identifier }
    )
end)

--- Checks whether a player's daily missions have expired and resets them if so.
RegisterServerEvent('peak-trucking:CheckDailyMission')
AddEventHandler('peak-trucking:CheckDailyMission', function()
    local src        = source
    local identifier = GetIdentifier(src)
    local playerData = GetPlayerJobData(src)

    if not playerData then return end

    local diff = os.difftime(playerData.dailymissions.resetAt, os.time())
    if diff <= 0 then
        playerData.dailymissions.resetAt = os.time() + 86400
        playerData.dailymissions.data    = CreateDailyMission()
        SyncPlayerDataByKey(src, 'dailymissions', playerData.dailymissions)
        ExecuteSql(
            'UPDATE peak_trucking SET `dailymissions` = :missions WHERE `identifier` = :id',
            { missions = json.encode(playerData.dailymissions), id = identifier }
        )
    end
end)
