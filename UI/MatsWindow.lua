--=====================================================================================
-- RGXProfessions - UI/MatsWindow.lua
-- "Materials to Max": everything still needed for each remaining rank of a profession, with live
-- bag counts. A minimal, scalable rounded RGX overlay: slim title bar (icon, profession, skill), one
-- tab per remaining rank, a totals line with a progress bar, and an aligned Material / Have / Need list. Rows show the
-- item tooltip on hover and link the item on shift-click. Counts refresh on bag changes.
--=====================================================================================

RGXProf = RGXProf or {}
RGXProf.MatsWindow = RGXProf.MatsWindow or {}
local W = RGXProf.MatsWindow

-- Minimal overlay: compact by default, resizable from the corner grip and scalable with
-- Ctrl + mouse wheel. Size, scale and position are remembered.
local WIDTH, HEIGHT = 300, 330
local MIN_W, MIN_H, MAX_W, MAX_H = 240, 200, 640, 900
local MIN_SCALE, MAX_SCALE = 0.6, 1.6
local PAD = 8
local ROW_H = 20
local ICON = 16
local COL_W = 38            -- Have / Need column width
local HEADER_H = 26
local TAB_H = 20
local BG_ALPHA = 0.96       -- near-opaque: the ring layer sits under the fill and must not tint it
local BRAND = { 0.545, 0.082, 0.220 } -- RGX crimson: accents only (selected tab)
local RING = { 0.200, 0.200, 0.247 }   -- neutral grey ring, like the other RGX addons

local function D() return _G.RGXDesign end
local function L(key, fallback) return (RGXProf.L and RGXProf.L[key]) or fallback end
local function Color(key, fallback)
    local design = D()
    if design and design.Unpack then
        local ok, r, g, b = pcall(design.Unpack, design, key)
        if ok and r then return r, g, b end
    end
    return fallback[1], fallback[2], fallback[3]
end

local GREEN = { 0.30, 0.85, 0.40 }
local AMBER = { 1.00, 0.70, 0.20 }
local DIM = { 0.62, 0.62, 0.66 }

local function LiveSkill(info)
    if info.professionID and RGXProf.WowAPI and RGXProf.WowAPI.GetProfessionSkill then
        local prof = RGXProf.Constants and RGXProf.Constants.Professions and RGXProf.Constants.Professions[info.professionID]
        if prof then
            local ok, earned = pcall(RGXProf.WowAPI.GetProfessionSkill, RGXProf.WowAPI, prof.name)
            if ok and tonumber(earned) then return tonumber(earned) end
        end
    end
    return tonumber(info.currentSkill) or 1
end

-- A rounded pill used for the rank tabs; selected tabs fill with the brand crimson.
local function CreatePill(parent)
    local b = CreateFrame("Button", nil, parent)
    b:SetHeight(TAB_H)
    if D() then D():ApplyPanel(b, { color = "surface" }) end
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.text:SetPoint("LEFT", 6, 0)
    b.text:SetPoint("RIGHT", -6, 0)
    b.text:SetJustifyH("CENTER")
    b.text:SetWordWrap(false)
    function b:SetSelected(on)
        self._on = on
        if self.SetPanelColor then
            local sr, sg, sb = Color("surface", { 0.09, 0.09, 0.11 })
            local br, bg, bb = Color("border", { 0.2, 0.2, 0.25 })
            if on then
                self:SetPanelColor({ 0.30, 0.09, 0.14 }, BRAND, 1)
            else
                self:SetPanelColor({ sr, sg, sb }, { br, bg, bb }, 1)
            end
        end
        self.text:SetTextColor(on and 1 or 0.78, on and 1 or 0.78, on and 1 or 0.80)
    end
    b:SetScript("OnEnter", function(self) if not self._on then self.text:SetTextColor(1, 1, 1) end end)
    b:SetScript("OnLeave", function(self) self:SetSelected(self._on) end)
    return b
end

