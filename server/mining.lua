local config = require 'config.shared'.mining

if not config.enabled then
    return
end


local miningObjects = {}
local miningTools = {}

local function deleteMiningObject(source)
    local object = miningObjects[source]

    if object and DoesEntityExist(object) then
        DeleteEntity(object)
        --- Check if another statebag was made that broke this
        Player(source).state:set('red40_mining', nil, true)
        miningObjects[source] = nil
    end
end

local function startMining(src, tool)
    if miningObjects[src] then
        DeleteEntity(miningObjects[src])
        miningObjects[src] = nil
    end

    local ped = GetPlayerPed(src)

    if GetVehiclePedIsIn(ped, false) > 0 then
        return Notify(src, locale('vehicle_mining'), 'error')
    end

    local coords = GetEntityCoords(ped)

    local object = CreateObject(config.tools[tool].prop, coords.x, coords.y, coords.z - 20, true, true, true)

    while not DoesEntityExist(object) do
        Wait(50)
    end

    SetEntityIgnoreRequestControlFilter(object, true)

    Player(src).state:set('red40_mining', {
        entity = NetworkGetNetworkIdFromEntity(object),
        tool = tool,
        mining = true
    }, true)

    miningObjects[src] = object
    miningTools[src] = tool
end

RegisterNetEvent('red40_mining:server:stopMining', function()
    local src = source
    deleteMiningObject(src)
end)

AddStateBagChangeHandler('red40_mining', '', function(bagName, _, value)
    if value then return end

    local source = GetPlayerFromStateBagName(bagName)
    if source and miningObjects[source] then
        deleteMiningObject(source)
    end
end)

--- Usable items
if GetResourceState('ox_inventory') ~= 'missing' then
    local function startMiningExport(_, _, inventory, slot, data)
        if inventory.type == 'player' then
            local src = inventory.player.source

            if miningObjects[src] then
                deleteMiningObject(src)
            else
                startMining(src, slot.item)
            end
        end
        return true
    end
    exports('mining', startMiningExport)

    -- build filter tables for inventory hooks
    local filterTable = {}
    for item, _ in pairs(config.tools) do
        filterTable[item] = true
    end

    exports.ox_inventory:registerHook('swapItems', function(payload)
        local source = payload.source

        if payload.toInventory ~= payload.fromInventory and miningObjects[source] then
            SetTimeout(100, function()
                if exports.ox_inventory:GetItemCount(source, miningTools[source]) == 0 then
                    deleteMiningObject(source)
                end
            end)

            return true
        end

        return true
    end, {
        itemFilter = filterTable,
        typeFilter = {
            ['player'] = true,
        }
    })
elseif GetResourceState('qb-core') ~= 'missing' then
    for item, _ in pairs(config.tools) do
        QBCore.Functions.CreateUseableItem(item, function(source, _)
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player.Functions.GetItemByName(item) then return end
            if miningObjects[source] then
                deleteMiningObject(source)
            else
                startMining(source, item)
            end
        end)
    end
elseif GetResourceState('es_extended') ~= 'missing' then
    for item, _ in pairs(config.tools) do
        ESX.RegisterUsableItem(item, function(source)
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer.getInventoryItem(item).count then return end
            if miningObjects[source] then
                deleteMiningObject(source)
            else
                startMining(source, item)
            end
        end)
    end
end