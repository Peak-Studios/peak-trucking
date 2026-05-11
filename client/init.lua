Peak = Peak or {}
Peak.Client = Peak.Client or {}
Peak.Client.FrameworkName   = nil
Peak.Client.FrameworkObject = nil
Peak.Client.Ready           = false

local notifySystem   = nil
local targetSystem   = nil
local progressSystem = nil

-- ============================================================
-- INITIALIZATION
-- ============================================================

--- Detects the currently running framework via resource state.
--- @return string frameworkName
local function GetFrameworkName()
    if Config.Framework ~= 'auto' then
        return Config.Framework
    end

    if GetResourceState('qb-core') == 'started' then
        return 'qbcore'
    elseif GetResourceState('qbx_core') == 'started' then
        return 'qbox'
    elseif GetResourceState('es_extended') == 'started' then
        return 'esx'
    end

    return 'standalone'
end

--- Initializes the framework object for client-side use.
--- Sets the global Core variable used by legacy bridge code.
local function InitializeFramework()
    Peak.Client.FrameworkName = GetFrameworkName()
    local fw = Peak.Client.FrameworkName

    if fw == 'qbcore' then
        Peak.Client.FrameworkObject = exports['qb-core']:GetCoreObject()
        Core = Peak.Client.FrameworkObject
        Peak.Utils.print('Framework detected: ^5QBCore^0')
    elseif fw == 'qbox' then
        local ok, obj = pcall(function() return exports['qb-core']:GetCoreObject() end)
        if not (ok and obj) then
            ok, obj = pcall(function() return exports['qbx_core']:GetCoreObject() end)
        end

        if ok and obj then
            Peak.Client.FrameworkObject = obj
        else
            Peak.Client.FrameworkObject = { Functions = exports.qbx_core }
        end
        Core = Peak.Client.FrameworkObject
        Peak.Utils.print('Framework detected: ^5QBox^0')
    elseif fw == 'esx' then
        Peak.Client.FrameworkObject = exports.es_extended:getSharedObject()
        Core = Peak.Client.FrameworkObject
        Peak.Utils.print('Framework detected: ^5ESX^0')
    else
        Peak.Utils.Warn('No framework detected. Running in standalone mode.')
    end

    Peak.Client.Ready = true
end

--- Detects which notification, target, and progress systems are active.
local function InitializeSubsystems()
    -- Notify
    if Config.Notify ~= 'auto' then
        notifySystem = Config.Notify
    elseif GetResourceState('qb-core') == 'started' then
        notifySystem = 'qb-core'
    elseif GetResourceState('es_extended') == 'started' then
        notifySystem = 'esx'
    else
        notifySystem = 'native'
    end

    -- Target
    if Config.Target ~= 'auto' then
        targetSystem = Config.Target
    elseif GetResourceState('ox_target') == 'started' then
        targetSystem = 'ox_target'
    elseif GetResourceState('qb-target') == 'started' then
        targetSystem = 'qb-target'
    end

    -- Progress bar
    if Config.Progress ~= 'auto' then
        progressSystem = Config.Progress
    elseif GetResourceState('progressbar') == 'started' then
        progressSystem = 'progressbar'
    else
        progressSystem = 'wait'
    end

    Peak.Utils.Debug(
        'Subsystems — Notify:', notifySystem,
        '| Target:', tostring(targetSystem),
        '| Progress:', progressSystem
    )
end

-- ============================================================
-- GETTERS
-- ============================================================

function Peak.Client.GetNotifySystem()   return notifySystem   end
function Peak.Client.GetTargetSystem()   return targetSystem   end
function Peak.Client.GetProgressSystem() return progressSystem end

-- ============================================================
-- PLAYER DATA
-- ============================================================

--- Returns the player's full data from the active framework.
--- @return table|nil
function Peak.Client.GetPlayerData()
    local fw  = Peak.Client.FrameworkName
    local obj = Peak.Client.FrameworkObject

    if fw == 'qbcore' or fw == 'qbox' then
        return obj.Functions.GetPlayerData()
    elseif fw == 'esx' then
        return obj.GetPlayerData()
    end

    return nil
end

--- Returns the player's job data normalised across frameworks.
--- @return table {name, label, grade, grade_name}
function Peak.Client.GetPlayerJob()
    local data = Peak.Client.GetPlayerData()
    if not data then
        return { name = 'unemployed', label = 'Unemployed', grade = 0, grade_name = '' }
    end

    local fw = Peak.Client.FrameworkName
    if fw == 'qbcore' or fw == 'qbox' then
        local job = data.job
        return {
            name       = job.name,
            label      = job.label,
            grade      = job.grade.level or 0,
            grade_name = job.grade.name or '',
        }
    elseif fw == 'esx' then
        local job = data.job
        return {
            name       = job.name,
            label      = job.label,
            grade      = job.grade,
            grade_name = job.grade_name or '',
        }
    end

    return { name = 'unemployed', label = 'Unemployed', grade = 0, grade_name = '' }
end

-- ============================================================
-- UI HELPERS
-- ============================================================

--- Displays a notification using the active subsystem.
--- @param text string
--- @param type string 'success'|'error'|'info'|'warning'
--- @param duration number Milliseconds
function Peak.Client.Notify(text, type, duration)
    type     = type or 'info'
    duration = duration or 5000

    if Open and Open.CustomNotify then
        if Open.CustomNotify(text, type, duration) then return end
    end

    local system = Peak.Client.GetNotifySystem()
    if system == 'qb-core' then
        local qbType = type == 'info' and 'primary' or (type == 'warning' and 'error' or type)
        Peak.Client.FrameworkObject.Functions.Notify(text, qbType, duration)
    elseif system == 'esx' then
        Peak.Client.FrameworkObject.ShowNotification(text, type == 'warning' and 'error' or type)
    else
        SetNotificationTextEntry('STRING')
        AddTextComponentSubstringPlayerName(text)
        DrawNotification(false, false)
    end
end

--- Shows a floating text UI near the player.
--- @param text string
function Peak.Client.ShowTextUI(text)
    if Open and Open.CustomShowTextUI then
        if Open.CustomShowTextUI(text) then return end
    end

    local fw = Peak.Client.FrameworkName
    if fw == 'qbcore' or fw == 'qbox' then
        TriggerEvent('qb-core:client:DrawText', text)
    elseif fw == 'esx' then
        Core.TextUI(text)
    end
end

--- Hides the floating text UI.
function Peak.Client.HideTextUI()
    if Open and Open.CustomHideTextUI then
        if Open.CustomHideTextUI() then return end
    end

    local fw = Peak.Client.FrameworkName
    if fw == 'qbcore' or fw == 'qbox' then
        TriggerEvent('qb-core:client:HideText')
    elseif fw == 'esx' then
        Core.HideUI()
    end
end

-- ============================================================
-- EXPORTS
-- ============================================================

exports('GetClientFrameworkName', function() return Peak.Client.FrameworkName  end)
exports('IsClientReady',          function() return Peak.Client.Ready           end)
exports('GetPlayerData',          function() return Peak.Client.GetPlayerData() end)
exports('GetPlayerJob',           function() return Peak.Client.GetPlayerJob()  end)

--- Returns the framework object and its name.
--- Used by legacy bridge code.
--- @return table, string
function GetCore()
    return Peak.Client.FrameworkObject, Peak.Client.FrameworkName
end

-- ============================================================
-- STARTUP
-- ============================================================

CreateThread(function()
    Wait(500)
    InitializeFramework()
    InitializeSubsystems()
end)
