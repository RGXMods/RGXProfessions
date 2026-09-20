RGXProf.Reagents = {}

---@param reagents Reagent[]
function RGXProf.Reagents:Render(reagents)
    for _, reagent in ipairs(reagents) do
        self:RenderReagentSlot(reagent)
    end

    for i = (#(reagents) + 1), RGXProf.Layouts.Defaults.maxReagents do
        local frame = RGXProf.MainWindow.UIElements["Reagent" .. i]
        if frame then frame:Hide() end
    end
end

---@param reagent Reagent
function RGXProf.Reagents:RenderReagentSlot(reagent)
    local frame = RGXProf.MainWindow.UIElements["Reagent"..reagent.slot]
    if not frame then return end

    local text = RGXProf.LayoutManager:GetChildFrame(frame, "_ItemName")
    local icon = RGXProf.LayoutManager:GetChildFrame(frame, "_Icon_Frame")
    local countText = RGXProf.LayoutManager:GetChildFrame(frame, "_Count")

    if text and text.fontString then
        RGXProf.Utils:SetText(text.fontString, reagent.name or "")
    end

    if icon and icon.fontString then
        RGXProf.Utils:SetText(icon.fontString, reagent.displayText or "")
    end

    if icon and icon.texture then
        local tex = reagent.link and RGXProf.WowAPI:GetItemIcon(reagent.link) or reagent.icon
        icon.texture:SetTexture(tex)
    end

    if countText and countText.fontString then
        RGXProf.Utils:SetText(countText.fontString, reagent.displayText or "")
    end

    RGXProf.FrameRegistry:Register(icon, {itemID = reagent.itemID, link = reagent.link})
    frame:Show()

end
