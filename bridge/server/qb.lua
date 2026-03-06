if GetResourceState('qb-core') ~= 'started' or GetResourceState('qbx_core') == 'started' then return end


QBCore = exports['qb-core']:GetCoreObject()

--- Get player object by ID
---@param source number Player source ID
---@return any Player object or nil if not found
function GetPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

---Notify player
---@param src number Player source ID
---@param text string Notification text
---@param nType string Notification type (e.g., 'success', 'error', 'info
function Notify(src, text, nType)
    TriggerClientEvent('QBCore:Notify', src, text, nType)
end

function AddMoney(src, moneyType, amount)
    local player = GetPlayer(src)
    player.Functions.AddMoney(moneyType, amount, "red40_mining-sale")
end

function RemoveMoney(src, moneyType, amount)
    local player = GetPlayer(src)
    player.Functions.RemoveMoney(moneyType, amount, "red40_mining-purchase")
end

function GetItemCountFramework(source, itemName)
    local player = GetPlayer(source)
    if not player then return 0 end
    local itemInfo = player.Functions.GetItemByName(itemName)
    return itemInfo.amount or itemInfo.count or 0
end

function CanCarryItemFramework(source, item, amount, metadata)
    return true -- Implement if you want to prevent players from going overweight
end

function AddItemFramework(src, item, amount, metadata)
    local player = GetPlayer(src)
    if not player then return end
    return player.Functions.AddItem(item, amount, nil, metadata)
end

function RemoveItemFramework(src, item, count)
    local player = GetPlayer(src)
    if not player then return end
    return player.Functions.RemoveItem(item, count)
end

function AddXp(src, amount, type)
    local player = GetPlayer(src)
    local metadataKey = 'red40_mining' .. type
    if player then
        player.Functions.SetMetaData(metadataKey, (player.PlayerData.metadata[metadataKey] or 0) + amount)
    end
end

function GetXp(src, type)
    local player = GetPlayer(src)
    local metadataKey = 'red40_mining' .. type
    if player then
        return player.PlayerData.metadata[metadataKey] or 0
    end
    return 0
end

function CheckDuty()
    local dutyCount = 0
    local leoJobs = { 'police', 'bcso' } -- Add your police jobs here...
    for _, job in ipairs(leoJobs) do
        dutyCount = dutyCount + QBCore.Functions.GetDutyCount(job)
    end
    return dutyCount
end