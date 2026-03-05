return {
    use3dText = true, -- Set to true to enable 3D text prompts at ore locations, false for textui
    useTarget = true, -- Set to true to enable target interactions for peds
    useKey = 38, -- The control key to use for action prompts (default is E) -- https://docs.fivem.net/docs/game-references/controls/#controls
    useKey2 = 23, -- The control key to use for action prompts (default is F) -- https://docs.fivem.net/docs/game-references/controls/#controls
    addLocalEntityTarget = function(entity, options)
        exports.ox_target:addLocalEntity(entity, options)
    end,
    removeLocalEntityTarget = function(entity, optionName)
        exports.ox_target:removeLocalEntity(entity, optionName)
    end,
}