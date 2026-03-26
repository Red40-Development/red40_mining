local enabled = require 'config.shared'.cracking

if not enabled then
    return
end

local config = require 'config.client'

local effectsLoop = false


local function createMiningEffects(anim, oreCoords)
    lib.playAnim(cache.ped, anim.anim, anim.dict, 8.0, 8.0,
        -1, 1, 1.0, false, false, false)
    lib.requestNamedPtfxAsset('core', 10000)
    CreateThread(function()
        while effectsLoop do
            UseParticleFxAssetNextCall('core')
            StartNetworkedParticleFxNonLoopedAtCoord('ent_dst_rocks', oreCoords.x, oreCoords.y, oreCoords.z, 0,
                0, 0, 0.1, false, false, false)
            Wait(120)
        end
    end)
end

lib.callback.register('red40_mining:client:crackSpot', function(waitTime, entityData)
    local closestSpot = lib.points.getClosestPoint()
    if not closestSpot then return end
    while not NetworkDoesEntityExistWithNetworkId(entityData.entity) do
        Wait(35)
    end

    local entity = NetworkGetEntityFromNetworkId(entityData.entity)

    if entity == 0 or not DoesEntityExist(entity) then return end

    local offsetCoords = GetOffsetFromEntityInWorldCoords(closestSpot.propNumber, entityData.offset.x,
        entityData.offset.y, entityData.offset.z)

    if NetworkGetEntityOwner(entity) ~= cache.playerId then
        while NetworkGetEntityOwner(entity) ~= cache.playerId do
            NetworkRequestControlOfEntity(entity)
            Wait(35)
        end
    end

    SetEntityCoords(entity, offsetCoords.x, offsetCoords.y, offsetCoords.z, false, false, false, false)
    SetEntityRotation(entity, entityData.rotation.x, entityData.rotation.y, entityData.rotation.z, 2, true)

    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)

    local oreCoords = GetEntityCoords(entity)

    TaskGoStraightToCoord(cache.ped, oreCoords.x, oreCoords.y, oreCoords.z, 0.5, 400, 0.0, 0)
    while #(oreCoords - GetEntityCoords(cache.ped)) > 2 do
        Wait(10)
    end
    if not IsPedHeadingTowardsPosition(cache.ped, oreCoords.x, oreCoords.y, oreCoords.z, 40.0) then
        TaskTurnPedToFaceCoord(cache.ped, oreCoords.x, oreCoords.y, oreCoords.z, 1500)
    end
    TaskLookAtEntity(cache.ped, entity, -1, 2048, 3)
    effectsLoop = true
    createMiningEffects(entityData.anim, oreCoords)
    local success = lib.progressBar({
        duration = waitTime,
        label = locale('progress.cracking'),
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

local function buildCrackPoints(crackPoint)
    local offset = vec3(crackPoint.coords.x, crackPoint.coords.y, crackPoint.coords.z)
    if crackPoint.prop then
        local propSizeMin, propSizeMax = GetModelDimensions(crackPoint.prop)
        offset = GetOffsetFromCoordAndHeadingInWorldCoords(crackPoint.coords.x, crackPoint.coords.y,
            crackPoint.coords.z,
            crackPoint.rot.z, 0.0, 0.0, math.abs(propSizeMax.z - propSizeMin.z) / 2)
    end
    local point = lib.points.new({
        coords = crackPoint.coords,
        distance = 200,
        prop = crackPoint.prop,
        rot = crackPoint.rot,
        textOffset = offset,
        id = crackPoint.id,
        looted = crackPoint.looted,
    })

    local targetOptions = {}
    if config.crackingTarget then
        targetOptions = {
            {
                name = 'red40_crack_ore',
                label = locale('target.crack'),
                icon = 'fa-solid fa-hammer',
                onSelect = function()
                    TriggerServerEvent('red40_mining:server:startCracking', crackPoint.id)
                end,
            } }
    end
    function point:onEnter()
            if config.crackingTarget and not self.prop then
                self.targetId = config.addSphereTarget({
                    coords = self.coords,
                    radius = 2.0,
                    options = targetOptions,
                })
            elseif self.prop then
                lib.requestModel(self.prop, 10000)
                self.propNumber = CreateObject(self.prop, self.coords.x, self.coords.y, self.coords.z, false, true, false)
                SetModelAsNoLongerNeeded(self.prop)
                SetEntityRotation(self.propNumber, self.rot.x, self.rot.y, self.rot.z, 2, true)
                FreezeEntityPosition(self.propNumber, true)
                SetEntityInvincible(self.propNumber, true)
                if config.crackingTarget then
                    config.addLocalEntityTarget(self.propNumber, targetOptions)
                end
            end
    end

    function point:onExit()
        if self.propNumber and DoesEntityExist(self.propNumber) then
            if config.crackingTarget then
                config.removeLocalEntityTarget(self.propNumber, 'red40_crack_ore')
            end
            if self.targetId then
                config.removeSphereTarget(self.targetId)
                self.targetId = nil
            end
            DeleteEntity(self.propNumber)
            self.propNumber = nil
        end
    end

    if not config.crackingTarget then
        function point:nearby()
            if not self.isClosest then return end
            if self.currentDistance < 5 and not effectsLoop then
                if config.use3dText then
                    DrawText3d({ coords = self.textOffset, text = locale('drawtext.crack') })
                else
                    local textOpen, text = lib.isTextUIOpen()
                    textOpen = textOpen and text == locale('textui.crack')
                    if not textOpen then
                        lib.showTextUI(locale('textui.crack'))
                    end
                end
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('red40_mining:server:startCracking', self.id)
                end
            else
                local textOpen, text = lib.isTextUIOpen()
                if textOpen and text == locale('textui.crack') then
                    lib.hideTextUI()
                end
            end
        end
    end
end


CreateThread(function()
    local points = lib.callback.await('red40_mining:server:getCrackingPoints')

    for i = 1, #points do
        local point = points[i]
        buildCrackPoints(point)
    end
end)