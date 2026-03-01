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

function CheckDuty()
    local dutyCount = 0
    local leoJobs = { 'police', 'bcso' } -- Add your police jobs here...
    for _, job in ipairs(leoJobs) do
        dutyCount = dutyCount + QBCore.Functions.GetDutyCount(job)
    end
    return dutyCount
end