local function CreateRow(parent)
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(ROW_H)
    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints()
    row.bg:SetColorTexture(1, 1, 1, 0)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(ICON, ICON)
    row.icon:SetPoint("LEFT", 4, 0)
    row.need = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.need:SetPoint("RIGHT", -6, 0)
    row.need:SetWidth(COL_W)
    row.need:SetJustifyH("RIGHT")
    row.have = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.have:SetPoint("RIGHT", row.need, "LEFT", -4, 0)
    row.have:SetWidth(COL_W)
    row.have:SetJustifyH("RIGHT")
    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.name:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
    row.name:SetPoint("RIGHT", row.have, "LEFT", -6, 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)
    row:RegisterForClicks("LeftButtonUp")
    row:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(1, 1, 1, 0.07)
        if self.itemID and GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if GameTooltip.SetItemByID then pcall(GameTooltip.SetItemByID, GameTooltip, self.itemID) end
            GameTooltip:AddLine(L("MATS_SHIFT_LINK", "Shift-click to link in chat."), DIM[1], DIM[2], DIM[3])
            GameTooltip:Show()
        end
    end)
    row:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(1, 1, 1, self._stripe and 0.03 or 0)
        if GameTooltip then GameTooltip:Hide() end
    end)
    row:SetScript("OnClick", function(self)
        if self.itemID and IsShiftKeyDown and IsShiftKeyDown() then
            local _, link = RGXProf.WowAPI:GetItemInfo(self.itemID)
            if link and ChatEdit_InsertLink then ChatEdit_InsertLink(link) end
        end
    end)
    return row
end

local function Clamp(v, lo, hi) if v < lo then return lo elseif v > hi then return hi end return v end

