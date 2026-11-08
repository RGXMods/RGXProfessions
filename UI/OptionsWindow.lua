RGXProf = RGXProf or {}
RGXProf.OptionsWindow = RGXProf.OptionsWindow or {}

local function GetMeta(key)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        local ok, v = pcall(C_AddOns.GetAddOnMetadata, "RGXProfessions", key)
        if ok and v and v ~= "" then return v end
    elseif GetAddOnMetadata then
        local ok, v = pcall(GetAddOnMetadata, "RGXProfessions", key)
        if ok and v and v ~= "" then return v end
    end
end

function RGXProf.OptionsWindow:Setting(key)
    RGXProf_Settings = RGXProf_Settings or {}
    RGXProf.Settings = RGXProf_Settings
    return RGXProf_Settings[key]
end

function RGXProf.OptionsWindow:SetSetting(key, value)
    RGXProf_Settings = RGXProf_Settings or {}
    RGXProf_Settings[key] = value
    RGXProf.Settings = RGXProf_Settings
end

function RGXProf.OptionsWindow:CreateOptionsPanel()

    local configPanel = CreateFrame("Frame", "RGXProfOptionsPanel", UIParent)
    configPanel.name = "RGX Professions"

    local Design = _G.RGXDesign

    local title = configPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("|cff8B1538RGX|r |cffffffffProfessions|r")
    if Design then title:SetTextColor(Design:Unpack("text")) end

    local ver = configPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    ver:SetPoint("TOPRIGHT", -16, -22)
    ver:SetJustifyH("RIGHT")
        ver:SetText("v" .. tostring(GetMeta("Version") or ""):gsub("^v+", "") .. "  by RealmGX")
    if Design then ver:SetTextColor(Design:Unpack("subtext")) end

    local accent = configPanel:CreateTexture(nil, "ARTWORK")
    accent:SetHeight(2)
    accent:SetPoint("TOPLEFT", 16, -44)
    accent:SetPoint("TOPRIGHT", -16, -44)
    if Design then
        accent:SetColorTexture(0.545, 0.082, 0.220) -- RGXProfessions crimson, not the shared theme colour
    else
        accent:SetColorTexture(0.545, 0.082, 0.220)
    end
    local autoOpenCheckbox = CreateFrame("CheckButton", nil, configPanel, "InterfaceOptionsCheckButtonTemplate")
    autoOpenCheckbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -26)
    autoOpenCheckbox.Text:SetText("Auto-open the guide when a profession window opens")
    autoOpenCheckbox:SetChecked(self:Setting("autoOpen") == true)
    autoOpenCheckbox:SetScript("OnClick", function(self)
        RGXProf.OptionsWindow:SetSetting("autoOpen", self:GetChecked() == true)
    end)

    local selectRecipeCheckbox = CreateFrame("CheckButton", nil, configPanel, "InterfaceOptionsCheckButtonTemplate")
    selectRecipeCheckbox:SetPoint("TOPLEFT", autoOpenCheckbox, "BOTTOMLEFT", 0, -8)
    selectRecipeCheckbox.Text:SetText("Click guide recipes to select them in the profession window")
    selectRecipeCheckbox:SetChecked(self:Setting("selectRecipesInProfessionWindow") ~= false)
    selectRecipeCheckbox:SetScript("OnClick", function(self)
        RGXProf.OptionsWindow:SetSetting("selectRecipesInProfessionWindow", self:GetChecked() == true)
    end)

    local selectRecipeDescription = configPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    selectRecipeDescription:SetPoint("TOPLEFT", selectRecipeCheckbox, "BOTTOMLEFT", 26, -2)
    selectRecipeDescription:SetWidth(520)
    selectRecipeDescription:SetJustifyH("LEFT")
    selectRecipeDescription:SetText("When disabled, recipe clicks still switch the guide's recipe/alternate display but do not expand or change the profession list.")
    return configPanel
end

--------------------------------------------------------------------------------
-- Settings window (the gear in the guide header): a small rounded RGX window with the same
-- options as the Blizzard options page, plus the minimap icon on/off switch.
--------------------------------------------------------------------------------
local BRAND = { 0.545, 0.082, 0.220 }
local BRAND_TEXT = { 0.929, 0.420, 0.522 }

-- Show or hide the minimap button now, creating it on demand, and remember the choice.
function RGXProf.OptionsWindow:SetMinimapIcon(show)
    show = show and true or false
    self:SetSetting("minimapIconEnabled", show)
    if not RGXProf.minimapButton and show and RGXProf.CreateMinimapButton then
        RGXProf:CreateMinimapButton()
    end
    if RGXProf.minimapButton then RGXProf.minimapButton:SetVisible(show) end
