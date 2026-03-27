local enabled = require 'config.shared'.smelting

if not enabled then
    return
end

local config = require 'config.client'

local function inputBox(smeltPointId, recipeId, itemName, maxAmount)
    local itemLabel = Items[itemName] and Items[itemName].label or itemName
    local title = locale('menu.smelt_item', itemLabel)
    local label = locale('menu.smelt_amount', itemLabel, maxAmount)
    local input = lib.inputDialog(title,
        { { type = 'number', label = label, required = true, min = 1, max = maxAmount, default = 1 } },
        { size = 'sm' })
    if input then
        local amount = tonumber(input[1])
        TriggerServerEvent('red40_mining:server:smeltItem', smeltPointId, recipeId, amount)
    end
end

local function openSmeltMenu(smeltPointId)
    local smeltableItems = lib.callback.await('red40_mining:server:getSmeltableItems', false, smeltPointId)
    if not smeltableItems or not next(smeltableItems) then
        Notify(locale('error.no_smeltable_items'), 'error')
        return
    end
    local smeltOptions = {}
    for i = 1, #smeltableItems do
        local item = smeltableItems[i]
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
        smeltOptions[#smeltOptions + 1] = {
            title = outputItems,
            description = inputItems,
            image = ItemImageURL(outputItemName),
            onSelect = function()
                inputBox(smeltPointId, item.recipeId, outputItemName, item.maxAmount)
            end,
        }
    end
    lib.registerContext({
        id = 'red40_mining_smelt_menu',
        title = locale('menu.smelt_title'),
        options = smeltOptions,
    })
    lib.showContext('red40_mining_smelt_menu')
end

local function createSmeltPoint(point)
    local offset = vec3(point.coords.x, point.coords.y, point.coords.z)
    if point.prop then
        local propSizeMin, propSizeMax = GetModelDimensions(point.prop)
        offset = GetOffsetFromCoordAndHeadingInWorldCoords(point.coords.x, point.coords.y, point.coords.z,
            point.rot.z, 0.0, 0.0, math.abs(propSizeMax.z - propSizeMin.z) / 2)
    end
    local shopOptions = {}
    if config.smeltingTarget then
        shopOptions = {
            {
                name = 'red40_mining_smelt',
                label = locale('target.smelt'),
                icon = 'fa-solid fa-fire',
                onSelect = function()
                    openSmeltMenu(point.id)
                end,
            }
        }
    end
    local smeltPoint = lib.points.new({
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

    function smeltPoint:onEnter()
        if config.smeltingTarget and not self.prop then
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
            if config.smeltingTarget then
                config.addLocalEntityTarget(self.propNumber, self.shopOptions)
            end
        end
    end

    function smeltPoint:onExit()
        if config.smeltingTarget then
            for i = 1, #self.shopOptions do
                config.removeLocalEntityTarget(self.propNumber, self.shopOptions[i].name)
            end
            if self.targetId then
                config.removeZoneTarget(self.targetId)
                self.targetId = nil
            end
        end
        if DoesEntityExist(self.propNumber) then
            lib.print.debug('Deleting prop: ', self.propNumber)
            DeleteEntity(self.propNumber)
        end
        self.propNumber = nil
    end

    if not config.smeltingTarget then
        function smeltPoint:nearby()
            if not self.isClosest then return end
            if self.currentDistance < 2 and (not lib.getOpenContextMenu() and not lib.progressActive()) then
                if config.use3dText then
                    DrawText3d({
                        coords = self.textOffset,
                        text = locale('drawtext.smelt'),
                    })
                else
                    local textOpen, text = lib.isTextUIOpen()
                    textOpen = textOpen and text == locale('textui.smelt')
                    if not textOpen then
                        lib.showTextUI(locale('textui.smelt'))
                    end
                end
                if IsControlJustReleased(0, config.useKey) then
                    openSmeltMenu(point.id)
                end
            else
                local textOpen, text = lib.isTextUIOpen()
                if textOpen and text == locale('textui.smelt') then
                    lib.hideTextUI()
                end
            end
        end
    end
end

lib.callback.register('red40_mining:client:playSmeltAnim', function(waitTime, currentNumber, total, anim)
    if not IsEntityPlayingAnim(cache.ped, anim.dict, anim.anim, 3) then
        lib.playAnim(cache.ped, anim.dict, anim.anim, 8.0, -8.0, -1, 0, 0, false, 0, false)
    end

    local success = lib.progressBar({
        duration = waitTime,
        label = locale('progress.smelting', currentNumber, total),
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
    local smeltPoints = lib.callback.await('red40_mining:server:getSmeltPoints')
    for i = 1, #smeltPoints do
        local smeltPoint = smeltPoints[i]
        createSmeltPoint(smeltPoint)
    end
end)