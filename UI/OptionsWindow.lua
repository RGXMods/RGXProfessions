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
        accent:SetColorTexture(Design:Unpack("primary"))
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
