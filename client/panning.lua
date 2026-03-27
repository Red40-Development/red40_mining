local enabled = require 'config.shared'.panning

if not enabled then
    return
end

-- local config = require 'config.client'

local playerState = LocalPlayer.state
local effectsLoop = false

local function createPanningEffects(type, toolEntity)
    lib.playAnim(cache.ped, playerState.red40_mining.anim.anim, playerState.red40_mining.anim.dict, 8.0, 8.0,
        -1, 1, 1.0, false, 0, false)
    if type == 'pan' then
        lib.requestNamedPtfxAsset('core', 10000)
        CreateThread(function()
            while effectsLoop do
                UseParticleFxAssetNextCall('core')
                StartNetworkedParticleFxLoopedOnEntity('water_splash_veh_out', toolEntity, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.5, false, false, false)
                Wait(350)
            end
        end)
    elseif type == 'sifter' then
        lib.requestNamedPtfxAsset('core', 10000)
        CreateThread(function()
            while effectsLoop do
                UseParticleFxAssetNextCall('core')
                StartNetworkedParticleFxLoopedOnEntity('water_splash_veh_out', toolEntity, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.5, false, false, false)
                Wait(350)
            end
        end)
    end
end

lib.callback.register('red40_mining:client:panSpot', function(waitTime)
    while not playerState.red40_mining do
        Wait(100)
    end
    local toolData = playerState.red40_mining

    local toolEntity = NetworkGetEntityFromNetworkId(toolData?.entity)

    if not DoesEntityExist(toolEntity) then return end

    effectsLoop = true
    createPanningEffects(toolData.type, toolEntity)

    local success = lib.progressBar({
        duration = waitTime,
        label = locale('progress.panning'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            combat = true,
            mouse = false,
        },
    })
    effectsLoop = false
    RemoveNamedPtfxAsset('core')
    ClearPedTasks(cache.ped)
    return success
end)

local function buildPanningZone(zone)
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
    local zones = lib.callback.await('red40_mining:server:getPanningZones')
    for i = 1, #zones do
        local zone = zones[i]
        buildPanningZone(zone)
    end
end)