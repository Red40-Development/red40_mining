local enabled = require 'config.shared'.mining

if not enabled then
    return
end

local config = require 'config.client'

local orePoints = {}
local playerState = LocalPlayer.state
local soundId = nil

RegisterNetEvent('red40_mining:client:updateMiningSpot', function(oreId, looted)
    local orePoint = orePoints[oreId]

    if orePoint then
        orePoints[oreId].looted = looted
        if looted and orePoint.propNumber then
            orePoint:onExit()
        elseif not looted then
            orePoint:onEnter()
        end
    end
end)

local effectsLoop = false

local function loadMiningSounds(type)
    if type == 'pickaxe' then
        -- no sound here
    elseif type == 'drill' then
        RequestAmbientAudioBank("DLC_HEIST_FLEECA_SOUNDSET", false)
        RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL", false)
        RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2", false)
    elseif type == 'laserdrill' then
        while not RequestScriptAudioBank('audiodirectory/red40_mining', false) do Wait(0) end
    end
end
local function unloadMiningSounds(type)
    if type == 'pickaxe' then
        -- no sound here
    elseif type == 'drill' then
        ReleaseAmbientAudioBank("DLC_HEIST_FLEECA_SOUNDSET", false)
        ReleaseAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL", false)
        ReleaseAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2", false)
    elseif type == 'laserdrill' then
        ReleaseNamedScriptAudioBank('audiodirectory/red40_mining')
    end
end

local function createMiningSounds(type, toolEntity)
    soundId = GetSoundId()
    if type == 'pickaxe' then
        -- no sound here
    elseif type == 'drill' then
        PlaySoundFromEntity(soundId, 'Drill', toolEntity, 'DLC_HEIST_FLEECA_SOUNDSET', true, 0)
    elseif type == 'laserdrill' then
        PlaySoundFromEntity(soundId, 'laserdrill_start', toolEntity, 'special_soundset', true, 0)
        while not HasSoundFinished(soundId) do
            Wait(0)
        end
        CreateThread(function()
            Wait(100)
            while effectsLoop do
                PlaySoundFromEntity(soundId, 'laserdrill_hit', toolEntity, 'special_soundset', true, 0)
                while not HasSoundFinished(soundId) do
                    Wait(0)
                end
            end
        end)
    end
end

