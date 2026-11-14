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
-- grey on grey with red only as an outline. This own pair never changes at runtime.
RGXProf.OwnBrand = {
    primary = { 0.545, 0.082, 0.220 },
    accent  = { 0.741, 0.765, 0.780 },
}
-- The live pair every window reads. It is the own pair, or the framework's main colour while the beta theme
-- override is on; RefreshBrand rewrites the values in place so every reference held elsewhere follows.
RGXProf.Brand = {
    primary = { unpack(RGXProf.OwnBrand.primary) },
    accent  = { unpack(RGXProf.OwnBrand.accent) },
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

--- The colours and style to build with: the addon's own pair in RGX Material Round, or the framework's main
--- colour and interface style while the beta global theme override is on. Rewrites RGXProf.Brand and
--- RGXProf.BrandHex in place and returns the style id.
function RGXProf.RefreshBrand()
    local D = _G.RGXDesign
    local own, live = RGXProf.OwnBrand, RGXProf.Brand
    local theme, style
    if D and type(D.ResolveAddonTheme) == "function" then
        theme, style = D:ResolveAddonTheme(own, RGXProf.BRAND_STYLE)
    else
        -- A framework without ResolveAddonTheme: honour the saved style only while the override is on.
        local db = rawget(_G, "RGXFrameworkDB")
        if type(db) == "table" and db.themeOverride == true and type(db.style) == "string"
            and D and D.ResolveStyle then
            style = D:ResolveStyle(db.style)
        end
    end
    theme = theme or own
    local p, a = theme.primary or own.primary, theme.accent or own.accent
    live.primary[1], live.primary[2], live.primary[3] = p[1], p[2], p[3]
    live.accent[1], live.accent[2], live.accent[3] = a[1], a[2], a[3]
    RGXProf.BrandHex.primary = Hex(live.primary)
    RGXProf.BrandHex.accent = Hex(live.accent)
    return style or RGXProf.BRAND_STYLE
end

--- The interface style to build in (see RefreshBrand).
function RGXProf.ActiveStyle()
    return RGXProf.RefreshBrand()
end

--- Run a window/widget builder in RGXProfessions' theme (own pair and style, or the override's), restored
--- afterwards so no other addon is affected. Returns the builder's results. On a framework without styles the
--- builder simply runs with the framework's defaults.
function RGXProf.Themed(fn)
    local D = _G.RGXDesign
    local style = RGXProf.RefreshBrand()
    if not (D and D.WithTheme and D.WithStyle and D.ResolveStyle and D:ResolveStyle(style)) then
        return fn()
    end
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
