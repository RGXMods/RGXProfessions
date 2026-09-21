--=====================================================================================
-- RGXProfessions - UI/BookWindow.lua
-- The profession leveling bible: a book-style window built on RGXDesign with a
-- button per profession and next/previous page navigation through every step.
--=====================================================================================

RGXProf = RGXProf or {}
RGXProf.BookWindow = RGXProf.BookWindow or {}

local Design = _G.RGXDesign

local BOOK_WIDTH = 560
local BOOK_HEIGHT = 440
local BUTTON_SIZE = 110

local function Accent() return "|cff8B1538" end
local function Text() return "|cffffffff" end
local function Dim() return "|cff9aa4b0" end

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

function RGXProf.BookWindow:GetCurrentProfession()
    local saved = RGXProf_Settings.bookProfessionID
    if saved and RGXProf.currentExpansion.paths[saved] then
        return saved
    end
    return nil
end

function RGXProf.BookWindow:GetCurrentPage(professionID)
    local path = RGXProf.currentExpansion.paths[professionID]
    local page = RGXProf_Settings.bookPage
    if not page or page < 1 or page > #path then
        page = 1
        local skill = RGXProf.WowAPI.GetProfessionSkill and RGXProf.WowAPI:GetProfessionSkill(RGXProf.Constants.Professions[professionID].name) or nil
        if skill then
            for i, step in ipairs(path) do
                if skill >= step.minSkill and skill < step.maxSkill and not step.alternate then
                    page = i
                    break
                end
            end
        end
    end
    return page
end

function RGXProf.BookWindow:OpenProfession(professionID)
    if not RGXProf.currentExpansion.paths[professionID] then return end
    RGXProf_Settings.bookProfessionID = professionID
    RGXProf_Settings.bookPage = self:GetCurrentPage(professionID)
    self:Show()
end

