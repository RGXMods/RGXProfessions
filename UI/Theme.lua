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

-- The addon's brand, registered with the framework: it answers with the own pair and Material Round, or with
-- the framework's main colour and interface style while the beta global theme override is on, and it tells
-- RGXProfessions when that changes so open windows are redrawn without a reload.
local function BrandObject()
    local D = _G.RGXDesign
    if not RGXProf.BrandObj and D and type(D.RegisterBrand) == "function" then
        RGXProf.BrandObj = D:RegisterBrand("RGXProfessions", RGXProf.OwnBrand, RGXProf.BRAND_STYLE)
        RGXProf.BrandObj:OnChange(function()
            RGXProf.RefreshBrand()
            if RGXProf.BookWindow and RGXProf.BookWindow.Rebuild then RGXProf.BookWindow:Rebuild() end
            if RGXProf.MatsWindow and RGXProf.MatsWindow.Rebuild then RGXProf.MatsWindow:Rebuild() end
        end)
    end
    return RGXProf.BrandObj
end
RGXProf.GetBrand = BrandObject

--- Rewrite RGXProf.Brand and RGXProf.BrandHex in place from the brand (so every held reference follows) and
--- return the style id to build in.
function RGXProf.RefreshBrand()
    local brand = BrandObject()
    local own, live = RGXProf.OwnBrand, RGXProf.Brand
    local theme, style
    if brand then theme, style = brand:Resolve() end
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

--- Run a window/widget builder in RGXProfessions' brand (colours and style, restored afterwards). Panels and
--- dropdowns built inside follow theme changes live. Returns the builder's results.
function RGXProf.Themed(fn)
    RGXProf.RefreshBrand()
    local brand = BrandObject()
    if not brand then return fn() end
    return brand:Build(fn)
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
