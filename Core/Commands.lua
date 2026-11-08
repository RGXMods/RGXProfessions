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
        print(RGXProf.L.CMD_NO_GUIDES)
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
        print(RGXProf.L.CMD_CHOOSE_PROF)
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
            print(RGXProf.L.CMD_BOOK_NOT_LOADED)
        end
    elseif command == "settings" or command == "options" or command == "config" then
        RGXProf.OptionsWindow:Show()
    elseif command == "book" then
        if RGXProf.BookWindow then RGXProf.BookWindow:Show() end
    elseif command == "icon" then
        local sub = (args or ""):lower()
        if sub == "on" then
            RGXProf.OptionsWindow:SetMinimapIcon(true)
            print(RGXProf.L.CMD_ICON_SHOWN)
        elseif sub == "off" then
            RGXProf.OptionsWindow:SetMinimapIcon(false)
            print(RGXProf.L.CMD_ICON_HIDDEN)
        else
            print(RGXProf.L.CMD_ICON_USAGE)
        end
    elseif command == "show" then
        local adapter = RGXProf.AdapterManager:GetCurrent()

        if args ~= "" then
            local name = ResolveProfessionName(args)
            if name then
                RGXProf.StateManager:ShowGuideForProfession(name)
            else
                print(RGXProf.L.CMD_UNKNOWN_PROF .. args)
            end
        else
            RGXProf.BookWindow:Show()
        end
    elseif command == "tips" then
        local name, id = ResolveProfessionName(args)
        if not name then
            print(RGXProf.L.CMD_TIPS_USAGE)
            return
        end
        RGXProf:PrintProfessionNotes(id, name)
    elseif command == "preview" then
        if args == "" then
            if not RGXProf.CurrentState or not RGXProf.CurrentState.profession then
                print(RGXProf.L.CMD_NO_ACTIVE_PROF)
                return
            end

            local prof = RGXProf.CurrentState.profession.name
            local skill = RGXProf.CurrentState.profession.pointsEarned or 1
            RGXProf.MiniWindow:Show(prof, skill)
        else
            local prof, skill = args:match("^(%S+)%s+(%d+)$")
            if not prof or not skill then
                print(RGXProf.L.CMD_PREVIEW_USAGE)
                return
            end
            RGXProf.MiniWindow:Show(prof, tonumber(skill))
        end
    else
        print(RGXProf.L.HELP_HEADER)
        print(RGXProf.L.HELP_BOOK)
        print(RGXProf.L.HELP_SHOW)
        print(RGXProf.L.HELP_SHOW_PROF)
        print(RGXProf.L.HELP_PREVIEW)
        print(RGXProf.L.HELP_ICON)
        print(RGXProf.L.HELP_TIPS)
    end
end

-- Prints a profession's Forever notes (what changed, tips, kit) to chat.
function RGXProf:PrintProfessionNotes(professionID, displayName)
    local notes = RGXProf.ForeverNotes and RGXProf.ForeverNotes[professionID]
    if not notes then
        print(RGXProf.L.CMD_NO_NOTES)
        return
    end
    print("|cffffff00[RGXProf]|r |cffffffff" .. tostring(displayName) .. "|r - " .. (notes.tagline or ""))
    if notes.summary and notes.summary ~= "" then print("  " .. notes.summary) end
    if notes.changes and #notes.changes > 0 then
        print("|cffffff00" .. RGXProf.L.NOTES_CHANGED .. "|r")
        for _, change in ipairs(notes.changes) do
            print("  - " .. change.text)
        end
    end
    if notes.tips and #notes.tips > 0 then
        print("|cffffff00" .. RGXProf.L.NOTES_TIPS .. "|r")
        for _, tip in ipairs(notes.tips) do print("  - " .. tip) end
    end
    if notes.tools and #notes.tools > 0 then
        print("|cffffff00" .. RGXProf.L.NOTES_KIT .. "|r")
        for _, tool in ipairs(notes.tools) do print("  - " .. tool.name .. ": " .. tool.note) end
    end
end
