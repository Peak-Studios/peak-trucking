Peak = Peak or {}
Peak.Server = Peak.Server or {}

-- ============================================================
-- FRAMEWORK BRIDGE
-- ============================================================

--- Returns the framework player object for a source.
--- @param source number
--- @return table|nil
function GetPlayer(source)
    WaitCore()

    local fw  = Peak.Server.FrameworkName
    local obj = Peak.Server.FrameworkObject

    if fw == 'esx' then
        return obj.GetPlayerFromId(source)
    end

    return obj.Functions.GetPlayer(source)
end

--- Returns the primary player identifier.
--- @param source number
--- @return string|false
function GetIdentifier(source)
    local player = GetPlayer(source)
    if not player then return false end

    local fw = Peak.Server.FrameworkName
    if fw == 'esx' then
        return player.getIdentifier()
    end

    return player.PlayerData.citizenid
end

--- Returns the player's roleplay name.
--- @param source number
--- @return string
function GetPlayerRPName(source)
    local player = GetPlayer(tonumber(source))
    if not player then return GetPlayerName(source) end

    local fw = Peak.Server.FrameworkName
    if fw == 'esx' then
        return player.getName()
    end

    local charinfo = player.PlayerData.charinfo or {}
    return ((charinfo.firstname or '') .. ' ' .. (charinfo.lastname or '')):gsub('^%s*(.-)%s*$', '%1')
end

--- Registers a server callback across supported frameworks.
--- @param callbackName string
--- @param callback function
function RegisterCallback(callbackName, callback)
    local fw  = Peak.Server.FrameworkName
    local obj = Peak.Server.FrameworkObject

    if fw == 'esx' then
        obj.RegisterServerCallback(callbackName, function(source, cb, data)
            callback(source, cb, data)
        end)
        return
    end

    obj.Functions.CreateCallback(callbackName, function(source, cb, data)
        callback(source, cb, data)
    end)
end

-- ============================================================
-- DATABASE BRIDGE
-- ============================================================

--- Executes a SQL query and waits for the result.
--- The SQL driver is auto-detected by server/init.lua.
--- @param query string
--- @param params? table
--- @return table
function ExecuteSql(query, params)
    local waiting = true
    local result  = {}
    local driver  = exports['peak-trucking']:GetSQLDriver()

    if driver == 'oxmysql' then
        exports.oxmysql:execute(query, params or {}, function(data)
            result  = data or {}
            waiting = false
        end)
    elseif driver == 'ghmattimysql' then
        exports.ghmattimysql:execute(query, params or {}, function(data)
            result  = data or {}
            waiting = false
        end)
    elseif driver == 'mysql-async' then
        MySQL.Async.fetchAll(query, params or {}, function(data)
            result  = data or {}
            waiting = false
        end)
    else
        error(('Unsupported SQL driver: %s'):format(tostring(driver)))
    end

    while waiting do Wait(0) end
    return result
end

-- ============================================================
-- MONEY & INVENTORY BRIDGE
-- ============================================================

--- Adds cash to a player.
--- Respects Open.AddMoney override from server/custom.lua.
--- @param source number
--- @param amount number
--- @return boolean
function addMoney(source, amount)
    amount = tonumber(amount) or 0
    if amount <= 0 then return false end

    if Open and Open.AddMoney then
        local res = Open.AddMoney(source, amount, 'cash')
        if res ~= nil then return res end
    end

    local player = GetPlayer(source)
    if not player then return false end

    local fw = Peak.Server.FrameworkName
    if fw == 'esx' then
        player.addMoney(amount)
        return true
    end

    return player.Functions.AddMoney('cash', amount, 'peak-trucking')
end

--- Adds an item to a player's inventory.
--- @param source number
--- @param item string
--- @param amount number
--- @return boolean
function AddInventoryItem(source, item, amount)
    local player = GetPlayer(source)
    if not player or not item then return false end

    amount = tonumber(amount) or 1
    if amount <= 0 then return false end

    local inv = Config.Inventory
    if inv == 'ox_inventory' or (inv == 'auto' and GetResourceState('ox_inventory') == 'started') then
        local ok, res = pcall(function() return exports.ox_inventory:AddItem(source, item, amount) end)
        return ok and res
    elseif inv == 'qs_inventory' or (inv == 'auto' and GetResourceState('qs-inventory') == 'started') then
        local ok, res = pcall(function() return exports['qs-inventory']:AddItem(source, item, amount) end)
        return ok and res
    elseif inv == 'qb_inventory' or (inv == 'auto' and GetResourceState('qb-inventory') == 'started') then
        if player.Functions and player.Functions.AddItem then
            return player.Functions.AddItem(item, amount)
        end
    elseif Peak.Server.FrameworkName == 'esx' or inv == 'esx_inventory' then
        player.addInventoryItem(item, amount)
        return true
    end

    return false
end

--- Removes an item from a player's inventory.
--- @param source number
--- @param item string
--- @param amount number
--- @return boolean
function RemoveItem(source, item, amount)
    local player = GetPlayer(source)
    if not player or not item then return false end

    amount = tonumber(amount) or 1
    if amount <= 0 then return false end

    local inv = Config.Inventory
    if inv == 'ox_inventory' or (inv == 'auto' and GetResourceState('ox_inventory') == 'started') then
        local ok, res = pcall(function() return exports.ox_inventory:RemoveItem(source, item, amount) end)
        return ok and res
    elseif inv == 'qs_inventory' or (inv == 'auto' and GetResourceState('qs-inventory') == 'started') then
        local ok, res = pcall(function() return exports['qs-inventory']:RemoveItem(source, item, amount) end)
        return ok and res
    elseif inv == 'qb_inventory' or (inv == 'auto' and GetResourceState('qb-inventory') == 'started') then
        if player.Functions and player.Functions.RemoveItem then
            return player.Functions.RemoveItem(item, amount)
        end
    elseif Peak.Server.FrameworkName == 'esx' or inv == 'esx_inventory' then
        player.removeInventoryItem(item, amount)
        return true
    end

    return false
end

--- Checks whether a player has at least the requested item amount.
--- @param source number
--- @param itemData table {name: string, amount: number}
--- @return boolean
function HasItem(source, itemData)
    local player = GetPlayer(source)
    if not player or not itemData or not itemData.name then return false end

    local required = tonumber(itemData.amount) or 1
    local count    = 0
    local inv      = Config.Inventory

    if inv == 'ox_inventory' or (inv == 'auto' and GetResourceState('ox_inventory') == 'started') then
        count = exports.ox_inventory:Search(source, 'count', itemData.name) or 0
    elseif inv == 'qs_inventory' or (inv == 'auto' and GetResourceState('qs-inventory') == 'started') then
        count = exports['qs-inventory']:GetItemTotalAmount(source, itemData.name) or 0
    elseif inv == 'qb_inventory' or (inv == 'auto' and GetResourceState('qb-inventory') == 'started') then
        local it = player.Functions.GetItemByName(itemData.name)
        count = it and (it.amount or it.count) or 0
    elseif Peak.Server.FrameworkName == 'esx' or inv == 'esx_inventory' then
        local it = player.getInventoryItem(itemData.name)
        count = it and (it.count or it.amount) or 0
    end

    return tonumber(count) >= required
end
