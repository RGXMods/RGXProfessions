--------------------------------------------------------------------------------
--- Handles all calls to the WoW API
--------------------------------------------------------------------------------
RGXProf = RGXProf or {}
RGXProf.WowAPI = RGXProf.WowAPI or {}

---@return Player
function RGXProf.WowAPI:GetPlayer()
	return {
		level = UnitLevel("player"),
		faction = UnitFactionGroup("player"),
		race = UnitRace("player")
	}
end

function RGXProf.WowAPI:GetItemInfo(itemID) return GetItemInfo(itemID) end
function RGXProf.WowAPI:GetSpellInfo(spellID)
	if C_Spell and C_Spell.GetSpellInfo then
		local info = C_Spell.GetSpellInfo(spellID)
		return info and info.name
	end

	if GetSpellInfo then return GetSpellInfo(spellID) end
	return nil
end
function RGXProf.WowAPI:GetBuildInfo() return GetBuildInfo() end

---------------------------------------------------------------------------------
--- Gets the character's current skill in a profession without opening the
--- trade skill window. Tries the retail professions API, then classic
--- skill lines. Returns nil when the character does not know it.
--------------------------------------------------------------------------------
function RGXProf.WowAPI:GetProfessionSkill(pName)
    if type(pName) ~= "string" then return nil, nil end

    local ok, skill, maxSkill = pcall(function()
        if GetProfessions and GetProfessionInfo then
            for i = 1, 5 do
                local index = GetProfessions(i)
                if not index then break end
                local name, _, _, skillLevel, skillMax = GetProfessionInfo(index)
                if name and name == pName then
                    return skillLevel, skillMax
                end
            end
        end
        if GetNumSkillLines and GetSkillLineInfo then
            for i = 1, GetNumSkillLines() do
                local name, _, _, skillLevel, skillMax = GetSkillLineInfo(i)
                if name and name == pName then
                    return skillLevel, skillMax
                end
            end
        end
    end)

    if ok then
        return skill, maxSkill
    end
    return nil, nil
end
function RGXProf.WowAPI:IsAddOnLoaded(addonName)
	if C_AddOns and C_AddOns.IsAddOnLoaded then
		return C_AddOns.IsAddOnLoaded(addonName)
	end

	if IsAddOnLoaded then
		return IsAddOnLoaded(addonName)
	end

	return false
end
function RGXProf.WowAPI:QueueItemLoad(itemID) return C_Item.RequestLoadItemDataByID(itemID) end
function RGXProf.WowAPI:GetTradeSkillReagentInfo(recipeIndex, reagentIndex) return GetTradeSkillReagentInfo(recipeIndex, reagentIndex) end
function RGXProf.WowAPI:GetTradeSkillReagentItemLink(recipeIndex, reagentIndex) return GetTradeSkillReagentItemLink(recipeIndex, reagentIndex) end
function RGXProf.WowAPI:GetBestMapForUnit(unit) return C_Map.GetBestMapForUnit(unit) end
function RGXProf.WowAPI:GetItemIcon(link) return GetItemIcon(link) end


---------------------------------------------------------------------------------
--- Gets the map name to show on the trainer list
--- @param id number id of the map
--- @return string
--------------------------------------------------------------------------------
function RGXProf.WowAPI:GetMapName(id)
	if type(id) ~= "number" then
print(debugstack(2, 1, 0))

		print("GetMapName called with non-numeric id:", id)
		return "(Invalid ID)"
	end

	local m = C_Map.GetMapInfo(id)
	if not m then
		print("No map info found for id:", id)
		return "(Unknown Zone)"
	end

	return m.name or "(Unnamed Map)"
end

function RGXProf.WowAPI:GetReagentInfoByItemID(itemID)
    local name, link, icon = self:GetItemInfo(itemID)
    local onHand = self:GetItemCount(itemID, false, false)

    if not name then
        self:QueueItemLoad(itemID)
    end
	return name, link, icon, onHand
end

function RGXProf.WowAPI:GetItemCount(itemID, includeBank, includeReagentBank)
	return C_Item.GetItemCount(itemID, includeBank, includeReagentBank)
end




--- Call WoW API to get item link and icon or spell info
--- @param step table with itemID or spellID
--- @return table with name, link, icon
function RGXProf.WowAPI:GetItemLinkAndIconOrSpell(step)

	local link, icon
	if step.itemID then
		if C_Item and C_Item.GetItemInfo then
			local itemInfo = C_Item.GetItemInfo(step.itemID)
			if itemInfo then
				link = itemInfo.link
				icon = itemInfo.icon
			end
		elseif GetItemInfo then
			_, link, _, _, _, _, _, _, _, icon = GetItemInfo(step.itemID)
		end
		if not icon then self:QueueItemLoad(step.itemID) end
	end

	if not link then
		link = string.format("|cff71d5ff|Hspell:%d|h[%s]|h|r", step.spellID, step.name)
	end

	return {
		name = step.name or "Loading...",
		link = link,
		icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark"
	}
end
