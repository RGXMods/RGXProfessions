--=====================================================================================
-- RGXProfessions - UI/BookWindow.lua
-- The profession leveling bible: a book-style window with a button per
-- profession and next/previous page navigation through every leveling step.
--=====================================================================================

RGXProf = RGXProf or {}
RGXProf.BookWindow = RGXProf.BookWindow or {}

local RGX = _G.RGXFramework

local BOOK_WIDTH = 560
local BOOK_HEIGHT = 420
local BUTTON_SIZE = 108
local COLORS = {
    bg = {0.05, 0.07, 0.10, 0.96},
    header = {0.06, 0.10, 0.16, 0.98},
    border = {0.16, 0.22, 0.30, 1.0},
    accent = "|cff8B1538",
    text = "|cffffffff",
    dim = "|cff9aa4b0",
}

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
    local saved = RGXProfSettings.bookProfessionID
    if saved and RGXProf.currentExpansion.paths[saved] then
        return saved
    end
    return nil
end

function RGXProf.BookWindow:GetCurrentPage(professionID)
    local path = RGXProf.currentExpansion.paths[professionID]
    local page = RGXProfSettings.bookPage
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
    RGXProfSettings.bookProfessionID = professionID
    RGXProfSettings.bookPage = self:GetCurrentPage(professionID)
    self:Show()
end

