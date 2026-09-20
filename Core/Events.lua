--------------------------------------------------------------------

RGXProf.Events = {
    TRADE_SKILL_SHOW = function(self, ...)
        self:TRADE_SHOW("TRADE_SKILL_SHOW")
    end,
    CRAFT_SHOW = function(self, ...)
        self:TRADE_SHOW("CRAFT_SHOW")
    end,
    TRADE_SKILL_CLOSE = function(self)
        self:TRADE_CLOSE()
    end,
    CRAFT_CLOSE = function(self)
        self:TRADE_CLOSE()
    end,
    TRADE_SKILL_UPDATE = function(self)
        RGXProf.StateManager:RequestRefresh()
    end,
    CRAFT_UPDATE = function(self)
        RGXProf.StateManager:RequestRefresh()
    end,
    SKILL_LINES_CHANGED = function(self)
        RGXProf.StateManager:RequestRefresh()
    end,
    TRADE_SKILL_LIST_UPDATE = function(self)
        RGXProf.StateManager:RequestRefresh()
    end,
    BAG_UPDATE_DELAYED = function(self)
        RGXProf.StateManager:RequestRefresh()
    end,
    GET_ITEM_INFO_RECEIVED = function(self, ...)
        RGXProf.StateManager:RequestRefresh()
    end,
    ADDON_LOADED = function(self, event, addonName)
        if RGXProf.AdapterFactories[addonName] then RGXProf.AdapterManager:RegisterAsLoaded(addonName) end

        if addonName == "RGXProfessions" then

            RGXProf_Settings = RGXProf_Settings or {}
            if RGXProf_Settings.autoOpen == nil then
                RGXProf_Settings.autoOpen = true
            end
            if RGXProf_Settings.selectRecipesInProfessionWindow == nil then
                RGXProf_Settings.selectRecipesInProfessionWindow = true
            end
            if RGXProf_Settings.minimapIconEnabled == nil then
                RGXProf_Settings.minimapIconEnabled = true
            end
            RGXProf_Settings.minimapAngle = RGXProf_Settings.minimapAngle or 220

            -- Older builds could save the Remaining Materials window on top of
            -- the main guide. Clear that legacy coordinate once so 4.3.2 can
            -- apply its beside-the-guide default; later user drags remain saved.
            if (RGXProf_Settings.positionSchemaVersion or 0) < 2 then
                if RGXProf_Settings.positions then
                    RGXProf_Settings.positions.RGXProf_MatsV_BackFrame_Position = nil
                end
                RGXProf_Settings.positionSchemaVersion = 2
            end
            RGXProf.Settings = RGXProf_Settings

            local configPanel = RGXProf.OptionsWindow:CreateOptionsPanel()

            if InterfaceOptions_AddCategory then
                InterfaceOptions_AddCategory(configPanel)
            elseif Settings and Settings.RegisterCanvasLayoutCategory then
                local category = Settings.RegisterCanvasLayoutCategory(configPanel, configPanel.name)
                Settings.RegisterAddOnCategory(category)
            end

            RGXProf:CreateMinimapButton()
        end
    end
}

local function RegisterEventSafe(eventName)
    local RGX = _G.RGXFramework
    if not RGX or not RGX.RegisterEvent then return end
    if C_EventUtils and C_EventUtils.IsEventValid and not C_EventUtils.IsEventValid(eventName) then
        return
    end
    local tag = "RGXProf_" .. eventName
    RGX:RegisterEvent(eventName, function(event, ...)
        RGXProf:HandleEvent(event, ...)
    end, tag)
end

function RGXProf:RegisterEvents()
    for eventName, _ in pairs(self.Events) do
        RegisterEventSafe(eventName)
    end
end

function RGXProf:TRADE_SHOW(event, forceShow)

    -- A real profession window takes over from manual guide mode
    if RGXProf.StateManager and RGXProf.StateManager.ClearManualProfession then
        RGXProf.StateManager:ClearManualProfession()
    end

    if not forceShow and not self.Settings.autoOpen then return end

    if not self.MainWindow.initializedUI then
        RGXProf.MainWindow:SetupUI()
    end

    RGXProf.StateManager:RequestRefresh(forceShow)
end

function RGXProf:TRADE_CLOSE()
    -- Keep a manually opened guide visible when no profession window is involved
    if RGXProf.StateManager and RGXProf.StateManager.manualProfessionObject then return end

    local adapter = RGXProf.AdapterManager:GetCurrent()

    --There's an adapter showing so don't close RGXProf
    if adapter and adapter.isShown and adapter:isShown() then return end

    local backFrame = RGXProf.MainWindow.UIElements.backFrame
    if backFrame then
        backFrame:Hide()
    end
end

function RGXProf:HandleEvent(event, ...)
    if not self.Events then return end

    if type(self.Events[event]) == "function" then
        self.Events[event](self, event, ...)
    elseif type(self[event]) == "function" then
        self[event](self, event, ...)
    end

    for _, adapter in pairs(self.AdapterManager.registeredAdapters) do
        if adapter.loaded and adapter.Events and adapter.Events[event] then
            adapter.Events[event](adapter, ...)
        end
    end
end
