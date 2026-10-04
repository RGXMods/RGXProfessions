--=====================================================================================
-- RGXProfessions - UI/BookWindow.lua
-- RGX Professions: a two-pane browser with a difficulty-colored
-- step list, live skill tracking, and a detail pane with materials, vendors,
-- and trainers for the selected step.
--=====================================================================================

RGXProf = RGXProf or {}
RGXProf.BookWindow = RGXProf.BookWindow or {}

local Design = _G.RGXDesign

local WINDOW_WIDTH = 720
local WINDOW_HEIGHT = 470
local LIST_WIDTH = 250
local ROW_HEIGHT = 20
local BANNER_HEIGHT = 22
local HEADER_HEIGHT = 60

local BRAND_BORDER = { 0.545, 0.082, 0.220 } -- RGX crimson #8B1538
local BRAND_RGB = BRAND_BORDER -- accents share the brand crimson

--------------------------------------------------------------------------------
-- Textures: this Forever beta client is inconsistent across builds - some
-- accept positional SetColorTexture(r,g,b[,a]) / SetVertexColor(r,g,b[,a]),
-- others only accept a single Color object, and CreateColor may be present
-- or absent. SetTextureColor probes each strategy once (cached per
-- texture) via pcall and uses the first that succeeds, so EnsureFrame -
-- which runs at first Show - never aborts on a color call. A plain white
-- texture colored via SetVertexColor is equivalent to a solid fill.
local function SetTextureColor(tex, r, g, b, a)
    if not tex or (not tex.SetColorTexture and not tex.SetVertexColor) then return end
    a = a or 1
    local key = rawget(tex, "__rgxColorMethod") or 0
    if key == 0 then
        local c = CreateColor and CreateColor(r, g, b, a)
        local opts = {
            function() tex:SetColorTexture(r, g, b, a) end,
            function() tex:SetColorTexture(r, g, b) end,
            function() tex:SetVertexColor(r, g, b, a) end,
            function() tex:SetVertexColor(r, g, b) tex:SetAlpha(a) end,
        }
        if c then
            table.insert(opts, function() tex:SetColorTexture(c) end)
            table.insert(opts, function() tex:SetVertexColor(c) end)
        end
        for i, fn in ipairs(opts) do
            if pcall(fn) then rawset(tex, "__rgxColorMethod", i) key = i break end
        end
        if key == 0 then rawset(tex, "__rgxColorMethod", -1) end
    end

    local c = CreateColor and CreateColor(r, g, b, a)
    if key == 1 then pcall(tex.SetColorTexture, tex, r, g, b, a)
    elseif key == 2 then pcall(tex.SetColorTexture, tex, r, g, b)
    elseif key == 3 then pcall(tex.SetVertexColor, tex, r, g, b, a)
    elseif key == 4 then pcall(tex.SetVertexColor, tex, r, g, b) pcall(tex.SetAlpha, tex, a)
    elseif key == 5 and c then pcall(tex.SetColorTexture, tex, c)
    elseif key == 6 and c then pcall(tex.SetVertexColor, tex, c)
    else pcall(tex.SetColorTexture, tex, r, g, b, a) end
end

--------------------------------------------------------------------------------
-- Colours / text helpers
--------------------------------------------------------------------------------

