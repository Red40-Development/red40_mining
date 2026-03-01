if GetResourceState('qb-core') ~= 'started' or GetResourceState('qbx_core') == 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

function Notify(text, nType)
    QBCore.Functions.Notify(text, nType)
end