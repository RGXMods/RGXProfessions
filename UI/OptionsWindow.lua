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
    local L = RGXProf.L
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

    local function Card(frame, title)
        local card = UI:CreateCard(frame, { title = title })
        frame._rgxFlow:Add(card)
        return card
    end

    local function Text(card, text)
        local w = UI:CreateLabel(card.content, {
            text = text,
            size = "small",
            color = "muted",
            wrap = true,
        })
        card.flow:Add(w)
        return w
    end

    local function Toggle(card, label, key, defaultValue, onChange)
        local w = UI:CreateSwitch(card.content, {
            label = label,
            storage = settingsRef,
            key = key,
            default = defaultValue,
            onChange = function(value)
                if onChange then onChange(value) end
            end,
        })
        card.flow:Add(w)
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
        tabs = {
            {
                text = L("SETTINGS", "Settings"),
                content = function(frame)
                    -- The shared General card: minimap button, Addons menu, chat output, login message, chat prefix.
                    if UI.CreateStandardCard then
                        RGXProf_Settings = RGXProf_Settings or {}
                        local general = UI:CreateStandardCard(frame, {
                            storage = RGXProf_Settings,
                            minimap = function() return RGXProf.minimapButton end,
                            defaultPrefix = "RGX Professions",
                            labels = {
                                description = L("OPT_MINIMAP_DESC", "The RGX Professions button on your minimap."),
                                addonMenu = L("OPT_ADDON_MENU", "List in the Addons menu"),
                                chat = L("OPT_CHAT", "Print guide messages to chat"),
                                login = L("OPT_LOGIN", "Print a loaded message at login"),
                                prefix = L("OPT_CHAT_PREFIX", "Chat prefix"),
                            },
                        })
                        frame._rgxFlow:Add(general)
                    else
                        local minimap = Card(frame, L("OPT_MINIMAP_HEADER", "Minimap and Addons menu"))
                        Text(minimap, L("OPT_MINIMAP_DESC", "The RGX Professions button on your minimap."))
                        Toggle(minimap, L("OPT_MINIMAP", "Show the minimap icon"), "minimapIconEnabled",
                            settings.minimapIconEnabled ~= false,
                            function(v) self_:SetMinimapIcon(v) end)
                        Text(minimap, L("OPT_ADDON_MENU_DESC", "Adds RGX | Professions to the Addons menu on the minimap."))
                        Toggle(minimap, L("OPT_ADDON_MENU", "List in the Addons menu"), "addonMenu",
                            settings.addonMenu ~= false,
                            function(v) self_:SetAddonMenu(v) end)
                        minimap:AutoHeight()

                    end

                    local guide = Card(frame, L("OPT_GUIDE_HEADER", "Guide"))
                    Text(guide, L("OPT_FOLLOW_DESC", "When a profession window is open, the guide opens to that profession."))
                    Toggle(guide, L("OPT_FOLLOW", "Open to the profession window"), "followProfessionWindow",
                        settings.followProfessionWindow ~= false)
                    Toggle(guide, L("OPT_AUTOOPEN", "Open the guide with a profession window"), "autoOpen",
                        settings.autoOpen == true)
                    Toggle(guide, L("OPT_SELECT", "Click guide recipes to select them"), "selectRecipesInProfessionWindow",
                        settings.selectRecipesInProfessionWindow ~= false)
                    guide:AutoHeight()

                    if not UI.CreateStandardCard then
                        local chat = Card(frame, L("OPT_CHAT_HEADER", "Chat"))
                        Text(chat, L("OPT_CHAT_DESC", "Guide messages print to your chat frame with this prefix."))
                        Toggle(chat, L("OPT_CHAT", "Print guide messages to chat"), "chatOutput",
                            settings.chatOutput ~= false)
                        Toggle(chat, L("OPT_LOGIN", "Print a loaded message at login"), "loginMessage",
                            settings.loginMessage ~= false)
                        UI:CreateTextInput(chat.content, {
                            label = L("OPT_CHAT_PREFIX", "Chat prefix"),
                            storage = settingsRef,
                            key = "chatPrefix",
                            default = "RGX Professions",
                            placeholder = "RGX Professions",
                            width = 260,
                        })
                        chat:AutoHeight()
                    end
                end,
            },
        },
    })

    self.panel = panel
    return panel
end

-- Show or hide the Blizzard Addons menu entry. Needs framework 2.16 (SetCompartmentVisible); on a client
-- that cannot remove an entry the choice applies after the next reload, and the player is told.
function RGXProf.OptionsWindow:SetAddonMenu(show)
    show = show and true or false
    self:SetSetting("addonMenu", show)
    local button = RGXProf.minimapButton
    if button and button.SetCompartmentVisible then
        if button:SetCompartmentVisible(show) == false then
            RGXProf.Utils:SendMsg(RGXProf.L.OPT_ADDON_MENU_RELOAD)
        end
    end
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