function W:Build()
    if self.frame then return end
    local design = D()
    local saved = RGXProf_Settings or {}
    local size = type(saved.matsSize) == "table" and saved.matsSize or {}
    local w = Clamp(tonumber(size[1]) or WIDTH, MIN_W, MAX_W)
    local h = Clamp(tonumber(size[2]) or HEIGHT, MIN_H, MAX_H)
    local f
    if design then
        f = design:CreateFrame(UIParent, { name = "RGXProf_MatsWindow", width = w, height = h, square = false, bgAlpha = BG_ALPHA })
        if f.SetPanelColor then
            local sr, sg, sb = Color("surface", { 0.086, 0.086, 0.110 })
            f:SetPanelColor({ sr, sg, sb }, RING, BG_ALPHA)
        end
    else
        f = CreateFrame("Frame", "RGXProf_MatsWindow", UIParent)
        f:SetSize(w, h)
    end
    f:SetScale(Clamp(tonumber(saved.matsScale) or 1, MIN_SCALE, MAX_SCALE))
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(s) s:StartMoving() end)
    f:SetScript("OnDragStop", function(s)
        s:StopMovingOrSizing()
        local point, _, relPoint, x, y = s:GetPoint()
        if RGXProf_Settings then RGXProf_Settings.matsPosition = { point, relPoint, x, y } end
    end)
    -- Ctrl + mouse wheel scales the whole overlay; plain wheel still scrolls the list.
    f:EnableMouseWheel(true)
    f:SetScript("OnMouseWheel", function(s, delta)
        if not (IsControlKeyDown and IsControlKeyDown()) then return end
        W:SetScale((s:GetScale() or 1) + delta * 0.05)
    end)
    if type(UISpecialFrames) == "table" then table.insert(UISpecialFrames, "RGXProf_MatsWindow") end
    f:Hide()

    -- Slim title bar: small icon, profession name, skill range on the right, close button.
    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetSize(16, 16)
    f.icon:SetPoint("TOPLEFT", PAD + 2, -6)
    f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.close:SetSize(22, 22)
    f.close:SetPoint("TOPRIGHT", -2, -2)
    f.close:SetScript("OnClick", function() f:Hide() end)
    f.sub = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.sub:SetPoint("RIGHT", f.close, "LEFT", -2, 0)
    f.sub:SetJustifyH("RIGHT")
    f.sub:SetTextColor(DIM[1], DIM[2], DIM[3])
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("LEFT", f.icon, "RIGHT", 6, 0)
    f.title:SetPoint("RIGHT", f.sub, "LEFT", -6, 0)
    f.title:SetJustifyH("LEFT")
    f.title:SetWordWrap(false)
    local divider = f:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(1)
    divider:SetPoint("TOPLEFT", PAD, -HEADER_H)
    divider:SetPoint("TOPRIGHT", -PAD, -HEADER_H)
    divider:SetColorTexture(1, 1, 1, 0.10)

    -- Rank tabs.
    f.tabs = {}
    f.tabBar = CreateFrame("Frame", nil, f)
    f.tabBar:SetPoint("TOPLEFT", PAD, -(HEADER_H + 6))
    f.tabBar:SetPoint("TOPRIGHT", -PAD, -(HEADER_H + 6))
    f.tabBar:SetHeight(TAB_H)

    -- Totals line + progress bar (share of the needed units already in your bags).
    local totalsY = HEADER_H + 6 + TAB_H + 6
    f.tierHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.tierHeader:SetPoint("TOPLEFT", PAD + 2, -totalsY)
    f.tierHeader:SetPoint("RIGHT", f, "RIGHT", -PAD, 0)
    f.tierHeader:SetJustifyH("LEFT")
    f.tierHeader:SetWordWrap(false)
    f.totals = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.totals:SetPoint("TOPLEFT", f.tierHeader, "BOTTOMLEFT", 0, -2)
    f.totals:SetPoint("RIGHT", f, "RIGHT", -PAD, 0)
    f.totals:SetJustifyH("LEFT")
    f.totals:SetWordWrap(false)
    f.bar = CreateFrame("StatusBar", nil, f)
    f.bar:SetPoint("TOPLEFT", f.totals, "BOTTOMLEFT", 0, -4)
    f.bar:SetPoint("RIGHT", f, "RIGHT", -PAD - 2, 0)
    f.bar:SetHeight(3)
    f.bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    f.bar:SetStatusBarColor(GREEN[1], GREEN[2], GREEN[3])
    f.bar:SetMinMaxValues(0, 1)
    local barBg = f.bar:CreateTexture(nil, "BACKGROUND")
    barBg:SetAllPoints()
    barBg:SetColorTexture(1, 1, 1, 0.08)

    -- List: column headers + scrolling rows, straight on the overlay (no nested card).
    local listTop = totalsY + 36
    f.list = CreateFrame("Frame", nil, f)
    f.list:SetPoint("TOPLEFT", PAD, -listTop)
    f.list:SetPoint("BOTTOMRIGHT", -PAD, PAD + 6)

    local cols = CreateFrame("Frame", nil, f.list)
    cols:SetPoint("TOPLEFT", 0, 0)
    cols:SetPoint("TOPRIGHT", 0, 0)
    cols:SetHeight(14)
    local function colLabel(text, width, justify)
        local fs = cols:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetText(text)
        fs:SetJustifyH(justify)
        fs:SetTextColor(DIM[1], DIM[2], DIM[3])
        if width then fs:SetWidth(width) end
        return fs
    end
    f.colNeed = colLabel(L("MATS_COL_NEED", "Need"), COL_W, "RIGHT")
    f.colNeed:SetPoint("RIGHT", cols, "RIGHT", -4, 0)
    f.colHave = colLabel(L("MATS_COL_HAVE", "Have"), COL_W, "RIGHT")
    f.colHave:SetPoint("RIGHT", f.colNeed, "LEFT", -4, 0)
    f.colItem = colLabel(L("MATS_COL_ITEM", "Material"), nil, "LEFT")
    f.colItem:SetPoint("LEFT", cols, "LEFT", 4 + ICON + 6, 0)
    local rule = f.list:CreateTexture(nil, "ARTWORK")
    rule:SetHeight(1)
    rule:SetPoint("TOPLEFT", cols, "BOTTOMLEFT", 0, -2)
    rule:SetPoint("TOPRIGHT", cols, "BOTTOMRIGHT", 0, -2)
    rule:SetColorTexture(1, 1, 1, 0.12)

    f.scroll = CreateFrame("ScrollFrame", nil, f.list)
    f.scroll:SetPoint("TOPLEFT", cols, "BOTTOMLEFT", 0, -4)
    f.scroll:SetPoint("BOTTOMRIGHT", f.list, "BOTTOMRIGHT", 0, 0)
    f.scroll:EnableMouseWheel(true)
    f.content = CreateFrame("Frame", nil, f.scroll)
    f.content:SetSize(1, 1)
    f.scroll:SetScrollChild(f.content)
    f.scroll:SetScript("OnSizeChanged", function(s, sw) f.content:SetWidth(math.max(1, sw or 1)) end)
    f.scroll:SetScript("OnMouseWheel", function(s, delta)
        if IsControlKeyDown and IsControlKeyDown() then
            W:SetScale((f:GetScale() or 1) + delta * 0.05)
            return
        end
        local maxOff = math.max(0, (f.content:GetHeight() or 0) - (s:GetHeight() or 0))
        local off = math.min(maxOff, math.max(0, (s:GetVerticalScroll() or 0) - delta * ROW_H * 3))
        s:SetVerticalScroll(off)
    end)

    f.empty = f.list:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.empty:SetPoint("TOPLEFT", f.scroll, "TOPLEFT", 4, -12)
    f.empty:SetPoint("RIGHT", f.scroll, "RIGHT", -4, 0)
    f.empty:SetJustifyH("CENTER")
    f.empty:SetTextColor(DIM[1], DIM[2], DIM[3])

    -- Corner grip: drag to resize (manual sizing; the client lacks the native resize-bounds API).
    f.grip = CreateFrame("Button", nil, f)
    f.grip:SetSize(14, 14)
    f.grip:SetPoint("BOTTOMRIGHT", -3, 3)
    f.grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    f.grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    f.grip:RegisterForDrag("LeftButton")
    f.grip:SetScript("OnDragStart", function(g)
        g._scale = f:GetEffectiveScale()
        g._left, g._top = f:GetLeft(), f:GetTop()
        g:SetScript("OnUpdate", function(self)
            local mx, my = GetCursorPosition()
            W:SetSize(mx / self._scale - self._left, self._top - my / self._scale, self._left, self._top)
        end)
    end)
    f.grip:SetScript("OnDragStop", function(g)
        g:SetScript("OnUpdate", nil)
        if RGXProf_Settings then
            RGXProf_Settings.matsSize = { f:GetWidth(), f:GetHeight() }
            local point, _, relPoint, x, y = f:GetPoint()
            RGXProf_Settings.matsPosition = { point, relPoint, x, y }
        end
    end)
    f:SetScript("OnSizeChanged", function() if W._tiers then W:LayoutTabs(W._tiers) end end)

    f.rows = {}
    self.frame = f
