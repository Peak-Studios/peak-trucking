Peak = Peak or {}
Peak.Server = Peak.Server or {}
Peak.Server.FrameworkName   = nil
Peak.Server.FrameworkObject = nil
Peak.Server.Ready           = false

local sqlDriver = nil

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

--- Initializes the framework object for server-side use.
--- Sets the global Core variable used by legacy bridge code.
local function InitializeFramework()
    Peak.Server.FrameworkName = GetFrameworkName()
    local fw = Peak.Server.FrameworkName

    if fw == 'qbcore' then
        Peak.Server.FrameworkObject = exports['qb-core']:GetCoreObject()
        Core = Peak.Server.FrameworkObject
        Peak.Utils.print('Framework detected: ^5QBCore^0')
    elseif fw == 'qbox' then
        local ok, obj = pcall(function() return exports.qbx_core:GetCoreObject() end)
        Peak.Server.FrameworkObject = (ok and obj) or { Functions = exports.qbx_core }
        Core = Peak.Server.FrameworkObject
        Peak.Utils.print('Framework detected: ^5QBox^0')
    elseif fw == 'esx' then
        Peak.Server.FrameworkObject = exports.es_extended:getSharedObject()
        Core = Peak.Server.FrameworkObject
        Peak.Utils.print('Framework detected: ^5ESX^0')
    else
        Peak.Utils.Warn('No framework detected. Running in standalone mode.')
    end

    Peak.Server.Ready = true
end

--- Detects the active SQL driver.
local function InitializeSQLDriver()
    if Config.SQL ~= 'auto' then
        sqlDriver = Config.SQL
        return
    end

    if GetResourceState('oxmysql') == 'started' then
        sqlDriver = 'oxmysql'
    elseif GetResourceState('ghmattimysql') == 'started' then
        sqlDriver = 'ghmattimysql'
    elseif GetResourceState('mysql-async') == 'started' then
        sqlDriver = 'mysql-async'
    else
        sqlDriver = 'oxmysql'
        Peak.Utils.Warn('No SQL driver detected — defaulting to oxmysql.')
    end

    Peak.Utils.Debug('SQL driver:', sqlDriver)
end

-- ============================================================
-- VERSION CHECKER
-- ============================================================

--- Sends a Discord embed webhook payload.
--- @param url string
--- @param title string
--- @param description string
--- @param color number
--- @param footer string|nil
function Peak.Server.SendDiscordWebhook(url, title, description, color, footer)
    if not url or url == '' then return end

    local payload = {
        embeds = {
            {
                title       = title,
                description = description,
                color       = color or 3447003,
                footer      = footer and { text = footer } or nil,
            }
        }
    }

    PerformHttpRequest(url, function() end, 'POST', json.encode(payload), {
        ['Content-Type'] = 'application/json'
    })
end

local function StartVersionChecker()
    if not Config.EnableVersionChecker then return end
    if not Config.VersionURL or Config.VersionURL == '' then return end

    PerformHttpRequest(Config.VersionURL, function(status, body)
        if status ~= 200 or not body then
            Peak.Utils.Warn('Failed to fetch version data (HTTP ' .. tostring(status) .. ')')
            return
        end

        local data = json.decode(body)
        if not data then return end

        local resourceName = GetCurrentResourceName()
        local info = data[resourceName]
        if not info then return end

        local current = GetResourceMetadata(resourceName, 'version', 0)
        if current == info.version then
            Peak.Utils.print('^5' .. resourceName .. '^0 is ^2up to date^0 (v' .. current .. ')')
        else
            Peak.Utils.Warn('^5' .. resourceName .. '^0 is ^1outdated^0! Current: ^1' .. current .. '^0 | Latest: ^2' .. info.version .. '^0')
        end
    end, 'GET')
end

-- ============================================================
-- EXPORTS
-- ============================================================

exports('GetSQLDriver',      function() return sqlDriver                   end)
exports('GetFramework',      function() return Peak.Server.FrameworkObject end)
exports('GetFrameworkName',  function() return Peak.Server.FrameworkName   end)
exports('IsServerReady',     function() return Peak.Server.Ready           end)

--- Returns the framework object and its name.
--- Used by legacy bridge code.
--- @return table, string
function GetCore()
    return Peak.Server.FrameworkObject, Peak.Server.FrameworkName
end

-- ============================================================
-- STARTUP
-- ============================================================

CreateThread(function()
    Wait(100)
    InitializeFramework()
    InitializeSQLDriver()

    Peak.Utils.print('Peak Trucking initialized. Framework: ^5' .. Peak.Server.FrameworkName .. '^0 | SQL: ^5' .. sqlDriver .. '^0')

    Wait(5000)
    StartVersionChecker()
end)
