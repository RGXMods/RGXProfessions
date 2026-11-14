RGXProf = RGXProf or {}
RGXProf.OptionsWindow = RGXProf.OptionsWindow or {}

local function GetMeta(key)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        local ok, v = pcall(C_AddOns.GetAddOnMetadata, "RGXProfessions", key)
        if ok and v and v ~= "" then return v end
    elseif GetAddOnMetadata then
        local ok, v = pcall(GetAddOnMetadata, "RGXProfessions", key)
        if ok and v and v ~= "" then return v end
    end
end

function RGXProf.OptionsWindow:Setting(key)
    RGXProf_Settings = RGXProf_Settings or {}
    RGXProf.Settings = RGXProf_Settings
    return RGXProf_Settings[key]
end

function RGXProf.OptionsWindow:SetSetting(key, value)
    RGXProf_Settings = RGXProf_Settings or {}
    RGXProf_Settings[key] = value
    RGXProf.Settings = RGXProf_Settings
end

-- Show or hide the minimap button now, creating it on demand, and remember the choice.
function RGXProf.OptionsWindow:SetMinimapIcon(show)
    show = show and true or false
    self:SetSetting("minimapIconEnabled", show)
    if not RGXProf.minimapButton and show and RGXProf.CreateMinimapButton then
        RGXProf:CreateMinimapButton()
    end
    if RGXProf.minimapButton then RGXProf.minimapButton:SetVisible(show) end
end

--------------------------------------------------------------------------------
-- All options live in the game's own settings canvas. There is no separate
-- settings window to find, drag or close.
--------------------------------------------------------------------------------

function RGXProf.OptionsWindow:CreateOptionsPanel()

    local UI = _G.RGXUI
    -- RGXProf.L is a table of strings, not a function: read a key, with the English text as the fallback.
    local strings = RGXProf.L or {}
    local function L(key, default) return strings[key] or default end
    if not (UI and UI.CreateOptionsPanel) then
        return nil
    end

    local self_ = self
    local settings = RGXProf_Settings or {}
    local settingsRef = setmetatable({}, {
        __index = function(_, key) return (RGXProf_Settings or {})[key] end,
        __newindex = function(_, key, value)
            RGXProf_Settings = RGXProf_Settings or {}
            RGXProf_Settings[key] = value
            RGXProf.Settings = RGXProf_Settings
        end,
    })

    -- RGX standard: a card's header switch turns the whole card on or off; the options inside are tick boxes.
    local function Card(host, title, switchKey, switchDefault, onSwitch)
        local card = UI:CreateCard(host, {
            title = title,
            switch = switchKey and { storage = settingsRef, key = switchKey, default = switchDefault, onChange = onSwitch } or nil,
        })
        return card
    end

    -- Two columns of cards on one scroll canvas; each card is sized to its rows and the page is laid out
    -- again once the client has sized it.
    local function Grid(frame, builders)
        local canvas = frame._rgxCanvas or frame
        local hosts = { UI:CreateColumns(canvas, #builders) }
        local flows = {}
        for i, host in ipairs(hosts) do flows[i] = UI:CreateFlowLayout(host) end
        for i, build in ipairs(builders) do
            for _, card in ipairs(build(hosts[i])) do
                card:AutoHeight()
                flows[i]:Add(card)
            end
        end
        local function reflow()
            if canvas:GetWidth() <= 0 then return end
            local used = 0
            for _, flow in ipairs(flows) do used = math.max(used, flow:Apply()) end
            canvas:SetHeight(math.max(1, used))
        end
        reflow()
        canvas:HookScript("OnShow", reflow)
        canvas:HookScript("OnSizeChanged", reflow)
        if RGX and RGX.After then for _, delay in ipairs({ 0, 0.2, 0.6 }) do RGX:After(delay, reflow) end end
    end

    local function Tick(card, label, key, defaultValue, onChange)
        local w = UI:CreateCheckbox(card.content, label, {
            storage = settingsRef, key = key, default = defaultValue,
            onChange = onChange,
        })
        card.flow:Add(w, { fill = true })
        return w
    end

    local panel = UI:CreateOptionsPanel({
        addonName = "RGXProfessions",
        title = RGXProf.BrandTitle("Professions"),
        sidebarTitle = RGXProf.BrandTitle("Professions"),
        subtitle = L("SETTINGS_TITLE", "RGX Professions Settings"),
        icon = "Interface\\AddOns\\RGX-Framework\\media\\square.tga",
        theme = { primary = RGXProf.Brand.primary, accent = RGXProf.Brand.accent },
        version = "v" .. tostring(GetMeta("Version") or ""):gsub("^v+", ""),
        author = "DonnieDice",
        brand = "|cff8b4b5cRGX|r |cffffd700Mods|r",
        style = RGXProf.ActiveStyle(),
        width = 820,
        height = 640,
        hideTabRow = true,
        tabs = {
            {
                text = L("SETTINGS", "Settings"),
                content = function(frame)
                    RGXProf_Settings = RGXProf_Settings or {}

                    Grid(frame, {
                        function(host)
                            -- Chat: the switch is chat output; the option is the loaded message; the chat prefix is branded and not configurable.
                            local chat = Card(host, L("OPT_CHAT_HEADER", "Chat"), "chatOutput", settings.chatOutput ~= false)
                            Tick(chat, L("OPT_LOGIN", "Print a loaded message at login"), "loginMessage", settings.loginMessage ~= false)

                            -- Minimap: no header switch; the button is a tick box in the card (the Addons menu entry is always on).
                            local minimap = Card(host, L("OPT_MINIMAP_HEADER", "Minimap"))
                            Tick(minimap, L("OPT_MINIMAP_SHOW", "Show minimap button"), "minimapIconEnabled",
                                settings.minimapIconEnabled ~= false, function(v) self_:SetMinimapIcon(v) end)
                            return { chat, minimap }
                        end,
                        function(host)
                            -- Guide: the switch makes the guide follow the profession window; the ticks say how.
                            local guide = Card(host, L("OPT_GUIDE_HEADER", "Guide"), "followProfessionWindow",
                                settings.followProfessionWindow ~= false)
                            Tick(guide, L("OPT_BOOK_OPEN", "Open the book when a profession window opens"), "bookAutoOpen", settings.bookAutoOpen == true)
                            Tick(guide, L("OPT_BOOK_CLOSE", "Close the book when the profession window closes"), "bookAutoClose", settings.bookAutoClose == true)
                            Tick(guide, L("OPT_AUTOOPEN", "Open the guide with a profession window"), "autoOpen", settings.autoOpen == true)
                            Tick(guide, L("OPT_SELECT", "Click guide recipes to select them"), "selectRecipesInProfessionWindow",
                                settings.selectRecipesInProfessionWindow ~= false)
                            return { guide }
                        end,
                    })
                end,
            },
        },
    })

    self.panel = panel
    return panel
end

-- The gear in the guide header, /prof settings and the minimap menu all land
-- here: open the addon's category inside the game settings.
function RGXProf.OptionsWindow:Show()
    local panel = self.panel
    if not panel then
        panel = self:CreateOptionsPanel()
    end
    if panel and panel.Open then
        panel:Open()
    end
end

function RGXProf.OptionsWindow:Hide()
    if self.panel and self.panel.frame and self.panel.frame.Hide then
        self.panel.frame:Hide()
    end
end

function RGXProf.OptionsWindow:Toggle()
    self:Show()
end
