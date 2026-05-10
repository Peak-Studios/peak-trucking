Config = Config or {}

-- ============================================================
-- INTERNAL CONFIGURATION (ADVANCED)
-- This file contains technical defaults and system settings.
-- Only modify these if you know what you are doing.
-- For user-facing settings, see shared/config.lua
-- ============================================================

-- Version Checker
Config.EnableVersionChecker = true
Config.VersionURL = 'https://raw.githubusercontent.com/Peak-Studios/peak-trucking/main/version.json'

-- Admin
Config.AdminGroups = { 'group.admin', 'admin', 'god', 'superadmin' }
Config.AdminAce    = 'admin'

-- XP thresholds — one entry per level (100 levels total).
-- Each value is the XP required to reach that level.
Config.XP = {}

CreateThread(function()
    for i = 1, 100 do
        table.insert(Config.XP, i * 1000)
    end
end)
