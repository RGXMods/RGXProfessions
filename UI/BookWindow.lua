--=====================================================================================
-- RGXProfessions - UI/BookWindow.lua
-- The profession leveling guide: a two-pane browser with a difficulty-colored
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
local HEADER_HEIGHT = 74

local BRAND_BORDER = { 0.545, 0.082, 0.220 } -- RGX crimson #8B1538

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
local function Accent() return C("primary") end
local function Text() return "|cffffffff" end
local function Dim() return C("subtext") end
local function Label() return C("label") end

local DIFF_WORDS = {
    optimal = { text = "Orange - always skill-ups", key = "warning" },
    medium  = { text = "Yellow - usually a skill-up", key = "accent" },
    easy    = { text = "Green - rarely a skill-up", key = "success" },
    trivial = { text = "Gray - no skill-ups", key = "label" },
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

-- Real in-game tooltip for a guide step: the crafted item when the step
-- carries an itemID, otherwise the craft spell. SetHyperlink renders true
-- client tooltips on every supported flavor.
local function ShowStepTooltip(owner, step)
    if not step then return end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    local shown = false
    if step.itemID then
        shown = pcall(GameTooltip.SetHyperlink, GameTooltip, "item:" .. step.itemID)
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
    tinsert(UISpecialFrames, f:GetName() or "RGXProfBookWindow")

    -- Brand border: RGX crimson frame ring
    if f.SetPanelColor then
        f:SetPanelColor(nil, BRAND_BORDER)
    end

    -- Single header block: icon + title + live skill + progress bar.
    f.headerIcon = f:CreateTexture(nil, "ARTWORK")
    f.headerIcon:SetSize(30, 30)
    f.headerIcon:SetPoint("TOPLEFT", 14, -14)
    f.headerIcon:SetTexture("Interface\\AddOns\\RGXProfessions\\Media\\RGXIcon.tga")

    f.headerTitle = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.headerTitle:SetPoint("LEFT", f.headerIcon, "RIGHT", 8, 0)
    f.headerTitle:SetText("Profession Leveling Guide")

    f.headerSkill = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.headerSkill:SetPoint("TOPRIGHT", -46, -20)
    f.headerSkill:SetJustifyH("RIGHT")

    f.progress = CreateFrame("StatusBar", nil, f)
    f.progress:SetPoint("TOPLEFT", 14, -50)
    f.progress:SetPoint("RIGHT", -14, 0)
    f.progress:SetHeight(8)
    f.progress:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    f.progress:SetMinMaxValues(0, MaxSkill())
    f.progress:SetValue(0)
    do
        local r, g, b = 0.0, 0.9, 1.0
        if Design then r, g, b = Design:Unpack("primary") end
        f.progress:SetStatusBarColor(r, g, b)
        local bg = f.progress:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        local br, bgc, bb = 0.137, 0.137, 0.173
        if Design then br, bgc, bb = Design:Unpack("border") end
        bg:SetColorTexture(br, bgc, bb, 0.8)
    end

    f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.close:SetPoint("TOPRIGHT", -4, -4)

    -- Landing page: profession grid with live skill under each.
    f.landing = CreateFrame("Frame", nil, f)
    f.landing:SetPoint("TOPLEFT", 12, -HEADER_HEIGHT)
    f.landing:SetPoint("BOTTOMRIGHT", -12, 12)

    f.landingHint = f.landing:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.landingHint:SetPoint("TOP", 0, -10)

    -- Guide view: left step list + right detail.
    f.guide = CreateFrame("Frame", nil, f)
    f.guide:SetPoint("TOPLEFT", 12, -HEADER_HEIGHT)
    f.guide:SetPoint("BOTTOMRIGHT", -12, 44)
    f.guide:Hide()

    f.guide.divider = f.guide:CreateTexture(nil, "ARTWORK")
    f.guide.divider:SetWidth(1)
    f.guide.divider:SetPoint("TOPLEFT", LIST_WIDTH + 16, 0)
    f.guide.divider:SetPoint("BOTTOMLEFT", LIST_WIDTH + 16, 0)
    do
        local br, bgc, bb = 0.137, 0.137, 0.173
        if Design then br, bgc, bb = Design:Unpack("border") end
        f.guide.divider:SetColorTexture(br, bgc, bb, 1)
    end

    -- Step list (wheel-scrolled plain ScrollFrame; portable across flavors).
    f.stepScroll = CreateFrame("ScrollFrame", nil, f.guide)
    f.stepScroll:SetPoint("TOPLEFT", 0, 0)
    f.stepScroll:SetSize(LIST_WIDTH, WINDOW_HEIGHT - HEADER_HEIGHT - 58)
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

    -- Detail pane (right half).
    local detail = CreateFrame("Frame", nil, f.guide)
    detail:SetPoint("TOPLEFT", LIST_WIDTH + 30, 0)
    detail:SetPoint("BOTTOMRIGHT", 0, 0)
    f.detail = detail

    detail.icon = detail:CreateTexture(nil, "ARTWORK")
    detail.icon:SetSize(36, 36)
    detail.icon:SetPoint("TOPLEFT", 6, -6)

    detail.title = detail:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    detail.title:SetPoint("LEFT", detail.icon, "RIGHT", 10, 0)
    detail.title:SetPoint("RIGHT", detail, "RIGHT", -6, 0)
    detail.title:SetJustifyH("LEFT")

    -- Hover frame over the title so the recipe shows its real in-game tooltip.
    detail.titleHover = CreateFrame("Frame", nil, detail)
    detail.titleHover:SetAllPoints(detail.title)
    detail.titleHover:EnableMouse(true)
    detail.titleHover:SetScript("OnEnter", function(s) ShowStepTooltip(s, detail._step) end)
    detail.titleHover:SetScript("OnLeave", function() GameTooltip:Hide() end)

    detail.meta = detail:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    detail.meta:SetPoint("TOPLEFT", detail.icon, "BOTTOMLEFT", 0, -10)
    detail.meta:SetPoint("RIGHT", -2, 0)
    detail.meta:SetJustifyH("LEFT")

    detail.difficulty = detail:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detail.difficulty:SetPoint("TOPLEFT", detail.meta, "BOTTOMLEFT", 0, -4)

    detail.matsHeader = detail:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    detail.matsHeader:SetPoint("TOPLEFT", detail.difficulty, "BOTTOMLEFT", 0, -14)
    detail.matsHeader:SetText("Materials")

    detail.materials = detail:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    detail.materials:SetPoint("TOPLEFT", detail.matsHeader, "BOTTOMLEFT", 0, -4)
    detail.materials:SetPoint("RIGHT", -4, 0)
    detail.materials:SetJustifyH("LEFT")
    detail.materials:SetWordWrap(true)
    detail.materials:SetSpacing(3)

    detail.locHeader = detail:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    detail.locHeader:SetPoint("TOPLEFT", detail.materials, "BOTTOMLEFT", 0, -14)

    detail.locations = detail:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detail.locations:SetPoint("TOPLEFT", detail.locHeader, "BOTTOMLEFT", 0, -4)
    detail.locations:SetPoint("RIGHT", -4, 0)
    detail.locations:SetJustifyH("LEFT")
    detail.locations:SetWordWrap(true)
    detail.locations:SetSpacing(3)

    detail.notes = detail:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detail.notes:SetPoint("TOPLEFT", detail.locations, "BOTTOMLEFT", 0, -12)
    detail.notes:SetPoint("RIGHT", -4, 0)
    detail.notes:SetJustifyH("LEFT")
    detail.notes:SetWordWrap(true)

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

local function GetRow(self, index)
    local row = self.rows[index]
    if row then return row end

    local content = self.frame.stepContent
    row = CreateFrame("Button", nil, content)
    row:SetSize(LIST_WIDTH, ROW_HEIGHT)

    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints()
    row.bg:Hide()

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

    row:SetScript("OnEnter", function(s) s.bg:Show() ShowStepTooltip(s, s._step) end)
    row:SetScript("OnLeave", function(s) if not s._selected then s.bg:Hide() end GameTooltip:Hide() end)

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

    local ar, ag, ab = 0.0, 0.9, 1.0
    if Design then ar, ag, ab = Design:Unpack("primary") end

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
        row.range:SetText(string.format("%s%d – %d", rangeHex, step.minSkill, step.maxSkill))

        local nameHex = DiffColorHex(StepDifficulty(step, skill))
        local name = step.name or ("Recipe " .. (step.spellID or i))
        if skill and step.maxSkill <= skill then
            nameHex = Dim()
        end
        row.name:SetText(nameHex .. name .. (step.alternate and (Dim() .. " (alt)") or ""))

        if row._selected then
            row.bg:SetColorTexture(ar, ag, ab, 0.14)
            row.bg:Show()
        else
            row.bg:Hide()
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

local function FormatNpcLine(npc)
    local zone = ""
    if npc.zoneID and RGXProf.WowAPI and RGXProf.WowAPI.GetMapName then
        local ok, name = pcall(RGXProf.WowAPI.GetMapName, RGXProf.WowAPI, npc.zoneID)
        if ok and name then zone = name end
    end
    local coords = ""
    if npc.x and npc.y then
        coords = string.format(" (%.1f, %.1f)", npc.x, npc.y)
    end
    return "  " .. Text() .. (npc.name or "Unknown") .. Dim() .. " — " .. zone .. coords
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

    -- Meta line: range + craft estimate
    local fromSkill = math.max(step.minSkill, skill or step.minSkill)
    local crafts = 0
    if not skill or skill < step.maxSkill then
        crafts = RGXProf.DataManager:GetEstimatedCrafts(fromSkill, step) or 0
    end
    local metaText = Accent() .. string.format("Skill %d - %d", step.minSkill, step.maxSkill)
    if crafts > 0 then
        metaText = metaText .. Dim() .. "  Â·  " .. Text() .. string.format("Craft ~%d to reach %d", crafts, step.maxSkill)
    elseif skill then
        metaText = metaText .. Dim() .. "  Â·  " .. Dim() .. "Completed"
    end
    if step.alternate then
        metaText = metaText .. Dim() .. "  Â·  " .. Dim() .. "alternate route"
    end
    detail.meta:SetText(metaText)

    -- Difficulty label
    local diff = StepDifficulty(step, skill)
    if diff and DIFF_WORDS[diff] then
        local d = DIFF_WORDS[diff]
        detail.difficulty:SetText(C(d.key) .. d.text)
    else
        detail.difficulty:SetText("")
    end

    -- Materials
    local lines = {}
    local displayCrafts = crafts > 0 and crafts or (RGXProf.DataManager:GetEstimatedCrafts(step.minSkill, step) or 1)
    local reagents = step.spellID and RGXProf.DataManager:GetReagentListWithDetails(step.spellID, displayCrafts) or {}
    for _, reagent in ipairs(reagents or {}) do
        local icon = reagent.icon and ("|T" .. reagent.icon .. ":14:14:0:0|t ") or ""
        local have = tonumber(reagent.onHandCount) or 0
        local need = tonumber(reagent.requiredCount) or 0
        local haveHex = (have >= need) and C("success") or C("warning")
        table.insert(lines, string.format("%s%s%d%sx %s %s(%d/%d)", icon, Text(), need, Dim(), reagent.name or tostring(reagent.itemID), haveHex, have, need))
    end
    if #lines == 0 then
        table.insert(lines, Dim() .. "No reagent data for this step.")
    end
    detail.materials:SetText(table.concat(lines, "\n"))

    -- Locations: vendors + trainers
    detail.locHeader:SetText("Where to get it")
    local locLines = {}

    local vendors = step.npcs and RGXProf.DataManager:GetVendors(step, faction) or {}
    if #vendors > 0 then
        table.insert(locLines, Dim() .. "Vendors:")
        for _, vendor in ipairs(vendors) do
            table.insert(locLines, FormatNpcLine(vendor))
        end
    end

    local trainers = RGXProf.DataManager:GetTrainers(faction, step.minSkill, professionID) or {}
    if #trainers > 0 then
        table.insert(locLines, Dim() .. "Trainers:")
        local shown = math.min(4, #trainers)
        for i = 1, shown do
            table.insert(locLines, FormatNpcLine(trainers[i]))
        end
        if #trainers > shown then
            table.insert(locLines, Dim() .. string.format("  …and %d more", #trainers - shown))
        end
    end

    if #locLines == 0 then
        table.insert(locLines, Dim() .. "Trainer-taught; ask any profession trainer.")
    end
    detail.locations:SetText(table.concat(locLines, "\n"))

    -- Notes
    local notes = {}
    if step.keep then table.insert(notes, C("accent") .. "Keep the crafted items for later steps.") end
    if step.note then table.insert(notes, Accent() .. "• " .. Text() .. step.note) end
    if step.quests then table.insert(notes, Dim() .. "Requires a quest (see trainer list).") end
    detail.notes:SetText(table.concat(notes, "\n"))

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
    self.frame.landingHint:SetText(Dim() .. "Choose a profession to open its leveling guide.")

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
        self.frame.headerTitle:SetText(prof.name .. " - Leveling Guide")
        local gate = skill and NextGate(tonumber(skill))
    local gateText = gate and (Dim() .. "  -  Train " .. Text() .. gate.rank .. Dim() .. " at " .. gate.cap) or ""
    self.frame.headerSkill:SetText(skill and (Dim() .. "Skill " .. Text() .. skill .. Dim() .. " / " .. maxSkill .. gateText) or (Dim() .. "Not learned"))
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
        self.frame.headerTitle:SetText("Profession Leveling Guide")
        self.frame.headerSkill:SetText("")
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
