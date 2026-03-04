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