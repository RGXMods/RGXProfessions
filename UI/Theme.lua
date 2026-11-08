--=====================================================================================
-- RGXProfessions - UI/Theme.lua
-- RGXProfessions is branded by two colours and nothing else: its primary and its accent. The framework
-- pipes that pair into the "RGX Material Round" interface style (rounded cards, header bands and
-- buttons on grey, the primary as the panel ring, the accent as card titles), so this addon draws no
-- panels or buttons of its own. Everything it builds goes through RGXProf.Themed.
--=====================================================================================

RGXProf = RGXProf or {}

-- The addon's brand pair (user-defined, per mod): RGX red #8B1538 and its readable coral tint #ED6B85.
RGXProf.Brand = {
    primary = { 0.545, 0.082, 0.220 },
    accent  = { 0.929, 0.420, 0.522 },
}
RGXProf.BRAND_STYLE = "materialround"

--- Run a window/widget builder in RGXProfessions' theme: its own primary/accent in the framework's
--- RGX Material Round style, restored afterwards so no other addon is affected. Returns the builder's
--- results. On a framework without styles the builder simply runs with the framework's defaults.
function RGXProf.Themed(fn)
    local D = _G.RGXDesign
    if not (D and D.WithTheme and D.WithStyle and D.ResolveStyle and D:ResolveStyle(RGXProf.BRAND_STYLE)) then
        return fn()
    end
    local r1, r2
    D:WithTheme(RGXProf.Brand, function()
        D:WithStyle(RGXProf.BRAND_STYLE, function() r1, r2 = fn() end)
    end)
    return r1, r2
end

--- The framework's rounded panel texture (for the few hand-drawn nine-slice pieces).
function RGXProf.PanelTexture()
    local D = _G.RGXDesign
    return (D and D.PANEL_TEX) or "Interface\\AddOns\\RGX-Framework\\libraries\\design\\panel_rounded.tga"
end

--- A button in the active framework style (rounded in Material Round).
function RGXProf.NewButton(parent, text, width, height)
    return RGXProf.Themed(function()
        return _G.RGXDesign:CreateButton(parent, text, width, height)
    end)
end
