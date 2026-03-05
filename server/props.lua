local config = require 'config.shared'

MiningObjects = {}
MiningTools = {}

function DeleteMiningObject(source)
    local object = MiningObjects[source]

    if object and DoesEntityExist(object) then
        DeleteEntity(object)
        Player(source).state:set('red40_mining', nil, true)
        MiningObjects[source] = nil
    end
end

function StartMining(src, activity, tool)
    if MiningObjects[src] then
        DeleteEntity(MiningObjects[src])
        MiningObjects[src] = nil
    end

    local ped = GetPlayerPed(src)

    if GetVehiclePedIsIn(ped, false) > 0 then
        return Notify(src, locale('vehicle_mining'), 'error')
    end

    local coords = GetEntityCoords(ped)

    local object = CreateObject(config[activity].tools[tool].prop, coords.x, coords.y, coords.z - 25, true, true, true)

    while not DoesEntityExist(object) do
        Wait(50)
    end

    SetEntityIgnoreRequestControlFilter(object, true)

    Player(src).state:set('red40_mining', {
        entity = NetworkGetNetworkIdFromEntity(object),
        tool = tool,
        bone = config[activity].tools[tool].bone,
        offset = config[activity].tools[tool].offset,
        rotation = config[activity].tools[tool].rotation,
        activity = activity,
    }, true)

    MiningObjects[src] = object
    MiningTools[src] = tool
end

RegisterNetEvent('red40_mining:server:stopMining', function()
    local src = source
    DeleteMiningObject(src)
end)

AddEventHandler('playerDropped', function()
    local src = source
    DeleteMiningObject(src)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == cache.resource then
        for src, _ in pairs(MiningObjects) do
            DeleteMiningObject(src)
        end
    end
end)