RGXProf = RGXProf or {}

---@class State
---@field CurrentState State
---@field RefreshPending boolean
---@field player Player
---@field profession Profession
---@field activeStep Step
---@field step Step
---@field nextStep Step
---@field altStep Step
---@field activeRecipe Recipe
---@field mainRecipe Recipe
---@field altRecipe Recipe
---@field nextRecipe Recipe
---@field selectedRecipe number
---@field reagents Reagent[]
---@field isCraft boolean
RGXProf.StateManager = {}

---@class Player
---@field level number
---@field faction string
---@field race string

-------------------------------------------------------
-- Manual guide mode: show a guide without a profession window
-------------------------------------------------------
function RGXProf.StateManager:ClearManualProfession()
    self.manualProfessionObject = nil
end

function RGXProf.StateManager:ShowGuideForProfession(pName)
    local professionID = RGXProf.Constants.ProfessionNameToID[pName]
    if not professionID then
        RGXProf.Utils:SendMsg(RGXProf.L.CMD_UNKNOWN_PROF .. tostring(pName))
        return
    end

    local path = RGXProf.currentExpansion and RGXProf.currentExpansion.paths and RGXProf.currentExpansion.paths[professionID]
    if not path then
        RGXProf.Utils:SendMsg(RGXProf.L.NO_GUIDE_AVAILABLE .. tostring(pName))
        return
    end

    local earned, total
    if RGXProf.WowAPI.GetProfessionSkill then
        earned, total = RGXProf.WowAPI:GetProfessionSkill(pName)
    end
    earned = earned or 1
    total = total or (RGXProf.currentExpansion.maxSkill or 300)

    if not RGXProf.MainWindow or not RGXProf.MainWindow.initializedUI then
        RGXProf.MainWindow:SetupUI()
    end

    self.manualProfessionObject = {
        id = professionID,
        icon = RGXProf.Constants.Professions[professionID].icon or RGXProf.Constants.Professions.Default.icon,
        pointsEarned = earned,
        pointsTotal = total,
        racialBonus = 0,
        name = pName,
        path = path,
        pointsRemaining = total - earned,
    }

    self:PerformRefresh()

    local backFrame = RGXProf.MainWindow.UIElements and RGXProf.MainWindow.UIElements.backFrame
    if backFrame then
        backFrame:Show()
    end
end

-------------------------------------------------------
-- Public API Entry: Request Refresh (debounced)
-------------------------------------------------------
function RGXProf.StateManager:RequestRefresh(forceShow)
    local mainWindow = RGXProf.MainWindow
    local legacyReady = mainWindow and mainWindow.initializedUI

    -- The trade-window guide only refreshes while a profession window (or a manual guide) is up.
    local adapter = RGXProf.AdapterManager:GetCurrent()
    local windowOpen = self.manualProfessionObject or (adapter and adapter:isShown())
    if not windowOpen then self.CurrentState = nil end

    local backFrame = legacyReady and mainWindow.UIElements and mainWindow.UIElements.backFrame
    local legacyWanted = legacyReady and windowOpen
        and (forceShow or not RGXProf.Settings or RGXProf.Settings.autoOpen or (backFrame and backFrame:IsShown()))

    -- The book tracks the live skill on its own: it refreshes whenever it is open, with or without a
    -- profession window and whether or not the trade-window guide has ever been built.
    local book = RGXProf.BookWindow
    local bookOpen = book and book.frame and book.frame:IsShown()

    if not legacyWanted and not bookOpen then return end

    if not self.RefreshPending then
        self.RefreshPending = true
        self.RefreshLegacy = legacyWanted and true or false
        -- RGX-Framework is a required dependency: its budgeted, labelled timer is the only timer used.
        _G.RGXFramework:After(0.2, function() self:PerformRefresh() end, "RGXProf_RequestRefresh")
    elseif legacyWanted then
        self.RefreshLegacy = true
    end
end

