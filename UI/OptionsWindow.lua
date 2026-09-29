RGXProf = RGXProf or {}
RGXProf.OptionsWindow = RGXProf.OptionsWindow or {}

function RGXProf.OptionsWindow:CreateOptionsPanel()

    local configPanel = CreateFrame("Frame", "RGXProfOptionsPanel", UIParent)
    configPanel.name = RGXProf.L.ADDON_TITLE

    local title = configPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(RGXProf.L.ADDON_TITLE)

    local autoOpenCheckbox = CreateFrame("CheckButton", nil, configPanel, "InterfaceOptionsCheckButtonTemplate")
    autoOpenCheckbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    autoOpenCheckbox.Text:SetText(RGXProf.L.OPT_AUTO_OPEN)
    autoOpenCheckbox:SetChecked(RGXProf.Settings and RGXProf.Settings.autoOpen or false)

    autoOpenCheckbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        RGXProf_Settings = RGXProf_Settings or {}
        RGXProf_Settings.autoOpen = checked
        RGXProf.Settings = RGXProf_Settings
        RGXProf.Settings.autoOpen = checked
    end)

    local selectRecipeCheckbox = CreateFrame("CheckButton", nil, configPanel, "InterfaceOptionsCheckButtonTemplate")
    selectRecipeCheckbox:SetPoint("TOPLEFT", autoOpenCheckbox, "BOTTOMLEFT", 0, -12)
    selectRecipeCheckbox.Text:SetText(RGXProf.L.OPT_SELECT_RECIPES)
    selectRecipeCheckbox:SetChecked(RGXProf.Settings and RGXProf.Settings.selectRecipesInProfessionWindow ~= false)

    selectRecipeCheckbox:SetScript("OnClick", function(self)
        RGXProf_Settings = RGXProf_Settings or {}
        RGXProf_Settings.selectRecipesInProfessionWindow = self:GetChecked()
        RGXProf.Settings = RGXProf_Settings
    end)

    local selectRecipeDescription = configPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    selectRecipeDescription:SetPoint("TOPLEFT", selectRecipeCheckbox, "BOTTOMLEFT", 26, -2)
    selectRecipeDescription:SetWidth(520)
    selectRecipeDescription:SetJustifyH("LEFT")
    selectRecipeDescription:SetText(RGXProf.L.OPT_SELECT_RECIPES_DESC)

    return configPanel
end
