RGXProf.Instructions = {}

--- @param training Training current training passed from state
function RGXProf.Instructions:Render(training)

    local text = training and training.instructions or ""
    local f = RGXProf.MainWindow.UIElements.Instructions
    local bodyFs = RGXProf.MainWindow.UIElements.Instructions_Body.fontString
    local titleFs = RGXProf.MainWindow.UIElements.Instructions_Title.fontString

    RGXProf.Utils:SetText(bodyFs, text)
    RGXProf.LayoutManager:AutoResizeTextFrames(f, titleFs, bodyFs)

    -- Set button texture if list exists
    if training.list and #training.list > 0 then
        local button = RGXProf.MainWindow.UIElements.Trainer
        button:SetNormalTexture(training.icon)

        local tooltipLayout = RGXProf.TooltipManager:CreateFinalTooltipContent(training.layout, self:BuildTooltipContent(training))
        RGXProf.FrameRegistry:Register(button, {tooltipLayout = tooltipLayout, list = training.list})
        button:Show()
        
    else
        RGXProf.MainWindow.UIElements.Trainer:Hide()
    end
end


--- The BuildTooltipContent tries to just expose enough to add all the relevant content without exposing the render information
--- @param training Training
function RGXProf.Instructions:BuildTooltipContent(training)
    local npcList = training.list
    local content = {
        subtitle = npcList[1].questName,
        children = {},
        footer = RGXProf.AdapterManager:HasNavigationAddon() and "|cff00ff00Click to set a waypoint.|r" or nil
    }
    for _, item in ipairs(npcList or {}) do
        table.insert(content.children, {
            leftText = item.name,
            rightText = RGXProf.WowAPI:GetMapName(item.zoneID)
        })
        if item.note then
            table.insert(content.children, {
                footer = item.note
            })
        end
    end

    return content
end