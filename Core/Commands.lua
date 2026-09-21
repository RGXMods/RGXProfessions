RGXProf = RGXProf or {}

local function GetGuideProfessions()
    local list = {}
    if not (RGXProf.currentExpansion and RGXProf.currentExpansion.paths and RGXProf.Constants and RGXProf.Constants.Professions) then
        return list
    end

    for _, professionID in ipairs(RGXProf.Constants.ProfessionOrder) do
        if RGXProf.currentExpansion.paths[professionID] and RGXProf.Constants.Professions[professionID] then
            table.insert(list, professionID)
        end
    end
    return list
end

local function ResolveProfessionName(input)
    if not input or input == "" then return nil end
    input = input:lower()
    for name, id in pairs(RGXProf.Constants.ProfessionNameToID) do
        if name:lower() == input then
            return name, id
        end
    end
    for name, id in pairs(RGXProf.Constants.ProfessionNameToID) do
        if name:lower():find(input, 1, true) then
            return name, id
        end
    end
    return nil
end

local menuFrame

local function ShowProfessionMenu()
    local professions = GetGuideProfessions()
    if #professions == 0 then
        print("|cffff0000[RGXProf]|r No profession guides are loaded.")
        return
    end

    local menu = {}
    for _, professionID in ipairs(professions) do
        local prof = RGXProf.Constants.Professions[professionID]
        local skill = RGXProf.WowAPI.GetProfessionSkill and RGXProf.WowAPI:GetProfessionSkill(prof.name) or nil
        local label = prof.name
        if skill then
            label = label .. " (" .. skill .. ")"
        end
        table.insert(menu, {
            text = label,
            icon = prof.icon,
            func = function()
                RGXProf.StateManager:ShowGuideForProfession(prof.name)
            end,
        })
    end

    if not menuFrame and EasyMenu and UIDropDownMenu_CreateInfo then
        menuFrame = CreateFrame("Frame", "RGXProf_ProfessionMenuFrame", UIParent, "UIDropDownMenuTemplate")
    end

    if menuFrame and EasyMenu then
        EasyMenu(menu, menuFrame, "cursor", 0, 0, "MENU")
    else
        print("|cffffff00[RGXProf]|r Choose a profession: /RGXProf show <name>")
        for _, professionID in ipairs(professions) do
            print("  - " .. RGXProf.Constants.Professions[professionID].name)
        end
    end
end

function RGXProf:HandleSlashCommand(msg)
    msg = (msg or ""):trim():lower()

    local command, args = msg:match("^(%S+)%s*(.-)$")
    command = command or ""

    if command == "" then
        if RGXProf.BookWindow then
            RGXProf.BookWindow:Toggle()
        else
            print("|cffff0000[RGXProf]|r The professions book is not loaded yet.")
        end
    elseif command == "book" then
        if RGXProf.BookWindow then RGXProf.BookWindow:Show() end
    elseif command == "icon" then
        local sub = (args or ""):lower()
        if sub == "on" then
            RGXProf_Settings.minimapIconEnabled = true
            if RGXProf.minimapButton then RGXProf.minimapButton:SetVisible(true) end
            print("[RGXProf] Minimap icon |cff00ff00shown|r")
        elseif sub == "off" then
            RGXProf_Settings.minimapIconEnabled = false
            if RGXProf.minimapButton then RGXProf.minimapButton:SetVisible(false) end
            print("[RGXProf] Minimap icon |cffff0000hidden|r. Use |cffffffff/prof icon on|r to show it again.")
        else
            print("Usage: |cffffff00/prof icon on|r or |cffffff00/prof icon off|r")
        end
    elseif command == "show" then
        local adapter = RGXProf.AdapterManager:GetCurrent()

        if args ~= "" then
            local name = ResolveProfessionName(args)
            if name then
                RGXProf.StateManager:ShowGuideForProfession(name)
            else
                print("|cffff0000[RGXProf]|r Unknown profession: " .. args)
            end
        else
            RGXProf.BookWindow:Show()
        end
    elseif command == "preview" then
        if args == "" then
            if not RGXProf.CurrentState or not RGXProf.CurrentState.profession then
                print("No active profession found. Open a profession window first.")
                return
            end

            local prof = RGXProf.CurrentState.profession.name
            local skill = RGXProf.CurrentState.profession.pointsEarned or 1
            RGXProf.MiniWindow:Show(prof, skill)
        else
            local prof, skill = args:match("^(%S+)%s+(%d+)$")
            if not prof or not skill then
                print("Usage: /RGXProf preview [profession] [skill]")
                return
            end
            RGXProf.MiniWindow:Show(prof, tonumber(skill))
        end
    else
        print("|cffffff00[RGXProf]|r Commands:")
        print("|cffffff00/prof|r - Open the professions book")
        print("|cffffff00/prof show|r - Open the trade-window guide (or the menu)")
        print("|cffffff00/prof show <profession>|r - Open the guide for a specific profession")
        print("|cffffff00/prof preview <profession> <skill>|r - Show the Preview Steps window")
        print("|cffffff00/prof icon on|r|cffffffff/|r|cffffff00off|r - Show or hide the minimap icon")
    end
end
