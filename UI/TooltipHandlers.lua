RGXProf.TooltipHandlers = {}

---@param frame {}
RGXProf.TooltipHandlers.RecipeTooltip = function(frame)
    local data = RGXProf.FrameRegistry:Get(frame)
    if not data or not data.link then return end
    GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
    GameTooltip:SetHyperlink(data.link)
    local selectInProfessionWindow = not RGXProf.Settings
        or RGXProf.Settings.selectRecipesInProfessionWindow ~= false
    if selectInProfessionWindow and data.slot ~= RGXProf.CurrentState.selectedRecipe then
        GameTooltip:AddLine(RGXProf.L.SELECT, 1, 1, 1, 0)
        SetCursor("CAST_CURSOR")
    end
    
    local spellID = data.spellID
    local skill = RGXProf.CurrentState.profession.pointsEarned
    if spellID and skill then
        local factor = RGXProf.DataManager:GetRecipeCraftFactor(spellID, skill)

        if factor == math.huge then
            GameTooltip:AddLine("|cffff4040No points|r", 1, 0.2, 0.2)
        elseif factor > 2.5 then
            GameTooltip:AddLine("|cff40ff40~5+ cpp|r", 0.5, 1, 0.5)
        elseif factor > 1.5 then
            GameTooltip:AddLine("|cffffff40~1.5 cpp|r", 1, 1, 0.5)
        elseif factor < 1.0 then
            local up = math.floor((1 / factor) + 0.5) -- round up
            GameTooltip:AddLine("|cffffffffBonus: "..up .. " point" .. (up > 1 and "s" or "") .. " per craft|r", 1, 1, 1)
        end
    end
    GameTooltip:Show()
end

RGXProf.TooltipHandlers.CalculateTooltip = function(frame)
    GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
    GameTooltip:AddLine(RGXProf.L.CALCULATE)
    GameTooltip:Show()
end

RGXProf.TooltipHandlers.PreviewTooltip = function(frame)
    GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
    GameTooltip:AddLine(RGXProf.L.PREVIEW)
    GameTooltip:Show()
end

RGXProf.TooltipHandlers.ReagentTooltip = function(frame)
    local data = RGXProf.FrameRegistry:Get(frame)
    if not data or not data.itemID then return end

    local itemID = data.itemID

    GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
    GameTooltip:SetItemByID(itemID)

    --usage information will get attached via AttachTooltip

    GameTooltip:Show()
end

RGXProf.TooltipHandlers.NextUpTooltip = function(frame)

    local data = RGXProf.FrameRegistry:Get(frame)
    if not data then
        return
    end

    if not data.tooltipLayout then
        return
    end

    GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
    RGXProf.TooltipManager:RenderTooltipFromLayout(GameTooltip, data.tooltipLayout)
    GameTooltip:Show()
end

RGXProf.TooltipHandlers.TrainingTooltip = function(frame)

    local data = RGXProf.FrameRegistry:Get(frame)
    if not data or not data.tooltipLayout then return end

    if RGXProf.AdapterManager:HasNavigationAddon() then
        SetCursor("Interface/CURSOR/Point.blp")
    end
    GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
    RGXProf.TooltipManager:RenderTooltipFromLayout(GameTooltip, data.tooltipLayout)
    GameTooltip:Show()
end

RGXProf.TooltipHandlers.SimpleTooltip = function(frame)
    if not frame.tooltipData then return end

    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink(frame.tooltipData)
    GameTooltip:Show()

end
