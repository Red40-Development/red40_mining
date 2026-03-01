if GetResourceState('qbx_core') ~= 'started' then return end

function Notify(text, nType)
    exports.qbx_core:Notify(text, nType)
end