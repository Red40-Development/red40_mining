local playerState = LocalPlayer.state
Prop = nil

AddStateBagChangeHandler('red40_mining', ('player:%s'):format(cache.serverId), function(_, _, value)
    if not value or type(value) ~= 'table' then return end

    if not value.activity then return end

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
                Prop = entity
        end
    end
end)


lib.onCache('vehicle', function(vehicle)
    if playerState.red40_mining and vehicle then
        TriggerServerEvent('red40_mining:server:stopMining')
    end
end)

lib.onCache('ped', function(ped)
    if playerState.red40_mining and ped then
        TriggerServerEvent('red40_mining:server:stopMining')
    end
end)

lib.onCache('weapon', function(weapon)
    if playerState.red40_mining and weapon then
        TriggerServerEvent('red40_mining:server:stopMining')
    end
end)