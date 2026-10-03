--------------
--- Handles all the clicks for display events
--------------
RGXProf.ClickHandlers = {}

---@param frame {}
RGXProf.ClickHandlers.RecipeClick = function(frame, data)
    if not data or not data.slot then return end
    -- RGXProf.CurrentState.selectedRecipe = data.slot
    -- if RGXProf.IsSimulation then RGXProf.MainWindow:Render(RGXProf.CurrentState) end
    RGXProf.StateManager:SwitchRecipeSlot(data.slot)
    -- RGXProf.StateManager:RequestRefresh()
end

---@param frame {}
RGXProf.ClickHandlers.TrainerClick = function(frame)
    if RGXProf.AdapterManager:HasNavigationAddon() then
        local data = RGXProf.FrameRegistry:Get(frame)
        if not data or not data.list or #(data.list) == 0 then return end

        local z = RGXProf.WowAPI:GetBestMapForUnit("player")

        local list = data.list
        if #list > 1 then
            local z = RGXProf.WowAPI:GetBestMapForUnit("player")
            for _, npc in ipairs(list) do
                if (npc.zoneID == z) then
                    RGXProf.AdapterManager:SetWaypoint(npc.name, npc.zoneID, npc.x, npc.y)
                    return
                end
            end
        end

        if #list == 1 then
            local npc = list[1]
            if (npc.zoneID == z) then
                RGXProf.AdapterManager:SetWaypoint(npc.name, npc.zoneID, npc.x, npc.y)
            else
                RGXProf.Utils:SendMsg(RGXProf.L.NO_TRAINER_IN_ZONE)
            end
        else
            RGXProf.Utils:SendMsg(RGXProf.L.NO_TRAINER_IN_ZONE)
        end
    end
end

RGXProf.ClickHandlers.CalculateClick = function(frame)
    local data = RGXProf.FrameRegistry:Get(frame)
    if not data then return end
    RGXProf.MatsWindow:Show(data)
end

RGXProf.ClickHandlers.PreviewClick = function(frame)
    local data = RGXProf.FrameRegistry:Get(frame)
    if not data then return end

    RGXProf.MiniWindow:Show(data)

end