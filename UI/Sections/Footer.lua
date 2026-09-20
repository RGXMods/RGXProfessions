RGXProf.Footer = {}

--- @param recipe Recipe The next recipe
--- @param profession Profession 
function RGXProf.Footer:Render(recipe, profession)

    self:RenderNextUpText(recipe)
    self:RegisterNextUpTooltip(recipe)
    self:RegisterCalculateClick(profession.icon, profession.pointsEarned, profession.path)

end

--- @param recipe Recipe The next recipe
function RGXProf.Footer:RenderNextUpText(recipe)
    local fs = RGXProf.MainWindow.UIElements.NextUp_Spell
    local section = RGXProf.MainWindow.UIElements.NextUp

    if not recipe or not recipe.name then
        if section then section:Hide() end
        return
    end

    if section then section:Show() end
    RGXProf.Utils:SetText(fs.fontString, recipe.name)

end

--- @param recipe Recipe The next recipe
function RGXProf.Footer:RegisterNextUpTooltip(recipe)
    local frame = RGXProf.MainWindow.UIElements.NextUp_Spell

    if not recipe or not recipe.name then
        RGXProf.FrameRegistry:Clear(frame)
        return
    end
    local layout = RGXProf.Utils:DeepCopy(RGXProf.Layouts.Tooltips.NextUp)
    local content = {
        title = recipe.name,
        footer = "x" .. tostring(recipe.craftCount),
        children = {},
    }

    for i, reagent in ipairs(recipe.reagents or {}) do
        table.insert(content.children, {
            leftText = reagent.name,
            rightText = reagent.tooltip
        })
    end
    local tooltipLayout = RGXProf.TooltipManager:CreateFinalTooltipContent(layout, content)
    RGXProf.FrameRegistry:Register(frame, { tooltipLayout = tooltipLayout })
end

--- Registers the Calculate button click handler
--- @param icon string The icon to display on the portraitFrame
---@param currentSkill number
---@param path table 
function RGXProf.Footer:RegisterCalculateClick(icon, currentSkill, path)
    local frame = RGXProf.MainWindow.UIElements.Calculate
    RGXProf.FrameRegistry:Register(frame, {icon = icon, currentSkill = currentSkill, path = path})
end
