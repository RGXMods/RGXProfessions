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

-- Brand colours come from one place (UI/Theme.lua): the primary is the panel ring, the accent is the
-- text tint. The framework's RGX Material Round style draws the panels, cards, headers and buttons from
-- that pair; this file only uses the pair for its few hand-drawn accents (progress bars, the big number).
local BRAND_BORDER = RGXProf.Brand.primary
local BRAND_RGB = BRAND_BORDER
local BRAND_TEXT = RGXProf.Brand.accent
local BRAND_TEXT_HEX = string.format("|cff%02X%02X%02X", math.floor(BRAND_TEXT[1] * 255 + 0.5),
    math.floor(BRAND_TEXT[2] * 255 + 0.5), math.floor(BRAND_TEXT[3] * 255 + 0.5))
local HEADER_TEXT = { 0.922, 0.922, 0.941 }
local INSET = 8                                  -- padding between a panel edge and its content
local HEADER_GAP = 8                             -- breathing room under a card header title

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
-- Instruction text (what to do next): WoW's standard gold, readable on the dark panel and distinct
-- from the crimson brand accents.
local function Instruct() return "|cffffd100" end
local function Text() return "|cffffffff" end
local function Dim() return C("subtext") end
local function Label() return C("label") end

-- The framework owns the rounded panel texture and the buttons; both come from UI/Theme.lua.
local PanelTexture = RGXProf.PanelTexture
local NewButton = RGXProf.NewButton

-- Guide data stores "keep" as true/false (Classic) or 1/0; 0 must not count as keep, because in Lua
-- 0 is true and every step would then claim its crafts are needed later.
-- Card headers come from the framework's RGX Material Round style (rounded band, the mod's accent as
-- the title colour). The framework puts the title 4px left of the content below it; line them up.
local function AlignSection(section)
    local label = section and section.header and section.header.label
    if label and label.ClearAllPoints and label.SetPoint then
        label:ClearAllPoints()
        label:SetPoint("LEFT", 6, 0)
    end
    return section
end

local function IsKeep(step)
    local k = step and step.keep
    return k == true or (type(k) == "number" and k > 0)
end

-- Forward declaration: the resize hook in EnsureFrame re-runs the landing
-- layout when the window size changes.
local BuildLanding
local RenderDetail
local LayoutDetail

local DIFF_WORDS = {
    optimal = "Always gives skill-ups",
    medium  = "Usually gives skill-ups",
    easy    = "Rarely gives skill-ups",
    trivial = "No skill-ups left",
}

-- Rank gates: crossing a skill cap like 75 requires training the next rank.
-- Built from Constants.TierLabels so every expansion tracks its own cadence.
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

-- Title in the RGX family style: "RGX" in the RGX red, a white pipe, then the product name with its
-- first letter in RGXProfessions' own coral (the two reds are deliberately different).
local function BrandTitle(name)
    name = name or "Professions"
    return "|cff8B1538RGX|r |cffffffff||r |cffED6B85" .. name:sub(1, 1) .. "|r|cffffffff" .. name:sub(2) .. "|r"
end
local HEADER_TITLE = BrandTitle("Professions")

-- Real in-game tooltip for a guide step: the crafted item when the step
-- carries an itemID, otherwise the craft spell. SetHyperlink renders true
-- client tooltips on every supported flavor.
local function ShowStepTooltip(owner, step)
    if not step then return end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    -- Prefer the recipe SPELL tooltip: it matches the step name. Path data
    -- itemIDs were mis-mapped upstream, so items are only the fallback.
    local shown = false
    if step.spellID then
        shown = pcall(GameTooltip.SetHyperlink, GameTooltip, "spell:" .. step.spellID)
    end
    if not shown and step.itemID then
        if GameTooltip.SetItemByID then
            shown = pcall(GameTooltip.SetItemByID, GameTooltip, step.itemID)
        end
        if not shown then
            shown = pcall(GameTooltip.SetHyperlink, GameTooltip, "item:" .. step.itemID)
        end
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

-- Resize bounds for the book window: clamped 640x420..1400x1000. Applied on
-- the real initialization path (EnsureFrame) before the sizer grip can drag,
-- and re-applied at drag time by the sizer's OnUpdate clamp.
local MIN_WIDTH, MAX_WIDTH = 640, 1400
local MIN_HEIGHT, MAX_HEIGHT = 420, 1000

local function ClampSize(width, height)
    if width < MIN_WIDTH then width = MIN_WIDTH
    elseif width > MAX_WIDTH then width = MAX_WIDTH end
    if height < MIN_HEIGHT then height = MIN_HEIGHT
    elseif height > MAX_HEIGHT then height = MAX_HEIGHT end
    return width, height
end

-- Apply all four resize bounds at window initialization, capability-guarded
-- the way RegisterEventSafe guards event registration: never call a client
-- API without probing it first. Where the client exposes the modern
-- Frame:SetResizeBounds(minW, minH, maxW, maxH) (retail-shaped clients),
-- publish all four bounds through it. Where the native resize-bound family
-- is absent entirely (the Forever beta, where SetResizeBounds and
-- SetMinResize are both nil), fall back to the manual clamp alone without
-- ever calling an absent API. The retired SetMinResize/SetMaxResize pair
-- from the issue #11 crash is not revived in either path: on modern clients
-- the single SetResizeBounds call replaces the pair; on legacy clients
-- neither is called.
local function ApplyResizeBounds(frame, width, height)
    if frame.SetResizeBounds then
        pcall(frame.SetResizeBounds, frame,
            MIN_WIDTH, MIN_HEIGHT, MAX_WIDTH, MAX_HEIGHT)
    end
    -- The manual clamp always runs, so the restored-or-default size is in
    -- range even on clients with no native bound API at all.
    width, height = ClampSize(width, height)
    if width ~= frame:GetWidth() or height ~= frame:GetHeight() then
        frame:SetSize(width, height)
    end
end

