Inv = nil
Items = nil
local function detectInventory()
    if GetResourceState('ox_inventory') == 'started' then
        Inv = 'ox_inventory'
        Items = exports.ox_inventory:Items()
    elseif GetResourceState('origen_inventory') == 'started' then
        Inv = 'origen_inventory'
        Items = exports.origen_inventory:Items()
    elseif GetResourceState('codem-inventory') == 'started' then
        Inv = 'codem-inventory'
        Items = exports['codem-inventory']:GetItemList()
    elseif GetResourceState('core_inventory') == 'started' then
        Inv = 'core_inventory'
        Items = exports.core_inventory:getItemsList()
    elseif GetResourceState('qs-inventory') == 'started' then
        Inv = 'qs-inventory'
        Items = exports['qs-inventory']:GetItemList()
    elseif GetResourceState('ps-inventory') == 'started' then
        Inv = 'ps-inventory'
        Items = exports['qb-core']:GetCoreObject().Shared.Items
    elseif GetResourceState('qb-inventory') == 'started' then
        Inv = 'qb-inventory'
        Items = exports['qb-core']:GetCoreObject().Shared.Items
    else
        lib.print.info('No supported inventory found. Item images will not be available.')
        -- Add custom inventory here
    end
end

detectInventory()

function ItemImageURL(item)
    if Inv == 'ox_inventory' then
        return 'nui://ox_inventory/web/images/' .. (Items[item] and Items[item].image or item .. '.png')
    elseif Inv == 'core_inventory' then
        return 'nui://core_inventory/html/img/' .. (Items[item] and Items[item].image or item .. '.png')
    elseif Inv == 'origen_inventory' then
        return 'nui://origen_inventory/html/images/' .. (Items[item] and Items[item].image or item .. '.png')
    elseif Inv == 'codem-inventory' then
        return 'nui://codem-inventory/html/itemimages/' .. (Items[item] and Items[item].image or item .. '.png')
    elseif Inv == 'qs-inventory' then
        return 'nui://qs-inventory/html/images/' .. (Items[item] and Items[item].image or item .. '.png')
    elseif Inv == 'ps-inventory' then
        return 'nui://ps-inventory/html/images/' .. (Items[item] and Items[item].image or item .. '.png')
    elseif Inv == 'qb-inventory' then
        return 'nui://qb-inventory/html/images/' .. (Items[item] and Items[item].image or item .. '.png')
    else
        return nil -- No image available for other inventories
    end
end