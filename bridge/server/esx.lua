if GetResourceState('es_extended') ~= 'started' then return end

ESX = exports['es_extended']:getSharedObject()

function GetPlayer(source)
    return ESX.GetPlayerFromId(source)
end

function Notify(src, text, type)
    TriggerClientEvent('esx:showNotification', src, text, type or 'inform')
end

function AddMoney(src, moneyType, amount)
    local xPlayer = GetPlayer(src)
    local account = moneyType == 'cash' and 'money' or moneyType
    xPlayer.addAccountMoney(account, amount, "red40_mining-sale")
end

function RemoveMoney(src, moneyType, amount)
    local xPlayer = GetPlayer(src)
    local account = moneyType == 'cash' and 'money' or moneyType
    xPlayer.removeAccountMoney(account, amount, "red40_mining-purchase")
end

function GetItemCountFramework(source, itemName)
    local xPlayer = GetPlayer(source)
    if not xPlayer then return 0 end
    local itemInfo = xPlayer.getInventoryItem(itemName)
    return itemInfo.county or itemInfo.amount or 0
end

function CanCarryItemFramework(source, item, amount, metadata)
    local xPlayer = GetPlayer(source)
    if not xPlayer then return false end
    return xPlayer.canCarryItem(item, amount, metadata)
end

function AddItemFramework(src, item, amount, metadata)
    local xPlayer = GetPlayer(src)
    return xPlayer.addInventoryItem(item, amount, metadata)
end

function RemoveItemFramework(src, item, count)
    local xPlayer = GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.removeInventoryItem(item, count)
end


function AddXp(src, amount, type)
    local player = GetPlayer(src)
    local metadataKey = 'red40_mining' .. type
    if player then
        player.setMeta(metadataKey, (player.getMeta(metadataKey) or 0) + amount)
    end
end

function GetXp(src, type)
    local player = GetPlayer(src)
    local metadataKey = 'red40_mining' .. type
    if player then
        return player.getMeta(metadataKey) or 0
    end
    return 0
end