local sharedConfig = require 'config.shared'.mining

if not sharedConfig.enabled then
    return
end

local playerState = LocalPlayer.state


-- Attach prop to player

AddStateBagChangeHandler('red40_mining', ('player:%s'):format(cache.serverId), function(_, _, value)
    if not value or type(value) ~= 'table' then return end

    if not value.mining then return end

    if value.entity then
        while not NetworkDoesEntityExistWithNetworkId(value.entity) do
            Wait(35)
        end

        local entity = NetworkGetEntityFromNetworkId(value.entity)

        if entity == 0 or not DoesEntityExist(entity) then return end

        if NetworkGetEntityOwner(entity) ~= cache.playerId then
            while NetworkGetEntityOwner(entity) ~= cache.playerId do
                NetworkRequestControlOfEntity(entity)
                Wait(35)
            end
        end

        if value.bone then
            local offset, rotation = value.offset, value.rotation

            AttachEntityToEntity(entity, cache.ped, GetPedBoneIndex(cache.ped, value.bone), offset.x, offset.y, offset.z,
                rotation.x, rotation.y, rotation.z, true, true, false, false, 1,
                true)
        end
    end

    if value.mining then
        SetTimeout(0, function()
            local object = NetworkGetEntityFromNetworkId(value.entity)

            if not DoesEntityExist(object) then
                return
            end

            lib.requestAnimDict('mini@golf')

            local offset = sharedConfig.markerOffset

            while playerState.red40_mining.mining do
                if not IsEntityPlayingAnim(cache.ped, 'mini@golf', 'wood_idle_high_a', 3) then
                    TaskPlayAnim(cache.ped, 'mini@golf', 'wood_idle_high_a', 1.0, -1.0, -1, 49, 1, false, false, false)
                end

                local textOpen, text = lib.isTextUIOpen()
                textOpen = textOpen and text == locale('mine_spot')
                local coords = GetOffsetFromEntityInWorldCoords(object, offset.x, offset.y, offset.z)

                if sharedConfig.blockWalkStyle then
                    ResetPedMovementClipset(cache.ped, 0.0)
                end
                local closestPoint = lib.points.getClosestPoint()

                if closestPoint then
                    local dist = closestPoint.currentDistance

                    if sharedConfig.drawText3d and dist < 2 then
                        DrawText3d({ coords = coords, text = locale('mine_spot_3d') })
                    else
                        if dist < 2 and not textOpen then
                            lib.showTextUI(locale('mine_spot'))
                        elseif dist >= 2 and textOpen then
                            lib.hideTextUI()
                        end
                    end

                    for i = 1, #sharedConfig.disableKeys do
                        DisableControlAction(0, sharedConfig.disableKeys[i], true)
                    end

                    if textOpen and IsControlJustPressed(0, sharedConfig.pickupKey) and not lib.progressActive() then
                        TriggerServerEvent('red40_mining:server:startMining', closestPoint.oreId)
                        lib.hideTextUI()
                    end
                    if sharedConfig.drawText3d and dist < 2 and IsControlJustPressed(0, sharedConfig.pickupKey) and not lib.progressActive() then
                        TriggerServerEvent('red40_mining:server:startMining', closestPoint.oreId)
                    end
                end

                Wait(0)
            end

            if IsEntityPlayingAnim(cache.ped, 'mini@golf', 'wood_idle_high_a', 3) then
                StopAnimTask(cache.ped, 'mini@golf', 'wood_idle_high_a', 1.0)
            end

            if lib.progressActive() then
                lib.hideTextUI()
            end
        end)
    end
end)

lib.onCache('vehicle', function(vehicle)
    if playerState.red40_mining.mining and vehicle then
        TriggerServerEvent('red40_mining:server:stopMining')
    end
end)

lib.onCache('ped', function(ped)
    if playerState.red40_mining.mining and ped then
        TriggerServerEvent('red40_mining:server:stopMining')
    end
end)

lib.onCache('weapon', function(weapon)
    if playerState.red40_mining.mining and weapon then
        TriggerServerEvent('red40_mining:server:stopMining')
    end
end)