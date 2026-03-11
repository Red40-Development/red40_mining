if GetResourceState('qbx_core') ~= 'started' then return end

function GetPlayer(source)
    return exports.qbx_core:GetPlayer(source)
end

function Notify(source, message, type)
    exports.qbx_core:Notify(source, message, type or 'inform')
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
    return true -- Unused
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