--- Modified from original source (https://github.com/Renewed-Scripts/Renewed-Lib/blob/main/modules/loot/server.lua)
--- License GPL-3.0
--- Copyright (C) 2024 Renewed Scripts.

local lootTables = {}

---register loot table
---@param id string
---@param data table
function RegisterLootTable(id, data)
    if not id or not data then return end

    data = table.type(data) == 'array' and data or { data }
    local reverseSort = false
    table.sort(data, function(a, b)
        if reverseSort then
            return a.chance > b.chance
        else
            return a.chance < b.chance
        end
    end)

    for i = 1, #data do
        local item = data[i]
        if not item.name or not item.chance or not item.level or not item.min or not item.max then
            lib.print.error('Invalid loot table id: ' .. id .. ' item: ' .. tostring(item))
        end
    end

    lootTables[id] = data
    -- return data
end

---Get the amount of items the player should recieve
---@param item table
---@return integer
local function getAmount(item)
    return item.amount or (item.min and item.max and math.random(item.min, item.max)) or 1
end

---Generate loot
---@param id string
---@param minLoot integer
---@param maxLoot integer
---@param xpLevel integer
---@return table<string, {amount: integer, metadata: table?}>?
function GenerateLoot(lootTableName, minLoot, maxLoot, xpLevel)
    local lootTable = lootTables[lootTableName]

    if not lootTable or not next(lootTable) then
        return
    end

    local loot = {}
    local lootAmount = 0

    for i = 1, #lootTable do
        local item = lootTable[i]
        if item.level and item.level > xpLevel then
            -- Skip items that are above the player's level
        else
            local chance = math.random()

            if chance <= item.chance then
                local amount = getAmount(item)

                if amount and amount > 0 then
                    lootAmount += 1
                    loot[item.name] = {
                        amount = amount,
                        metadata = item.metadata or nil
                    }

                    if maxLoot and lootAmount >= maxLoot then
                        break
                    end
                end
            end
        end
    end

    if minLoot and lootAmount < minLoot then
        return GenerateLoot(lootTable, minLoot, maxLoot, xpLevel)
    end

    return loot
end