function RGXProf.BookWindow:EnsureFrame()
    if self.frame then return end

    local f = Design:CreateFrame(UIParent, {
        width = BOOK_WIDTH,
        height = BOOK_HEIGHT,
        variant = "dark",
    })
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetClampedToScreen(true)
    f:SetFrameStrata("HIGH")
    f:SetToplevel(true)
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, relFrame, relPoint, x, y = self:GetPoint()
        RGXProf_Settings.bookPosition = { point, relFrame, relPoint, x, y }
    end)
    tinsert(UISpecialFrames, f:GetName() or "RGXProfBookWindow")

    f.titleBar = Design:CreateSectionHeader(f, "RGX Professions", "Interface\\AddOns\\RGXProfessions\\Media\\PLGIcon.tga")
    f.titleBar:SetPoint("TOPLEFT", 0, 0)
    f.titleBar:SetPoint("TOPRIGHT", 0, 0)

    f.subHeader = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.subHeader:SetPoint("TOP", 0, -42)

    f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.close:SetPoint("TOPRIGHT", -4, -4)

    f.landing = Design:CreateFrame(f, { variant = "dark", bgAlpha = 0.4 })
    f.landing:SetPoint("TOPLEFT", 12, -56)
    f.landing:SetPoint("BOTTOMRIGHT", -12, 12)

    f.guide = Design:CreateFrame(f, { variant = "dark", bgAlpha = 0.4 })
    f.guide:SetPoint("TOPLEFT", 12, -56)
    f.guide:SetPoint("BOTTOMRIGHT", -12, 12)
    f.guide:Hide()

    -- Guide widgets
    f.guide.recipeIcon = f.guide:CreateTexture(nil, "ARTWORK")
    f.guide.recipeIcon:SetSize(36, 36)
    f.guide.recipeIcon:SetPoint("TOPLEFT", 12, -12)

    f.guide.recipeLink = f.guide:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.guide.recipeLink:SetPoint("LEFT", f.guide.recipeIcon, "RIGHT", 10, 0)
    f.guide.recipeLink:SetJustifyH("LEFT")

    f.guide.pageLabel = f.guide:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.guide.pageLabel:SetPoint("TOPRIGHT", -12, -14)

    f.guide.rangeLabel = f.guide:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.guide.rangeLabel:SetPoint("RIGHT", f.guide.pageLabel, "LEFT", -14, 0)

    f.guide.note = f.guide:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.guide.note:SetPoint("TOPLEFT", f.guide.recipeIcon, "BOTTOMLEFT", 0, -14)
    f.guide.note:SetPoint("RIGHT", -12, 0)
    f.guide.note:SetJustifyH("LEFT")
    f.guide.note:SetWordWrap(true)

    f.guide.reagents = f.guide:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.guide.reagents:SetPoint("TOPLEFT", 12, -130)
    f.guide.reagents:SetPoint("RIGHT", -12, 0)
    f.guide.reagents:SetJustifyH("LEFT")
    f.guide.reagents:SetWordWrap(true)
    f.guide.reagents:SetSpacing(4)

    f.guide.vendors = f.guide:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.guide.vendors:SetPoint("BOTTOMLEFT", 14, 52)
    f.guide.vendors:SetPoint("RIGHT", -12, 0)
    f.guide.vendors:SetJustifyH("LEFT")
    f.guide.vendors:SetWordWrap(true)

    f.guide.back = Design:CreateButton(f.guide, "Professions", 110, 24)
    f.guide.back:SetPoint("BOTTOMLEFT", 14, 12)
    f.guide.back:SetTooltip("Professions", "Back to the profession selection page.")

    f.guide.prev = Design:CreateButton(f.guide, "< Prev", 90, 24)
    f.guide.prev:SetPoint("BOTTOMRIGHT", -150, 12)
    f.guide.prev:SetTooltip("Previous step", "Turn back one page in this leveling path.")

    f.guide.next = Design:CreateButton(f.guide, "Next >", 90, 24)
    f.guide.next:SetPoint("BOTTOMRIGHT", -14, 12)
    f.guide.next:SetTooltip("Next step", "Turn forward one page in this leveling path.")

    f.guide.back:SetScript("OnClick", function()
        RGXProf_Settings.bookProfessionID = nil
        RGXProf.BookWindow:Show()
    end)
    f.guide.prev:SetScript("OnClick", function()
        local professionID = RGXProf.BookWindow:GetCurrentProfession()
        if not professionID then return end
        local path = RGXProf.currentExpansion.paths[professionID]
        local page = RGXProf_Settings.bookPage or 1
        RGXProf_Settings.bookPage = math.max(1, page - 1)
        RGXProf.BookWindow:Show()
    end)
    f.guide.next:SetScript("OnClick", function()
        local professionID = RGXProf.BookWindow:GetCurrentProfession()
        if not professionID then return end
        local path = RGXProf.currentExpansion.paths[professionID]
        local page = RGXProf_Settings.bookPage or 1
        RGXProf_Settings.bookPage = math.min(#path, page + 1)
        RGXProf.BookWindow:Show()
    end)

    self.frame = f
end

function RGXProf.BookWindow:BuildLanding()
    local landing = self.frame.landing
    for _, child in ipairs({landing:GetChildren()}) do
        if child:IsObjectType("Button") then
            child:Hide()
        end
    end

    local professions = GetGuideProfessions()
    local columns = 4
    local rows = math.ceil(#professions / columns)
    local colGap = 12
    local rowGap = 12
    local colWidth = BUTTON_SIZE + colGap
    local rowHeight = BUTTON_SIZE + rowGap

    for index, professionID in ipairs(professions) do
        local prof = RGXProf.Constants.Professions[professionID]
        local btn = Design:CreateButton(landing, nil, BUTTON_SIZE, BUTTON_SIZE)
        local row = math.floor((index - 1) / columns)
        local col = (index - 1) % columns
        local totalW = columns * colWidth - colGap
        local totalH = rows * rowHeight - rowGap
        btn:SetPoint("TOPLEFT", landing, "TOPLEFT", (landing:GetWidth() - totalW) / 2 + col * colWidth, -(landing:GetHeight() - totalH) / 2 - row * rowHeight)

        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetSize(38, 38)
        icon:SetPoint("TOP", 0, -12)
        icon:SetTexture(prof.icon or 133741)

        local name = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("TOP", icon, "BOTTOM", 0, -6)
        name:SetText(Text() .. prof.name)

        local skillText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        skillText:SetPoint("TOP", name, "BOTTOM", 0, -2)
        local skill = RGXProf.WowAPI.GetProfessionSkill and RGXProf.WowAPI:GetProfessionSkill(prof.name) or nil
        skillText:SetText(skill and (Dim() .. "Skill " .. skill) or (Dim() .. "Not learned"))

        btn:SetScript("OnClick", function()
            RGXProf.BookWindow:OpenProfession(professionID)
        end)
    end
end

function RGXProf.BookWindow:RenderGuide()
    local guide = self.frame.guide
    local professionID = self:GetCurrentProfession()
    if not professionID then
        guide:Hide()
        self.frame.landing:Show()
        self.frame.subHeader:SetText(Dim() .. "Choose a profession")
        return
    end

    local prof = RGXProf.Constants.Professions[professionID]
    local path = RGXProf.currentExpansion.paths[professionID]
    local page = RGXProf_Settings.bookPage or 1
    local step = path[page]
    if not step then
        page = 1
        step = path[1]
        RGXProf_Settings.bookPage = 1
    end

    self.frame.landing:Hide()
    guide:Show()

    self.frame.subHeader:SetText(Accent() .. prof.name .. "|r  " .. Dim() .. "Leveling Path")

    guide.recipeIcon:SetTexture(step.itemID and GetItemIcon(step.itemID) or "Interface\\Icons\\INV_Misc_QuestionMark")

    local display = RGXProf.WowAPI:GetItemLinkAndIconOrSpell(step)
    guide.recipeLink:SetText(display.link or (Text() .. (step.name or "")))

    guide.pageLabel:SetText(Dim() .. string.format("Page %d / %d", page, #path))

    guide.rangeLabel:SetText(string.format("%sSkill %d - %d%s", Text(), step.minSkill, step.maxSkill, step.alternate and ("  " .. Accent() .. "(alternate route)") or ""))

    local noteText = ""
    if step.keep and step.keep > 0 then
        noteText = noteText .. Dim() .. "Keep the crafted items.\n"
    end
    if step.note then
        noteText = noteText .. Text() .. step.note .. "\n"
    end
    if step.quests then
        noteText = noteText .. Dim() .. "Requires a quest (see the trainer list).\n"
    end
    guide.note:SetText(noteText)

    local crafts = math.max(1, step.maxSkill - step.minSkill)
    local reagents = RGXProf.DataManager:GetReagentListWithDetails(step.spellID, crafts)
    local lines = {}
    table.insert(lines, Accent() .. "Materials for " .. crafts .. " crafts:")
    for _, reagent in ipairs(reagents or {}) do
        local have = reagent.onHandCount or 0
        local need = reagent.requiredCount or 0
        local haveColor = (have >= need) and "|cff2e7d32" or "|cffff9900"
        table.insert(lines, string.format("%s  %s %dx %s(%d/%d)", Text(), reagent.icon or "", need, reagent.name or tostring(reagent.itemID), haveColor, have, need))
    end
    if #lines == 1 then
        table.insert(lines, Dim() .. "No material data for this step.")
    end
    guide.reagents:SetText(table.concat(lines, "\n"))

    local vendors = RGXProf.DataManager:GetVendors(step, RGXProf.WowAPI:GetPlayer().faction)
    local vendorLines = {}
    if #vendors > 0 then
        table.insert(vendorLines, Accent() .. "Vendors:")
        for _, vendor in ipairs(vendors) do
            table.insert(vendorLines, Text() .. vendor.name)
        end
    end
    guide.vendors:SetText(table.concat(vendorLines, "\n"))

    guide.prev:SetEnabled(page > 1)
    guide.next:SetEnabled(page < #path)
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
        RGXProf_Settings.bookPage = RGXProf_Settings.bookPage or self:GetCurrentPage(professionID)
        self:RenderGuide()
    else
        self.frame.guide:Hide()
        self.frame.landing:Show()
        self.frame.subHeader:SetText(Dim() .. "Choose a profession")
        self:BuildLanding()
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