function RGXProf.BookWindow:EnsureFrame()
    if self.frame then return end

    local f = CreateFrame("Frame", "RGXProfBookWindow", UIParent, "BackdropTemplate")
    f:SetSize(BOOK_WIDTH, BOOK_HEIGHT)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetClampedToScreen(true)
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        RGXProfSettings.bookPosition = {self:GetPoint()}
    end)
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    f:SetBackdropColor(unpack(COLORS.bg, 1, 4))
    f:SetBackdropBorderColor(unpack(COLORS.border, 1, 4))
    f:SetFrameStrata("HIGH")
    tinsert(UISpecialFrames, "RGXProfBookWindow")

    f.header = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.header:SetPoint("TOP", 0, -14)
    f.header:SetText(COLORS.accent .. "RGX|r Professions")

    f.subHeader = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.subHeader:SetPoint("TOP", f.header, "BOTTOM", 0, -2)

    f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.close:SetPoint("TOPRIGHT", -6, -6)

    f.landing = CreateFrame("Frame", nil, f)
    f.landing:SetPoint("TOPLEFT", 12, -44)
    f.landing:SetPoint("BOTTOMRIGHT", -12, 12)

    f.guide = CreateFrame("Frame", nil, f)
    f.guide:SetPoint("TOPLEFT", 12, -44)
    f.guide:SetPoint("BOTTOMRIGHT", -12, 12)
    f.guide:Hide()

    -- Guide page widgets
    f.guide.recipeIcon = f.guide:CreateTexture(nil, "ARTWORK")
    f.guide.recipeIcon:SetSize(34, 34)
    f.guide.recipeIcon:SetPoint("TOPLEFT", 10, -10)

    f.guide.recipeLink = f.guide:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.guide.recipeLink:SetPoint("LEFT", f.guide.recipeIcon, "RIGHT", 10, 0)
    f.guide.recipeLink:SetJustifyH("LEFT")

    f.guide.pageLabel = f.guide:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.guide.pageLabel:SetPoint("TOPRIGHT", -10, -10)

    f.guide.rangeLabel = f.guide:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.guide.rangeLabel:SetPoint("RIGHT", f.guide.pageLabel, "LEFT", -12, 0)

    f.guide.note = f.guide:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.guide.note:SetPoint("TOPLEFT", f.guide.recipeIcon, "BOTTOMLEFT", 0, -12)
    f.guide.note:SetPoint("RIGHT", -10, 0)
    f.guide.note:SetJustifyH("LEFT")
    f.guide.note:SetWordWrap(true)

    f.guide.reagents = f.guide:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.guide.reagents:SetPoint("TOPLEFT", 10, -120)
    f.guide.reagents:SetPoint("RIGHT", -10, 0)
    f.guide.reagents:SetJustifyH("LEFT")
    f.guide.reagents:SetWordWrap(true)
    f.guide.reagents:SetSpacing(4)

    f.guide.vendors = f.guide:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.guide.vendors:SetPoint("BOTTOMLEFT", 12, 44)
    f.guide.vendors:SetPoint("RIGHT", -10, 0)
    f.guide.vendors:SetJustifyH("LEFT")
    f.guide.vendors:SetWordWrap(true)

    f.guide.back = CreateFrame("Button", nil, f.guide, "UIPanelButtonTemplate")
    f.guide.back:SetPoint("BOTTOMLEFT", 12, 8)
    f.guide.back:SetSize(110, 24)
    f.guide.back:SetText("Professions")
    f.guide.back:SetScript("OnClick", function()
        RGXProfSettings.bookProfessionID = nil
        RGXProf.BookWindow:Show()
    end)

    f.guide.prev = CreateFrame("Button", nil, f.guide, "UIPanelButtonTemplate")
    f.guide.prev:SetPoint("BOTTOMRIGHT", -138, 8)
    f.guide.prev:SetSize(90, 24)
    f.guide.prev:SetText("< Prev")
    f.guide.prev:SetScript("OnClick", function()
        local professionID = RGXProf.BookWindow:GetCurrentProfession()
        if not professionID then return end
        local path = RGXProf.currentExpansion.paths[professionID]
        local page = RGXProfSettings.bookPage or 1
        RGXProfSettings.bookPage = math.max(1, page - 1)
        RGXProf.BookWindow:Show()
    end)

    f.guide.next = CreateFrame("Button", nil, f.guide, "UIPanelButtonTemplate")
    f.guide.next:SetPoint("BOTTOMRIGHT", -12, 8)
    f.guide.next:SetSize(90, 24)
    f.guide.next:SetText("Next >")
    f.guide.next:SetScript("OnClick", function()
        local professionID = RGXProf.BookWindow:GetCurrentProfession()
        if not professionID then return end
        local path = RGXProf.currentExpansion.paths[professionID]
        local page = RGXProfSettings.bookPage or 1
        RGXProfSettings.bookPage = math.min(#path, page + 1)
        RGXProf.BookWindow:Show()
    end)

    self.frame = f
    self:BuildLanding()
end

function RGXProf.BookWindow:BuildLanding()
    local landing = self.frame.landing
    for _, child in ipairs({landing:GetChildren()}) do
        child:Hide()
    end

    local professions = GetGuideProfessions()
    local columns = 4
    local rows = math.ceil(#professions / columns)

    for index, professionID in ipairs(professions) do
        local prof = RGXProf.Constants.Professions[professionID]
        local btn = CreateFrame("Button", nil, landing, "BackdropTemplate")
        btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
        local row = math.floor((index - 1) / columns)
        local col = (index - 1) % columns
        local colWidth = BUTTON_SIZE + 14
        local rowHeight = BUTTON_SIZE + 14
        local totalW = columns * colWidth
        local totalH = rows * rowHeight
        btn:SetPoint("TOPLEFT", landing, "TOPLEFT", (landing:GetWidth() - totalW) / 2 + col * colWidth, -(landing:GetHeight() - totalH) / 2 - row * rowHeight)

        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(0.08, 0.11, 0.15, 0.95)
        btn:SetBackdropBorderColor(unpack(COLORS.border, 1, 4))

        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetSize(40, 40)
        icon:SetPoint("TOP", 0, -12)
        icon:SetTexture(prof.icon or 133741)

        local name = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("TOP", icon, "BOTTOM", 0, -6)
        name:SetText(COLORS.text .. prof.name)

        local skillText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        skillText:SetPoint("TOP", name, "BOTTOM", 0, -2)
        local skill = RGXProf.WowAPI.GetProfessionSkill and RGXProf.WowAPI:GetProfessionSkill(prof.name) or nil
        skillText:SetText(skill and (COLORS.dim .. "Skill " .. skill) or (COLORS.dim .. "Not learned"))

        btn:SetScript("OnClick", function()
            RGXProf.BookWindow:OpenProfession(professionID)
        end)
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(0.55, 0.10, 0.22, 1)
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(unpack(COLORS.border, 1, 4))
        end)
    end
end

function RGXProf.BookWindow:RenderGuide()
    local guide = self.frame.guide
    local professionID = self:GetCurrentProfession()
    if not professionID then
        guide:Hide()
        self.frame.landing:Show()
        self.frame.subHeader:SetText(COLORS.dim .. "Choose a profession")
        return
    end

    local prof = RGXProf.Constants.Professions[professionID]
    local path = RGXProf.currentExpansion.paths[professionID]
    local page = RGXProfSettings.bookPage or 1
    local step = path[page]
    if not step then
        page = 1
        step = path[1]
        RGXProfSettings.bookPage = 1
    end

    self.frame.landing:Hide()
    guide:Show()

    self.frame.subHeader:SetText(COLORS.accent .. prof.name .. "|r  " .. COLORS.dim .. "Leveling Path")

    guide.recipeIcon:SetTexture(step.itemID and GetItemIcon(step.itemID) or "Interface\\Icons\\INV_Misc_QuestionMark")

    local display = RGXProf.WowAPI:GetItemLinkAndIconOrSpell(step)
    guide.recipeLink:SetText(display.link or (COLORS.text .. step.name))

    local pageText = string.format("Page %d / %d", page, #path)
    guide.pageLabel:SetText(COLORS.dim .. pageText)

    local rangeText = string.format("%sSkill %d - %d%s", COLORS.text, step.minSkill, step.maxSkill, step.alternate and ("  " .. COLORS.accent .. "(alternate route)") or "")
    guide.rangeLabel:SetText(rangeText)

    local noteText = ""
    if step.keep and step.keep > 0 then
        noteText = noteText .. COLORS.dim .. "Keep the crafted items.\n"
    end
    if step.note then
        noteText = noteText .. COLORS.text .. step.note .. "\n"
    end
    if step.quests then
        noteText = noteText .. COLORS.dim .. "Requires a quest (see the trainer list).\n"
    end
    guide.note:SetText(noteText)

    local crafts = math.max(1, step.maxSkill - step.minSkill)
    local reagents = RGXProf.DataManager:GetReagentListWithDetails(step.spellID, crafts)
    local lines = {}
    table.insert(lines, COLORS.accent .. "Materials for " .. crafts .. " crafts:")
    for _, reagent in ipairs(reagents or {}) do
        local have = reagent.onHandCount or 0
        local haveColor = (have >= (reagent.requiredCount or 0)) and "|cff00ff00" or "|cffff9900"
        table.insert(lines, string.format("%s  %s %dx %s(%d/%d)", COLORS.text, reagent.icon or "", reagent.requiredCount or 0, reagent.name or tostring(reagent.itemID), haveColor, have, reagent.requiredCount or 0))
    end
    if #lines == 1 then
        table.insert(lines, COLORS.dim .. "No material data for this step.")
    end
    guide.reagents:SetText(table.concat(lines, "\n"))

    local vendors = RGXProf.DataManager:GetVendors(step, RGXProf.WowAPI:GetPlayer().faction)
    local vendorLines = {}
    if #vendors > 0 then
        table.insert(vendorLines, COLORS.accent .. "Vendors:")
        for _, vendor in ipairs(vendors) do
            table.insert(vendorLines, COLORS.text .. vendor.name)
        end
    end
    guide.vendors:SetText(table.concat(vendorLines, "\n"))

    guide.prev:SetEnabled(page > 1)
    guide.next:SetEnabled(page < #path)
end

function RGXProf.BookWindow:Show()
    self:EnsureFrame()
    if RGXProfSettings.bookPosition and self.frame:GetNumPoints() == 1 then
        local pos = RGXProfSettings.bookPosition
        local point, relFrame = pos[1], pos[2]
        local relPoint, x, y = pos[3], pos[4], pos[5]
        if relFrame == nil then relFrame = UIParent end
        pcall(function()
            self.frame:ClearAllPoints()
            self.frame:SetPoint(point, relFrame, relPoint, x, y)
        end)
    end
    local professionID = self:GetCurrentProfession()
    if professionID then
        RGXProfSettings.bookPage = RGXProfSettings.bookPage or self:GetCurrentPage(professionID)
        self.frame.subHeader:SetText("")
        self:RenderGuide()
    else
        self.frame.guide:Hide()
        self.frame.landing:Show()
        self.frame.subHeader:SetText(COLORS.dim .. "Choose a profession")
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
