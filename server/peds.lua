local enabled = require 'config.shared'.peds

if not enabled then
    return
end

local config = require 'config.server'.peds

if config.style == 'ox_inventory' then
    --- Modified from original source (https://github.com/Renewed-Scripts/Renewed-Lib/blob/main/modules/stashshop/server.lua)
    --- License GPL-3.0
    --- Copyright (C) 2024 Renewed Scripts.
    if not lib.checkDependency('ox_inventory', '2.37.3') then return end

    local ox_inventory = exports.ox_inventory

    local inventories = {}
    local openedBy = {}
    local shops = {}

    ---Adds an item to the second slot
    ---@param id string
    ---@param price number
    ---@param payload table
    local function addItemToSecondSlot(id, price, payload)
        SetTimeout(50, function()
            local addMoney = ox_inventory:AddItem(id, config.moneyItem, price, nil, 1)

            if addMoney then
                ox_inventory:RemoveItem(payload.fromInventory, payload.fromSlot.name, payload.count,
                    payload.fromSlot.metadata, payload.fromSlot.slot)
                ox_inventory:AddItem(id, payload.fromSlot.name, payload.count, payload.fromSlot.metadata, 2)

                inventories[id] += 1
                ox_inventory:SetSlotCount(id, inventories[id])
            end
        end)
    end

    ---Resets the inventory state
    ---@param source number
    ---@param id string
    local function resetInventory(source, id)
        SetTimeout(100, function()
            local items = ox_inventory:GetInventoryItems(id)
            ox_inventory:ClearInventory(id)
            ox_inventory:SetSlotCount(id, 2)
            inventories[id] = 2

            lib.logger(source, ('renewed_stashitems:%s'):format(id), items)
            TriggerEvent('Renewed-Lib:server:soldStashItems', source, id, items)
        end)
    end

    ---Prepares the stash for usage by registering it and clearing it
    ---@param id string
    ---@param label string
    ---@param coords vector3
    local function prepStash(id, label, coords)
        ox_inventory:RegisterStash(id, label, 2, 9000000, nil, nil, coords and vec3(coords.x, coords.y, coords.z) or nil)
        ox_inventory:ClearInventory(id, false)
    end


    ---Creates a sales stash, where players can insert items into a stash and get money in return
    ---@param id string
    ---@param label string
    ---@param items table<string, number>
    ---@param coords vector3
    local function createSaleStash(id, label, items, coords)

        if inventories[id] then
            return
        end

        prepStash(id, label, coords)

        inventories[id] = 2
        shops[id] = items
    end

    ox_inventory:registerHook('swapItems', function(payload)
        local source = payload.source
        local item = payload.fromSlot.name:lower()
        local addItem = inventories[payload.toInventory]
        local inventory = payload.toInventory == source and payload.fromInventory or payload.toInventory

        if payload.toInventory == payload.fromInventory then
            return false
        end

        if item == config.moneyItem and not addItem then
            if payload.count < payload.fromSlot.count then
                return false
            end

            resetInventory(source, inventory)
            return true
        end

        if payload.action ~= 'move' then
            return false
        end

        local price = shops?[inventory]?[item]
        if not price or openedBy[inventory] ~= source then
            return false
        end

        price *= payload.count

        local slotCount = inventories[inventory]

        if addItem then
            if payload.toSlot == 1 then
                addItemToSecondSlot(inventory, price, payload)
                return false
            else
                local added = ox_inventory:AddItem(inventory, config.moneyItem, price, nil, 1)

                if added then
                    slotCount += 1
                    ox_inventory:SetSlotCount(inventory, slotCount)

                    inventories[inventory] = slotCount
                end

                return added
            end
        elseif payload.fromSlot.slot > 1 and payload.fromSlot.slot == slotCount - 1 then
            local removed = ox_inventory:RemoveItem(inventory, config.moneyItem, price, nil, 1)

            if removed then
                slotCount -= 1
                ox_inventory:SetSlotCount(inventory, slotCount)

                inventories[inventory] = slotCount
            end

            return removed
        end

        return false
    end, {
        inventoryFilter = {
            '^red40_mining_sale_[%w]+'
        }
    })

    AddEventHandler('ox_inventory:openedInventory', function(playerId, inventoryId)
        if inventories[inventoryId] and not openedBy[inventoryId] then
            openedBy[inventoryId] = playerId
        end
    end)

    AddEventHandler('ox_inventory:closedInventory', function(playerId, inventoryId)
        if openedBy[inventoryId] == playerId then
            openedBy[inventoryId] = nil
        end
    end)


    AddEventHandler('playerDropped', function()
        local src = source
        for inventory, playerId in pairs(openedBy) do
            if playerId == src then
                openedBy[inventory] = nil
            end
        end
    end)

    --- End of modified code
    ---
    local pedPoints = {}

    lib.callback.register('red40_mining:server:getPedPoints', function(_)
        return pedPoints
    end)

    local function buildPedPoints()
        for i = 1, #config.locations do
            local location = config.locations[i]
            if location.enabled then
                createSaleStash('red40_mining_sale_' .. location.name, location.label, location.buys, location.coords)
                local sellItems = {}
                for itemName, price in pairs(location.sells) do
                    sellItems[#sellItems + 1] = {
                        name = itemName,
                        price = price,
                    }
                end
                ox_inventory:RegisterShop('red40_mining' .. location.name,
                    { name = location.label, inventory = sellItems, label = location.label })

                local pedPoint = {
                    stashName = 'red40_mining_sale_' .. location.name,
                    shopName = 'red40_mining' .. location.name,
                    style = 'ox_inventory',
                    blip = location.blip,
                    coords = location.coords,
                    pedModel = location.pedModel,
                    pedAnim = location.pedAnim,
                    pedScenario = location.pedScenario,
                    pedBuys = location.buys and next(location.buys) and true or false,
                    pedSells = location.sells and next(location.sells) and true or false,
                }
                pedPoints[#pedPoints + 1] = pedPoint
            end
        end
    end

    CreateThread(function()
        buildPedPoints()
    end)
else
    local pedPoints = {}
    local function getShop(shopName)
        for i = 1, #config.locations do
            local location = config.locations[i]
            if location.name == shopName then
                return location
            end
        end
    end

    RegisterNetEvent('red40_mining:server:buy', function(shopName, itemName, amount)
        local src = source


        local shop = getShop(shopName)
        if not shop then return end

        --Distance check
        local playerCoords = GetEntityCoords(GetPlayerPed(src))
        if #(playerCoords - vec3(shop.coords.x, shop.coords.y, shop.coords.z)) > 5 then
            Notify(src, locale('error.too_far'))
            return
        end

        local price = shop.sells[itemName]
        if not price then
            --Drop player cause they are trying to buy an item that doesn't exist in the shop
            return
        end

        if not CanCarryItem(src, itemName, amount) then
            Notify(src, locale('error.not_carry'))
            return
        end
        local totalPrice = price * amount

        if RemoveMoney(src, 'cash', totalPrice) then
            AddItem(src, itemName, amount)
            Logger(src, 'shop_buy', { item = itemName, amount = amount, price = totalPrice })
        end
    end)

    RegisterNetEvent('red40_mining:server:sell', function(shopName, itemName, amount)
        local src = source

        local shop = getShop(shopName)
        if not shop then return end

        --Distance check
        local playerCoords = GetEntityCoords(GetPlayerPed(src))
        if #(playerCoords - vec3(shop.coords.x, shop.coords.y, shop.coords.z)) > 5 then
            Notify(src, locale('error.too_far'))
            return
        end

        local price = shop.buys[itemName]
        if not price then
            --Drop player cause they are trying to sell an item that doesn't exist in the shop
            return
        end

        if RemoveItem(src, itemName, amount) then
            local totalPrice = price * amount
            AddMoney(src, 'cash', totalPrice)
            Logger(src, 'shop_sell', { item = itemName, amount = amount, price = totalPrice })
         end
    end)

    lib.callback.register('red40_mining:server:getSellableItems', function(source, shopName)
        local shop = getShop(shopName)
        if not shop then return end

        local sellableItems = {}
        for itemName, price in pairs(shop.buys) do
            local itemCount = GetItemCount(source, itemName)
            if itemCount > 0 then
                sellableItems[#sellableItems + 1] = {
                    name = itemName,
                    price = price,
                    maxAmount = itemCount,
                }
            end
        end
        return sellableItems
    end)

    lib.callback.register('red40_mining:server:getShopItems', function(source, shopName)
        local shop = getShop(shopName)
        if not shop then return end

        local itemsForSale = {}
        for itemName, price in pairs(shop.sells) do
            itemsForSale[#itemsForSale + 1] = {
                name = itemName,
                price = price,
            }
        end
        return itemsForSale
    end)

    lib.callback.register('red40_mining:server:getPedPoints', function(_)
        return pedPoints
    end)

    local function buildPedPoints()
        for i = 1, #config.locations do
            local location = config.locations[i]
            if location.enabled then
                local pedPoint = {
                    shopName = location.name,
                    style = 'ox_lib',
                    blip = location.blip,
                    coords = location.coords,
                    pedModel = location.pedModel,
                    pedAnim = location.pedAnim,
                    pedScenario = location.pedScenario,
                }
                pedPoints[#pedPoints + 1] = pedPoint
            end
        end
    end

    CreateThread(function()
        buildPedPoints()
    end)
end