local enabled = require 'config.shared'.washing

if not enabled then
    return
end

local config = require 'config.server'.washing

local washingZones = {}
local washingClientZones = {}

local function getWashingZone(coords)
    for i = 1, #washingZones do
        if washingZones[i]:contains(coords) then
            return washingZones[i]
        end
    end
end

local function washSpot(src, itemName)
    local pedCoords = GetEntityCoords(GetPlayerPed(src))
    local washingZone = getWashingZone(pedCoords)

    if not washingZone then
        Notify(src, locale('error.not_in_washing_zone'), 'error')
        return
    end

    local toolConfig = config.tools[itemName]
    if not toolConfig then
        Notify(src, locale('error.invalid_tool'), 'error')
        return
    end
    local playerXp = GetXp(src, 'washing') or 0
    local playerLevel = GetXpLevel(playerXp, config.xpTables) or 0
    if playerLevel < toolConfig.level then
        Notify(src, locale('error.washing_tool_level_too_low'), 'error')
        return
    end

    StartMining(src, 'washing', itemName)

    local waitTime = math.random(toolConfig.minUseTime, toolConfig.maxUseTime)

    local success = lib.callback.await('red40_mining:client:washSpot', src, waitTime)

    if success then
        local items = GenerateLoot(toolConfig.rewards, toolConfig.min, toolConfig.max, playerLevel)
        lib.print.debug('Generated loot for player ' .. src .. ' at washing zone ' .. washingZone.id .. ': ', items)

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
            Notify(src, locale('info.found_nothing'), 'inform')
            lib.print.debug('Player ' .. src .. ' found nothing at washing zone ' .. washingZone.id)
        end

        if playerXp < config.tools[itemName].maxXp then
            local xpGained = config.xpPerAction()
            AddXp(src, xpGained, 'washing')
            lib.print.debug('Added ' .. xpGained .. ' XP to player ' .. src .. ' for washing')
        end
        RemoveItem(src, itemName, 1)
    end
    DeleteMiningObject(src)
end

lib.callback.register('red40_mining:server:getWashingZones', function()
    return washingClientZones
end)

local function buildWashingZone()
    for i = 1, #config.locations do
        local zone = config.locations[i]
        if zone.enabled then
            local createdZone = lib.zones.poly({
                name = zone.name,
                points = zone.points,
                thickness = zone.thickness or 400,
                blip = zone.blip,
            })
            if zone.debug then
                local clientZone = {
                    points = zone.points,
                    thickness = zone.thickness or 400,
                    blip = zone.blip,
                    debug = true,
                }
                washingClientZones[#washingClientZones + 1] = clientZone
            end
            washingZones[#washingZones + 1] = createdZone
        end
    end
end

CreateThread(function()
    buildWashingZone()
    for zone, lootTable in pairs(config.lootTables) do
        RegisterLootTable(zone, lootTable)
    end
end)

--- Usable items
if GetResourceState('ox_inventory') ~= 'missing' then
    local function startWashingExport(_, item, inventory)
        if inventory.type == 'player' then
            local src = inventory.player.source
            washSpot(src, item.name)
        end
        return true
    end
    exports('washing', startWashingExport)
elseif GetResourceState('qb-core') ~= 'missing' then
    for item, _ in pairs(config.tools) do
        QBCore.Functions.CreateUseableItem(item, function(source, _)
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player.Functions.GetItemByName(item) then return end
            washSpot(source, item)
        end)
    end
elseif GetResourceState('es_extended') ~= 'missing' then
    for item, _ in pairs(config.tools) do
        ESX.RegisterUsableItem(item, function(source)
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer.getInventoryItem(item).count then return end
            washSpot(source, item)
        end)
    end
end