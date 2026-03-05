local enabled = require 'config.shared'.peds

if not enabled then
    return
end

local config = require 'config.client'

local oxInv = lib.checkDependency('ox_inventory', '2.37.3')

local function inputBox(action, shopName, item, maxAmount)
    local title = action == 'sell' and locale('sell_item', item.label) or locale('buy_item', item.label)
    local label = action == 'sell' and locale('sell_amount', item.label, maxAmount) or locale('buy_amount', item.label)
    local input = lib.inputDialog(title, { type = 'number', label = label, required = true, min = 1, max = maxAmount })
    if input then
        local amount = tonumber(input[1])
        TriggerServerEvent('red40_mining:server:' .. action, shopName, item.name, amount)
    end
end

local function openSellMenu(shopName)
    --TODO: query server for list of sellable items and build ox_lib context menu
    local itemsForSale = lib.callback.await('red40_mining:server:getSellableItems', shopName)
    local sellOptions = {}
    for i = 1, #itemsForSale do
        local item = itemsForSale[i]
        sellOptions[#sellOptions + 1] = {
            title = locale('sell_item', item.label),
            description = locale('sell_price', item.price),
            image = 'https://cfx-ox_inventory/web/images/items/' .. item.name .. '.png',
            onSelect = function()
                inputBox('sell', shopName, item, item.maxAmount)
            end,
        }
    end
    lib.registerContext({
        id = 'red40_mining_sell_menu',
        title = locale('sell_menu_title'),
        options = sellOptions,
    })
    lib.showContext('red40_mining_sell_menu')
end

local function openBuyMenu(shopName)
    --TODO: query server for list of items in shop and build ox_lib context menu
    local itemsForSale = lib.callback.await('red40_mining:server:getShopItems', shopName)
    local buyOptions = {}
    for i = 1, #itemsForSale do
        local item = itemsForSale[i]
        buyOptions[#buyOptions + 1] = {
            title = locale('buy_item', item.label),
            description = locale('buy_price', item.price),
            image = 'https://cfx-ox_inventory/web/images/items/' .. item.name .. '.png',
            onSelect = function()
                inputBox('buy', shopName, item, item.maxAmount)
            end,
        }
    end
    lib.registerContext({
        id = 'red40_mining_buy_menu',
        title = locale('buy_menu_title'),
        options = buyOptions,
    })
    lib.showContext('red40_mining_buy_menu')
end

local function createPedPoint(point)
    local shopOptions = {}
    if point.style == 'ox_inventory' and oxInv and config.useTarget then
        shopOptions = {
            {
                name = 'red40_mining_buy',
                label = locale('target.buy'),
                icon = 'fa-solid fa-box',
                onSelect = function()
                    exports.ox_inventory:openInventory('stash', point.shopName)
                end,
            },
            {
                name = 'red40_mining_sell',
                label = locale('target.sell'),
                icon = 'fa-solid fa-hand-holding-dollar',
                onSelect = function()
                    exports.ox_inventory:openInventory('shop', { type = point.shopName })
                end,
            }
        }
    elseif config.useTarget then
        shopOptions = {
            {
                name = 'red40_mining_buy',
                label = locale('target.buy'),
                icon = 'fa-solid fa-box',
                onSelect = function()
                    openSellMenu(point.shopName)
                end,
            },
            {
                name = 'red40_mining_sell',
                label = locale('target.sell'),
                icon = 'fa-solid fa-hand-holding-dollar',
                onSelect = function()
                    openBuyMenu(point.shopName)
                end,
            }
        }
    end
    local pedPoint = lib.points.new({
        coords = vec3(point.coords.x, point.coords.y, point.coords.z),
        distance = 200.0,
        pedModel = point.pedModel,
        heading = point.coords.w,
        pedAnim = point.anim,
        pedScenario = point.pedScenario,
        options = shopOptions,
    })

    function pedPoint:onEnter()
        lib.print.debug('Creating ped for store: ', self.store)
        lib.requestModel(self.pedModel, 10000)

        self.ped = CreatePed(0, self.pedModel, self.coords.x, self.coords.y, self.coords.z,
            self.heading, false, true)
        lib.print.debug(self.ped and 'Ped created: ' .. self.ped or 'Ped failed to create')
        SetEntityHeading(self.ped, self.heading)
        SetModelAsNoLongerNeeded(self.pedModel)

        if self.pedScenario then
            TaskStartScenarioInPlace(self.ped, self.pedScenario, 0, true)
        elseif self.pedAnim and self.pedAnim.dict and self.pedAnim.anim then
            CreateThread(function()
                lib.playAnim(self.ped, self.pedAnim.dict, self.pedAnim.anim, 8.0, -8.0, -1, 1, 0, false, 0, false)
            end)
        end
        FreezeEntityPosition(self.ped, true)
        SetEntityInvincible(self.ped, true)
        SetBlockingOfNonTemporaryEvents(self.ped, true)
        if config.useTarget then
            config.addLocalEntityTarget(self.ped, self.options)
        end
    end

    function point:onExit()
        if config.useTarget then
            for i = 1, #self.options do
                config.removeLocalEntityTarget(self.ped, self.options[i].name)
            end
        end
        if DoesEntityExist(self.ped) then
            lib.print.debug('Deleting ped: ', self.ped)
            DeleteEntity(self.ped)
        end
        self.ped = nil
    end

    if not config.useTarget then
        function pedPoint:nearby()
            if not self.isClosest then return end
            if self.currentDistance < 2 then
                if config.use3dText then
                    DrawText3d({
                        coords = self.coords,
                        text = locale('shop_text_3d'),
                    })
                else
                    local textOpen, text = lib.isTextUIOpen()
                    textOpen = textOpen and text == locale('shop_text')
                    if not textOpen then
                        lib.showTextUI(locale('shop_text'))
                    end
                end
                if IsControlJustReleased(0, config.useKey) then
                    openSellMenu(self.shopName)
                end
                if IsControlJustReleased(0, config.useKey2) then
                    openBuyMenu(self.shopName)
                end
            else
                local textOpen, text = lib.isTextUIOpen()
                if textOpen and text == locale('shop_text') then
                    lib.hideTextUI()
                end
            end
        end
    end
end

CreateThread(function()
    local pedPoints = lib.callback.await('red40_mining:server:getPedPoints')
    for i = 1, #pedPoints do
        local pedPoint = pedPoints[i]
        createPedPoint(pedPoint)
    end
end)