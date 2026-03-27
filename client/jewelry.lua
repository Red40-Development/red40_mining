local enabled = require 'config.shared'.jewelry

if not enabled then
    return
end

local config = require 'config.client'

local function inputBox(jewelryPointId, recipeId, itemName, maxAmount)
    local itemLabel = Items[itemName] and Items[itemName].label or itemName
    local title = locale('menu.jewelry_item', itemLabel)
    local label = locale('menu.jewelry_amount', itemLabel, maxAmount)
    local input = lib.inputDialog(title,
        { { type = 'number', label = label, required = true, min = 1, max = maxAmount, default = 1 } },
        { size = 'sm' })
    if input then
        local amount = tonumber(input[1])
        TriggerServerEvent('red40_mining:server:jewelryItem', jewelryPointId, recipeId, amount)
    end
end

local function openJewelryMenu(jewelryPointId)
    local jewelryItems = lib.callback.await('red40_mining:server:getJewelryItems', false, jewelryPointId)
    if not jewelryItems or not next(jewelryItems) then
        Notify(locale('error.no_jewelry_items'), 'error')
        return
    end
    local jewelryOptions = {}
    for i = 1, #jewelryItems do
        local item = jewelryItems[i]
        local inputItems, outputItems, outputItemName
        for itemName, amount in pairs(item.input) do
            inputItems = (inputItems or '') ..
            amount .. 'x ' .. (Items[itemName] and Items[itemName].label or itemName) .. ' '
        end
        for itemName, amount in pairs(item.output) do
            outputItemName = itemName
            outputItems = (outputItems or '') ..
            amount .. 'x ' .. (Items[itemName] and Items[itemName].label or itemName) .. ' '
        end
        jewelryOptions[#jewelryOptions + 1] = {
            title = outputItems,
            description = inputItems,
            image = ItemImageURL(outputItemName),
            onSelect = function()
                inputBox(jewelryPointId, item.recipeId, outputItemName, item.maxAmount)
            end,
        }
    end
    lib.registerContext({
        id = 'red40_mining_jewelry_menu',
        title = locale('menu.jewelry_title'),
        options = jewelryOptions,
    })
    lib.showContext('red40_mining_jewelry_menu')
end

local function createJewelryPoint(point)
    local offset = vec3(point.coords.x, point.coords.y, point.coords.z)
    if point.prop then
        local propSizeMin, propSizeMax = GetModelDimensions(point.prop)
        offset = GetOffsetFromCoordAndHeadingInWorldCoords(point.coords.x, point.coords.y, point.coords.z,
            point.rot.z, 0.0, 0.0, math.abs(propSizeMax.z - propSizeMin.z) / 2)
    end
    local shopOptions = {}
    if config.jewelryTarget then
        shopOptions = {
            {
                name = 'red40_mining_jewelry',
                label = locale('target.jewelry'),
                icon = 'fa-solid fa-gem',
                onSelect = function()
                    openJewelryMenu(point.id)
                end,
            }
        }
    end
    local pedPoint = lib.points.new({
        coords = vec3(point.coords.x, point.coords.y, point.coords.z),
        distance = 200.0,
        prop = point.prop,
        rot = point.rot,
        id = point.id,
        textOffset = offset,
        shopOptions = shopOptions,
    })

    if point.blip.enabled then
        CreateBlip({
            coords = point.blip.coords,
            sprite = point.blip.sprite,
            color = point.blip.color,
            scale = point.blip.scale,
            name = point.blip.name,
        })
    end

    function pedPoint:onEnter()
        if config.jewelryTarget and not self.prop then
            self.targetId = config.addSphereTarget({
                coords = self.coords,
                radius = 2.0,
                options = shopOptions,
            })
        elseif self.prop then
            lib.requestModel(self.prop, 10000)
            self.propNumber = CreateObject(self.prop, self.coords.x, self.coords.y, self.coords.z, false, true, false)
            SetModelAsNoLongerNeeded(self.prop)
            SetEntityRotation(self.propNumber, self.rot.x, self.rot.y, self.rot.z, 2, true)
            FreezeEntityPosition(self.propNumber, true)
            SetEntityInvincible(self.propNumber, true)
            if config.jewelryTarget then
                config.addLocalEntityTarget(self.propNumber, self.shopOptions)
            end
        end
    end

    function pedPoint:onExit()
        if config.jewelryTarget then
            for i = 1, #self.shopOptions do
                config.removeLocalEntityTarget(self.propNumber, self.shopOptions[i].name)
            end
            if self.targetId then
                config.removeSphereTarget(self.targetId)
                self.targetId = nil
            end
        end
        if DoesEntityExist(self.propNumber) then
            lib.print.debug('Deleting prop: ', self.propNumber)
            DeleteEntity(self.propNumber)
        end
        self.propNumber = nil
    end

    if not config.jewelryTarget then
        function pedPoint:nearby()
            if not self.isClosest then return end
            if self.currentDistance < 2 and not lib.getOpenContextMenu() then
                if config.use3dText then
                    DrawText3d({
                        coords = vec3(self.coords.x, self.coords.y, self.coords.z + 1.0),
                        text = locale('drawtext.jewelry'),
                    })
                else
                    local textOpen, text = lib.isTextUIOpen()
                    textOpen = textOpen and text == locale('textui.jewelry')
                    if not textOpen then
                        lib.showTextUI(locale('textui.jewelry'))
                    end
                end
                if IsControlJustReleased(0, config.useKey) then
                    openJewelryMenu(point.id)
                end
            else
                local textOpen, text = lib.isTextUIOpen()
                if textOpen and text == locale('textui.jewelry') then
                    lib.hideTextUI()
                end
            end
        end
    end
end

lib.callback.register('red40_mining:client:playJewelryAnim', function(waitTime, currentNumber, total, anim)
    if not IsEntityPlayingAnim(cache.ped, anim.dict, anim.anim, 3) then
        lib.playAnim(cache.ped, anim.dict, anim.anim, 8.0, -8.0, -1, 0, 0, false, 0, false)
    end

    local success = lib.progressBar({
        duration = waitTime,
        label = locale('progress.jewelry', currentNumber, total),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            combat = true,
            mouse = false,
        },
    })
    if currentNumber == total then
        ClearPedTasks(cache.ped)
    end
    return success
end)


CreateThread(function()
    local jewelryPoints = lib.callback.await('red40_mining:server:getJewelryPoints')
    for i = 1, #jewelryPoints do
        local jewelryPoint = jewelryPoints[i]
        createJewelryPoint(jewelryPoint)
    end
end)