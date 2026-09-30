RGXProf = RGXProf or {}
RGXProf.MatsWindow = RGXProf.MatsWindow or {
    layoutGroup = "MatsWindow",
    layoutRoot = "BackFrame",
    UIElements = {},
    initializedUI = false,
    -- MatsV_Header = {},
    MatsV_Body = {}
}
function RGXProf.MatsWindow:InitLayoutContext()
    return {
        layoutGroup = RGXProf.Layouts[self.layoutGroup],
        layoutRoot = RGXProf.Layouts[self.layoutGroup][self.layoutRoot],
        ui = self.UIElements,
    }
end
---Show the Remaining Materials window after clicking the Calculate button
---@param professionInfo {} the profession info to show in the Remaining Materials window
function RGXProf.MatsWindow:Show(professionInfo)

    if not self.initializedUI then
        self.context = self:InitLayoutContext()
        RGXProf.LayoutManager:BuildLayout(self.context)
        self.initializedUI = true
    end
    self:Render(professionInfo)
end

---Fill and show the Remaining Materials window
---@param professionInfo {} the profession info to show in the Remaining Materials window
function RGXProf.MatsWindow:Render(professionInfo)
    local ui = self.UIElements
    local frame = ui.backFrame

    frame:Show()
    
    ----------------------------------------------------------
    -- Render all the frames with their data
    ----------------------------------------------------------
    self:SetPortrait(professionInfo.icon)

    self.MatsV_Body:Render(professionInfo, self)
end

--- @param professionInfo Profession
function RGXProf.MatsWindow.MatsV_Body:Render(professionInfo, parent)

    local ui = parent.UIElements
    local content = ui.Mats.content
    local scrollLineTemplate = RGXProf.Layouts.MatsWindow.Mats.scrollContent

    local contentLines = RGXProf.DataManager:GetRemainingMaterials(professionInfo.currentSkill, professionInfo.path)
    RGXProf.LayoutManager:FillScrollContent(
        scrollLineTemplate,
        content,
        contentLines,
        parent.context
    )
end

function RGXProf.MatsWindow:SetPortrait(icon)
    local portraitFrame = _G[self.UIElements.backFrame:GetName().."Portrait"]
    -- SetPortraitToTexture is a classic-era global the Forever client no
    -- longer exposes. Fall back to a plain texture set when it is absent.
    if type(SetPortraitToTexture) == "function" and portraitFrame and portraitFrame.SetTexture then
        pcall(SetPortraitToTexture, portraitFrame, icon)
    elseif portraitFrame and portraitFrame.SetTexture then
        portraitFrame:SetTexture(icon)
    end
end