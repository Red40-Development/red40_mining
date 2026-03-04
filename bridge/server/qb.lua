if GetResourceState('qb-core') ~= 'started' or GetResourceState('qbx_core') == 'started' then return end


QBCore = exports['qb-core']:GetCoreObject()

--- Get player object by ID
---@param source number Player source ID
---@return any Player object or nil if not found
function GetPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

---Notify player
---@param src number Player source ID
---@param text string Notification text
---@param nType string Notification type (e.g., 'success', 'error', 'info
function Notify(src, text, nType)
    TriggerClientEvent('QBCore:Notify', src, text, nType)
end

function AddMoney(Player, moneyType, amount)
    Player.Functions.AddMoney(moneyType, amount, "redwire-sale")
end

function AddItems(src, items, coords)
    local player = GetPlayer(src)
    if not player then return end
    for item, data in pairs(items) do
        local amount = data.amount or 1
        local metadata = data.metadata or {}
        player.Functions.AddItem(item, amount, metadata)
    end
end

function AddXp(src, amount, type)
    local player = GetPlayer(src)
    local metadataKey = 'red40_mining' .. type
    if player then
        player.Functions.SetMetaData(metadataKey, (player.PlayerData.metadata[metadataKey] or 0) + amount)
    end
end

function GetXp(src, type)
    local player = GetPlayer(src)
    local metadataKey = 'red40_mining' .. type
    if player then
        return player.PlayerData.metadata[metadataKey] or 0
    end
    return 0
end

function CheckDuty()
    local dutyCount = 0
    local leoJobs = { 'police', 'bcso' } -- Add your police jobs here...
    for _, job in ipairs(leoJobs) do
        dutyCount = dutyCount + QBCore.Functions.GetDutyCount(job)
    end
    return dutyCount
end