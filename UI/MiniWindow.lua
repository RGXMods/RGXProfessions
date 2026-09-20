RGXProf = RGXProf or {}
RGXProf.MiniWindow = RGXProf.MiniWindow or {
    layoutGroup = "MiniWindow",
    layoutRoot = "BackFrame",
    UIElements = {},
    initializedUI = false,
    MV_Header = {},
    MV_Body = {}
}

---@class Context
---@field layoutGroup table <string, table> the layout group for the window
---@field ui table<string, Frame> the UIElements of the window
---@field layoutRoot table the layout definitio for the root of the window --typically BackFrame

--- @return Context
function RGXProf.MiniWindow:InitLayoutContext()
    return {
        layoutGroup = RGXProf.Layouts[self.layoutGroup],
        layoutRoot = RGXProf.Layouts[self.layoutGroup][self.layoutRoot],
        ui = self.UIElements,
    }
end

function RGXProf.MiniWindow:Show(professionName, skill)
    local profession = RGXProf.DataManager:GetOtherProfession(professionName)
    if not profession then
        print("|cffff0000[RGXProf]|r Unknown profession name:", professionName)
		return
    end
    if not self.initializedUI then
        self.context = RGXProf.MiniWindow:InitLayoutContext()
        RGXProf.LayoutManager:BuildLayout(self.context)
        self.initializedUI = true
    end
    profession.pointsEarned = skill
    self:Render(profession)
end

--- @param profession Profession 
function RGXProf.MiniWindow:Render(profession)
    local ui = self.UIElements
    local frame = ui.backFrame

    frame:Show()
    
    ----------------------------------------------------------
    -- Render all the frames with their data
    ----------------------------------------------------------
    self:SetPortrait(profession.icon)

    self.MV_Header:Render(profession, self)
    self.MV_Body:Render(profession, self)

end

function RGXProf.MiniWindow:SetPortrait(icon)
    local portraitFrame = _G[self.UIElements.backFrame:GetName().."Portrait"]
    SetPortraitToTexture(portraitFrame, icon)
end

--- @param profession Profession
function RGXProf.MiniWindow.MV_Header:Render(profession, parent)
    local ui = parent.UIElements
    local h = ui.Header
    local titleFs = ui.MV_Title.fontString

    local text = string.format("%s Preview", profession.name)
    
    RGXProf.Utils:SetText(titleFs, text)

end

--- @param profession Profession
function RGXProf.MiniWindow.MV_Body:Render(profession, parent)

    local ui = parent.UIElements
    local content = ui.Steps.content
    local scrollLineTemplate = RGXProf.Layouts.MiniWindow.Steps.scrollContent

    local contentLines = RGXProf.DataManager:GetStepPreviews(profession, profession.path, profession.pointsEarned)
    RGXProf.LayoutManager:FillScrollContent(
        scrollLineTemplate,
        content,
        contentLines,
        parent.context
    )
end