local function createMiningEffects(type, toolEntity, oreEntity)
    lib.playAnim(cache.ped, playerState.red40_mining.anim.anim, playerState.red40_mining.anim.dict, 8.0, 8.0,
        -1, 1, 1.0, false, false, false)
    if type == 'pickaxe' then
        -- no effects =(
    elseif type == 'drill' then
        lib.requestNamedPtfxAsset('core', 10000)
        CreateThread(function()
            while effectsLoop do
                UseParticleFxAssetNextCall('core')
                Wait(200)
                local toolCoords = GetOffsetFromEntityInWorldCoords(toolEntity, 0, -0.7, 0.0)
                StartNetworkedParticleFxNonLoopedAtCoord('ent_dst_rocks', toolCoords.x, toolCoords.y, toolCoords.z, 0.0,
                    0.0, 0.0, 0.4, false, false, false)
                Wait(350)
            end
        end)
    elseif type == 'laserdrill' then
        lib.requestNamedPtfxAsset('core', 10000)
        CreateThread(function()
            while effectsLoop do
                local laserCoords = GetOffsetFromEntityInWorldCoords(toolEntity, 0.0, -0.4, 0.02)
                UseParticleFxAssetNextCall('core')
                StartNetworkedParticleFxNonLoopedAtCoord('muz_railgun', laserCoords.x, laserCoords.y, laserCoords.z, 0,
                -10.0, GetEntityHeading(toolEntity) + 270, 1.0, false, false, false)
                Wait(60)
            end
        end)
        CreateThread(function()
            while effectsLoop do
                local hitCoords = GetOffsetFromEntityInWorldCoords(oreEntity, 0.0, 0.0, 0.5)
                UseParticleFxAssetNextCall('core')
                StartNetworkedParticleFxNonLoopedAtCoord('ent_dst_rocks', hitCoords.x, hitCoords.y, hitCoords.z, 0.0,
                    0.0, 0.0, 1.0, false, false, false)
                Wait(350)
            end
        end)
    end
end

lib.callback.register('red40_mining:client:mineSpot', function(waitTime, toolType)
    --TODO add animation, skillcheck (optional), and sounds here (tool config based)
    local closestOre = lib.points.getClosestPoint()
    local oreCoords = GetEntityCoords(closestOre.propNumber)
    TaskGoStraightToCoord(cache.ped, oreCoords.x, oreCoords.y, oreCoords.z, 0.5, 400, 0.0, 0)
    while #(oreCoords - GetEntityCoords(cache.ped)) > 2 do
        Wait(10)
    end
    if not IsPedHeadingTowardsPosition(cache.ped, oreCoords.x, oreCoords.y, oreCoords.z, 40.0) then
        TaskTurnPedToFaceCoord(cache.ped, oreCoords.x, oreCoords.y, oreCoords.z, 1500)
    end
    TaskLookAtEntity(cache.ped, closestOre.propNumber, -1, 2048, 3)
    effectsLoop = true
    loadMiningSounds(toolType)
    createMiningSounds(toolType, Prop)
    createMiningEffects(toolType, Prop, closestOre.propNumber)
    local success = lib.progressBar({
        duration = waitTime,
        label = locale('mining_ore'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            combat = true,
            mouse = false,
        },
    })
    effectsLoop = false
    if soundId then
        StopSound(soundId)
        ReleaseSoundId(soundId)
    end
    unloadMiningSounds(toolType)
    ClearPedTasks(cache.ped)
    return success
end)

local function buildLightPoints(lightPoint)
    local point = lib.points.new({
        coords = lightPoint.coords,
        distance = 200,
        prop = lightPoint.prop,
        rot = lightPoint.rot,
    })
    function point:onEnter()
        lib.requestModel(self.prop, 10000)
        self.propNumber = CreateObject(self.prop, self.coords.x, self.coords.y, self.coords.z, false, true, false)
        SetModelAsNoLongerNeeded(self.prop)
        SetEntityRotation(self.propNumber, self.rot.x, self.rot.y, self.rot.z, 2, true)
        FreezeEntityPosition(self.propNumber, true)
        SetEntityInvincible(self.propNumber, true)
    end

    function point:onExit()
        if self.propNumber and DoesEntityExist(self.propNumber) then
            DeleteEntity(self.propNumber)
            self.propNumber = nil
        end
    end
end

local function buildOrePoints(orePoint)
    local propSizeMin, propSizeMax = GetModelDimensions(orePoint.prop)
    local offset = GetOffsetFromCoordAndHeadingInWorldCoords(orePoint.coords.x, orePoint.coords.y, orePoint.coords.z,
        orePoint.rot.z, 0.0, 0.0, math.abs(propSizeMax.z - propSizeMin.z) / 2)
    local point = lib.points.new({
        coords = orePoint.coords,
        distance = 200,
        prop = orePoint.prop,
        rot = orePoint.rot,
        textOffset = offset,
        id = orePoint.id,
        looted = orePoint.looted,
    })
    function point:onEnter()
        if not self.looted then
            lib.requestModel(self.prop, 10000)
            self.propNumber = CreateObject(self.prop, self.coords.x, self.coords.y, self.coords.z, false, true, false)
            SetModelAsNoLongerNeeded(self.prop)
            SetEntityRotation(self.propNumber, self.rot.x, self.rot.y, self.rot.z, 2, true)
            FreezeEntityPosition(self.propNumber, true)
            SetEntityInvincible(self.propNumber, true)
        end
    end

    function point:onExit()
        if self.propNumber and DoesEntityExist(self.propNumber) then
            DeleteEntity(self.propNumber)
            self.propNumber = nil
        end
    end

    function point:nearby()
        if not self.isClosest or not playerState.red40_mining or not playerState.red40_mining.activity == 'mining' then return end
        if not self.looted and self.currentDistance < 5 and not effectsLoop then
            if config.use3dText then
                DrawText3d({ coords = self.textOffset, text = locale('mine_ore_3d') })
            else
                local textOpen, text = lib.isTextUIOpen()
                textOpen = textOpen and text == locale('mine_ore')
                if not textOpen then
                    lib.showTextUI(locale('mine_ore'))
                end
            end
            if IsControlJustReleased(0, 38) then
                TriggerServerEvent('red40_mining:server:startMining', self.id)
            end
        else
            local textOpen, text = lib.isTextUIOpen()
            if textOpen and text == locale('mine_ore') then
                lib.hideTextUI()
            end
        end
    end

    orePoints[orePoint.id] = point
end


CreateThread(function()
    local points = lib.callback.await('red40_mining:server:getMiningPoints')

    for i = 1, #points do
        local point = points[i]
        buildOrePoints(point)
    end

    local lightPoints = lib.callback.await('red40_mining:server:getMiningLightPoints')

    for i = 1, #lightPoints do
        local point = lightPoints[i]
        buildLightPoints(point)
    end
end)