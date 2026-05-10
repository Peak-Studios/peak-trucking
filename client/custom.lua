--- ============================================================
--- CUSTOM CLIENT HOOKS
--- Use this file to add your own custom logic, overrides, and integrations.
--- Core files are never modified here, keeping upgrades clean.
--- ============================================================

Open = Open or {}

-- ============================================================
-- PERMISSIONS & VALIDATION
-- ============================================================

--- Called before the trucking menu can be opened.
--- Return false to deny access.
--- @return boolean
function CanOpenTruckingMenu()
    -- Example: restrict to a specific job
    -- local job = Peak.Client.GetPlayerJob()
    -- if job.name ~= 'trucker' then return false end
    return true
end

-- ============================================================
-- JOB LIFECYCLE EVENTS
-- ============================================================

--- Called when a trucking mission is started by the player.
--- @param missionId number
--- @param routeIndex number
function OnMissionStarted(missionId, routeIndex)
    Peak.Utils.Debug('[Custom] Mission started — id:', missionId, 'route:', routeIndex)
    -- TriggerEvent('your_script:onTruckingStarted', missionId)
end

--- Called when a trucking mission is completed and payment issued.
--- @param missionId number
--- @param payment number
function OnMissionCompleted(missionId, payment)
    Peak.Utils.Debug('[Custom] Mission completed — id:', missionId, 'pay:', payment)
    -- TriggerEvent('your_script:onTruckingCompleted', missionId, payment)
end

-- ============================================================
-- CUSTOM SUBSYSTEM OVERRIDES
-- ============================================================
-- Return a truthy value to stop default logic; return nil to continue.

--- Override for the notification system.
--- @param msg string
--- @param type string 'success'|'error'|'info'|'warning'
--- @param duration number Milliseconds
--- @return boolean|nil
function Open.CustomNotify(msg, type, duration)
    return nil
end

--- Override for the text UI display.
--- @param text string
--- @return boolean|nil
function Open.CustomShowTextUI(text)
    return nil
end

--- Override to hide the text UI.
--- @return boolean|nil
function Open.CustomHideTextUI()
    return nil
end

-- ============================================================
-- EXPORTS
-- ============================================================

--- Returns the current active job data cached by the trucking script.
--- @return table
exports('GetTruckingJobData', function()
    return jobData or {}
end)
