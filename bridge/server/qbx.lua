if GetResourceState('qbx_core') ~= 'started' then return end

function GetPlayer(source)
    return exports.qbx_core:GetPlayer(source)
end

function Notify(source, message, type)
    exports.qbx_core:Notify(source, message, type or 'inform')
end

function AddMoney(Player, moneyType, amount)
    Player.Functions.AddMoney(moneyType, amount, "redwire-sale")
end

function CheckDuty()
    return exports.qbx_core:GetDutyCountType('leo')
end