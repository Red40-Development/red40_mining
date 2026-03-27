local enabled = require 'config.shared'.peds

if not enabled then
    return
end

local config = require 'config.client'

local oxInv = lib.checkDependency('ox_inventory', '2.37.3')

local function inputBox(action, shopName, item, maxAmount)
    local itemLabel = Items[item.name] and Items[item.name].label or item.name
    local title = action == 'sell' and locale('menu.sell_item', itemLabel) or locale('menu.buy_item', itemLabel)
    local label = action == 'sell' and locale('menu.sell_amount', itemLabel, maxAmount) or locale('menu.buy_amount', itemLabel)
    local input = lib.inputDialog(title, {{ type = 'number', label = label, required = true, min = 1, max = maxAmount, precision = 1}},
        { size = 'sm' })
    if input then
        local amount = tonumber(input[1])
        TriggerServerEvent('red40_mining:server:' .. action, shopName, item.name, amount)
    end
end

local function openSellMenu(shopName)
    local itemsForSale = lib.callback.await('red40_mining:server:getSellableItems', false, shopName)
    local sellOptions = {}
    for i = 1, #itemsForSale do
        local item = itemsForSale[i]
        sellOptions[#sellOptions + 1] = {
            title = locale('menu.sell_item', Items[item.name].label),
            description = locale('menu.sell_price', item.price),
            image = ItemImageURL(item.name),
            onSelect = function()
                inputBox('sell', shopName, item, item.maxAmount)
            end,
        }
    end
    lib.registerContext({
        id = 'red40_mining_sell_menu',
        title = locale('menu.sell_title'),
        options = sellOptions,
    })
    lib.showContext('red40_mining_sell_menu')
end

local function openBuyMenu(shopName)
    local itemsForSale = lib.callback.await('red40_mining:server:getShopItems', false, shopName)
    local buyOptions = {}
    for i = 1, #itemsForSale do
        local item = itemsForSale[i]
        local label = Items[item.name] and Items[item.name].label or item.name
        buyOptions[#buyOptions + 1] = {
            title = locale('menu.buy_item', label),
            description = locale('menu.buy_price', item.price),
            image = ItemImageURL(item.name),
            onSelect = function()
                inputBox('buy', shopName, item)
            end,
        }
    end
    lib.registerContext({
        id = 'red40_mining_buy_menu',
        title = locale('menu.buy_title'),
        options = buyOptions,
    })
    lib.showContext('red40_mining_buy_menu')
end

local function createPedPoint(point)
    local shopOptions = {}
    if point.style == 'ox_inventory' and oxInv and config.useTarget then
        if point.pedpedBuys then
            shopOptions[#shopOptions + 1] = {
                name = 'red40_mining_buy',
                label = locale('target.buy'),
                icon = 'fa-solid fa-box',
                onSelect = function()
                    exports.ox_inventory:openInventory('shop', { type = point.shopName })
                end,
            }
        end
        if point.pedpedSells then
            shopOptions[#shopOptions + 1] = {
                name = 'red40_mining_sell',
                label = locale('target.sell'),
                icon = 'fa-solid fa-hand-holding-dollar',
                onSelect = function()
                    exports.ox_inventory:openInventory('stash', point.stashName)
                end,
            }
        end
    elseif config.useTarget then
        if point.pedpedBuys then
            shopOptions[#shopOptions + 1] = {
                name = 'red40_mining_buy',
                label = locale('target.buy'),
                icon = 'fa-solid fa-box',
                onSelect = function()
                    openBuyMenu(point.shopName)
                end,
            }
        end
        if point.pedpedSells then
            shopOptions[#shopOptions + 1] = {
                name = 'red40_mining_sell',
                label = locale('target.sell'),
                icon = 'fa-solid fa-hand-holding-dollar',
                onSelect = function()
                    openSellMenu(point.shopName)
                end,
            }
        end
    end

    if point.blip.enabled then
        CreateBlip({
            coords = point.blip.coords,
            sprite = point.blip.sprite,
            color = point.blip.color,
            scale = point.blip.scale,
            name = point.blip.name,
        })
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

    function pedPoint:onExit()
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
        local textLocale = point.pedpedBuys and point.pedpedSells and locale('textui.shop') or
            (point.pedpedBuys and locale('textui.buyshop') or (point.pedpedSells and locale('textui.sellshop') or ''))
        local drawTextLocale = point.pedpedBuys and point.pedpedSells and locale('drawtext.shop') or
            (point.pedpedBuys and locale('drawtext.buyshop') or (point.pedpedSells and locale('drawtext.sellshop') or ''))
        function pedPoint:nearby()
            if not self.isClosest then return end
            if self.currentDistance < 2 and not lib.getOpenContextMenu() then
                if config.use3dText then
                    DrawText3d({
                        coords = vec3(self.coords.x, self.coords.y, self.coords.z + 1.0),
                        text = drawTextLocale,
                    })
                else
                    local textOpen, text = lib.isTextUIOpen()
                    textOpen = textOpen and text == textLocale
                    if not textOpen then
                        lib.showTextUI(textLocale)
                    end
                end
                if IsControlJustReleased(0, config.useKey) then
                    openSellMenu(point.shopName)
                end
                if IsControlJustReleased(0, config.useKey2) then
                    openBuyMenu(point.shopName)
                end
            else
                local textOpen, text = lib.isTextUIOpen()
                if textOpen and text == textLocale then
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