function RGXProf.StateManager:PerformRefresh()
    self.RefreshPending = false
    -- RefreshState renders the trade-window guide; run it only when that guide is wanted and built.
    local legacy = self.RefreshLegacy
    self.RefreshLegacy = nil
    if legacy == nil then legacy = true end   -- called directly (manual guide): the guide is wanted
    if legacy and RGXProf.MainWindow and RGXProf.MainWindow.initializedUI then
        self:RefreshState()
    end
    -- Live book: the professions book re-renders (and auto-advances the
    -- page) on every debounced refresh while it is open. Hooked here,
    -- not RefreshState, so it still runs when no trade window is open.
    if RGXProf.BookWindow and RGXProf.BookWindow.Refresh then
        RGXProf.BookWindow:Refresh()
    end
end

-------------------------------------------------------
-- Core Full State Rebuild
-------------------------------------------------------

function RGXProf.StateManager:RefreshState()

    local state = {}

    -- PROFESSION --
    local profession = self.manualProfessionObject or RGXProf.DataManager:GetProfession()
    if not profession or not profession.id then
        self.CurrentState = nil
        return
    end
    state.profession = profession

    -- PLAYER --
    state.player = RGXProf.WowAPI.GetPlayer()

    -- STEP --
    local step, nextStep, altStep = RGXProf.DataManager:GetSteps(state.player.faction, state.profession)

    if not step then
        self.CurrentState = nil
        return
    end

    state.step = step
    state.nextStep = nextStep
    state.altStep = altStep

    -- RECIPE (includes REAGENTS) --
    state.mainRecipe = RGXProf.DataManager:GetRecipeWithReagents(state.profession.pointsEarned, step)
    state.altRecipe  = altStep and RGXProf.DataManager:GetRecipeWithReagents(state.profession.pointsEarned, altStep) or nil
    state.nextRecipe = nextStep and RGXProf.DataManager:GetRecipeWithReagents(state.profession.pointsEarned, nextStep) or nil
    if RGXProf.CurrentState and RGXProf.CurrentState.activeRecipe.name == state.mainRecipe.name then 
        state.selectedRecipe = RGXProf.Constants.MAIN
    elseif RGXProf.CurrentState and state.altRecipe and RGXProf.CurrentState.activeRecipe.name  == state.altRecipe.name  then 
        state.selectedRecipe = RGXProf.Constants.ALTERNATE 
    else
        state.selectedRecipe = RGXProf.Constants.MAIN
    end

    state.activeStep = (state.selectedRecipe == RGXProf.Constants.MAIN)
            and state.step
            or state.altStep
    state.activeRecipe = (state.selectedRecipe == RGXProf.Constants.MAIN)
            and state.mainRecipe
            or state.altRecipe
    state.training = RGXProf.DataManager:DetermineTraining(state.player.faction, state.activeStep, state.activeRecipe, profession)
    RGXProf.CurrentState = state
    RGXProf.MainWindow:Render(state)

end


function RGXProf.StateManager:ShouldShowUI(profession)
    if not profession then return false end
    return ( profession.id and profession.id > 0) and
            (profession.pointsEarned < RGXProf.currentExpansion.maxSkill) and
            (profession.pointsTotal > 1)
end

-------------------------------------------------------
-- Helpers to determine profession and step
-------------------------------------------------------

function RGXProf.StateManager:DetermineCurrentStep(professionData, skillLevel)
    for _, step in ipairs(professionData.steps) do
        if skillLevel >= step.minSkill and skillLevel <= step.maxSkill then
            return step
        end
    end
    return nil
end

-- -------------------------------------------------------
-- -- Handle toggle (main/alt switch)
-- -------------------------------------------------------

function RGXProf.StateManager:SwitchRecipeSlot(slot)
    local state = RGXProf.CurrentState
    if not state then return end

    state.selectedRecipe = slot
    state.activeStep = (slot == RGXProf.Constants.MAIN)
            and state.step
            or state.altStep
    state.activeRecipe = (state.selectedRecipe == RGXProf.Constants.MAIN)
            and state.mainRecipe
            or state.altRecipe

    local adapter = RGXProf.AdapterManager:GetCurrent()
    local selectInProfessionWindow = not RGXProf.Settings
        or RGXProf.Settings.selectRecipesInProfessionWindow ~= false
    if selectInProfessionWindow and state.activeRecipe and adapter then
        adapter:selectBySpellID(state.activeRecipe.spellID, state.activeRecipe.name)
    end

    RGXProf.MainWindow:Render(state)
end
