Locales = {}

local currentLocale = 'en'

local translations = {
    en = {
        -- Interaction
        ['open_menu']                = 'PRESS E TO OPEN MENU',
        ['load_box']                 = 'E - Load Box',
        ['take_box']                 = 'E - Take Box',
        ['deliver']                  = 'E - Deliver',
        ['finish_job']               = 'E - Finish Job',
        ['take_illegal']             = 'E - Take Illegal Job',

        -- Job feedback
        ['get_trailer']              = 'Get the trailer from the location marked on your map...',
        ['deliver_trailer']          = 'Deliver the trailer to the location marked on your map...',
        ['return_veh']               = 'Return the vehicle to finish job and get payment...',
        ['wait_call']                = 'Wait for the call...',
        ['get_ready']                = 'Get Ready For Transport!',

        -- Errors & validation
        ['cant_select_truck']        = "You can't select this truck in this mission!",
        ['mission_locked']           = 'Mission is locked!',
        ['not_enough_points']        = "You don't have enough points!",
        ['already_unlocked']         = 'This mission is already unlocked',
        ['you_charged']              = 'You were charged $%s for vehicle damage',
        ['not_enough_illegal_box']   = "You don't have enough illegal box. REQUIRED : 10",
        ['trailer_doesnt_match']     = "Trailer doesn't match!",
        ['in_vehicle']               = "You can't take the box in vehicle!",
        ['spawn_location_full']      = 'Spawn Locations are full!',
        ['leave_vehicle']            = 'Leave the vehicle!',
        ['stop_vehicle']             = 'Stop vehicle to deliver!',
        ['notaccessjob']             = "You don't have access to this job!",

        -- UI labels
        ['transportation_stage']     = 'Transportation Stage',
        ['trailer_quality']          = 'Trailer Quality',
        ['truck_fuel']               = 'Truck Fuel',
        ['detach_trailer']           = 'Detach Trailer',
        ['mark_location']            = 'Mark Location',
        ['nts_main']                 = 'NTS MAIN',
        ['companies']                = 'COMPANIES',
        ['leaderboard']              = 'LEADERBOARD',
        ['profile']                  = 'PROFILE',
        ['unlocked']                 = 'UNLOCKED',
        ['locked']                   = 'LOCKED',
        ['trust_point']              = 'Trust Point',
        ['select_route']             = 'Select A Route',
        ['select_mission']           = 'SELECT MISSION',
        ['daily_missions']           = 'Daily Missions',
        ['hour']                     = 'hr',
        ['completed']                = 'Completed',
        ['not_completed']            = 'Not Completed',
        ['select_truck']             = 'Select A Truck',
        ['select_your_truck']        = 'Select Your Truck!',
        ['select_mission_and_route'] = 'Select a mission and a route!',
        ['start_the_job']            = 'Start the Job!',
        ['stop_job']                 = 'CANCEL JOB',
        ['start_job']                = 'START JOB',

        -- Profile / stats
        ['completed_jobs']           = 'Completed Jobs',
        ['total_missions_completed'] = 'Total missions completed on National Transfer & Storage Company.',
        ['total_earnings']           = 'Total Earnings',
        ['total_earnings_desc']      = 'Total money earned on National Transfer & Storage Company.',
        ['current_level']            = 'Current Level',
        ['latest_works']             = 'Latest Works',
        ['earned']                   = 'Earned',
    }
}

--- Returns the localised string for the given key, optionally formatted.
--- Falls back to English, then to the raw key if not found.
--- @param key string
--- @param ... any Format arguments (optional)
--- @return string
function Locales.Get(key, ...)
    local str = translations[currentLocale] and translations[currentLocale][key]
    if not str then
        str = translations['en'] and translations['en'][key]
    end
    if not str then
        return key
    end
    if ... then
        return string.format(str, ...)
    end
    return str
end

--- Sets the active locale.
--- @param locale string ISO locale code, e.g. 'en', 'fr'
function Locales.SetLocale(locale)
    currentLocale = locale
end

--- Registers a custom locale's translation table.
--- @param locale string
--- @param strings table Key-value translation map
function Locales.AddLocale(locale, strings)
    translations[locale] = strings
end

-- Shorthand alias used throughout the codebase.
L = Locales.Get

-- ============================================================
-- BACKWARD COMPAT
-- Config.Language is a real flat table so existing code (including
-- NuiMessage serialization) continues to work unchanged.
-- New code should use L('key') or Locales.Get('key').
-- ============================================================

Config = Config or {}
Config.Language = (function()
    local out = {}
    -- Pull all keys from the English locale into a flat table.
    for k, v in pairs(translations['en'] or {}) do
        out[k] = v
    end
    return out
end)()