end

--- Resize, clamped; keeps the top-left corner where it is while dragging.
function W:SetSize(width, height, left, top)
    local f = self.frame
    if not f then return end
    width, height = Clamp(width or f:GetWidth(), MIN_W, MAX_W), Clamp(height or f:GetHeight(), MIN_H, MAX_H)
    if left and top then
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
    end
    f:SetSize(width, height)
    return width, height
end

--- Scale the overlay (Ctrl + mouse wheel), clamped and remembered.
function W:SetScale(scale)
    local f = self.frame
    if not f then return end
    scale = Clamp(math.floor((scale or 1) * 100 + 0.5) / 100, MIN_SCALE, MAX_SCALE)
    f:SetScale(scale)
    if RGXProf_Settings then RGXProf_Settings.matsScale = scale end
    return scale
end

function W:Place()
    local f = self.frame
    f:ClearAllPoints()
    local saved = RGXProf_Settings and RGXProf_Settings.matsPosition
    if type(saved) == "table" and saved[1] then
        f:SetPoint(saved[1], UIParent, saved[2] or saved[1], saved[3] or 0, saved[4] or 0)
        return
    end
    local book = RGXProf.BookWindow and RGXProf.BookWindow.frame
    if book and book:IsShown() then
        f:SetPoint("TOPLEFT", book, "TOPRIGHT", 8, 0)
    else
        f:SetPoint("CENTER")
    end
end

-- Tabs show just the skill level the rank reaches.
local function TabCaption(tier)
    return tostring(tier.skillCap)
end

function W:LayoutTabs(tiers)
    local f = self.frame
    local count = #tiers
    for i = count + 1, #f.tabs do f.tabs[i]:Hide() end
    if count == 0 then return end
    local gap = 6
    local width = (f.tabBar:GetWidth() > 10 and f.tabBar:GetWidth()) or ((f:GetWidth() or WIDTH) - PAD * 2)
    local tabW = math.floor((width - gap * (count - 1)) / count)
    for i, tier in ipairs(tiers) do
        local tab = f.tabs[i] or CreatePill(f.tabBar)
        f.tabs[i] = tab
        tab:ClearAllPoints()
        tab:SetPoint("TOPLEFT", f.tabBar, "TOPLEFT", (i - 1) * (tabW + gap), 0)
        tab:SetWidth(tabW)
        tab.text:SetText(TabCaption(tier, i == count))
        tab:SetScript("OnClick", function()
            self.selectedCap = tier.skillCap
            self:Refresh()
        end)
        tab:SetSelected(tier.skillCap == self.selectedCap)
        tab:Show()
    end
end

