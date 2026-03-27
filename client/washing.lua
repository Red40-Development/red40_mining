local enabled = require 'config.shared'.washing

if not enabled then
    return
end

local playerState = LocalPlayer.state

local function createWashingEffects(type, toolEntity)
    TaskStartScenarioInPlace(cache.ped, 'PROP_HUMAN_BUM_BIN', 0, true)
end

lib.callback.register('red40_mining:client:washSpot', function(waitTime)
    while not playerState.red40_mining do
        Wait(100)
    end
    local toolData = playerState.red40_mining

    local toolEntity = NetworkGetEntityFromNetworkId(toolData?.entity)

    if not DoesEntityExist(toolEntity) then return end

    createWashingEffects(toolData.type, toolEntity)

    local success = lib.progressBar({
        duration = waitTime,
        label = locale('progress.washing'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            combat = true,
            mouse = false,
        },
    })
    ClearPedTasks(cache.ped)
    return success
end)

local function buildWashingZone(zone)
    if zone.debug then

        lib.zones.poly({
            points = zone.points,
            thickness = zone.thickness,
            debug = true,
        })
    end
    if zone.blip.enabled then
        CreateBlip({
            coords = zone.blip.coords,
            sprite = zone.blip.sprite,
            color = zone.blip.color,
            scale = zone.blip.scale,
            name = zone.blip.name,
        })
    end
end

CreateThread(function()
    local zones = lib.callback.await('red40_mining:server:getWashingZones')
    for i = 1, #zones do
        local zone = zones[i]
        buildWashingZone(zone)
    end
end)