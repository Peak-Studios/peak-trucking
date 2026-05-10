Peak = Peak or {}
Peak.Utils = {}

-- ============================================================
-- GENERAL UTILS (PEAK)
-- ============================================================

--- Prints a debug message to the console if Config.Debug is enabled.
--- @param ... any Arguments to print
function Peak.Utils.Debug(...)
    if not Config.Debug then return end

    local args = { ... }
    local strArgs = {}
    for i = 1, #args do
        strArgs[#strArgs + 1] = tostring(args[i])
    end

    print('^3[Peak:Debug]^0 ' .. table.concat(strArgs, ' '))
end

--- Prints a standard message to the console.
--- @param ... any Arguments to print
function Peak.Utils.print(...)
    local args = { ... }
    local strArgs = {}
    for i = 1, #args do
        strArgs[#strArgs + 1] = tostring(args[i])
    end

    print('^2[Peak]^0 ' .. table.concat(strArgs, ' '))
end

--- Prints a warning message to the console.
--- @param ... any Arguments to print
function Peak.Utils.Warn(...)
    local args = { ... }
    local strArgs = {}
    for i = 1, #args do
        strArgs[#strArgs + 1] = tostring(args[i])
    end

    print('^1[Peak:WARN]^0 ' .. table.concat(strArgs, ' '))
end

--- Performs a deep copy of a table.
--- @param obj any Object to copy
--- @return any Copied object
function Peak.Utils.DeepCopy(obj)
    if type(obj) ~= 'table' then return obj end

    local res = {}
    for k, v in next, obj do
        res[Peak.Utils.DeepCopy(k)] = Peak.Utils.DeepCopy(v)
    end

    return setmetatable(res, Peak.Utils.DeepCopy(getmetatable(obj)))
end

--- Formats a number with comma separators.
--- @param val number
--- @return string
function Peak.Utils.FormatNumber(val)
    local str = tostring(math.floor(val))
    while true do
        local newStr, count = string.gsub(str, '^(-?%d+)(%d%d%d)', '%1,%2')
        str = newStr
        if count == 0 then break end
    end
    return str
end

--- Formats a number as a currency string.
--- @param val number
--- @return string
function Peak.Utils.FormatMoney(val)
    return '$' .. Peak.Utils.FormatNumber(val)
end

--- Safely encodes data into JSON.
--- @param data any
--- @return string
function Peak.Utils.JsonEncode(data)
    local ok, res = pcall(json.encode, data)
    if ok then return res end
    Peak.Utils.Warn('JSON encode failed:', res)
    return '{}'
end

--- Safely decodes data from JSON.
--- @param data string
--- @return any|nil
function Peak.Utils.JsonDecode(data)
    if not data or data == '' then return nil end
    local ok, res = pcall(json.decode, data)
    if ok then return res end
    Peak.Utils.Warn('JSON decode failed:', res)
    return nil
end

-- ============================================================
-- LEGACY COMPAT HELPERS
-- ============================================================

--- Blocks execution until the global Core object is available.
--- Call at the top of any thread that depends on the framework.
function WaitCore()
    while Core == nil do
        Wait(0)
    end
end

--- Prints a debug message using the legacy format.
--- Prefer Peak.Utils.Debug() in new code.
--- @param ... any
function debugPrint(...)
    if not Config.Debug then return end

    local data = { ... }
    local str = ''

    for i = 1, #data do
        if type(data[i]) == 'table' then
            str = str .. json.encode(data[i])
        elseif type(data[i]) ~= 'string' then
            str = str .. tostring(data[i])
        else
            str = str .. data[i]
        end

        if i ~= #data then
            str = str .. ' '
        end
    end

    print('^6[Peak Trucking] ^3[Debug]^7: ' .. str)
end