local function BuildFrame(self)
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
    --
    -- The real init path applies all four resize bounds before the sizer
    -- grip is usable: the saved RGXProf_Settings.bookSize (or the fixed
    -- default) is clamped into 640x420..1400x1000 through the
    -- capability-guarded ApplyResizeBounds, so an out-of-bounds saved size
    -- is repaired at init and an in-range size passes through unchanged.
    local savedSize = RGXProf_Settings and RGXProf_Settings.bookSize
    if type(savedSize) == "table" and type(savedSize[1]) == "number" and type(savedSize[2]) == "number" then
        ApplyResizeBounds(f, savedSize[1], savedSize[2])
    else
        ApplyResizeBounds(f, WINDOW_WIDTH, WINDOW_HEIGHT)
    end
    f.sizer = CreateFrame("Button", nil, f)
    f.sizer:SetSize(16, 16)
    f.sizer:SetPoint("BOTTOMRIGHT", -2, 2)
    f.sizer:RegisterForDrag("LeftButton")
    f.sizer:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    f.sizer:SetScript("OnDragStart", function(s)
        -- The pages are rebuilt once, when the drag is released: rebuilding the profession grid or the
        -- detail cards on every frame of the drag made resizing stutter.
        f._sizing = true
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
        f._sizing = false
        RGXProf_Settings.bookSize = { f:GetWidth(), f:GetHeight() }
        -- One rebuild at the final size.
        if f.landing:IsShown() then BuildLanding(self) end
        if f.guide:IsShown() then RenderDetail(self) end
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
            tx:SetTexture(PanelTexture())
            tx:SetTexCoord(u1, u2, v1, v2)
            pcall(tx.SetVertexColor, tx, color[1], color[2], color[3], alpha or 1)
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
    f.headerIcon:SetTexture("Interface\\AddOns\\RGX-Framework\\media\\square.tga")

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
    f.headerVer:SetText("v" .. tostring(HeaderMeta("Version") or "?"):gsub("^v+", ""))

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

    -- Settings gear: opens the RGX settings window (minimap icon, auto-open, recipe clicks).
    f.gear = CreateFrame("Button", nil, f)
    f.gear:SetSize(18, 18)
    f.gear:SetPoint("RIGHT", f.close, "LEFT", 2, 0)
    f.gear:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
    f.gear:SetHighlightTexture("Interface\\Buttons\\UI-OptionsButton")
    local gearHi = f.gear.GetHighlightTexture and f.gear:GetHighlightTexture()
    if gearHi and gearHi.SetAlpha then gearHi:SetAlpha(0.5) end
    f.gear:SetScript("OnClick", function()
        if RGXProf.OptionsWindow and RGXProf.OptionsWindow.Toggle then RGXProf.OptionsWindow:Toggle() end
    end)
    f.gear:SetScript("OnEnter", function(s)
        GameTooltip:SetOwner(s, "ANCHOR_BOTTOM")
        GameTooltip:SetText(RGXProf.L.SETTINGS, 1, 1, 1)
        GameTooltip:Show()
    end)
    f.gear:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Landing page: profession grid with live skill under each.
    f.landing = CreateFrame("Frame", nil, f)
    f.landing:SetPoint("TOPLEFT", f.progress, "BOTTOMLEFT", INSET - 1, -(INSET + 4))
    f.landing:SetPoint("BOTTOMRIGHT", -INSET, 12)

    f.landingHint = f.landing:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.landingHint:SetPoint("TOP", 0, -10)

    -- Re-lay out the profession grid and detail page whenever the window
    -- is resized. Throttled: the manual sizer fires OnSizeChanged every
    -- frame of the drag, and a full rebuild per tick stutters (the detail
    -- pass re-queries crafts, reagents, and vendors). A pending rebuild is
    -- flushed on sizer release so content settles at the final size.
    f:HookScript("OnSizeChanged", function()
        if f.landing:IsShown() then BuildLanding(self) end
        if f.guide:IsShown() then LayoutDetail(self) end
    end)

    -- Guide view: left step list + right detail.
    f.guide = CreateFrame("Frame", nil, f)
    f.guide:SetPoint("TOPLEFT", f.progress, "BOTTOMLEFT", INSET - 1, -(INSET + 4))
    f.guide:SetPoint("BOTTOMRIGHT", -INSET, 12 + 26 + INSET) -- room for the footer row under the list
    f.guide:Hide()

    -- Rounded panel behind the recipe list column: the same nine-slice
    -- panel skin as the other RGX surfaces; the step rows render on top.
    -- The old 1px divider is retired - the two panel borders now provide
    -- the column separation.
    f.stepPanel = Design:CreateFrame(f.guide, { width = LIST_WIDTH })
    f.stepPanel:SetPoint("TOPLEFT", 0, 0)
    f.stepPanel:SetPoint("BOTTOMLEFT", 0, 0)

    -- Step list (wheel-scrolled plain ScrollFrame; portable across flavors).
    f.stepScroll = CreateFrame("ScrollFrame", nil, f.stepPanel)
    f.stepScroll:SetPoint("TOPLEFT", INSET, -INSET)
    f.stepScroll:SetPoint("BOTTOMRIGHT", -INSET, INSET)
    f.stepScroll:EnableMouse(true)
    f.stepScroll:EnableMouseWheel(true)

    f.stepContent = CreateFrame("Frame", nil, f.stepScroll)
    f.stepContent:SetSize(LIST_WIDTH - INSET * 2, 1)
    f.stepScroll:SetScrollChild(f.stepContent)
    f.stepScroll:HookScript("OnSizeChanged", function(_, w) if w and w > 1 then f.stepContent:SetWidth(w) end end)

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

    -- Detail pane (right half): a scrollable card column so the cards can
    -- never overflow the window height; the canvas grows and the scroll
    -- frame keeps every card reachable. Lifted 8px so the framework's
    -- scroll inset cancels out and the first card sits tight under the
    -- panel top.
    local detail = CreateFrame("Frame", nil, f.guide)
    detail:SetPoint("TOPLEFT", f.detailPanel, "TOPLEFT", 0, 0)
    detail:SetPoint("BOTTOMRIGHT", f.detailPanel, "BOTTOMRIGHT", 0, 0)
    f.detail = detail

local UI = assert(_G.RGXUI, "RGXProf: RGXUI unavailable")
    local canvas = UI:CreateScrollPage(detail, 0)
    detail.canvas = canvas
    canvas:SetHeight(1)

    -- Recipe card ("next up"): icon + recipe name on the left, the big craft count on the right, then
    -- the one-line instruction, the skill-up colour ladder, any training note, and a progress bar
    -- through this step. Everything is positioned in LayoutDetail from explicit sizes.
    detail.recipeCard = AlignSection(UI:CreateSection(canvas, { title = RGXProf.L.NEXT_UP, square = false }))
    local rc = detail.recipeCard.content

    detail.icon = rc:CreateTexture(nil, "ARTWORK")
    detail.icon:SetSize(44, 44)
    detail.icon:SetPoint("TOPLEFT", 0, -HEADER_GAP)

    detail.title = rc:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    detail.title:SetPoint("LEFT", detail.icon, "RIGHT", 10, 0)
    detail.title:SetJustifyH("LEFT")
    detail.title:SetWordWrap(true)

    -- Hovering the icon or the name shows the real recipe tooltip.
    detail.titleHover = CreateFrame("Frame", nil, rc)
    detail.titleHover:SetPoint("TOPLEFT", detail.icon, "TOPLEFT", 0, 0)
    detail.titleHover:SetPoint("BOTTOMRIGHT", detail.title, "BOTTOMRIGHT", 0, 0)
    detail.titleHover:EnableMouse(true)
    detail.titleHover:SetScript("OnEnter", function(s) ShowStepTooltip(s, detail._step) end)
    detail.titleHover:SetScript("OnLeave", function() GameTooltip:Hide() end)

    detail.stat = rc:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    detail.stat:SetJustifyH("RIGHT")
    detail.statLabel = rc:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detail.statLabel:SetJustifyH("RIGHT")
    detail.statLabel:SetTextColor(0.62, 0.62, 0.66)

    detail.instruct = rc:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    detail.instruct:SetJustifyH("LEFT")
    detail.instruct:SetWordWrap(true)
    detail.ladder = rc:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detail.ladder:SetJustifyH("LEFT")
    detail.ladder:SetWordWrap(true)
    detail.meta = rc:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detail.meta:SetJustifyH("LEFT")
    detail.meta:SetWordWrap(true)

    detail.stepBar = CreateFrame("StatusBar", nil, rc)
    detail.stepBar:SetHeight(6)
    detail.stepBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    detail.stepBar:SetStatusBarColor(BRAND_TEXT[1], BRAND_TEXT[2], BRAND_TEXT[3])
    detail.stepBar:SetMinMaxValues(0, 1)
    local stepBarBg = detail.stepBar:CreateTexture(nil, "BACKGROUND")
    stepBarBg:SetAllPoints()
    SetTextureColor(stepBarBg, 1, 1, 1, 0.08)
    detail.barCaption = rc:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detail.barCaption:SetJustifyH("LEFT")
    detail.barCaption:SetTextColor(0.62, 0.62, 0.66)

    -- Middle row: Materials 46% | Where 54%. Cards are positioned and sized in LayoutDetail (one anchor
    -- plus an explicit size each); nothing here depends on another frame's measured position.
    detail.matsCard = AlignSection(UI:CreateSection(canvas, { title = RGXProf.L.MATERIALS, square = false }))

    -- Material rows: each row self-sizes to its wrapped content and shows the real item tooltip.
    detail.materials = {}
    for i = 1, 8 do
        local row = CreateFrame("Frame", nil, detail.matsCard.content)
        if i == 1 then
            row:SetPoint("TOPLEFT", 0, -HEADER_GAP)
            row:SetPoint("TOPRIGHT", 0, -HEADER_GAP)
        else
            row:SetPoint("TOPLEFT", detail.materials[i - 1], "BOTTOMLEFT", 0, -3)
            row:SetPoint("TOPRIGHT", detail.materials[i - 1], "BOTTOMRIGHT", 0, -3)
        end
        row:EnableMouse(true)
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(16, 16)
        row.icon:SetPoint("TOPLEFT", 0, 0)
        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 6, -1)
        row.name:SetJustifyH("LEFT")
        row.name:SetWordWrap(true)
        row.name:SetNonSpaceWrap(true)
        row.count = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.count:SetPoint("TOPRIGHT", 0, -1)
        row.count:SetJustifyH("RIGHT")
        row.count:SetTextColor(0.9, 0.9, 0.9)
        row:SetScript("OnEnter", function(s)
            if not (s.itemID and GameTooltip) then return end
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            local shown = GameTooltip.SetItemByID and pcall(GameTooltip.SetItemByID, GameTooltip, s.itemID)
            if not shown then pcall(GameTooltip.SetHyperlink, GameTooltip, "item:" .. s.itemID) end
            if s.need then
                GameTooltip:AddLine(string.format("You have %d of %d needed", s.have or 0, s.need), 0.62, 0.62, 0.66)
            end
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row:Hide()
        detail.materials[i] = row
    end

    detail.locCard = AlignSection(UI:CreateSection(canvas, { title = RGXProf.L.WHERE_TO_GET, square = false }))
    local lc = detail.locCard.content

    detail.locHeader = lc:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    detail.locHeader:SetJustifyH("LEFT")
    detail.locHeader:SetWordWrap(true)
    detail.locHeader:SetNonSpaceWrap(true)
    detail.locHeader:SetTextColor(0.95, 0.95, 0.95)

    detail.locCoords = lc:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detail.locCoords:SetJustifyH("LEFT")
    detail.locCoords:SetWordWrap(true)
    detail.locCoords:SetNonSpaceWrap(true)
    detail.locCoords:SetTextColor(0.7, 0.7, 0.74)

    detail.locAction = lc:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detail.locAction:SetJustifyH("LEFT")
    detail.locAction:SetWordWrap(true)
    detail.locAction:SetNonSpaceWrap(true)

    -- The whole card is the pin button: click sets a map waypoint on the nearest vendor / trainer.
    detail.locHit = CreateFrame("Button", nil, detail.locCard)
    detail.locHit:SetAllPoints(detail.locCard)
    detail.locHit:RegisterForClicks("LeftButtonUp")
    detail.locHit:SetScript("OnClick", function()
        if detail._pinTarget then RGXProf.BookWindow.PinTarget(detail._pinTarget) end
    end)
    detail.locHit:SetScript("OnEnter", function(s)
        local t = detail._pinTarget
        if not (t and GameTooltip) then return end
        GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
        GameTooltip:SetText(t.name or "Unknown", 1, 1, 1)
        if t.x and t.y then GameTooltip:AddLine(string.format("%.1f, %.1f", t.x, t.y), 0.7, 0.7, 0.74) end
        GameTooltip:AddLine(RGXProf.L.PIN_HINT, BRAND_TEXT[1], BRAND_TEXT[2], BRAND_TEXT[3])
        GameTooltip:Show()
    end)
    detail.locHit:SetScript("OnLeave", function() GameTooltip:Hide() end)
    detail.locHit:Hide()

    detail.notesCard = AlignSection(UI:CreateSection(canvas, { title = "Notes", square = false }))
    detail.notes = detail.notesCard.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detail.notes:SetJustifyH("LEFT")
    detail.notes:SetWordWrap(true)
    detail.notes:SetNonSpaceWrap(true)
    detail.notes:SetTextColor(0.9, 0.9, 0.9)

    -- Footer buttons.
    -- Footer buttons fill the width under the step list exactly: two halves with an INSET gap,
    -- anchored to the list panel's own edges so they always line up with that column.
    local FOOTER_GAP = INSET
    local footerW = math.floor((LIST_WIDTH - FOOTER_GAP) / 2)
    f.backBtn = NewButton(f, RGXProf.L.BTN_BACK_PROFESSIONS, footerW, 26)
    f.backBtn:SetPoint("TOPLEFT", f.stepPanel, "BOTTOMLEFT", 0, -INSET)
    f.backBtn:SetTooltip("Back", RGXProf.L.TIP_BACK)
    f.backBtn:SetScript("OnClick", function()
        RGXProf_Settings.bookProfessionID = nil
        RGXProf.BookWindow:Show()
    end)

    f.matsBtn = NewButton(f, RGXProf.L.BTN_MATS_TO_MAX, footerW, 26)
    f.matsBtn:SetPoint("TOPRIGHT", f.stepPanel, "BOTTOMRIGHT", 0, -INSET)
    -- Small font so longer translations ("Matériaux jusqu'au maximum") still fit the half width.
    for _, b in ipairs({ f.backBtn, f.matsBtn }) do
        if b.label and b.label.SetFontObject then b.label:SetFontObject("GameFontNormalSmall") end
    end
    f.matsBtn:SetTooltip(RGXProf.L.BTN_MATS_TO_MAX, RGXProf.L.TIP_MATS_TO_MAX)
    f.matsBtn:SetScript("OnClick", function()
        local professionID = RGXProf.BookWindow:GetCurrentProfession()
        if not professionID then return end
        local prof = RGXProf.Constants.Professions[professionID]
        local skill = LiveSkill(professionID)
        RGXProf.MatsWindow:Show({
            icon = prof.icon,
            name = prof.name,
            professionID = professionID,
            currentSkill = skill or 1,
            path = RGXProf.currentExpansion.paths[professionID],
        })
    end)

    self.rows = {}
    self.frame = f
end

-- Everything the guide draws is built inside RGXProfessions' theme: its primary/accent in the framework's
-- RGX Material Round style (rounded panels, cards, headers and buttons).
function RGXProf.BookWindow:EnsureFrame()
    if self.frame then return end
    RGXProf.Themed(function() BuildFrame(self) end)
end

--------------------------------------------------------------------------------
-- Step list rows
--------------------------------------------------------------------------------

-- Row highlight helpers. The first row sits on the panel's rounded top
-- corners, so its highlight is a rounded-corner slice set (clipped to the
-- panel's curve); every other row uses a flat full-bleed rectangle.
-- Color via positional SetColorTexture/SetVertexColor + SetAlpha, the same
-- form Blizzard's FrameXML uses on this client (verified against the
-- forever UI dump); wrap in pcall so a per-texture quirk can never abort
-- the hover handler.
local function RowHighlightSetColor(row, r, g, b, a)
    if row.bgIsSlice then
        for _, tx in ipairs(row.bgPieces) do
            pcall(tx.SetVertexColor, tx, r, g, b)
            pcall(tx.SetAlpha, tx, a)
        end
    else
        pcall(row.bg.SetColorTexture, row.bg, r, g, b, a)
    end
end

local function HighlightAlpha()
    return 0.18
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

    -- Highlight layer. Row 1 sits on the panel's rounded top corners:
    -- nine-slice the same rounded panel texture (rounded top corners,
    -- solid body) so the fill terminates inside the curve instead of
    -- poking past the rounded border. Other rows keep the flat fill.
    row.bgIsSlice = false -- rows sit inside the panel padding, clear of its rounded corners
    if row.bgIsSlice then
        local R = 12
        local function piece(u1, u2, v1, v2)
            local tx = row:CreateTexture(nil, "BACKGROUND")
            tx:SetTexture(PanelTexture())
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
            RowHighlightSetColor(s, unpack(BRAND_RGB), HighlightAlpha())
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
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", f.stepContent, "TOPLEFT", 0, -((i - 1) * ROW_HEIGHT))
        row:SetPoint("TOPRIGHT", f.stepContent, "TOPRIGHT", 0, -((i - 1) * ROW_HEIGHT))
        row._selected = (i == selected)
        row._step = step

        -- Range colored by step difficulty relative to live skill
        local diff = StepDifficulty(step, skill)
        local rangeHex = (diff and DiffColorHex(diff)) or Label()
        row.range:SetText(string.format("%s%d - %d", rangeHex, step.minSkill, step.maxSkill))

        local name = step.name or (RGXProf.L.RECIPE_PREFIX .. (step.spellID or i))
        row.name:SetText(Text() .. name .. (step.alternate and (Dim() .. RGXProf.L.ALT_SUFFIX) or ""))

        if row._selected then
            RowHighlightSetColor(row, ar, ag, ab, HighlightAlpha())
            RowHighlightShow(row, true)
        else
            RowHighlightShow(row, false)
        end

        if i == currentIdx then
            SetTextureColor(row.current, ar, ag, ab, 0.9)
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

-- Which rows the Materials card shows, in order. The card has 8 rows: reagents first
-- (6 plus a "+ N more" row when there are more than 7), then the optional to-max
-- summary, so the summary always fits. Pure function; see tests/MaterialEntries.test.lua.
-- BEGIN MATERIAL ENTRIES
function RGXProf.BookWindow.BuildMaterialEntries(reagents, hasSummary)
    local entries = {}
    reagents = reagents or {}
    if #reagents == 0 then
        entries[1] = { kind = "empty" }
    else
        local limit = (#reagents > 7) and 6 or #reagents
        for i = 1, limit do
            entries[#entries + 1] = { kind = "reagent", reagent = reagents[i] }
        end
        if #reagents > 7 then
            entries[#entries + 1] = { kind = "more", hidden = #reagents - 6 }
        end
    end
    if hasSummary then
        entries[#entries + 1] = { kind = "summary" }
    end
    return entries
end
-- END MATERIAL ENTRIES

RenderDetail = function(self)
    local f = self.frame
    local detail = f.detail
    local canvas = detail.canvas
    local professionID = self:GetCurrentProfession()
    if not professionID then return end

    local path = RGXProf.currentExpansion.paths[professionID]
    local page = SelectedPage(professionID)
    local step = path[page]
    if not step then return end

    local skill = LiveSkill(professionID)
    local player = RGXProf.WowAPI and RGXProf.WowAPI.GetPlayer and RGXProf.WowAPI:GetPlayer() or nil
    local faction = player and player.faction or "Alliance"

    -- Title + icon. The name always comes from the path data; a resolved
    -- item link can name the WRONG recipe when a step's itemID is off.
    detail._step = step
    local display = RGXProf.WowAPI:GetItemLinkAndIconOrSpell(step)
    detail.icon:SetTexture(display.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    detail.title:SetText(Text() .. (step.name or ""))

    -- "Next up" card: the big number on the right is what to do now (crafts left, or points to gather),
    -- the instruction line says it in words, and the ladder shows when the recipe stops giving skill.
    local fromSkill = math.max(step.minSkill, skill or step.minSkill)
    local crafts = 0
    if not skill or skill < step.maxSkill then
        crafts = RGXProf.DataManager:GetEstimatedCrafts(fromSkill, step) or 0
    end

    local statNum, statLabel, instruct
    if skill and skill >= step.maxSkill then
        statNum, statLabel = "OK", RGXProf.L.STAT_DONE
        instruct = C("success") .. RGXProf.L.INSTR_DONE
    elseif step.source == "gather" then
        statNum, statLabel = tostring(math.max(0, step.maxSkill - fromSkill)), RGXProf.L.STAT_POINTS
        instruct = Instruct() .. "Gather until skill " .. Text() .. step.maxSkill
    elseif crafts > 0 then
        statNum, statLabel = tostring(crafts), RGXProf.L.STAT_CRAFTS
        instruct = Instruct() .. "Craft " .. Text() .. crafts .. Instruct() .. " more to reach " .. Text() .. step.maxSkill
    else
        statNum, statLabel = "", ""
        instruct = Dim() .. string.format("Skill %d-%d", step.minSkill, step.maxSkill)
    end
    detail.stat:SetText(statNum)
    detail.stat:SetTextColor(BRAND_TEXT[1], BRAND_TEXT[2], BRAND_TEXT[3])
    detail.statLabel:SetText(statLabel)
    detail.instruct:SetText(instruct)

    -- Skill-up ladder: orange below the first number, then yellow, green and grey at the numbers shown.
    local c = step.colors
    if c and c.y and c.g and c.r then
        detail.ladder:SetText(string.format("%s%s|r  %s%d|r  %s%d|r  %s%d|r",
            Dim(), RGXProf.L.LADDER_LABEL, "|cffffff00", c.y, "|cff40bf40", c.g, "|cff9d9d9d", c.r))
    else
        detail.ladder:SetText("")
    end

    -- Extra lines are only actionable facts: when you can train it, and Classic-style alternates.
    local lines = {}
    if step.learnAt then
        if skill and skill >= step.learnAt then
            table.insert(lines, C("success") .. RGXProf.L.TRAIN_AVAILABLE)
        else
            table.insert(lines, Dim() .. string.format(RGXProf.L.TRAIN_AT, step.learnAt))
        end
    end
    if step.alternate then
        table.insert(lines, Dim() .. "Alternate")
    end
    detail.meta:SetText(table.concat(lines, "\n"))

    -- Progress through this step.
    detail.stepBar:SetMinMaxValues(step.minSkill, math.max(step.maxSkill, step.minSkill + 1))
    detail.stepBar:SetValue(math.min(math.max(skill or step.minSkill, step.minSkill), step.maxSkill))
    if skill then
        detail.barCaption:SetText(string.format(RGXProf.L.STEP_PROGRESS, math.max(skill, step.minSkill), step.maxSkill))
    else
        detail.barCaption:SetText(string.format("%d - %d", step.minSkill, step.maxSkill))
    end

    -- Materials: structured rows - icon left, name flexible, have/need right. Hover shows the item.
    local displayCrafts = crafts > 0 and crafts or (RGXProf.DataManager:GetEstimatedCrafts(step.minSkill, step) or 1)
    local reagents = step.spellID and RGXProf.DataManager:GetReagentListWithDetails(step.spellID, displayCrafts) or {}
    reagents = reagents or {}
    -- "To max" totals with live bag counts, one compact row at the end of the card.
    local summaryText
    local okS, summary = pcall(function()
        return RGXProf.DataManager:GetRemainingMaterialsSummary(skill or step.minSkill, path)
    end)
    if okS and summary and summary.items > 0 then
        local color = summary.missing == 0 and C("success") or C("warning")
        summaryText = Dim() .. string.format(RGXProf.L.MATS_TO_MAX_SUMMARY, summary.skillCap, summary.items)
            .. " " .. color .. string.format(RGXProf.L.MATS_STILL_NEEDED, summary.missing)
    end
    local entries = RGXProf.BookWindow.BuildMaterialEntries(reagents, summaryText ~= nil)
    for i = 1, 8 do
        local row = detail.materials[i]
        local entry = entries[i]
        row.itemID, row.need, row.have = nil, nil, nil
        if entry and entry.kind == "summary" then
            row.icon:Hide()
            row.name:SetText(summaryText)
            row.count:SetText("")
            row:Show()
        elseif entry and entry.kind == "more" then
            row.icon:Hide()
            row.name:SetText(Dim() .. string.format("+ %d more", entry.hidden))
            row.count:SetText("")
            row:Show()
        elseif entry and entry.kind == "reagent" then
            local reagent = entry.reagent
            row.icon:SetTexture(reagent.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
            row.icon:Show()
            local have = tonumber(reagent.onHandCount) or 0
            local need = tonumber(reagent.requiredCount) or 0
            local haveHex = (have >= need) and C("success") or C("warning")
            row.itemID, row.need, row.have = reagent.itemID, need, have
            row.name:SetText(Text() .. need .. Dim() .. "x " .. Text() .. (reagent.name or tostring(reagent.itemID)))
            row.count:SetText(haveHex .. string.format("%d/%d", have, need))
            row:Show()
        elseif entry and entry.kind == "empty" then
            row.icon:Hide()
            row.name:SetText(Dim() .. RGXProf.L.NO_REAGENT_DATA)
            row.count:SetText("")
            row:Show()
        else
            row:Hide()
        end
    end

    -- Where: the nearest vendor / trainer (click pins it on the map); gathering steps list their zones.
    local vendors = step.npcs and RGXProf.DataManager:GetVendors(step, faction) or {}
    local trainers = RGXProf.DataManager:GetTrainers(faction, step.minSkill, professionID) or {}
    local allLocs = {}
    for _, v in ipairs(vendors) do table.insert(allLocs, v) end
    for _, t in ipairs(trainers) do table.insert(allLocs, t) end
    detail._pinTarget = NearestNpc(allLocs)

    if detail._pinTarget then
        local target = detail._pinTarget
        local nameLine = Text() .. (target.name or "Unknown")
        local zone = ""
        if target.zoneID and RGXProf.WowAPI and RGXProf.WowAPI.GetMapName then
            local ok, zname = pcall(RGXProf.WowAPI.GetMapName, RGXProf.WowAPI, target.zoneID)
            if ok and zname then zone = zname end
        end
        if zone ~= "" then
            nameLine = nameLine .. "\n" .. Dim() .. zone
        end
        detail.locHeader:SetText(nameLine)
        if target.x and target.y then
            detail.locCoords:SetText(Dim() .. string.format("%.1f, %.1f", target.x, target.y))
        else
            detail.locCoords:SetText("")
        end
        detail.locAction:SetText(BRAND_TEXT_HEX .. RGXProf.L.PIN_HINT)
        detail.locHit:Show()
    elseif step.zones and ((step.zones.alliance and step.zones.alliance ~= "") or (step.zones.horde and step.zones.horde ~= "")) then
        local first = (faction == "Horde") and step.zones.horde or step.zones.alliance
        local second = (faction == "Horde") and step.zones.alliance or step.zones.horde
        detail.locHeader:SetText(Text() .. (first or ""))
        detail.locCoords:SetText((second and second ~= "") and (Dim() .. second) or "")
        detail.locAction:SetText("")
        detail.locHit:Hide()
    else
        detail.locHeader:SetText(Dim() .. RGXProf.L.TRAINER_TAUGHT)
        detail.locCoords:SetText("")
        detail.locAction:SetText("")
        detail.locHit:Hide()
    end

    -- Notes: hide the card entirely when there is nothing to say.
    local notes = {}
    if IsKeep(step) then
        table.insert(notes, BRAND_TEXT_HEX .. RGXProf.L.KEEP_FOR_LATER)
        if step.keepNote then
            table.insert(notes, Text() .. step.keepNote)
        end
    end
    if step.note and step.note ~= "" then table.insert(notes, Text() .. step.note) end
    if type(step.quests) == "table" and #step.quests > 0 then table.insert(notes, Dim() .. RGXProf.L.REQUIRES_QUEST) end

    if #notes > 0 then
        detail.notesCard:Show()
        detail.notes:SetText(table.concat(notes, "\n"))
    else
        detail.notesCard:Hide()
    end

    LayoutDetail(self)
end

-- Click on the Where card: put a waypoint on the map. Forever has no UiMapPoint helper (it only loads
-- on Retail), so the point is a plain table with the same shape; TomTom is used when it is installed.
function RGXProf.BookWindow.PinTarget(target)
    if not (target and target.zoneID and target.x and target.y) then return false end
    local mapID, x, y = target.zoneID, target.x / 100, target.y / 100
    local name = target.name or "RGX Professions"
    if C_Map and C_Map.SetUserWaypoint and CreateVector2D then
        local can = true
        if C_Map.CanSetUserWaypointOnMap then
            local ok, result = pcall(C_Map.CanSetUserWaypointOnMap, mapID)
            can = ok and result ~= false
        end
        if can then
            local point = { uiMapID = mapID, position = CreateVector2D(x, y) }
            if UiMapPoint and UiMapPoint.CreateFromCoordinates then
                point = UiMapPoint.CreateFromCoordinates(mapID, x, y)
            end
            local ok = pcall(C_Map.SetUserWaypoint, point)
            if ok then
                if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                    pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
                end
                RGXProf.Utils:SendMsg(string.format(RGXProf.L.PIN_SET, name))
                return true
            end
        end
    end
    if TomTom and TomTom.AddWaypoint then
        local ok = pcall(TomTom.AddWaypoint, TomTom, mapID, x, y, { title = name })
        if ok then
            RGXProf.Utils:SendMsg(string.format(RGXProf.L.PIN_SET, name))
            return true
        end
    end
    RGXProf.Utils:SendMsg(string.format(RGXProf.L.PIN_FALLBACK, name, target.x, target.y))
    return false
end

-- Geometry only: every card width and height is computed from the canvas width and the text itself,
-- never read back from frame positions (which are not resolved yet on the frame the text changes) and
-- never both anchored and sized. That keeps the cards aligned and lets the pane reflow cheaply on
-- every step of a window resize.
LayoutDetail = function(self)
    local f = self.frame
    local detail = f and f.detail
    if not (detail and detail.canvas and detail.recipeCard) then return end
    local canvas = detail.canvas
    local canvasW = canvas:GetWidth() or 0
    if canvasW < 50 then canvasW = (detail:GetWidth() or 0) - 16 end
    if canvasW < 50 then return end

    local GAP = 8
    local full = math.max(120, canvasW)                -- padding is the scroll page inset
    local function insets(card) return card.contentTopInset or 42, card.contentBottomInset or 12 end
    local function textH(fs)
        local text = fs:GetText()
        if text == nil or text == "" then return 0 end
        return fs:GetStringHeight() or 0
    end
    local function place(card, x, y, w, h)
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, -y)
        card:SetSize(w, h)
    end

    -- Recipe card: [icon][name .......... big number] / instruction / ladder / training / bar + caption.
    local rt, rb = insets(detail.recipeCard)
    local rInner = full - 32
    local ICON = 44

    detail.stat:ClearAllPoints()
    detail.stat:SetPoint("TOPRIGHT", detail.recipeCard.content, "TOPRIGHT", 0, -HEADER_GAP)
    detail.statLabel:ClearAllPoints()
    detail.statLabel:SetPoint("TOPRIGHT", detail.stat, "BOTTOMRIGHT", 0, -1)
    local statW = math.max(detail.stat:GetStringWidth() or 0, detail.statLabel:GetStringWidth() or 0)
    if statW > 0 then statW = statW + 12 end

    detail.title:ClearAllPoints()
    detail.title:SetPoint("LEFT", detail.icon, "RIGHT", 10, 0)
    detail.title:SetWidth(math.max(40, rInner - ICON - 10 - statW))
    local headRow = math.max(ICON, textH(detail.title), (detail.stat:GetText() or "") ~= "" and (textH(detail.stat) + 1 + textH(detail.statLabel)) or 0)

    local y = HEADER_GAP + headRow + 10
    local function stack(fs, gap)
        fs:ClearAllPoints()
        fs:SetPoint("TOPLEFT", detail.recipeCard.content, "TOPLEFT", 0, -y)
        fs:SetWidth(math.max(40, rInner))
        local h = textH(fs)
        if h > 0 then y = y + h + gap end
    end
    stack(detail.instruct, 4)
    stack(detail.ladder, 4)
    stack(detail.meta, 4)

    detail.stepBar:ClearAllPoints()
    detail.stepBar:SetPoint("TOPLEFT", detail.recipeCard.content, "TOPLEFT", 0, -(y + 4))
    detail.stepBar:SetWidth(math.max(40, rInner))
    y = y + 4 + 6
    detail.barCaption:ClearAllPoints()
    detail.barCaption:SetPoint("TOPLEFT", detail.recipeCard.content, "TOPLEFT", 0, -(y + 3))
    detail.barCaption:SetWidth(math.max(40, rInner))
    y = y + 3 + textH(detail.barCaption)

    local recipeH = rt + y + rb + 4
    place(detail.recipeCard, 0, 0, full, recipeH)

    -- Middle row: Materials 46% | Where to get it 54%, both cards the same height so the row is level.
    local wM = math.floor((full - GAP) * 0.46)
    local wL = full - GAP - wM

    local mt, mb = insets(detail.matsCard)
    local nameW = math.max(30, (wM - 32) - 22 - 44)
    local matsContent, shown = HEADER_GAP, 0
    for i = 1, #detail.materials do
        local row = detail.materials[i]
        if row:IsShown() then
            row.name:ClearAllPoints()
            row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 6, -1)
            row.name:SetWidth(nameW)
            local h = math.max(textH(row.name) + 2, 18)
            row:SetHeight(h)
            matsContent = matsContent + h + (shown > 0 and 3 or 0)
            shown = shown + 1
        end
    end

    local lt, lb = insets(detail.locCard)
    local locW = math.max(30, wL - 32)
    local locContent = HEADER_GAP
    detail.locHeader:ClearAllPoints()
    detail.locHeader:SetPoint("TOPLEFT", detail.locCard.content, "TOPLEFT", 0, -HEADER_GAP)
    detail.locHeader:SetWidth(locW)
    detail.locCoords:ClearAllPoints()
    detail.locCoords:SetPoint("TOPLEFT", detail.locHeader, "BOTTOMLEFT", 0, -3)
    detail.locCoords:SetWidth(locW)
    detail.locAction:ClearAllPoints()
    detail.locAction:SetPoint("TOPLEFT", detail.locCoords, "BOTTOMLEFT", 0, -6)
    detail.locAction:SetWidth(locW)
    locContent = locContent + textH(detail.locHeader)
    local cH, aH = textH(detail.locCoords), textH(detail.locAction)
    if cH > 0 then locContent = locContent + 3 + cH end
    if aH > 0 then locContent = locContent + 6 + aH end

    local rowH = math.max(mt + matsContent + mb + 4, lt + locContent + lb + 4)
    local rowY = recipeH + GAP
    place(detail.matsCard, 0, rowY, wM, rowH)
    place(detail.locCard, wM + GAP, rowY, wL, rowH)

    -- Notes card: full width below the middle row, only when it has text.
    local bottom = rowY + rowH
    if detail.notesCard:IsShown() then
        local nt, nb = insets(detail.notesCard)
        detail.notes:ClearAllPoints()
        detail.notes:SetPoint("TOPLEFT", detail.notesCard.content, "TOPLEFT", 0, -HEADER_GAP)
        detail.notes:SetWidth(math.max(40, full - 32))
        local notesH = nt + HEADER_GAP + textH(detail.notes) + nb + 4
        place(detail.notesCard, 0, bottom + GAP, full, notesH)
        bottom = bottom + GAP + notesH
    end

    canvas:SetHeight(math.max(bottom + 10, detail:GetHeight() or 0))
end

--------------------------------------------------------------------------------
-- Landing page
--------------------------------------------------------------------------------

BuildLanding = function(self)
    local landing = self.frame.landing
    landing._buttons = landing._buttons or {}

    local professions = GetGuideProfessions()
    for i = #professions + 1, #landing._buttons do
        landing._buttons[i]:Hide()
    end
    self.frame.landingHint:SetText(Dim() .. "Choose a profession to open its leveling path.")
    self.frame.landingHint:ClearAllPoints()
    self.frame.landingHint:SetPoint("TOP", landing, "TOP", 0, -INSET)

    -- Host size is 0 until first layout resolves; fall back to the design size.
    local availW = landing:GetWidth() or 0
    if availW <= 0 then availW = 600 end
    local availH = landing:GetHeight() or 0
    if availH <= 0 then availH = 340 end

    -- Stable tile geometry: tiles keep a readable size and the grid wraps, instead of every tile
    -- stretching with the window. Columns come from the width, tile height from the rows that fit.
    local GAP = 10
    local TOP = INSET + 24 -- under the hint line
    local count = math.max(1, #professions)
    local columns = math.max(2, math.min(6, math.floor((availW + GAP) / (128 + GAP))))
    columns = math.min(columns, count)
    local rowsNeeded = math.ceil(count / columns)
    local tileW = math.max(112, math.min(172, math.floor((availW - GAP * (columns - 1)) / columns)))
    local tileH = math.max(86, math.min(120, math.floor((availH - TOP - GAP * (rowsNeeded - 1)) / rowsNeeded)))
    local gridW = columns * tileW + (columns - 1) * GAP
    local originX = math.max(0, math.floor((availW - gridW) / 2))
    local iconSize = math.max(28, math.min(48, math.floor(tileH * 0.38)))

    for index, professionID in ipairs(professions) do
        local prof = RGXProf.Constants.Professions[professionID]
        local btn = landing._buttons[index]
        if not btn then
            btn = NewButton(landing, nil, tileW, tileH)
            btn.icon = btn:CreateTexture(nil, "ARTWORK")
            btn.name = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            btn.skill = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            btn.bar = CreateFrame("StatusBar", nil, btn)
            btn.bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
            btn.bar:SetMinMaxValues(0, 1)
            local barBg = btn.bar:CreateTexture(nil, "BACKGROUND")
            barBg:SetAllPoints()
            SetTextureColor(barBg, 1, 1, 1, 0.08)
            btn:HookScript("OnEnter", function(s)
                if not (GameTooltip and s.professionName) then return end
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetText(s.professionName, 1, 1, 1)
                GameTooltip:AddLine(s.tooltipLine or "", 0.7, 0.7, 0.74)
                GameTooltip:AddLine(RGXProf.L.TILE_HINT, BRAND_TEXT[1], BRAND_TEXT[2], BRAND_TEXT[3])
                GameTooltip:Show()
            end)
            landing._buttons[index] = btn
        end
        btn:SetSize(tileW, tileH)
        btn.icon:ClearAllPoints()
        btn.icon:SetPoint("TOP", 0, -10)
        btn.icon:SetSize(iconSize, iconSize)
        btn.name:ClearAllPoints()
        btn.name:SetPoint("TOP", btn.icon, "BOTTOM", 0, -6)
        btn.name:SetWidth(tileW - 16)
        btn.name:SetJustifyH("CENTER")
        btn.name:SetWordWrap(false)
        btn.skill:ClearAllPoints()
        btn.skill:SetPoint("TOP", btn.name, "BOTTOM", 0, -3)
        btn.bar:ClearAllPoints()
        btn.bar:SetPoint("BOTTOMLEFT", 10, 9)
        btn.bar:SetPoint("BOTTOMRIGHT", -10, 9)
        btn.bar:SetHeight(4)

        local row = math.floor((index - 1) / columns)
        local col = (index - 1) % columns
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", landing, "TOPLEFT", originX + col * (tileW + GAP), -(TOP + row * (tileH + GAP)))

        btn.icon:SetTexture(prof.icon or 133741)
        btn.professionName = prof.name
        local skill, total = LiveSkill(professionID)
        if skill then
            local maxSkill = total or MaxSkill()
            btn.name:SetText(Text() .. prof.name)
            btn.icon:SetDesaturated(false)
            btn.skill:SetFontObject("GameFontHighlightSmall")
            btn.skill:SetText(string.format(RGXProf.L.SKILL_FRACTION, skill, maxSkill))
            btn.skill:SetTextColor(0.9, 0.9, 0.9)
            btn.bar:SetValue(maxSkill > 0 and math.min(1, skill / maxSkill) or 0)
            btn.bar:SetStatusBarColor(BRAND_TEXT[1], BRAND_TEXT[2], BRAND_TEXT[3])
            btn.bar:Show()
            btn.tooltipLine = string.format(RGXProf.L.SKILL_FRACTION, skill, maxSkill)
        else
            btn.name:SetText(Dim() .. prof.name)
            btn.icon:SetDesaturated(true)
            btn.skill:SetFontObject("GameFontHighlightSmall")
            btn.skill:SetText(Label() .. RGXProf.L.NOT_LEARNED)
            btn.skill:SetTextColor(0.6, 0.6, 0.64)
            btn.bar:SetValue(0)
            btn.bar:Hide()
            btn.tooltipLine = RGXProf.L.NOT_LEARNED
        end

        btn:SetScript("OnClick", function()
            RGXProf.BookWindow:OpenProfession(professionID)
        end)
        btn:Show()
    end
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

-- Shared live progress header: skill value, rank-gate hint, bar fill.
-- Used by both Show and Refresh so a skill-up re-renders identically.
local function UpdateProgressFrame(f, professionID)
    local skill, total = LiveSkill(professionID)
    local maxSkill = total or MaxSkill()
    local gate = skill and NextGate(tonumber(skill))
    local gateText = gate and (Dim() .. "  -  Train " .. Text() .. gate.rank .. Dim() .. " at " .. gate.cap) or ""
    f.progressLabel:SetText(skill and (Dim() .. "Skill " .. Text() .. skill .. Dim() .. " / " .. maxSkill .. gateText) or (Dim() .. RGXProf.L.NOT_LEARNED))
    f.progress:SetMinMaxValues(0, maxSkill)
    f.progress:SetValue(skill or 0)
end

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
        self.frame.headerIcon:SetTexture(prof.icon or "Interface\\AddOns\\RGX-Framework\\media\\square.tga")
        self.frame.headerTitle:SetText(BrandTitle(prof.name))
        UpdateProgressFrame(self.frame, professionID)

        self.frame.landing:Hide()
        self.frame.guide:Show()
        self.frame.backBtn:Show()
        self.frame.matsBtn:Show()
        RenderStepList(self)
        RenderDetail(self)
    else
        self.frame.headerIcon:SetTexture("Interface\\AddOns\\RGX-Framework\\media\\square.tga")
        self.frame.headerTitle:SetText(HEADER_TITLE)
        self.frame.progressLabel:SetText("")
        self.frame.progress:SetMinMaxValues(0, 1)
        self.frame.progress:SetValue(0)

        self.frame.guide:Hide()
        self.frame.backBtn:Hide()
        self.frame.matsBtn:Hide()
        self.frame.landing:Show()
        BuildLanding(self)
    end
    self.frame:Show()
end

-- Live refresh: the debounced profession refresh calls this on every
-- skill-up, craft, or bag change while the book is open. Re-renders the
-- step list (difficulty colors, current marker), the detail page, and the
-- progress header, and auto-advances the page once the shown step is fully
-- passed so the book tracks the player's live step. An incomplete page the
-- user is browsing is never yanked away.
function RGXProf.BookWindow:Refresh()
    local f = self.frame
    if not f or not f:IsShown() then return end
    local professionID = self:GetCurrentProfession()
    if not professionID then
        if f.landing:IsShown() then BuildLanding(self) end
        return
    end
    UpdateProgressFrame(f, professionID)
    local path = RGXProf.currentExpansion.paths[professionID]
    local skill = LiveSkill(professionID)
    local page = SelectedPage(professionID)
    local step = path and path[page]
    if skill and step and not step.alternate and skill >= step.maxSkill then
        local current = FindCurrentIndex(path, skill)
        if current and current ~= page then
            RGXProf_Settings.bookPage = current
        end
    end
    RenderStepList(self)
    RenderDetail(self)
end

-- Re-render only the detail page (counts and to-max totals) after a bag change.
function RGXProf.BookWindow:RefreshMaterials()
    local f = self.frame
    if not f or not f:IsShown() then return end
    if not self:GetCurrentProfession() then return end
    RenderDetail(self)
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
