local enabled = require 'config.shared'.mining

if not enabled then
    return
end

local config = require 'config.server'.mining

local orePoints = {}
local lightPoints = {}
local miningBlips = {}

RegisterNetEvent('red40_mining:server:startMining', function(oreId)
    local src = source
    local orePoint = orePoints[oreId]

    if not orePoint then
        --OPTIONAL: Ban player cause they triggered this event
        Logger(src, 'red40_mining', 'Player attempted to mine an invalid ore point with id: ' .. oreId)
        return
    end

    if orePoint.looted then
        Notify(src, locale('error.already_looted'), 'error')
        Logger(src, 'red40_mining', 'Player attempted to mine ore point ' .. oreId .. ' but it was already looted.')
        return
    end

    local coords = GetEntityCoords(GetPlayerPed(src))
    if #(coords - orePoint.coords) > 5.0 then
        Notify(src, locale('error.too_far'), 'error')
        Logger(src, 'red40_mining',
            'Player attempted to mine ore point ' ..
            oreId .. ' but was too far away. Distance: ' .. #(coords - orePoint.coords))
        return
    end

    local tool = MiningTools[src]
    if not tool then
        Notify(src, locale('error.no_tool'), 'error')
        Logger(src, 'red40_mining', 'Player attempted to mine ore point ' .. oreId .. ' without a mining tool.')
        return
    end

    local waitTime = math.random(config.tools[tool].minUseTime, config.tools[tool].maxUseTime)

    local success = lib.callback.await('red40_mining:client:mineSpot', src, waitTime, config.tools[tool].type)

    if success and not orePoint.looted then
        orePoints[orePoint.id].looted = true
        lib.print.debug('Player ' .. src .. ' mined ore point ' .. orePoint.id)
        TriggerClientEvent('red40_mining:client:updateMiningSpot', -1, orePoint.id, true)
        SetTimeout(math.random(orePoint.respawnTimeMin, orePoint.respawnTimeMax), function()
            orePoints[orePoint.id].looted = false
            TriggerClientEvent('red40_mining:client:updateMiningSpot', -1, orePoint.id, false)
            lib.print.debug('Ore point ' .. orePoint.id .. ' has respawned')
        end)

        -- This is mildly redundant but the player could have an RGB gaming chair
        coords = GetEntityCoords(GetPlayerPed(src))
        if #(coords - orePoint.coords) > 5.0 then
            Notify(src, locale('error.too_far'), 'error')
            Logger(src, 'red40_mining',
                'Player finished mining ore point ' ..
                oreId .. ' but was too far away. Distance: ' .. #(coords - orePoint.coords))
            return
        end

        local playerXp = GetXp(src, 'mining') or 0
        local items = GenerateLoot(orePoint.rewards, orePoint.min, orePoint.max,
            GetXpLevel(playerXp, config.xpTables) or 0)
        lib.print.debug('Generated loot for player ' .. src .. ' at ore point ' .. orePoint.id .. ': ', items)

        if items and next(items) then
            local itemList = {}
            for itemName, v in pairs(items) do
                if not CanCarryItem(src, itemName, v.amount, v.metadata) then
                    lib.print.debug('Player ' .. src .. ' cannot carry item ' .. itemName .. ' x' .. v.amount)
                    itemList[#itemList + 1] = { itemName, v.amount, v.metadata }
                else
                    AddItem(src, itemName, v.amount, v.metadata)
                    lib.print.debug('Added items to player ' .. src .. ': ', items)
                end
            end
            if itemList and next(itemList) then
                CustomDrop(src, itemList, GetEntityCoords(GetPlayerPed(src)))
                lib.print.debug('Player ' .. src .. ' had some items dropped due to weight: ', itemList)
            end
        else
            Notify(src, locale('info.found_nothing'), 'inform')
            lib.print.debug('Player ' .. src .. ' found nothing at ore point ' .. orePoint.id)
        end

        if playerXp < config.tools[tool].maxXp then
            local xpGained = config.xpPerAction()
            AddXp(src, xpGained, 'mining')
            lib.print.debug('Added ' .. xpGained .. ' XP to player ' .. src .. ' for mining')
        end

        if config.tools[tool].damage then
            local durabilityRemoved = config.durability()
            local durabilityLeft = RemoveItemDurability(src, tool, durabilityRemoved)
            lib.print.debug('Removed ' ..
                durabilityRemoved .. ' durability from player ' .. src .. ' for mining with tool ' .. tool)
            if durabilityLeft and durabilityLeft <= 0 then
                Notify(src, locale('error.tool_broke'), 'error')
                Logger(src, 'red40_mining',
                    'Player ' .. src .. '\'s tool ' .. tool .. ' broke due to durability reaching 0.')
            end
        end
    end
end)

lib.callback.register('red40_mining:server:getMiningPoints', function(_)
    return orePoints, lightPoints, miningBlips
end)

-- Build ore points
local function buildPoints()
    local oreCount = 1
    for i = 1, #config.locations do
        local location = config.locations[i]
        for j = 1, #location.oreLocations do
            local oreLocation = location.oreLocations[j]
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
        for k = 1, #location.lights.locations do
            local lightPoint = location.lights.locations[k]

            lightPoints[#lightPoints + 1] = {
                coords = lightPoint.coords,
                prop = location.lights.prop,
                rot = lightPoint.rotation,
            }
        end
        if location.blip and location.blip.enabled then
            miningBlips[#miningBlips + 1] = {
                coords = location.blip.coords,
                sprite = location.blip.sprite,
                color = location.blip.color,
                scale = location.blip.scale,
                name = location.blip.name,
            }
        end
    end
end

CreateThread(function()
    buildPoints()
    for zone, lootData in pairs(config.lootTables) do
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