local function C(key)
    if Design then
        local r, g, b = Design:Unpack(key)
        return string.format("|cff%02x%02x%02x", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
    end
    return "|cffffffff"
end
-- Brand highlight: the same crimson as the RGX mark, the version text,
-- and the window border - deliberately NOT the active theme's primary.
local function Accent() return "|cff8B1538" end
local function Text() return "|cffffffff" end
local function Dim() return C("subtext") end
local function Label() return C("label") end

local DIFF_WORDS = {
    optimal = { text = "Orange · always skill-ups", key = "warning" },
    medium  = { text = "Yellow · usually a skill-up", key = "accent" },
    easy    = { text = "Green · rarely a skill-up", key = "success" },
    trivial = { text = "Gray · no skill-ups", key = "label" },
}

-- Rank gates: crossing a skill cap like 75 requires training the next rank.
-- Derived from Constants.TierLabels so every expansion tracks its own cadence.
local function BuildRankGates()
    local gates = {}
    local labels = RGXProf.Constants and RGXProf.Constants.TierLabels
    if not labels then return gates end

    local sorted = {}
    for cap in pairs(labels) do table.insert(sorted, cap) end
    table.sort(sorted)

    for i, cap in ipairs(sorted) do
        local nextCap = sorted[i + 1]
        if nextCap then
            table.insert(gates, { cap = cap, rank = labels[nextCap], extendsTo = nextCap })
        end
    end
    return gates
end

-- Next rank gate above the current skill (for the header "when to upgrade" text).
local function NextGate(skill)
    for _, gate in ipairs(BuildRankGates()) do
        if not skill or skill < gate.cap then return gate end
    end
    return nil
end

--------------------------------------------------------------------------------
-- Data helpers
--------------------------------------------------------------------------------

local function GetGuideProfessions()
    local list = {}
    if not (RGXProf.currentExpansion and RGXProf.currentExpansion.paths and RGXProf.Constants and RGXProf.Constants.Professions) then
        return list
    end
    for _, professionID in ipairs(RGXProf.Constants.ProfessionOrder) do
        if RGXProf.currentExpansion.paths[professionID] and RGXProf.Constants.Professions[professionID] then
            table.insert(list, professionID)
        end
    end
    return list
end

local function LiveSkill(professionID)
    if not (RGXProf.WowAPI and RGXProf.WowAPI.GetProfessionSkill) then return nil, nil end
    local prof = RGXProf.Constants.Professions[professionID]
    if not prof then return nil, nil end
    local earned, total = RGXProf.WowAPI:GetProfessionSkill(prof.name)
    return earned, total
end

local function MaxSkill()
    return (RGXProf.currentExpansion and RGXProf.currentExpansion.maxSkill) or 300
end

-- First non-alternate step covering the current skill; else last step below
-- the skill; else step 1.
local function FindCurrentIndex(path, skill)
    if not skill then return 1 end
    local best
    for i, step in ipairs(path) do
        if not step.alternate and skill >= step.minSkill and skill < step.maxSkill then
            return i
        end
        if not step.alternate and step.minSkill <= skill then
            best = i
        end
    end
    return best or 1
end

-- Difficulty of a step relative to the player's live skill. Uses the recipe's
-- known threshold table when available; otherwise infers from step range.
local function StepDifficulty(step, skill)
    if not skill then return nil end
    -- Prefer the step's own skill-up colors: Forever beta steps carry
    -- thresholds that differ from the global (Classic) spell table.
    local y, g, r
    if step.colors then
        y, g, r = step.colors.y, step.colors.g, step.colors.r
    else
        local thresholds = RGXProf.Data and RGXProf.Data.Skill and step.spellID and RGXProf.Data.Skill[step.spellID]
        if thresholds then
            y, g, r = thresholds.y, thresholds.g, thresholds.r
        end
    end
    if y and g and r then
        local eff = math.max(step.minSkill, skill)
        if eff < y then return "optimal" end
        if eff < g then return "medium" end
        if eff < r then return "easy" end
        return "trivial"
    end
    if skill < step.minSkill then return "optimal" end
    if skill >= step.maxSkill then return "trivial" end
    return nil
end

local function DiffColorHex(diffKey)
    if diffKey and RGXProf.Constants.SkillUpColors[diffKey] then
        local c = RGXProf.Constants.SkillUpColors[diffKey]
        return string.format("|cff%02x%02x%02x", math.floor(c.r * 255), math.floor(c.g * 255), math.floor(c.b * 255))
    end
    return Text()
end

-- Header-only addon title: the first letter of each word carries the
-- brand highlight; the rest keeps the font's default color.
local function StyledHeaderTitle(text)
    local words = {}
    for word in text:gmatch("%S+") do
        words[#words + 1] = Accent() .. word:sub(1, 1) .. "|r" .. word:sub(2)
    end
    return table.concat(words, " ")
end
local HEADER_TITLE = StyledHeaderTitle("Profession Leveling Guide")

-- Real in-game tooltip for a guide step: the crafted item when the step
-- carries an itemID, otherwise the craft spell. SetHyperlink renders true
-- client tooltips on every supported flavor.
local function ShowStepTooltip(owner, step)
    if not step then return end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    -- Prefer the crafted ITEM tooltip; fall back to the recipe spell
    -- only when there is no item to show.
    local shown = false
    if step.itemID then
        if GameTooltip.SetItemByID then
            shown = pcall(GameTooltip.SetItemByID, GameTooltip, step.itemID)
        end
        if not shown then
            shown = pcall(GameTooltip.SetHyperlink, GameTooltip, "item:" .. step.itemID)
        end
    end
    if not shown and step.spellID then
        shown = pcall(GameTooltip.SetHyperlink, GameTooltip, "spell:" .. step.spellID)
    end
    if shown then
        GameTooltip:Show()
    else
        GameTooltip:Hide()
    end
end

-- Recipe-list hover: required materials with inline icons, rendered in the
-- same format as the page's Materials card (live have/need bag counts).
local function ShowStepMaterials(owner, step)
    if not step then return end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    -- Title carries the step's difficulty color, matching its list row.
    local skill
    if RGXProf.BookWindow and RGXProf.BookWindow.GetCurrentProfession then
        local profID = RGXProf.BookWindow:GetCurrentProfession()
        if profID then skill = LiveSkill(profID) end
    end
    local diff = StepDifficulty(step, skill)
    local dc = diff and RGXProf.Constants and RGXProf.Constants.SkillUpColors
        and RGXProf.Constants.SkillUpColors[diff]
    if dc then
        GameTooltip:SetText(step.name or "Recipe", dc.r, dc.g, dc.b)
    else
        GameTooltip:SetText(step.name or "Recipe", 1, 1, 1)
    end

    local crafts
    if RGXProf.DataManager and RGXProf.DataManager.GetEstimatedCrafts then
        local ok, result = pcall(RGXProf.DataManager.GetEstimatedCrafts, RGXProf.DataManager, step.minSkill, step)
        if ok and result and result > 0 and result < math.huge then crafts = result end
    end
    if crafts then
        GameTooltip:AddLine(string.format("Craft about %d", crafts), 0.6, 0.6, 0.6)
    end

    local reagents = {}
    if step.spellID and RGXProf.DataManager and RGXProf.DataManager.GetReagentListWithDetails then
        local okR, list = pcall(RGXProf.DataManager.GetReagentListWithDetails, RGXProf.DataManager, step.spellID, crafts or 1)
        if okR and type(list) == "table" then reagents = list end
    end
    for _, reagent in ipairs(reagents) do
        local icon = reagent.icon and ("|T" .. reagent.icon .. ":14:14:0:0|t ") or ""
        local have = tonumber(reagent.onHandCount) or 0
        local need = tonumber(reagent.requiredCount) or 0
        local haveHex = (have >= need) and C("success") or C("warning")
        GameTooltip:AddLine(string.format("%s%s%d%sx %s %s(%d/%d)", icon, Text(), need, Dim(), reagent.name or tostring(reagent.itemID), haveHex, have, need), 1, 1, 1)
    end
    if #reagents == 0 then
        GameTooltip:AddLine(Dim() .. "No reagent data for this step.", 0.6, 0.6, 0.6)
    end
    GameTooltip:Show()
end

local function SelectedPage(professionID)
    local path = RGXProf.currentExpansion.paths[professionID]
    local page = RGXProf_Settings.bookPage
    if type(page) ~= "number" or page < 1 or page > #path then
        local skill = LiveSkill(professionID)
        page = FindCurrentIndex(path, skill)
        RGXProf_Settings.bookPage = page
    end
    return page
end

--------------------------------------------------------------------------------
-- Frame
--------------------------------------------------------------------------------

function RGXProf.BookWindow:EnsureFrame()
    if self.frame then return end

    local f = Design:CreateFrame(UIParent, {
        width = WINDOW_WIDTH,
        height = WINDOW_HEIGHT,
    })
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetClampedToScreen(true)
    f:SetFrameStrata("HIGH")
    f:SetToplevel(true)
    f:SetScript("OnDragStart", function(s) s:StartMoving() end)
    f:SetScript("OnDragStop", function(s)
        s:StopMovingOrSizing()
        local point, relFrame, relPoint, x, y = s:GetPoint()
        RGXProf_Settings.bookPosition = { point, relFrame, relPoint, x, y }
    end)

    -- Resizable window: a bottom-right grip sizes the frame with a manual
    -- drag (SetSize + TOPLEFT pinning each update) because the beta client
    -- does not expose the native frame resize family (SetMinResize is nil
    -- there); clamped 640x420..1400x1000 and persisted to
    -- RGXProf_Settings.bookSize. Every content region below the header is
    -- anchor-driven so the layout reflows.
    local savedSize = RGXProf_Settings and RGXProf_Settings.bookSize
    if type(savedSize) == "table" and type(savedSize[1]) == "number" and type(savedSize[2]) == "number" then
        f:SetSize(savedSize[1], savedSize[2])
    end
    f.sizer = CreateFrame("Button", nil, f)
    f.sizer:SetSize(16, 16)
    f.sizer:SetPoint("BOTTOMRIGHT", -2, 2)
    f.sizer:RegisterForDrag("LeftButton")
    f.sizer:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    f.sizer:SetScript("OnDragStart", function(s)
        s._scale = f:GetEffectiveScale()
        s._left = f:GetLeft()
        s._top = f:GetTop()
        s:SetScript("OnUpdate", function(self)
            local mx, my = GetCursorPosition()
            local w = mx / self._scale - self._left
            local h = self._top - my / self._scale
            if w < 640 then w = 640 elseif w > 1400 then w = 1400 end
            if h < 420 then h = 420 elseif h > 1000 then h = 1000 end
            f:ClearAllPoints()
            f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self._left, self._top)
            f:SetSize(w, h)
        end)
    end)
    f.sizer:SetScript("OnDragStop", function(s)
        s:SetScript("OnUpdate", nil)
        RGXProf_Settings.bookSize = { f:GetWidth(), f:GetHeight() }
    end)
    f.sizer:SetScript("OnEnter", function(s)
        GameTooltip:SetOwner(s, "ANCHOR_LEFT")
        GameTooltip:SetText("Resize")
        GameTooltip:Show()
    end)
    f.sizer:SetScript("OnLeave", function() GameTooltip:Hide() end)
    -- ESC closes the window; every other key propagates so chat stays
    -- usable while the book is open. UISpecialFrames only works for named
    -- frames and Design:CreateFrame builds unnamed ones, so handle the key
    -- directly. If the client lacks key propagation, keep chat working by
    -- not enabling the keyboard hook at all (the close button remains).
    f:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:Hide()
            if self.SetPropagateKeyboardInput then
                self:SetPropagateKeyboardInput(false)
            end
        elseif self.SetPropagateKeyboardInput then
            self:SetPropagateKeyboardInput(true)
        end
    end)
    if f.SetPropagateKeyboardInput then
        f:EnableKeyboard(true)
    end

    -- Brand border: RGX crimson frame ring
    if f.SetPanelColor then
        f:SetPanelColor(nil, BRAND_BORDER)
    end

    -- Traditional RGXMods header: dark band, accent line, logo, title,
    -- subtitle and brand - the same layout as the framework options panels.
    -- Borderless band tucked inside the window's own panel ring: the
    -- window border doubles as the header border, so the band reaches the
    -- outer window border on every side. Only the fill is drawn (nine-
    -- sliced from the framework panel texture, rounded top corners
    -- matching the window's own radius, straight sides and bottom); the
    -- progress strip below doubles as the band's bottom edge.
    local header = CreateFrame("Frame", nil, f)
    header:SetHeight(HEADER_HEIGHT)
    header:SetPoint("TOPLEFT", 1, -1)
    header:SetPoint("TOPRIGHT", -1, -1)
    local R = 12
    local function HeaderFill(color, alpha)
        local function piece(u1, u2, v1, v2)
            local tx = header:CreateTexture(nil, "BACKGROUND")
            tx:SetTexture("Interface\\AddOns\\RGX-Framework\\media\\panel_rounded.tga")
            tx:SetTexCoord(u1, u2, v1, v2)
            tx:SetVertexColor(color[1], color[2], color[3], alpha or 1)
            return tx
        end
        local tl = piece(0, 0.25, 0, 0.25)
        tl:SetSize(R, R); tl:SetPoint("TOPLEFT", 0, 0)
        local tr = piece(0.75, 1, 0, 0.25)
        tr:SetSize(R, R); tr:SetPoint("TOPRIGHT", 0, 0)
        local tm = piece(0.25, 0.75, 0, 0.25)
        tm:SetPoint("TOPLEFT", tl, "TOPRIGHT"); tm:SetPoint("BOTTOMRIGHT", tr, "BOTTOMLEFT")
        local ml = piece(0, 0.25, 0.25, 0.75)
        ml:SetPoint("TOPLEFT", tl, "BOTTOMLEFT"); ml:SetPoint("BOTTOMRIGHT", header, "BOTTOMLEFT", R, 0)
        local mr = piece(0.75, 1, 0.25, 0.75)
        mr:SetPoint("TOPRIGHT", tr, "BOTTOMRIGHT"); mr:SetPoint("BOTTOMLEFT", header, "BOTTOMRIGHT", -R, 0)
        local c = piece(0.25, 0.75, 0.25, 0.75)
        c:SetPoint("TOPLEFT", tl, "BOTTOMRIGHT"); c:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -R, 0)
    end
    local hsr, hsg, hsb = 0.086, 0.086, 0.110
    if Design then hsr, hsg, hsb = Design:Unpack("surface") end
    HeaderFill({ hsr, hsg, hsb }, 0.95)

    f.headerIcon = header:CreateTexture(nil, "ARTWORK")
    f.headerIcon:SetSize(48, 48)
    f.headerIcon:SetPoint("TOPLEFT", 12, -4)
    f.headerIcon:SetTexture("Interface\\AddOns\\RGXProfessions\\Media\\RGXIconSquare.tga")

    f.headerTitle = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.headerTitle:SetPoint("LEFT", f.headerIcon, "RIGHT", 10, 10)
    f.headerTitle:SetText(HEADER_TITLE)

    f.headerSub = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.headerSub:SetPoint("LEFT", f.headerIcon, "RIGHT", 10, -8)
    f.headerSub:SetText("The profession leveling bible for WoW Forever")
    if Design then
        local tr, tg, tb = Design:Unpack("subtext")
        f.headerSub:SetTextColor(tr, tg, tb)
    end

    f.headerBrand = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.headerBrand:SetPoint("TOPRIGHT", -46, -40)
    f.headerBrand:SetJustifyH("RIGHT")
    f.headerBrand:SetText("|cff8B1538RGX|r |cffffd700Mods|r")

    local function HeaderMeta(key)
        if C_AddOns and C_AddOns.GetAddOnMetadata then
            local ok, v = pcall(C_AddOns.GetAddOnMetadata, "RGXProfessions", key)
            if ok and v and v ~= "" then return v end
        elseif GetAddOnMetadata then
            local ok, v = pcall(GetAddOnMetadata, "RGXProfessions", key)
            if ok and v and v ~= "" then return v end
        end
    end

    f.headerVer = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.headerVer:SetPoint("TOPRIGHT", -46, -8)
    f.headerVer:SetJustifyH("RIGHT")
    f.headerVer:SetText("v" .. tostring(HeaderMeta("Version") or "?"))

    f.headerAuthor = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.headerAuthor:SetPoint("TOPRIGHT", -46, -24)
    f.headerAuthor:SetJustifyH("RIGHT")
    f.headerAuthor:SetText("by donniedice")

    f.headerDiscord = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.headerDiscord:SetPoint("TOPLEFT", f.headerSub, "BOTTOMLEFT", 0, -2)
    f.headerDiscord:SetText("|cff7289daDiscord:|r |cffffd700" .. tostring(HeaderMeta("X-Discord") or "") .. "|r")

    local sr, sg, sb = 0.545, 0.545, 0.596
    if Design then sr, sg, sb = Design:Unpack("subtext") end
    f.headerAuthor:SetTextColor(sr, sg, sb)
    f.headerDiscord:SetTextColor(0.85, 0.85, 0.85)
    local vr, vg, vb = unpack(BRAND_RGB)
    f.headerVer:SetTextColor(vr, vg, vb)

    -- Progress strip: a full-width bar directly below the header band,
    -- edge to edge, doubling as the band's bottom edge.
    f.progress = CreateFrame("StatusBar", nil, f)
    f.progress:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -1)
    f.progress:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -1)
    f.progress:SetHeight(12)
    f.progressLabel = f.progress:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.progressLabel:SetAllPoints()
    f.progressLabel:SetJustifyH("CENTER")
    f.progress:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    f.progress:SetMinMaxValues(0, MaxSkill())
    f.progress:SetValue(0)
    do
        local r, g, b = unpack(BRAND_RGB)
        f.progress:SetStatusBarColor(r, g, b)
        local bg = f.progress:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        local br, bgc, bb = 0.137, 0.137, 0.173
        if Design then br, bgc, bb = Design:Unpack("border") end
        SetTextureColor(bg, br, bgc, bb, 0.8)
    end

    f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.close:SetPoint("TOPRIGHT", -4, -4)

    -- Landing page: profession grid with live skill under each.
    f.landing = CreateFrame("Frame", nil, f)
    f.landing:SetPoint("TOPLEFT", f.progress, "BOTTOMLEFT", 7, -8)
    f.landing:SetPoint("BOTTOMRIGHT", -8, 12)

    f.landingHint = f.landing:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.landingHint:SetPoint("TOP", 0, -10)

    -- Guide view: left step list + right detail.
    f.guide = CreateFrame("Frame", nil, f)
    f.guide:SetPoint("TOPLEFT", f.progress, "BOTTOMLEFT", 7, -8)
    f.guide:SetPoint("BOTTOMRIGHT", -8, 44)
    f.guide:Hide()

    -- Rounded panel behind the recipe list column: the same nine-slice
    -- panel skin as the other RGX surfaces; the step rows render on top.
    -- The old 1px divider is retired - the two panel borders now provide
    -- the column separation.
    f.stepPanel = Design:CreateFrame(f.guide, { width = LIST_WIDTH })
    f.stepPanel:SetPoint("TOPLEFT", 0, 0)
    f.stepPanel:SetPoint("BOTTOMLEFT", 0, 0)
    if f.stepPanel.SetPanelColor then
        f.stepPanel:SetPanelColor(nil, BRAND_BORDER)
    end

    -- Step list (wheel-scrolled plain ScrollFrame; portable across flavors).
    f.stepScroll = CreateFrame("ScrollFrame", nil, f.stepPanel)
    f.stepScroll:SetPoint("TOPLEFT", 0, 0)
    f.stepScroll:SetPoint("BOTTOMRIGHT", 0, 6)
    f.stepScroll:EnableMouse(true)
    f.stepScroll:EnableMouseWheel(true)

    f.stepContent = CreateFrame("Frame", nil, f.stepScroll)
    f.stepContent:SetSize(LIST_WIDTH, 1)
    f.stepScroll:SetScrollChild(f.stepContent)

    f.stepScroll:SetScript("OnMouseWheel", function(_, delta)
        local viewH = f.stepScroll:GetHeight() or 1
        local contentH = f.stepContent:GetHeight() or 1
        local maxOff = math.max(0, contentH - viewH)
        if maxOff <= 0 then return end
        local off = (f.stepScroll:GetVerticalScroll() or 0) - delta * 40
        if off < 0 then off = 0 elseif off > maxOff then off = maxOff end
        f.stepScroll:SetVerticalScroll(off)
    end)

    -- Rounded panel behind the detail pages column.
    f.detailPanel = Design:CreateFrame(f.guide)
    f.detailPanel:SetPoint("TOPLEFT", LIST_WIDTH + 14, 0)
    f.detailPanel:SetPoint("BOTTOMRIGHT", 0, 0)
    if f.detailPanel.SetPanelColor then
        f.detailPanel:SetPanelColor(nil, BRAND_BORDER)
    end

    -- Detail pane (right half): a scrollable card column so the cards can
    -- never overflow the window height; the canvas grows and the scroll
    -- frame keeps every card reachable. Lifted 8px so the framework's
    -- scroll inset cancels out and the first card sits tight under the
    -- panel top.
    local detail = CreateFrame("Frame", nil, f.guide)
    detail:SetPoint("TOPLEFT", LIST_WIDTH + 24, 8)
    detail:SetPoint("BOTTOMRIGHT", 0, 0)
    f.detail = detail

    local UI = assert(_G.RGXUI, "RGXProf: RGXUI unavailable")
    local canvas = UI:CreateScrollPage(detail, 780)
    detail.canvas = canvas

    -- Recipe card: icon, title, meta and difficulty together at the top,
    -- using the same RGXUI section skin as every other RGX options surface.
    detail.recipeCard = UI:CreateSection(canvas, { title = "Recipe" })
    detail.recipeCard:SetPoint("TOPLEFT", canvas, "TOPLEFT", 2, -6)
    detail.recipeCard:SetPoint("TOPRIGHT", canvas, "TOPRIGHT", -8, -6)
    detail.recipeCard:SetHeight(100)
    -- Flush the recipe card to the window surface tone so it reads as the
    -- prominent recipe well rather than a contrasting panel. SetTextureColor
    -- probes the client's texture-color API (this build rejects positional
    -- SetColorTexture/SetVertexColor) and caches the winner per texture.
    if detail.recipeCard._panelFill then
        local sr, sg, sb = 0.086, 0.086, 0.110
        if Design then sr, sg, sb = Design:Unpack("surface") end
        for _, tx in ipairs(detail.recipeCard._panelFill) do
            SetTextureColor(tx, sr, sg, sb, 1)
        end
    end

    detail.icon = detail.recipeCard.content:CreateTexture(nil, "ARTWORK")
    detail.icon:SetSize(36, 36)
    detail.icon:SetPoint("TOPLEFT", 2, -4)

    detail.title = detail.recipeCard.content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    detail.title:SetPoint("LEFT", detail.icon, "RIGHT", 10, 0)
    detail.title:SetPoint("RIGHT", -2, 0)
    detail.title:SetJustifyH("LEFT")

    -- Hover frame over the title so the recipe shows its real in-game tooltip.
    detail.titleHover = CreateFrame("Frame", nil, detail.recipeCard.content)
    detail.titleHover:SetAllPoints(detail.title)
    detail.titleHover:EnableMouse(true)
    detail.titleHover:SetScript("OnEnter", function(s) ShowStepTooltip(s, detail._step) end)
    detail.titleHover:SetScript("OnLeave", function() GameTooltip:Hide() end)

    detail.meta = detail.recipeCard.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    detail.meta:SetPoint("TOPLEFT", detail.icon, "BOTTOMLEFT", 0, -8)
    detail.meta:SetPoint("RIGHT", -170, 0)
    detail.meta:SetJustifyH("LEFT")
    detail.meta:SetWordWrap(false)

    detail.difficulty = detail.recipeCard.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detail.difficulty:SetPoint("TOPLEFT", detail.meta, "TOPRIGHT", 12, 0)
    detail.difficulty:SetPoint("RIGHT", -2, 0)
    detail.difficulty:SetJustifyH("RIGHT")

    detail.matsCard = UI:CreateSection(canvas, { title = "Materials" })
    detail.matsCard:SetPoint("TOPLEFT", detail.recipeCard, "BOTTOMLEFT", 0, -6)
    detail.matsCard:SetWidth(198)
    detail.matsCard:SetHeight(116)
    -- Material rows: icon left, name flexible, have/need right-aligned
    -- and never wrapped. Row 8 doubles as the overflow note.
    detail.materials = {}
    for i = 1, 8 do
        local row = CreateFrame("Frame", nil, detail.matsCard.content)
        row:SetHeight(14)
        if i == 1 then
            row:SetPoint("TOPLEFT", 2, -2)
        else
            row:SetPoint("TOPLEFT", detail.materials[i - 1], "BOTTOMLEFT", 0, 0)
        end
        row:SetPoint("RIGHT", -2, 0)
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(14, 14)
        row.icon:SetPoint("TOPLEFT", 0, 0)
        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.name:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
        row.name:SetPoint("RIGHT", row, "RIGHT", -44, 0)
        row.name:SetJustifyH("LEFT")
        row.name:SetWordWrap(false)
        row.count = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.count:SetPoint("RIGHT", -2, 0)
        row.count:SetJustifyH("RIGHT")
        row:Hide()
        detail.materials[i] = row
    end

    detail.locCard = UI:CreateSection(canvas, { title = "Where to get it" })
    detail.locCard:SetPoint("TOPLEFT", detail.matsCard, "TOPRIGHT", 10, 0)
    detail.locCard:SetPoint("TOPRIGHT", detail.recipeCard, "BOTTOMRIGHT", 0, -6)
    -- Fixed height matching the materials column so the notes card can
    -- anchor below both. No FitContent - this card must never balloon.
    detail.locCard:SetHeight(116)

    detail.locations = detail.locCard.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detail.locations:SetPoint("TOPLEFT", 2, -2)
    detail.locations:SetPoint("RIGHT", -2, 0)
    detail.locations:SetJustifyH("LEFT")
    detail.locations:SetWordWrap(true)
    detail.locations:SetSpacing(3)

    -- Location card interaction: click drops a map pin on the shown NPC
    -- (waypoint API capability-gated; opens the map either way); hover
    -- highlights the card.
    detail.locHover = CreateFrame("Button", nil, detail.locCard.content)
    detail.locHover:SetAllPoints(detail.locCard.content)
    detail.locHover:EnableMouse(true)
    detail.locHover:SetScript("OnEnter", function(s)
        detail.locations:SetTextColor(1, 0.82, 0)
        GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
        GameTooltip:SetText("Pin on the map")
        GameTooltip:AddLine("Drops a map pin on this location.", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    detail.locHover:SetScript("OnLeave", function()
        detail.locations:SetTextColor(1, 1, 1)
        GameTooltip:Hide()
    end)
    detail.locHover:SetScript("OnClick", function()
        local target = detail._pinTarget
        -- 1. Real pin when the client exposes the waypoint API.
        if target and target.zoneID and target.x and target.y
            and UiMapPoint and UiMapPoint.CreateFromCoordinates
            and C_Map and C_Map.SetUserWaypoint then
            local okPoint, point = pcall(UiMapPoint.CreateFromCoordinates, target.zoneID, target.x, target.y)
            if okPoint and point then
                local okSet = pcall(C_Map.SetUserWaypoint, point)
                if okSet and C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                    pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
                end
            end
        end
        -- 2. Always open the map, zoomed to the NPC's zone when possible -
        --    this is the functional fallback when no waypoint API exists.
        if WorldMapFrame and WorldMapFrame:IsShown() then
            WorldMapFrame:Hide()
        elseif ToggleWorldMap then
            ToggleWorldMap()
            if target and target.zoneID and WorldMapFrame and WorldMapFrame.SetMapID then
                pcall(WorldMapFrame.SetMapID, WorldMapFrame, target.zoneID)
            end
        end
    end)

    detail.notesCard = UI:CreateSection(canvas, { title = "Notes" })
    detail.notesCard:SetPoint("TOPLEFT", detail.matsCard, "BOTTOMLEFT", 0, -6)
    detail.notesCard:SetPoint("TOPRIGHT", detail.locCard, "BOTTOMRIGHT", 0, -6)

    detail.notes = detail.notesCard.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detail.notes:SetPoint("TOPLEFT", 2, -2)
    detail.notes:SetPoint("RIGHT", -2, 0)
    detail.notes:SetJustifyH("LEFT")
    detail.notes:SetWordWrap(true)
    detail.notes:SetSpacing(3)

    -- Footer buttons.
    f.backBtn = Design:CreateButton(f, "< Professions", 110, 24)
    f.backBtn:SetPoint("BOTTOMLEFT", 14, 12)
    f.backBtn:SetTooltip("Back", "Return to the profession list.")
    f.backBtn:SetScript("OnClick", function()
        RGXProf_Settings.bookProfessionID = nil
        RGXProf.BookWindow:Show()
    end)

    f.matsBtn = Design:CreateButton(f, "Materials to Max", 130, 24)
    f.matsBtn:SetPoint("BOTTOMLEFT", 134, 12)
    f.matsBtn:SetTooltip("Materials to Max", "Show everything you still need to reach the skill cap.")
    f.matsBtn:SetScript("OnClick", function()
        local professionID = RGXProf.BookWindow:GetCurrentProfession()
        if not professionID then return end
        local prof = RGXProf.Constants.Professions[professionID]
        local skill = LiveSkill(professionID)
        RGXProf.MatsWindow:Show({
            icon = prof.icon,
            currentSkill = skill or 1,
            path = RGXProf.currentExpansion.paths[professionID],
        })
    end)

    f.prevBtn = Design:CreateButton(f, "< Prev", 90, 24)
    f.prevBtn:SetPoint("BOTTOMRIGHT", -150, 12)
    f.prevBtn:SetScript("OnClick", function()
        local professionID = RGXProf.BookWindow:GetCurrentProfession()
        if not professionID then return end
        local page = SelectedPage(professionID)
        RGXProf_Settings.bookPage = math.max(1, page - 1)
        RGXProf.BookWindow:Show()
    end)

    f.nextBtn = Design:CreateButton(f, "Next >", 90, 24)
    f.nextBtn:SetPoint("BOTTOMRIGHT", -14, 12)
    f.nextBtn:SetScript("OnClick", function()
        local professionID = RGXProf.BookWindow:GetCurrentProfession()
        if not professionID then return end
        local path = RGXProf.currentExpansion.paths[professionID]
        local page = SelectedPage(professionID)
        RGXProf_Settings.bookPage = math.min(#path, page + 1)
        RGXProf.BookWindow:Show()
    end)

    self.rows = {}
    self.frame = f
end

--------------------------------------------------------------------------------
-- Step list rows
--------------------------------------------------------------------------------

-- Row highlight helpers. The first row sits on the panel's rounded top
-- corners, so its highlight is a rounded-corner slice set (clipped to the
-- panel's curve); every other row uses a flat full-bleed rectangle.
local function RowHighlightSetColor(row, r, g, b, a)
    if row.bgIsSlice then
        for _, tx in ipairs(row.bgPieces) do
            SetTextureColor(tx, r, g, b, a)
        end
    else
        SetTextureColor(row.bg, r, g, b, a)
    end
end

local function RowHighlightShow(row, show)
    if row.bgIsSlice then
        for _, tx in ipairs(row.bgPieces) do
            if show then tx:Show() else tx:Hide() end
        end
    else
        if show then row.bg:Show() else row.bg:Hide() end
    end
end

local function GetRow(self, index)
    local row = self.rows[index]
    if row then return row end

    local content = self.frame.stepContent
    row = CreateFrame("Button", nil, content)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("RIGHT")

    -- Highlight layer. Row 1 sits on the panel's rounded top corners:
    -- nine-slice the same rounded panel texture (rounded top corners,
    -- solid body) so the fill terminates inside the curve instead of
    -- poking past the rounded border. Other rows keep the flat fill.
    row.bgIsSlice = (index == 1)
    if row.bgIsSlice then
        local R = 12
        local function piece(u1, u2, v1, v2)
            local tx = row:CreateTexture(nil, "BACKGROUND")
            tx:SetTexture("Interface\\AddOns\\RGX-Framework\\media\\panel_rounded.tga")
            tx:SetTexCoord(u1, u2, v1, v2)
            return tx
        end
        local tl = piece(0, 0.25, 0, 0.25)
        tl:SetSize(R, R); tl:SetPoint("TOPLEFT", 0, 0)
        local tr = piece(0.75, 1, 0, 0.25)
        tr:SetSize(R, R); tr:SetPoint("TOPRIGHT", 0, 0)
        local tm = piece(0.25, 0.75, 0, 0.25)
        tm:SetPoint("TOPLEFT", tl, "TOPRIGHT"); tm:SetPoint("BOTTOMRIGHT", tr, "BOTTOMLEFT")
        local body = piece(0.25, 0.75, 0.25, 0.75)
        body:SetPoint("TOPLEFT", tl, "BOTTOMLEFT")
        body:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
        row.bgPieces = { tl, tr, tm, body }
        for _, tx in ipairs(row.bgPieces) do tx:Hide() end
    else
        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints()
        row.bg:Hide()
    end

    row.current = row:CreateTexture(nil, "ARTWORK")
    row.current:SetWidth(3)
    row.current:SetPoint("TOPLEFT", 0, -1)
    row.current:SetPoint("BOTTOMLEFT", 0, 1)
    row.current:Hide()

    row.range = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.range:SetPoint("LEFT", 6, 0)
    row.range:SetWidth(56)
    row.range:SetJustifyH("LEFT")

    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.name:SetPoint("LEFT", row.range, "RIGHT", 6, 0)
    row.name:SetPoint("RIGHT", -4, 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)

    row:SetScript("OnEnter", function(s)
        if not s._selected then
            RowHighlightSetColor(s, unpack(BRAND_RGB), 0.10)
        end
        RowHighlightShow(s, true)
        ShowStepMaterials(s, s._step)
    end)
    row:SetScript("OnLeave", function(s)
        if not s._selected then RowHighlightShow(s, false) end
        GameTooltip:Hide()
    end)

    self.rows[index] = row
    return row
end

local function RenderStepList(self)
    local f = self.frame
    local professionID = self:GetCurrentProfession()
    if not professionID then return end
    local path = RGXProf.currentExpansion.paths[professionID]
    local skill = LiveSkill(professionID)
    local selected = SelectedPage(professionID)
    local currentIdx = FindCurrentIndex(path, skill)

    local ar, ag, ab = unpack(BRAND_RGB)

    for i, step in ipairs(path) do
        local row = GetRow(self, i)
        row:SetPoint("TOPLEFT", 0, -((i - 1) * ROW_HEIGHT))
        row._selected = (i == selected)
        row._step = step

        local rangeHex
        if skill and step.maxSkill <= skill then
            rangeHex = Dim()
        elseif i == currentIdx then
            rangeHex = Accent()
        else
            rangeHex = Label()
        end
        row.range:SetText(string.format("%s%d - %d", rangeHex, step.minSkill, step.maxSkill))

        local nameHex = DiffColorHex(StepDifficulty(step, skill))
        local name = step.name or ("Recipe " .. (step.spellID or i))
        if skill and step.maxSkill <= skill then
            nameHex = Dim()
        end
        row.name:SetText(nameHex .. name .. (step.alternate and (Dim() .. " (alt)") or ""))

        if row._selected then
            RowHighlightSetColor(row, ar, ag, ab, 0.14)
            RowHighlightShow(row, true)
        else
            RowHighlightShow(row, false)
        end

        if i == currentIdx then
            row.current:SetColorTexture(ar, ag, ab, 0.9)
            row.current:Show()
        else
            row.current:Hide()
        end

        row:SetScript("OnClick", function()
            RGXProf_Settings.bookPage = i
            RGXProf.BookWindow:Show()
        end)
        row:Show()
    end

    for i = #path + 1, #self.rows do
        self.rows[i]:Hide()
    end

    f.stepContent:SetHeight(math.max(1, #path * ROW_HEIGHT))

    -- Scroll so the selected row stays visible.
    local viewH = f.stepScroll:GetHeight() or 1
    local contentH = f.stepContent:GetHeight() or 1
    if contentH > viewH then
        local target = (selected - 1) * ROW_HEIGHT - (viewH / 2)
        if target < 0 then target = 0 end
        local maxOff = contentH - viewH
        if target > maxOff then target = maxOff end
        f.stepScroll:SetVerticalScroll(target)
    else
        f.stepScroll:SetVerticalScroll(0)
    end
end

--------------------------------------------------------------------------------
-- Detail pane
--------------------------------------------------------------------------------

-- Closest-NPC helpers: compare positions in world coordinates when the
-- client can translate both points, else prefer NPCs on the player's map.
-- Everything is pcall-guarded; missing APIs degrade to the first candidate.
-- C_Map.GetWorldPosFromMapPos returns (continentID, worldX, worldY) on most
-- clients, but the Forever beta hands the position back as a vector-like
-- table. Normalize both shapes to continentID, x, y; nil when unusable.
local function WorldPos(mapID, x, y)
    if not (C_Map and C_Map.GetWorldPosFromMapPos and CreateVector2D and mapID) then return nil end
    local ok, a, b, c = pcall(C_Map.GetWorldPosFromMapPos, mapID, CreateVector2D(x, y))
    if not ok then return nil end
    if type(b) == "table" then
        if type(b.GetXY) == "function" then
            local okXY, bx, by = pcall(b.GetXY, b)
            if okXY and type(bx) == "number" and type(by) == "number" then
                return a, bx, by
            end
        end
        if type(b.x) == "number" and type(b.y) == "number" then
            return a, b.x, b.y
        end
        return nil
    end
    if type(b) == "number" and type(c) == "number" then
        return a, b, c
    end
    return nil
end

local function NpcDistance(npc, playerMapID, playerX, playerY)
    if npc.zoneID == playerMapID and npc.x and npc.y and playerX and playerY then
        local dx, dy = npc.x - playerX, npc.y - playerY
        return dx * dx + dy * dy
    end
    if playerMapID and playerX and playerY and npc.zoneID and npc.x and npc.y then
        local pCont, pwx, pwy = WorldPos(playerMapID, playerX, playerY)
        local nCont, nwx, nwy = WorldPos(npc.zoneID, npc.x, npc.y)
        if pCont and nCont and pCont == nCont
            and type(pwx) == "number" and type(pwy) == "number"
            and type(nwx) == "number" and type(nwy) == "number" then
            local dx, dy = nwx - pwx, nwy - pwy
            return dx * dx + dy * dy
        end
    end
    return nil
end

local function NearestNpc(candidates)
    if not candidates or #candidates == 0 then return nil end
    local playerMapID
    if C_Map and C_Map.GetBestMapForUnit then
        local ok, mapID = pcall(C_Map.GetBestMapForUnit, "player")
        if ok and mapID then playerMapID = mapID end
    end
    local px, py
    if playerMapID and C_Map.GetPlayerMapPosition then
        local ok, pos = pcall(C_Map.GetPlayerMapPosition, playerMapID, "player")
        if ok and pos and pos.GetXY then
            local okXY, x, y = pcall(pos.GetXY, pos)
            if okXY then px, py = x, y end
        end
    end
    local best, bestDist = candidates[1], nil
    for _, npc in ipairs(candidates) do
        local d = NpcDistance(npc, playerMapID, px, py)
        if d and (not bestDist or d < bestDist) then
            best, bestDist = npc, d
        end
    end
    return best
end

local function RenderDetail(self)
    local f = self.frame
    local detail = f.detail
    local professionID = self:GetCurrentProfession()
    if not professionID then return end

    local path = RGXProf.currentExpansion.paths[professionID]
    local page = SelectedPage(professionID)
    local step = path[page]
    if not step then return end

    local skill, total = LiveSkill(professionID)
    local player = RGXProf.WowAPI and RGXProf.WowAPI.GetPlayer and RGXProf.WowAPI:GetPlayer() or nil
    local faction = player and player.faction or "Alliance"

    -- Title + icon
    detail._step = step
    local display = RGXProf.WowAPI:GetItemLinkAndIconOrSpell(step)
    detail.icon:SetTexture(display.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    detail.title:SetText(display.link or (Text() .. (step.name or "")))

    -- Meta block: structured fields, no sentence-style wrapping.
    -- Line 1: skill range + learn-at. Line 2: craft status.
    local fromSkill = math.max(step.minSkill, skill or step.minSkill)
    local crafts = 0
    if not skill or skill < step.maxSkill then
        crafts = RGXProf.DataManager:GetEstimatedCrafts(fromSkill, step) or 0
    end
    local metaText = Accent() .. string.format("Skill %d-%d", step.minSkill, step.maxSkill)
    if step.learnAt then
        metaText = metaText .. Dim() .. " · " .. Text() .. string.format("Learn at %d", step.learnAt)
    end
    local statusLine
    if crafts > 0 then
        statusLine = Text() .. string.format("Craft about %d", crafts)
    elseif skill then
        statusLine = Dim() .. "Completed"
    end
    if step.alternate then
        local alt = Dim() .. "Alternate"
        statusLine = statusLine and (statusLine .. Dim() .. " · " .. alt) or alt
    end
    detail.meta:SetText(statusLine and (metaText .. "\n" .. statusLine) or metaText)

    -- Difficulty label
    local diff = StepDifficulty(step, skill)
    if diff and DIFF_WORDS[diff] then
        local d = DIFF_WORDS[diff]
        detail.difficulty:SetText(C(d.key) .. d.text)
    else
        detail.difficulty:SetText("")
    end
    if detail.recipeCard and detail.recipeCard.FitContent then
        detail.recipeCard:FitContent(6)
    end

    -- Materials: structured rows - icon left, name flexible, count right.
    local displayCrafts = crafts > 0 and crafts or (RGXProf.DataManager:GetEstimatedCrafts(step.minSkill, step) or 1)
    local reagents = step.spellID and RGXProf.DataManager:GetReagentListWithDetails(step.spellID, displayCrafts) or {}
    reagents = reagents or {}
    for i = 1, 8 do
        local row = detail.materials[i]
        if i == 8 and #reagents > 8 then
            row.icon:Hide()
            row.name:SetText(Dim() .. string.format("+ %d more", #reagents - 7))
            row.count:SetText("")
            row:Show()
        elseif reagents[i] then
            local reagent = reagents[i]
            row.icon:SetTexture(reagent.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
            row.icon:Show()
            local have = tonumber(reagent.onHandCount) or 0
            local need = tonumber(reagent.requiredCount) or 0
            local haveHex = (have >= need) and C("success") or C("warning")
            row.name:SetText(Text() .. need .. Dim() .. "x " .. Text() .. (reagent.name or tostring(reagent.itemID)))
            row.count:SetText(haveHex .. string.format("%d/%d", have, need))
            row:Show()
        elseif i == 1 and #reagents == 0 then
            row.icon:Hide()
            row.name:SetText(Dim() .. "No reagent data for this step.")
            row.count:SetText("")
            row:Show()
        else
            row:Hide()
        end
    end

    -- Location card: show ONLY the NPC closest to the player when the
    -- window is open, not the full vendor/trainer roster.
    local vendors = step.npcs and RGXProf.DataManager:GetVendors(step, faction) or {}
    local trainers = RGXProf.DataManager:GetTrainers(faction, step.minSkill, professionID) or {}
    local allLocs = {}
    for _, v in ipairs(vendors) do table.insert(allLocs, v) end
    for _, t in ipairs(trainers) do table.insert(allLocs, t) end
    detail._pinTarget = NearestNpc(allLocs)

    local locLines = {}
    if detail._pinTarget then
        local target = detail._pinTarget
        local nameLine = Text() .. (target.name or "Unknown")
        local zone = ""
        if target.zoneID and RGXProf.WowAPI and RGXProf.WowAPI.GetMapName then
            local ok, zname = pcall(RGXProf.WowAPI.GetMapName, RGXProf.WowAPI, target.zoneID)
            if ok and zname then zone = zname end
        end
        if zone ~= "" then
            nameLine = nameLine .. Dim() .. " · " .. Text() .. zone
        end
        table.insert(locLines, nameLine)
        if target.x and target.y then
            table.insert(locLines, Dim() .. string.format("%.1f, %.1f", target.x, target.y))
        end
        table.insert(locLines, Dim() .. "Closest to you · Click to pin")
    else
        table.insert(locLines, Dim() .. "Trainer-taught; ask any profession trainer.")
    end
    detail.locations:SetText(table.concat(locLines, "\n"))

    -- Notes
    local notes = {}
    if step.keep then
        table.insert(notes, C("accent") .. "Keep the crafted items for later steps.")
        if step.keepNote then
            table.insert(notes, Text() .. step.keepNote)
        end
    end
    if step.note then table.insert(notes, Accent() .. "* " .. Text() .. step.note) end
    if step.quests then table.insert(notes, Dim() .. "Requires a quest (see trainer list).") end
    detail.notes:SetText(table.concat(notes, "\n"))
    if detail.notesCard and detail.notesCard.FitContent then
        detail.notesCard:FitContent(4)
    end

    -- Footer buttons
    f.prevBtn:SetEnabled(page > 1)
    f.nextBtn:SetEnabled(page < #path)
end

--------------------------------------------------------------------------------
-- Landing page
--------------------------------------------------------------------------------

local function BuildLanding(self)
    local landing = self.frame.landing
    if landing._buttons then
        for _, b in ipairs(landing._buttons) do b:Hide() end
    else
        landing._buttons = {}
    end

    local professions = GetGuideProfessions()
    self.frame.landingHint:SetText(Dim() .. "Choose a profession to open its leveling path.")

    local columns = 4
    local rowsNeeded = math.ceil(#professions / columns)
    local cellW, cellH = 118, 118
    local gridW = columns * cellW
    local gridH = rowsNeeded * cellH
    local originX = math.max(0, ((landing:GetWidth() or 600) - gridW) / 2)
    local originY = math.max(0, ((landing:GetHeight() or 350) - gridH) / 2) + 16

    for index, professionID in ipairs(professions) do
        local prof = RGXProf.Constants.Professions[professionID]
        local btn = landing._buttons[index]
        if not btn then
            btn = Design:CreateButton(landing, nil, 108, 108)
            btn.icon = btn:CreateTexture(nil, "ARTWORK")
            btn.icon:SetSize(38, 38)
            btn.icon:SetPoint("TOP", 0, -14)
            btn.name = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            btn.name:SetPoint("TOP", btn.icon, "BOTTOM", 0, -6)
            btn.skill = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            btn.skill:SetPoint("TOP", btn.name, "BOTTOM", 0, -2)
            landing._buttons[index] = btn
        end

        local row = math.floor((index - 1) / columns)
        local col = (index - 1) % columns
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", originX + col * cellW, -(originY + row * cellH))

        btn.icon:SetTexture(prof.icon or 133741)
        btn.name:SetText(Text() .. prof.name)
        local skill, total = LiveSkill(professionID)
        btn.skill:SetText(skill and (Dim() .. string.format("Skill %d/%d", skill, total or MaxSkill())) or (Label() .. "Not learned"))

        btn:SetScript("OnClick", function()
            RGXProf.BookWindow:OpenProfession(professionID)
        end)
        btn:Show()
    end
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

function RGXProf.BookWindow:GetCurrentProfession()
    local saved = RGXProf_Settings.bookProfessionID
    if saved and RGXProf.currentExpansion.paths[saved] then
        return saved
    end
    return nil
end

function RGXProf.BookWindow:GetCurrentPage(professionID)
    return SelectedPage(professionID)
end

function RGXProf.BookWindow:OpenProfession(professionID)
    if not RGXProf.currentExpansion.paths[professionID] then return end
    RGXProf_Settings.bookProfessionID = professionID
    local skill = LiveSkill(professionID)
    RGXProf_Settings.bookPage = FindCurrentIndex(RGXProf.currentExpansion.paths[professionID], skill)
    self:Show()
end

function RGXProf.BookWindow:Show()
    self:EnsureFrame()
    if RGXProf_Settings.bookPosition then
        local pos = RGXProf_Settings.bookPosition
        pcall(function()
            self.frame:ClearAllPoints()
            self.frame:SetPoint(pos[1], pos[2] or UIParent, pos[3], pos[4], pos[5])
        end)
    end

    local professionID = self:GetCurrentProfession()
    if professionID then
        local prof = RGXProf.Constants.Professions[professionID]
        local skill, total = LiveSkill(professionID)
        local maxSkill = total or MaxSkill()

        self.frame.headerIcon:SetTexture(prof.icon or 133741)
        self.frame.headerTitle:SetText(prof.name .. " - Leveling Path")
        local gate = skill and NextGate(tonumber(skill))
    local gateText = gate and (Dim() .. "  -  Train " .. Text() .. gate.rank .. Dim() .. " at " .. gate.cap) or ""
    self.frame.progressLabel:SetText(skill and (Dim() .. "Skill " .. Text() .. skill .. Dim() .. " / " .. maxSkill .. gateText) or (Dim() .. "Not learned"))
        self.frame.progress:SetMinMaxValues(0, maxSkill)
        self.frame.progress:SetValue(skill or 0)

        self.frame.landing:Hide()
        self.frame.guide:Show()
        self.frame.backBtn:Show()
        self.frame.matsBtn:Show()
        self.frame.prevBtn:Show()
        self.frame.nextBtn:Show()
        RenderStepList(self)
        RenderDetail(self)
    else
        self.frame.headerIcon:SetTexture("Interface\\AddOns\\RGXProfessions\\Media\\RGXIcon.tga")
        self.frame.headerTitle:SetText(HEADER_TITLE)
        self.frame.progressLabel:SetText("")
        self.frame.progress:SetMinMaxValues(0, 1)
        self.frame.progress:SetValue(0)

        self.frame.guide:Hide()
        self.frame.backBtn:Hide()
        self.frame.matsBtn:Hide()
        self.frame.prevBtn:Hide()
        self.frame.nextBtn:Hide()
        self.frame.landing:Show()
        BuildLanding(self)
    end
    self.frame:Show()
end

function RGXProf.BookWindow:Hide()
    if self.frame then self.frame:Hide() end
end

function RGXProf.BookWindow:Toggle()
    if self.frame and self.frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end
