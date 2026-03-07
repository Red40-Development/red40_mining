local enabled = require 'config.shared'.panning

if not enabled then
    return
end

local config = require 'config.server'.panning

local panningZones = {}
local panningClientZones = {}

local function getPanningZone(coords)
    for i = 1, #panningZones do
        if panningZones[i]:contains(coords) then
            return panningZones[i]
        end
    end
end

local function panSpot(src, itemName)
    local pedCoords = GetEntityCoords(GetPlayerPed(src))
    local panningZone = getPanningZone(pedCoords)

    if not panningZone then
        Notify(src, locale('not_in_panning_zone'), 'error')
        return
    end

    StartMining(src, 'panning', itemName)

    local waitTime = math.random(config.tools[itemName].minUseTime, config.tools[itemName].maxUseTime)

    local success = lib.callback.await('red40_mining:client:panSpot', src, waitTime, config.tools[itemName].type)

    if success then
        local playerXp = GetXp(src, 'panning') or 0
        local items = GenerateLoot(panningZone.rewards, panningZone.min, panningZone.max,
            GetXpLevel(playerXp, config.xpTables) or 0)
        lib.print.debug('Generated loot for player ' .. src .. ' at pan zone ' .. panningZone.id .. ': ', items)

        if items and next(items) then
            local itemList = {}
            for lootItemName, v in pairs(items) do
                if not CanCarryItem(src, lootItemName, v.amount, v.metadata) then
                    lib.print.debug('Player ' .. src .. ' cannot carry item ' .. lootItemName .. ' x' .. v.amount)
                    itemList[#itemList + 1] = { lootItemName, v.amount, v.metadata }
                else
                    AddItem(src, lootItemName, v.amount, v.metadata)
                    lib.print.debug('Added items to player ' .. src .. ': ', items)
                end
            end
            if itemList and next(itemList) then
                CustomDrop(src, itemList, pedCoords)
                lib.print.debug('Player ' .. src .. ' had some items dropped due to weight: ', itemList)
            end
        else
            Notify(src, locale('found_nothing'), 'inform')
            lib.print.debug('Player ' .. src .. ' found nothing at pan zone ' .. panningZone.id)
        end

        if playerXp < config.tools[itemName].maxXp then
            local xpGained = config.xpPerAction()
            AddXp(src, xpGained, 'panning')
            lib.print.debug('Added ' .. xpGained .. ' XP to player ' .. src .. ' for panning')
        end
    end
    DeleteMiningObject(src)
end

lib.callback.register('red40_mining:server:getPanningZones', function()
    return panningClientZones
end)


local function buildPanningZone()
    for i = 1, #config.locations do
        local zone = config.locations[i]
        if zone.enabled then
            local createdZone = lib.zones.poly({
                name = zone.name,
                points = zone.points,
                thickness = zone.thickness or 400,
                blip = zone.blip,
                rewards = zone.rewards,
                min = zone.min,
                max = zone.max,
            })
            if zone.debug then
                local clientZone = {
                    points = zone.points,
                    thickness = zone.thickness or 400,
                    blip = zone.blip,
                }
                panningClientZones[#panningClientZones + 1] = clientZone
            end
            panningZones[#panningZones + 1] = createdZone
        end
    end
end

CreateThread(function()
    buildPanningZone()
    for zone, lootTable in pairs(config.lootTables) do
        RegisterLootTable(zone, lootTable)
    end
end)

--- Usable items
if GetResourceState('ox_inventory') ~= 'missing' then
    local function startPanningExport(_, item, inventory)
        if inventory.type == 'player' then
            local src = inventory.player.source
            panSpot(src, item.name)
        end
        return true
    end
    exports('panning', startPanningExport)
elseif GetResourceState('qb-core') ~= 'missing' then
    for item, _ in pairs(config.tools) do
        QBCore.Functions.CreateUseableItem(item, function(source, _)
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player.Functions.GetItemByName(item) then return end
            panSpot(source, item)
        end)
    end
elseif GetResourceState('es_extended') ~= 'missing' then
    for item, _ in pairs(config.tools) do
        ESX.RegisterUsableItem(item, function(source)
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer.getInventoryItem(item).count then return end
            panSpot(source, item)
        end)
    end
end