RGXProf = RGXProf or {}

local RGX = assert(_G.RGXFramework, "RGXProfessions: RGX-Framework not loaded")

local hasInitialized = false

function RGXProf:SafeInitialize()
    if hasInitialized then return end
    hasInitialized = true

    if not RGXProf.Expansions:IsSupported() then return end
    local version = RGXProf.Expansions:GetVersion()
    RGXProf.Expansions:SetExpansionData(version)
    RGXProf.Constants:InitializeLocalizedProfessionNames()
    RGXProf.DataManager:BuildReagentUsageIndex()
    RGXProf:Initialize()
end

function RGXProf:Initialize()
    RGXProf:RegisterEvents()
    RGXProf.AdapterManager:RegisterMissedAdapters()
end

function RGXProf:CreateMinimapButton()
    if RGXProf.minimapButton or not RGX then return end

    local MM = RGX:GetMinimap()
    RGXProf.minimapButton = MM:Create({
        name = "RGXProfessions_MinimapButton",
        icon = "Interface\\AddOns\\RGXProfessions\\Media\\RGXIcon.tga",
        defaultAngle = 220,
        storage = RGXProf_Settings,
        angleKey = "minimapAngle",
        enabledKey = "minimapIconEnabled",
        tooltip = {
            title = "|cff8B1538RGX|r Professions",
            getLines = function()
                return {
                    { left = "|cffffffffProfession leveling paths|r" },
                    { left = "|cff8B1538Left-Click|r", right = "|cffffffffOpen the book|r" },
                    { left = "|cff4ecdc4Left-Drag|r", right = "|cffffffffMove around minimap|r" },
                    { left = "|cffe74c3cCtrl+Right-Click|r", right = "|cffffffffHide minimap icon|r" },
                }
            end,
        },
        onLeftClick = function()
            if RGXProf.BookWindow then
                RGXProf.BookWindow:Toggle()
            end
        end,
        onRightClick = function()
            -- Open addon options panel using legacy API (panel is created with CreateFrame)
            if InterfaceOptionsFrame_OpenToCategory then
                InterfaceOptionsFrame_OpenToCategory("RGX Professions")
                -- WoW quirk: first call sometimes doesn't work
                InterfaceOptionsFrame_OpenToCategory("RGX Professions")
            end
        end,
        onCtrlRight = function(btn)
            btn:SetVisible(false)
            RGXProf_Settings.minimapIconEnabled = false
            print("[RGXProf] Minimap icon |cffff0000hidden|r. Use |cffffffff/prof icon on|r to show it again.")
        end,
    })

    RGXProf.minimapButton:SetVisible(RGXProf_Settings.minimapIconEnabled ~= false)

    RGX:RegisterSlashCommand("/prof", function(args)
        RGXProf:HandleSlashCommand(args)
    end, "RGXProfessions")
end

RGXProf:SafeInitialize()
