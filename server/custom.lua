--- ============================================================
--- CUSTOM SERVER HOOKS
--- Use this file to add your own custom logic, overrides, and integrations.
--- Core files are never modified here, keeping upgrades clean.
--- ============================================================

Open = Open or {}

-- ============================================================
-- PERMISSIONS & VALIDATION
-- ============================================================

--- Called before a mission is accepted by the server.
--- Return false to deny.
--- @param source number Player server ID
--- @return boolean
function ServerCanStartMission(source)
    -- Example: require a minimum player count
    -- if #GetPlayers() < 2 then return false end
    return true
end

-- ============================================================
-- JOB LIFECYCLE EVENTS
-- ============================================================

--- Called when a mission is completed and payment is about to be issued.
--- @param source number
--- @param missionId number
--- @param payment number
function OnServerMissionCompleted(source, missionId, payment)
    Peak.Utils.Debug('[Custom] Mission complete — source:', source, 'id:', missionId, 'pay:', payment)
    -- TriggerEvent('your_script:onTruckingPaid', source, payment)
end

-- ============================================================
-- PLAYER HOOKS
-- ============================================================

--- Called when a player loads into the server.
--- @param source number
function Open.OnPlayerLoaded(source)
end

--- Called when a player disconnects.
--- @param source number
function Open.OnPlayerUnloaded(source)
end

-- ============================================================
-- CUSTOM MONEY OVERRIDES
-- ============================================================
-- Return a truthy result to override; return nil to use default framework logic.

--- Override to give money using a custom system.
--- @param source number
--- @param amount number
--- @param moneyType string 'cash'|'bank'
--- @return boolean|nil
function Open.AddMoney(source, amount, moneyType)
    return nil
end

--- Override to remove money using a custom system.
--- @param source number
--- @param amount number
--- @param moneyType string
--- @return boolean|nil
function Open.RemoveMoney(source, amount, moneyType)
    return nil
end
