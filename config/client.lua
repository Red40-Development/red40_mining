return {
    use3dText = true, -- Set to true to enable 3D text prompts at ore locations, false for textui
    useKey = 38, -- The control key to use for action prompts (default is E) -- https://docs.fivem.net/docs/game-references/controls/#controls
    useKey2 = 23, -- The control key to use for action prompts (default is F) -- https://docs.fivem.net/docs/game-references/controls/#controls
    miningTarget = true, -- True removes prompts and adds target interactions for mining locations
    smeltingTarget = true, -- True removes prompts and adds target interactions for smelting locations
    craftingTarget = true, -- True removes prompts and adds target interactions for crafting locations
    useTarget = false, -- Set to true to enable target interactions for peds
    addLocalEntityTarget = function(entity, options)
        exports.ox_target:addLocalEntity(entity, options)
    end,
    removeLocalEntityTarget = function(entity, optionName)
        exports.ox_target:removeLocalEntity(entity, optionName)
    end,
}