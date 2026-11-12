--=====================================================================================
-- RGXProfessions - UI/Theme.lua
-- RGXProfessions is branded by two colours and nothing else: its primary and its accent. The framework
-- pipes that pair into the "RGX Material Round" interface style (rounded cards, header bands and
-- buttons on grey, the primary as the panel ring, the accent as card titles), so this addon draws no
-- panels or buttons of its own. Everything it builds goes through RGXProf.Themed.
--=====================================================================================

RGXProf = RGXProf or {}

-- The addon's brand pair (user-defined, per mod): RGX red #8B1538 for rings and bars, and a light grey
-- (#BDC3C7, the Breeze "cloud" grey used across KDE Plasma) for titles and highlights, so the look is
-- grey on grey with red only as an outline.
RGXProf.Brand = {
    primary = { 0.545, 0.082, 0.220 },
    accent  = { 0.741, 0.765, 0.780 },
}

local function Hex(c)
    return string.format("|cff%02X%02X%02X", math.floor(c[1] * 255 + 0.5), math.floor(c[2] * 255 + 0.5), math.floor(c[3] * 255 + 0.5))
end
RGXProf.BrandHex = { primary = Hex(RGXProf.Brand.primary), accent = Hex(RGXProf.Brand.accent) }

--- "RGX | Professions": RGX in the RGX red, a white pipe, the product name in white. In a WoW string a literal
--- pipe is written "||" - a single "|" starts an escape. The pipe pair is followed by a space and the name, never
--- by a colour reset, so no "|r" sits against the pipes (that sequence showed "|r" in the header titles).
function RGXProf.BrandTitle(name)
    return RGXProf.BrandHex.primary .. "RGX|r |cffffffff|| " .. (name or "Professions") .. "|r"
end
RGXProf.BRAND_STYLE = "materialround"   -- the addon's own look, used unless the operator chose another style

--- The interface style to build in: the one chosen on the RGX-Framework settings page (Theme tab) while
--- "Apply the framework theme to addons" is on, otherwise RGX Material Round. The brand colours stay the
--- addon's own in every style.
function RGXProf.ActiveStyle()
    local D = _G.RGXDesign
    local db = rawget(_G, "RGXFrameworkDB")
    if type(db) == "table" and db.themeOverride ~= false and type(db.style) == "string"
        and D and D.ResolveStyle then
        local id = D:ResolveStyle(db.style)
        if id then return id end
    end
    return RGXProf.BRAND_STYLE
end

--- Run a window/widget builder in RGXProfessions' theme: its own primary/accent in the framework's
--- RGX Material Round style, restored afterwards so no other addon is affected. Returns the builder's
--- results. On a framework without styles the builder simply runs with the framework's defaults.
function RGXProf.Themed(fn)
    local D = _G.RGXDesign
    if not (D and D.WithTheme and D.WithStyle and D.ResolveStyle and D:ResolveStyle(RGXProf.BRAND_STYLE)) then
        return fn()
    end
    local style = RGXProf.ActiveStyle()
    local r1, r2
    D:WithTheme(RGXProf.Brand, function()
        D:WithStyle(style, function() r1, r2 = fn() end)
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
