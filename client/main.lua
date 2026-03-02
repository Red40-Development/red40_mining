function DrawText3d(params) -- luacheck: ignore
    local isScaleparamANumber = type(params.scale) == "number"
    local text = params.text
    local coords = params.coords
    local scale = (isScaleparamANumber and vec2(params.scale, params.scale))
        or params.scale
        or vec2(0.35, 0.35)
    local font = params.font or 4
    local color = params.color or vec4(255, 255, 255, 255)
    local enableDropShadow = params.enableDropShadow or true
    local enableOutline = params.enableOutline or false

    SetTextScale(scale.x, scale.y)
    SetTextFont(font)
    SetTextColour(math.floor(color.r), math.floor(color.g), math.floor(color.b), math.floor(color.a))
    if enableDropShadow then
        SetTextDropShadow()
    end
    if enableOutline then
        SetTextOutline()
    end
    SetTextCentre(true)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    EndTextCommandDisplayText(0.0, 0.0)

    ClearDrawOrigin()
end