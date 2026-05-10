-- ============================================================
-- XP — Driver level and experience point management
-- ============================================================

--- Advances a player's driver level by one, unlocking eligible missions
--- and resetting XP to 0 (or capping at the max level).
--- @param source number  Player server ID
function AddLevel(source)
    local identifier = GetIdentifier(source)
    local myData = GetPlayerJobData(source)

    if not myData then return end

    myData.level = myData.level + 1
    if not Config.XP[myData.level] then
        myData.level = #Config.XP
        myData.xp   = Config.XP[myData.level]
    else
        myData.xp = 0
    end

    for _, v in pairs(Config.Missions) do
        if v.reqLevel and myData.level == v.reqLevel then
            myData.unlockedMissions[tostring(v.id)] = true
        end
    end

    SyncPlayerDataByKey(source, 'unlockedMissions', myData.unlockedMissions)
    SyncPlayerDataByKey(source, 'xp',               myData.xp)
    SyncPlayerDataByKey(source, 'level',             myData.level)

    ExecuteSql(
        'UPDATE peak_trucking SET `level` = :level, `xp` = :xp, `unlockedMissions` = :missions WHERE `identifier` = :id',
        {
            level    = myData.level,
            xp       = myData.xp,
            missions = json.encode(myData.unlockedMissions),
            id       = identifier,
        }
    )
end

--- Adds XP to a player and triggers a level-up if the threshold is reached.
--- @param source number  Player server ID
--- @param xp     number  Amount of XP to award
function AddXP(source, xp)
    local identifier = GetIdentifier(source)
    local myData     = GetPlayerJobData(source)

    xp = tonumber(xp) or 0
    if xp <= 0 then return end
    if not myData then return end

    local level = myData.level
    if level == #Config.XP then
        myData.xp = 0
        return
    end

    myData.xp = tonumber(myData.xp) + tonumber(xp)

    if Config.XP[level] and myData.xp >= Config.XP[level] then
        local remainXp = Config.XP[level] - myData.xp
        AddLevel(source)
        if remainXp < 0 then
            AddXP(source, -(remainXp))
        end
    else
        SyncPlayerDataByKey(source, 'xp', myData.xp)
    end

    ExecuteSql(
        'UPDATE peak_trucking SET `level` = :level, `xp` = :xp WHERE `identifier` = :id',
        { level = myData.level, xp = myData.xp, id = identifier }
    )
end