function W:RenderRows(tier)
    local f = self.frame
    local items = tier and tier.items or {}
    for i, item in ipairs(items) do
        local row = f.rows[i] or CreateRow(f.content)
        f.rows[i] = row
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", f.content, "TOPLEFT", 0, -(i - 1) * ROW_H)
        row:SetPoint("TOPRIGHT", f.content, "TOPRIGHT", 0, -(i - 1) * ROW_H)
        row._stripe = (i % 2 == 0)
        row.bg:SetColorTexture(1, 1, 1, row._stripe and 0.03 or 0)
        row.itemID = item.itemID
        row.icon:SetTexture(item.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        local done = item.short == 0
        row.name:SetText(item.name or ((L("ITEM_ID_FALLBACK", "ItemID:")) .. " " .. item.itemID))
        if done then
            row.name:SetTextColor(DIM[1], DIM[2], DIM[3])
            row.icon:SetDesaturated(true)
            row.have:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
        else
            row.name:SetTextColor(0.95, 0.95, 0.95)
            row.icon:SetDesaturated(false)
            row.have:SetTextColor(AMBER[1], AMBER[2], AMBER[3])
        end
        row.have:SetText(tostring(item.have))
        row.need:SetText(tostring(item.need))
        row.need:SetTextColor(0.95, 0.95, 0.95)
        row:Show()
    end
    for i = #items + 1, #f.rows do f.rows[i]:Hide() end
    f.content:SetHeight(math.max(1, #items * ROW_H))
    local maxOff = math.max(0, #items * ROW_H - (f.scroll:GetHeight() or 0))
    if (f.scroll:GetVerticalScroll() or 0) > maxOff then f.scroll:SetVerticalScroll(maxOff) end
end

function W:Refresh()
    local f, info = self.frame, self.info
    if not (f and info and f:IsShown()) then return end
    local skill = LiveSkill(info)
    local tiers = RGXProf.DataManager:GetRemainingMaterialsTiers(skill, info.path)
    local maxCap = 0
    for _, tier in ipairs(tiers) do maxCap = math.max(maxCap, tier.skillCap) end
    local pathMax = info.path and info.path[#info.path] and info.path[#info.path].maxSkill or maxCap

    f.icon:SetTexture(info.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    f.title:SetText(info.name or L("MATS_WINDOW_TITLE", "Materials to Max"))
    f.sub:SetText(string.format(L("MATS_SKILL_LINE", "%d / %d"), skill, pathMax))

    -- Keep the chosen rank across refreshes; default to the final cap.
    local selected
    for _, tier in ipairs(tiers) do if tier.skillCap == self.selectedCap then selected = tier end end
    selected = selected or tiers[#tiers]
    self.selectedCap = selected and selected.skillCap
    self._tiers = tiers
    self:LayoutTabs(tiers)

    local missingNames = false
    if not selected then
        f.tierHeader:SetText("")
        f.totals:SetText("")
        f.bar:SetValue(1)
        f.empty:SetText(L("MATS_AT_CAP", "Nothing left to gather - you are at the skill cap."))
        f.empty:Show()
        self:RenderRows(nil)
    else
        f.tierHeader:SetText(string.format(L("MATS_TIER_HEADER", "To reach %s (%d)"), selected.label, selected.skillCap))
        f.totals:SetText(string.format(L("MATS_TOTALS", "%d items, %d ready, %d to get"),
            #selected.items, selected.ready, selected.missing))
        if selected.missing == 0 and #selected.items > 0 then
            f.totals:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
        else
            f.totals:SetTextColor(0.85, 0.85, 0.85)
        end
        f.bar:SetValue(selected.needed > 0 and (selected.have / selected.needed) or 1)
        if #selected.items == 0 then
            f.empty:SetText(L("MATS_NO_DATA", "No material data for this route."))
            f.empty:Show()
        else
            f.empty:Hide()
        end
        self:RenderRows(selected)
        for _, item in ipairs(selected.items) do if not item.name then missingNames = true end end
    end

    -- Item names stream in from the server; re-render a few times until they have all arrived.
    if missingNames and (self._nameRetries or 0) < 5 and C_Timer and C_Timer.After then
        self._nameRetries = (self._nameRetries or 0) + 1
        C_Timer.After(0.5, function() W:Refresh() end)
    elseif not missingNames then
        self._nameRetries = 0
    end
end

--- Show the window for a profession: { icon, name, professionID, currentSkill, path }.
function W:Show(info)
    if not info or not info.path then return end
    self:Build()
    if self.info and self.info.path ~= info.path then self.selectedCap = nil end
    self.info = info
    self._nameRetries = 0
    if not self.frame:IsShown() then self:Place() end
    self.frame:Show()
    self.frame:Raise()
    self:Refresh()
end

function W:Hide()
    if self.frame then self.frame:Hide() end
end

function W:IsShown()
    return self.frame ~= nil and self.frame:IsShown()
end

function W:Toggle(info)
    if self:IsShown() then self:Hide() else self:Show(info) end
end
