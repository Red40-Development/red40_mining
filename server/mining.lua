local config = require 'config.shared'.mining

if not config.enabled then
    return
end

local orePoints = {}

RegisterNetEvent('red40_mining:server:startMining', function(oreId)
    local src = source
    local orePoint = orePoints[oreId]

    if not orePoint then return end

    -- coord check
    local coords = GetEntityCoords(GetPlayerPed(src))
    if #(coords - orePoint.coords) > 2.0 then
        Notify(src, locale('too_far'), 'error')
        return
    end

    local tool = MiningTools[src]
    lib.print.info('Player ' .. src .. ' is attempting to mine ore point ' .. oreId .. ' with tool: ' .. tostring(tool))
    if not tool then
        Notify(src, locale('no_tool'), 'error')
        return
    end

    local waitTime = math.random(config.tools[tool].minUseTime, config.tools[tool].maxUseTime)

    local success = lib.callback.await('red40_mining:client:mineSpot', src, waitTime)

    if success and not orePoint.looted then
        orePoints[orePoint.id].looted = true
        lib.print.debug('Player ' .. src .. ' mined ore point ' .. orePoint.id)
        TriggerClientEvent('red40_mining:client:updateMiningSpot', -1, orePoint.id, true)
        SetTimeout(math.random(orePoint.respawnTimeMin, orePoint.respawnTimeMax), function()
            orePoints[orePoint.id].looted = false
            TriggerClientEvent('red40_mining:client:updateMiningSpot', -1, orePoint.id, false)
            lib.print.debug('Ore point ' .. orePoint.id .. ' has respawned')
        end)

        lib.print.info(orePoint)
        local items = GenerateLoot(orePoint.rewards, orePoint.min, orePoint.max,
            GetXpLevel(GetXp(src, 'mining'), config.xpTables) or 0)
        lib.print.debug('Generated loot for player ' .. src .. ' at ore point ' .. orePoint.id .. ': ', items)

        if items and next(items) then
            AddItems(src, items, coords)
            lib.print.debug('Added items to player ' .. src .. ': ', items)
        else
            Notify(src, locale('found_nothing'), 'inform')
            lib.print.debug('Player ' .. src .. ' found nothing at ore point ' .. orePoint.id)
        end
        local xpGained = config.xpPerAction
        AddXp(src, xpGained, 'mining')
        lib.print.debug('Added ' .. xpGained .. ' XP to player ' .. src .. ' for mining')
    end
end)

lib.callback.register('red40_mining:server:getMiningPoints', function(_)
    return orePoints
end)

-- Build ore points
local function buildOrePoints()
    local oreCount = 1
    for i = 1, #config.locations do
        local location = config.locations[i]

        for j = 1, #location.ore_locations do
            local oreLocation = location.ore_locations[j]
            for k = 1, #oreLocation.coords do
                local coords = oreLocation.coords[k]

                orePoints[oreCount] = {
                    id = oreCount,
                    coords = coords,
                    prop = oreLocation.prop,
                    rot = oreLocation.rotation,
                    looted = false,
                    rewards = oreLocation.rewards,
                    min = oreLocation.min,
                    max = oreLocation.max,
                    respawnTimeMin = location.respawnTimeMin,
                    respawnTimeMax = location.respawnTimeMax,
                }

                oreCount = oreCount + 1
            end
        end
    end
end

CreateThread(function()
    buildOrePoints()
    for zone, lootData in pairs(config.lootTables) do
        lib.print.info('Registering loot table for zone: ' .. zone)
        RegisterLootTable(zone, lootData)
    end
end)

--- Usable items
if GetResourceState('ox_inventory') ~= 'missing' then
    local function startMiningExport(_, item, inventory)
        if inventory.type == 'player' then
            local src = inventory.player.source

            if MiningObjects[src] then
                DeleteMiningObject(src)
            else
                StartMining(src, 'mining', item.name)
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

        if payload.toInventory ~= payload.fromInventory and MiningObjects[source] then
            SetTimeout(100, function()
                if exports.ox_inventory:GetItemCount(source, MiningTools[source]) == 0 then
                    DeleteMiningObject(source)
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
            if MiningObjects[source] then
                DeleteMiningObject(source)
            else
                StartMining(source, 'mining', item)
            end
        end)
    end
elseif GetResourceState('es_extended') ~= 'missing' then
    for item, _ in pairs(config.tools) do
        ESX.RegisterUsableItem(item, function(source)
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer.getInventoryItem(item).count then return end
            if MiningObjects[source] then
                DeleteMiningObject(source)
            else
                StartMining(source, 'mining', item)
            end
        end)
    end
end