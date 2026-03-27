local enabled = require 'config.shared'.smelting

if not enabled then
    return
end

local config = require 'config.server'.smelting

local smeltPoints = {}

local function getRecipe(recipeTable, recipeId)
    for _, recipeList in pairs(recipeTable) do
        local recipes = config.recipes[recipeList]
        for i = 1, #recipes do
            local recipe = recipes[i]
            if recipe.id == recipeId then
                return recipe
            end
        end
    end
end


RegisterNetEvent('red40_mining:server:smeltItem', function(smeltPointId, recipeId, amount)
    local src = source

    local smeltPoint = smeltPoints[smeltPointId]
    if not smeltPoint then return end

    --Distance check
    local pedCoords = GetEntityCoords(GetPlayerPed(src))
    if #(pedCoords - smeltPoint.coords) > 5.0 then
        Notify(src, locale('error.not_in_smelt_point'), 'error')
        return
    end

    local recipe = getRecipe(smeltPoint.smelts, recipeId)
    if not recipe then return end

    --Check if player has required items
    for itemName, requiredAmount in pairs(recipe.input) do
        local itemCount = GetItemCount(src, itemName)
        if itemCount < (requiredAmount * amount) then
            Notify(src, locale('error.not_enough_items'), 'error')
            return
        end
    end

    --Remove required items
    for itemName, requiredAmount in pairs(recipe.input) do
        local removeItem = RemoveItem(src, itemName, requiredAmount * amount)
        if not removeItem then
            Notify(src, locale('error.not_enough_items'), 'error')
            return
        end
    end

    -- For multicrafts we loop until the amount to prevent gamers and let people quit mid craft
    for i = 1, amount do

        -- calculate wait time for each craft for mah immersion
        local waitTime = math.random(smeltPoint.minUseTime, smeltPoint.maxUseTime)


        --Trigger callback for animation
        local success = lib.callback.await('red40_mining:client:playSmeltAnim', src, waitTime, i, amount, smeltPoint.anim)

        -- distance check
        pedCoords = GetEntityCoords(GetPlayerPed(src))
        if #(pedCoords - smeltPoint.coords) > 5.0 then
            Notify(src, locale('error.not_in_smelt_point'), 'error')
            return
        end

        if success then
            local excessItems = {}
            for outputItem, outputAmount in pairs(recipe.output) do
                if not CanCarryItem(src, outputItem, outputAmount) then
                    excessItems[#excessItems + 1] = { outputItem, outputAmount }
                else
                    AddItem(src, outputItem, outputAmount)
                end
            end
            if excessItems and next(excessItems) then
                CustomDrop(src, excessItems, pedCoords)
            end
            AddXp(src, config.xpPerAction(), 'smelting')
        else
            Notify(src, locale('error.craft_cancelled'), 'error')
            return
        end
    end
end)

lib.callback.register('red40_mining:server:getSmeltableItems', function(source, smeltPointId)
    local smeltPoint = smeltPoints[smeltPointId]
    if not smeltPoint then return end

    local pedCoords = GetEntityCoords(GetPlayerPed(source))
    if #(pedCoords - smeltPoint.coords) > 5.0 then
        Notify(source, locale('error.not_in_smelt_point'), 'error')
        return
    end

    local playerXp = GetXp(source, 'smelting') or 0
    local playerLevel = GetXpLevel(playerXp, config.xpTables) or 0

    local smeltableItems = {}
    for _, recipeTable in pairs(smeltPoint.smelts) do
        local recipes = config.recipes[recipeTable]
        if not recipes then return end

        for i = 1, #recipes do
            local recipe = recipes[i]
            local canCraft = true
            local maxCrafts = math.huge
            for itemName, requiredAmount in pairs(recipe.input) do
                local itemCount = GetItemCount(source, itemName)
                if playerLevel < recipe.level then
                    canCraft = false
                    break
                elseif itemCount < requiredAmount then
                    canCraft = false
                    break
                else
                    local crafts = math.floor(itemCount / requiredAmount)
                    if crafts < maxCrafts then
                        maxCrafts = crafts
                    end
                end
            end
            if canCraft then
                smeltableItems[#smeltableItems + 1] = {
                    ---@diagnostic disable-next-line: inject-field
                    recipeId = recipe.id,
                    input = recipe.input,
                    output = recipe.output,
                    maxAmount = maxCrafts,
                }
            end
        end
    end
    return smeltableItems
end)

lib.callback.register('red40_mining:server:getSmeltPoints', function(_)
    return smeltPoints
end)

local function buildSmeltPoints()
    local smeltCount = 1
    for i = 1, #config.locations do
        local location = config.locations[i]
        if location.enabled then
            for j = 1, #location.locations do
                local smeltLocation = location.locations[j]
                local smeltPoint = {
                    id = smeltCount,
                    coords = smeltLocation.coords,
                    prop = location.prop,
                    rot = smeltLocation.rotation,
                    anim = location.anim,
                    blip = location.blip,
                    smelts = location.smelts,
                    minUseTime = location.minUseTime,
                    maxUseTime = location.maxUseTime,
                }
                smeltPoints[smeltCount] = smeltPoint
                smeltCount = smeltCount + 1
            end
        end
    end
end

local function tagSmeltRecipes()
    local recipeCount = 1
    for _, recipes in pairs(config.recipes) do
        for i = 1, #recipes do
            local recipe = recipes[i]
            ---@diagnostic disable-next-line: inject-field
            recipe.id = recipeCount
            recipeCount = recipeCount + 1
        end
    end
end

CreateThread(function()
    buildSmeltPoints()
    tagSmeltRecipes()
end)