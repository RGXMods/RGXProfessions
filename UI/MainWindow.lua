RGXProf = RGXProf or {}
RGXProf.MainWindow = RGXProf.MainWindow or {
    layoutGroup = "MainWindow",
    layoutRoot = "BackFrame",
    UIElements = {},
    initializedUI = false
}

--- @return Context
function RGXProf.MainWindow:InitLayoutContext()
    return {
        layoutGroup = RGXProf.Layouts[self.layoutGroup],
        layoutRoot = RGXProf.Layouts[self.layoutGroup][self.layoutRoot],
        ui = self.UIElements,
    }
end

--- Fully sets up the RGXProf window UI.
function RGXProf.MainWindow:SetupUI()

    local context = self:InitLayoutContext()
    self.UIElements = RGXProf.LayoutManager:BuildLayout(context)
    RGXProf.AdapterManager:RegisterMissedAdapters()
    self.initializedUI = true

    if RGXProf.IsSimulation then
        RGXProf._simUsedRecipes = nil
        local btn = CreateFrame("Button", "RGXProfSimNextButton", RGXProf.MainWindow.UIElements.backFrame, "UIPanelButtonTemplate")
        btn:SetSize(60, 20)
        btn:SetPoint("TOPRIGHT", RGXProf.MainWindow.UIElements.backFrame, "TOPRIGHT", -10, -10)
        btn:SetText("Next")
        btn:SetScript("OnClick", function()
        local state = RGXProf.CurrentState
        if not state then
            print("⚠️  No active simulation. Use /RGXProfsim first.")
            return
        end
        local next = state.nextStep
        if not next then
            print("✅  End of path reached!")
            return
        end
        RGXProf:SimulateStep(state.profession.id, next.minSkill, state.player.faction)
        end)
    end
end

---
--- @param state State
function RGXProf.MainWindow:Render(state)
    local frame = self.UIElements.backFrame
    -- Handle empty state (e.g. max skill, invalid profession, etc.)
    if not state or not state.profession or not state.profession.id then
        frame:Hide()
        return
    end
    -- Handle maxed out profession
    if state.profession.pointsEarned >= RGXProf.currentExpansion.maxSkill then
        RGXProf.Utils:SendMsg("Your profession is maxed.")
        frame:Hide()
        return
    end
    -- Evaluate ShouldShowUI logic here
    if not RGXProf.StateManager:ShouldShowUI(state.profession) then
        frame:Hide()
        return
    end

    local RGX = _G.RGXFramework; local afterFn = (RGX and RGX.After) or C_Timer.After; afterFn(0.1, function()
        local adapter = RGXProf.AdapterManager:GetCurrent()
        if adapter and adapter.position then
            adapter:position(self.UIElements.backFrame)
            frame:Show()
        end
    end)


    ----------------------------------------------------------
    -- Render all the frames with their data
    ----------------------------------------------------------
    self:SetPortrait(state.profession.icon)

    RGXProf.Instructions:Render(state.training)
    RGXProf.Recipes:Render(state)
    RGXProf.Reagents:Render(state.activeRecipe.reagents)
    RGXProf.Footer:Render(state.nextRecipe, state.profession)
    
end

function RGXProf.MainWindow:SetPortrait(icon)
    local portraitFrame = _G[self.UIElements.backFrame:GetName().."Portrait"]
    SetPortraitToTexture(portraitFrame, icon)
end
