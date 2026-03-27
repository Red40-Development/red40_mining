Inv = nil
local function detectInventory()
    if GetResourceState('ox_inventory') == 'started' then
        Inv = 'ox_inventory'
    elseif GetResourceState('origen_inventory') == 'started' then
        Inv = 'origen_inventory'
    elseif GetResourceState('codem-inventory') == 'started' then
        Inv = 'codem-inventory'
    elseif GetResourceState('core_inventory') == 'started' then
        Inv = 'core_inventory'
    elseif GetResourceState('qs-inventory') == 'started' then
        Inv = 'qs-inventory'
    elseif GetResourceState('ps-inventory') == 'started' then
        Inv = 'ps-inventory'
    elseif GetResourceState('qb-inventory') == 'started' then
        Inv = 'qb-inventory'
    else
        lib.print.info('No supported inventory found. Item images will not be available.')
        -- Add custom inventory here
    end
end

detectInventory()

---@param xp number
---@param xpTable table
function GetXpLevel(xp, xpTable)
    local level = 1
    for i = #xpTable, 1, -1 do
        local table = xpTable[i]
        if xp >= table.xp then
            level = table.level
        else
            break
        end
    end
    return level
end

function Logger(src, type, message)
    lib.logger(src, type, message, 'red40_mining')
end

---@param src number
---@param items table
---@param coords vector3
function CustomDrop(src, items, coords)
    if Inv then
        if Inv == 'ox_inventory' then
            exports.ox_inventory:CustomDrop('Mining Drop', items, coords)
        else
            lib.print.debug('Custom drop not implemented for this inventory, using default drop')
            -- Implement custom drop for other inventories if you want
        end
    else
        lib.print.debug('No inventory found, skipping drop')
        -- Implement custom drop framework fallback if you want
    end
end

---@param source number
---@param item string
---@param amount number
---@param metadata? table
---@return boolean|nil
function AddItem(source, item, amount, metadata)
    if Inv then
        if Inv == 'ox_inventory' then
            return exports.ox_inventory:AddItem(source, item, amount, metadata)
        elseif Inv == 'core_inventory' then
            return exports.core_inventory:AddItem(source, item, amount, metadata)
        elseif Inv == 'qs-inventory' then
            return exports['qs-inventory']:AddItem(source, item, amount, metadata)
        elseif Inv == 'origen_inventory' then
            return exports.origen_inventory:AddItem(source, item, amount, metadata)
        else
            return exports[Inv]:AddItem(source, item, amount, metadata)
        end
    else
        return AddItemFramework(source, item, amount, metadata)
    end
end

---@param source number
---@param item string
---@param count number
---@return boolean|nil
function RemoveItem(source, item, count)
    if Inv then
        if Inv == 'ox_inventory' then
            return exports.ox_inventory:RemoveItem(source, item, count)
        elseif Inv == 'core_inventory' then
            return exports.core_inventory:RemoveItem(source, item, count)
        elseif Inv == 'qs-inventory' then
            return exports['qs-inventory']:RemoveItem(source, item, count)
        elseif Inv == 'origen_inventory' then
            return exports.origen_inventory:RemoveItem(source, item, count)
        else
            return exports[Inv]:RemoveItem(source, item, count)
        end
    else
        return RemoveItemFramework(source, item, count)
    end
end

---@param source number
---@param itemName string
---@return integer
function GetItemCount(source, itemName)
    if Inv then
        if Inv == 'ox_inventory' then
            return exports.ox_inventory:GetItemCount(source, itemName) or 0
        elseif Inv == 'core_inventory' then
            return exports.core_inventory:getItemCount(source, itemName)
        elseif Inv == 'qs-inventory' then
            return exports['qs-inventory']:GetItemTotalAmount(source, itemName)
        elseif Inv == 'origen_inventory' then
            return exports.origen_inventory:getItemCount(source, itemName) or 0
        else
            local itemData = exports[Inv]:GetItemByName(source, itemName)
            if not itemData then return 0 end
            return itemData.amount or itemData.count or 0
        end
    else
        return GetItemCountFramework(source, itemName)
    end
end

---@param source number
---@param item string
---@param amount number
---@param metadata? table
---@return boolean|nil
function CanCarryItem(source, item, amount, metadata)
    if Inv then
        if Inv == 'ox_inventory' then
            return exports.ox_inventory:CanCarryItem(source, item, amount, metadata)
        elseif Inv == 'core_inventory' then
            return exports.core_inventory:CanCarryItem(source, item, amount, metadata)
        elseif Inv == 'qs-inventory' then
            return exports['qs-inventory']:CanCarryItem(source, item, amount, metadata)
        elseif Inv == 'origen_inventory' then
            return exports.origen_inventory:CanCarryItem(source, item, amount, metadata)
        else
            -- If you want your inventory to not overweight players then you can implement it here
            return true
        end
    else
        return CanCarryItemFramework(source, item, amount, metadata)
    end
end

---@param source number
---@param itemName string
---@param durability number
---@return boolean|nil
function RemoveItemDurability(source, itemName, durability)
    if Inv then
        if Inv == 'ox_inventory' then
            local slot = exports.ox_inventory:GetSlotWithItem(source, itemName)
            if not slot then return false end
            return exports.ox_inventory:SetDurability(source, slot.slot, (slot.metadata.durability - durability))
        elseif Inv == 'core_inventory' then
            return exports.core_inventory:removeDurability(source, itemName, durability)
        elseif Inv == 'qs-inventory' then
            -- Not supported?
            return true
        elseif Inv == 'origen_inventory' then
            -- Not supported?
            return true
        else
            -- Implement for other inventories if you want
            return false
        end
    else
        return false -- Implement framework fallback if you want
    end
end