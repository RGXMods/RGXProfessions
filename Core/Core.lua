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
        -- Blizzard Addons menu entry: always on, not an option
        compartment = true,
        compartmentText = RGXProf.BrandTitle("Professions"),
        defaultAngle = 220,
        storage = RGXProf_Settings,
        angleKey = "minimapAngle",
        enabledKey = "minimapIconEnabled",
        tooltip = {
            title = RGXProf.BrandTitle("Professions"),
            getLines = function()
                local L = RGXProf.L
                return {
                    { left = "|cffffffffProfession leveling paths|r" },
                    { left = "|cff8B1538" .. L.MINIMAP_LEFT_CLICK .. "|r", right = "|cffffffff" .. L.MINIMAP_OPEN_BOOK .. "|r" },
                    { left = "|cff4ecdc4" .. L.MINIMAP_LEFT_DRAG .. "|r", right = "|cffffffff" .. L.MINIMAP_MOVE .. "|r" },
                    { left = "|cffe74c3c" .. L.MINIMAP_CTRL_RIGHT_CLICK .. "|r", right = "|cffffffff" .. L.MINIMAP_HIDE .. "|r" },
                }
            end,
        },
        onLeftClick = function()
            if RGXProf.BookWindow then
                RGXProf.BookWindow:Toggle()
            end
        end,
        onRightClick = function()
            if RGXProf.OptionsWindow and RGXProf.OptionsWindow.Toggle then RGXProf.OptionsWindow:Toggle() end
        end,
        onCtrlRight = function()
            RGXProf.OptionsWindow:SetMinimapIcon(false)
            RGXProf.Utils:SendMsg(RGXProf.L.CMD_ICON_HIDDEN)
        end,
    })

    RGXProf.minimapButton:SetVisible(RGXProf_Settings.minimapIconEnabled ~= false)

    RGX:RegisterSlashCommand("/prof", function(args)
        RGXProf:HandleSlashCommand(args)
    end, "RGXProfessions")
end

RGXProf:SafeInitialize()
