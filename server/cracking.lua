local enabled = require 'config.shared'.cracking

if not enabled then
    return
end

local config = require 'config.server'.cracking

local crackingSpots = {}

local toolTable = {}
for item, _ in pairs(config.tools) do
    toolTable[item] = true
end

local function findToolInInventory(src)
    for itemName, _ in pairs(toolTable) do
        if GetItemCount(src, itemName) > 0 then
            return itemName
        end
    end
end

RegisterNetEvent('red40_mining:server:startCracking', function(spotId)
    local src = source
    local pedCoords = GetEntityCoords(GetPlayerPed(src))
    local crackingSpot = crackingSpots[spotId]

    if not crackingSpot then
        Notify(src, locale('not_in_cracking_spot'), 'error')
        return
    end

    if not crackingSpot.coords or #(pedCoords - crackingSpot.coords) > 5.0 then
        Notify(src, locale('not_in_cracking_spot'), 'error')
        return
    end

    local playerXp = GetXp(src, 'cracking') or 0
    local playerLevel = GetXpLevel(playerXp, config.xpTables) or 0

    --Find first tool in inventory
    local toolItem = findToolInInventory(src)
    if not toolItem then
        Notify(src, locale('no_cracking_tool'), 'error')
        return
    end
    local toolConfig = config.tools[toolItem]
    if not toolConfig then
        Notify(src, locale('invalid_tool'), 'error')
        return
    end

    if playerLevel < toolConfig.level then
        Notify(src, locale('cracking_tool_level_too_low'), 'error')
        return
    end

    --Find crackable item
    local crackableItem = nil
    for itemName in pairs(config.crackableItems) do
        if GetItemCount(src, itemName) > 0 then
            crackableItem = itemName
            break
        end
    end

    if not crackableItem then
        Notify(src, locale('no_crackable_item'), 'error')
        return
    end

    local crackableConfig = config.crackableItems[crackableItem]
    if not crackableConfig then
        Notify(src, locale('invalid_crackable_item'), 'error')
        return
    end

    local waitTime = math.random(toolConfig.minUseTime, toolConfig.maxUseTime)

    -- Create the cracking prop and pass to client

    local object = CreateObject(crackableConfig.prop, crackingSpot.coords.x, crackingSpot.coords.y, crackingSpot.coords.z - 25, true, true, true)

    while not DoesEntityExist(object) do
        Wait(50)
    end

    SetEntityIgnoreRequestControlFilter(object, true)

    local entityData = {
        entity = NetworkGetNetworkIdFromEntity(object),
        anim = crackingSpot.anim,
        offset = crackableConfig.offset,
        rotation = crackableConfig.rotation,
    }

    local success = lib.callback.await('red40_mining:client:crackSpot', src, waitTime, entityData)

    -- Cleanup the cracking prop
    DeleteEntity(object)

    if success then
        local items = GenerateLoot(crackableConfig.rewards, crackableConfig.min, crackableConfig.max, playerLevel)
        lib.print.debug('Generated loot for player ' .. src .. ' at cracking spot ' .. crackingSpot.id .. ': ', items)
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
            lib.print.debug('Player ' .. src .. ' found nothing at cracking zone ' .. crackingSpot.id)
        end

        if playerXp < toolConfig.maxXp then
            local xpGained = config.xpPerAction()
            AddXp(src, xpGained, 'cracking')
            lib.print.debug('Added ' .. xpGained .. ' XP to player ' .. src .. ' for cracking')
        end
        RemoveItem(src, crackableItem, 1)
        if toolConfig.damage then
            local durabilityRemoved = config.durabilityPerAction()
            local durabilityLeft = RemoveItemDurability(src, toolItem, durabilityRemoved)
            lib.print.debug('Removed ' ..
            durabilityRemoved .. ' durability from player ' .. src .. ' for cracking with tool ' .. toolItem)
            if durabilityLeft and durabilityLeft <= 0 then
                Notify(src, locale('tool_broke'), 'error')
                lib.print.debug('Player ' ..
                src .. '\'s cracking tool ' .. toolItem .. ' broke due to durability reaching 0')
            end
        end
    end
end)

lib.callback.register('red40_mining:server:getCrackingPoints', function()
    return crackingSpots
end)

local function buildCrackingZone()
    local crackCount = 1
    for i = 1, #config.locations do
        local zone = config.locations[i]
        if zone.enabled then
            for j = 1, #zone.locations do
                local location = zone.locations[j]
                local crackSpot = {
                    id = crackCount,
                    coords = location.coords,
                    prop = zone.prop,
                    rot = location.rotation,
                    anim = zone.anim,
                    blip = zone.blip,
                }
                crackingSpots[crackCount] = crackSpot
                crackCount = crackCount + 1
            end
        end
    end
end

CreateThread(function()
    buildCrackingZone()
    for zone, lootTable in pairs(config.lootTables) do
        RegisterLootTable(zone, lootTable)
    end
end)