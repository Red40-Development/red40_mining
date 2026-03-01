if GetResourceState('es_extended') ~= 'started' then return end

ESX = exports['es_extended']:getSharedObject()

function GetPlayer(source)
    return ESX.GetPlayerFromId(source)
end

function Notify(src, text, type)
    TriggerClientEvent('esx:showNotification', src, text, type or 'inform')
end

function AddMoney(xPlayer, moneyType, amount)
    local account = moneyType == 'cash' and 'money' or moneyType
    xPlayer.addAccountMoney(account, amount, "redwire-sale")
end

function CheckDuty()
    local amount = 0
    local players = ESX.GetExtendedPlayers()
    for i = 1, #players do
        local xPlayer = players[i]
        if xPlayer.job.name == 'police' then
            amount += 1
        end
    end
    return amount
end