end

local function CreateToggle(parent, label, desc, isOn, onChange)
    local D = _G.RGXDesign
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(desc and 40 or 24)

    local box = CreateFrame("Frame", nil, row)
    box:SetSize(18, 18)
    box:SetPoint("TOPLEFT", 0, -2)
    if D and D.ApplyPanel then
        D:ApplyPanel(box, { color = "surface", radius = 5 })
        box:SetPanelColor(nil, BRAND, 1)
    end
    row.tick = box:CreateTexture(nil, "OVERLAY")
    row.tick:SetPoint("TOPLEFT", 4, -4)
    row.tick:SetPoint("BOTTOMRIGHT", -4, 4)
    row.tick:SetColorTexture(BRAND_TEXT[1], BRAND_TEXT[2], BRAND_TEXT[3], 1)

    row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.label:SetPoint("TOPLEFT", box, "TOPRIGHT", 8, -1)
    row.label:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    row.label:SetJustifyH("LEFT")
    row.label:SetText(label)
    if desc then
        row.desc = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.desc:SetPoint("TOPLEFT", row.label, "BOTTOMLEFT", 0, -2)
        row.desc:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        row.desc:SetJustifyH("LEFT")
        row.desc:SetTextColor(0.62, 0.62, 0.66)
        row.desc:SetText(desc)
    end
    function row:Refresh() self.tick:SetShown(isOn()) end
    row:SetScript("OnClick", function(self)
        onChange(not isOn())
        self:Refresh()
    end)
    row:Refresh()
    return row
end

function RGXProf.OptionsWindow:Build()
    if self.window then return self.window end
    local D = _G.RGXDesign
    local L = RGXProf.L
    local f = D and D.CreateFrame and D:CreateFrame(UIParent, { name = "RGXProf_SettingsWindow", width = 380, height = 262, square = false })
        or CreateFrame("Frame", "RGXProf_SettingsWindow", UIParent)
    f:SetSize(380, 262)
    if f.SetPanelColor then f:SetPanelColor(nil, BRAND) end
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(w) w:StartMoving() end)
    f:SetScript("OnDragStop", function(w) w:StopMovingOrSizing() end)
    if type(UISpecialFrames) == "table" then table.insert(UISpecialFrames, "RGXProf_SettingsWindow") end
    f:Hide()

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOPLEFT", 16, -14)
    f.title:SetText("|cff8B1538RGX|r |cffffffff||r |cffED6B85P|r|cffffffffrofessions|r")
    f.sub = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.sub:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -3)
    f.sub:SetTextColor(0.62, 0.62, 0.66)
    f.sub:SetText(L.SETTINGS)
    f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.close:SetPoint("TOPRIGHT", -4, -4)
    f.close:SetScript("OnClick", function() f:Hide() end)
    local divider = f:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(1)
    divider:SetPoint("TOPLEFT", 14, -52)
    divider:SetPoint("TOPRIGHT", -14, -52)
    divider:SetColorTexture(BRAND[1], BRAND[2], BRAND[3], 0.6)

    local self_ = self
    f.rows = {
        CreateToggle(f, L.OPT_MINIMAP, L.OPT_MINIMAP_DESC,
            function() return self_:Setting("minimapIconEnabled") ~= false end,
            function(v) self_:SetMinimapIcon(v) end),
        CreateToggle(f, L.OPT_AUTOOPEN, L.OPT_AUTOOPEN_DESC,
            function() return self_:Setting("autoOpen") == true end,
            function(v) self_:SetSetting("autoOpen", v) end),
        CreateToggle(f, L.OPT_SELECT, L.OPT_SELECT_DESC,
            function() return self_:Setting("selectRecipesInProfessionWindow") ~= false end,
            function(v) self_:SetSetting("selectRecipesInProfessionWindow", v) end),
    }
    local y = 66
    for _, row in ipairs(f.rows) do
        row:SetPoint("TOPLEFT", 16, -y)
        row:SetPoint("TOPRIGHT", -16, -y)
        y = y + row:GetHeight() + 14
    end
    f:SetHeight(y + 14)
    f:SetScript("OnShow", function() for _, row in ipairs(f.rows) do row:Refresh() end end)
    self.window = f
    return f
end

function RGXProf.OptionsWindow:Show()
    local f = self:Build()
    f:Show()
    f:Raise()
end

function RGXProf.OptionsWindow:Hide()
    if self.window then self.window:Hide() end
end

function RGXProf.OptionsWindow:Toggle()
    local f = self:Build()
    if f:IsShown() then f:Hide() else self:Show() end
end
