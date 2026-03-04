if GetResourceState('qbx_core') ~= 'started' then return end

function GetPlayer(source)
    return exports.qbx_core:GetPlayer(source)
end

function Notify(source, message, type)
    exports.qbx_core:Notify(source, message, type or 'inform')
end

function AddMoney(Player, moneyType, amount)
    Player.Functions.AddMoney(moneyType, amount, "redwire-sale")
end

function AddItems(src, items, coords)
    for item, data in pairs(items) do
        local amount = data.amount or 1
        local metadata = data.metadata or {}

        if exports.ox_inventory:CanCarryItem(src, item, amount, metadata) then
            exports.ox_inventory:AddItem(src, item, amount, metadata)
        else
            exports.ox_inventory:CustomDrop('Mining Drop', {
                { item, amount, metadata },
            }, coords)
        end
    end
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
    return exports.qbx_core:GetDutyCountType('leo')
end