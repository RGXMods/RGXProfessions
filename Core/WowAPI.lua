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

-- C_Item.GetItemInfo returns multiple values, never a table.
-- Canonical order (matches legacy GetItemInfo / wow-ui-source ItemDocumentation):
--   1 name, 2 link, 3 quality, 4 itemLevel, 5 itemMinLevel, 6 itemType,
--   7 itemSubType, 8 itemStackCount, 9 itemEquipLoc, 10 icon, 11 sellPrice, ...
function RGXProf.WowAPI:GetItemInfo(itemID)
	if C_Item and C_Item.GetItemInfo then
		local name, link, quality, itemLevel, itemMinLevel, itemType, itemSubType,
		      itemStackCount, itemEquipLoc, icon, sellPrice = C_Item.GetItemInfo(itemID)
		if name then
			return name, link, quality, itemLevel, itemMinLevel, itemType, itemSubType,
			       itemStackCount, itemEquipLoc, icon, sellPrice
		end
		pcall(C_Item.RequestLoadItemDataByID, itemID)
	end
	if GetItemInfo then
		return GetItemInfo(itemID)
	end
	return nil
end
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
            -- GetProfessions() takes no arguments and returns all six
            -- profession indices at once; calling it with an index would
            -- only ever re-read the first slot.
            for _, index in ipairs({ GetProfessions() }) do
                if index then
                    -- name(1), icon(2), skillLevel(3), maxSkill(4) in both
                    -- the classic-era and modern return orders.
                    local name, _, skillLevel, skillMax = GetProfessionInfo(index)
                    if name and name == pName then
                        return skillLevel, skillMax
                    end
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
function RGXProf.WowAPI:GetItemIcon(link)
	if C_Item and C_Item.GetItemIconByID and type(link) == "number" then
		return C_Item.GetItemIconByID(link)
	end
	if C_Item and C_Item.GetItemIcon and type(link) == "string" then
		return C_Item.GetItemIcon(link)
	end
	if GetItemIcon then
		return GetItemIcon(link)
	end
	return nil
end


---------------------------------------------------------------------------------
--- Gets the map name to show on the trainer list
--- @param id number id of the map
--- @return string
--------------------------------------------------------------------------------
function RGXProf.WowAPI:GetMapName(id)
	if type(id) ~= "number" then
print(debugstack(2, 1, 0))

		print(RGXProf.L.DIAG_MAPNAME_BAD_ID, id)
		return RGXProf.L.INVALID_ID
	end

	local m = C_Map.GetMapInfo(id)
	if not m then
		print(RGXProf.L.DIAG_NO_MAP_INFO, id)
		return RGXProf.L.UNKNOWN_ZONE
	end

	return m.name or RGXProf.L.UNNAMED_MAP
end

function RGXProf.WowAPI:GetReagentInfoByItemID(itemID)
    -- GetItemInfo returns icon as the 10th value, not the 3rd.
    local name, link, _, _, _, _, _, _, _, icon = self:GetItemInfo(itemID)
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

	-- Spell first: the step name describes the recipe and its spellID is the
	-- reliable identifier (path data itemIDs were mis-mapped upstream, e.g.
	-- Woolen Cape carried the Reinforced Linen Cape itemID). GetSpellInfo
	-- returns (name, rank, icon); recipe spells carry the product's icon.
	if step.spellID then
		if GetSpellInfo then
			local _, _, spellIcon = GetSpellInfo(step.spellID)
			if spellIcon then icon = spellIcon end
		end
		if step.name then
			link = string.format("|cff71d5ff|Hspell:%d|h[%s]|h|r", step.spellID, step.name)
		end
	end

	-- Item fallback, for steps that only carry an itemID.
	if (not icon or not link) and step.itemID then
		-- GetItemInfoInstant returns immediately (no cache wait).
		-- Classic shape: itemID, itemType, itemSubType, equipLoc, icon, ...
		if C_Item and C_Item.GetItemInfoInstant then
			local ok, r1, r2, r3, r4, r5, r6 = pcall(C_Item.GetItemInfoInstant, step.itemID)
			if ok then
				if not link then
					for _, v in ipairs({ r1, r2, r3, r4 }) do
						if type(v) == "string" and v:find("item:") then
							link = v
							break
						end
					end
				end
				if not icon then
					for _, v in ipairs({ r5, r4, r6 }) do
						if type(v) == "number" then
							icon = v
							break
						end
					end
				end
			end
		end

		if not icon then
			if C_Item and C_Item.GetItemIconByID then
				icon = C_Item.GetItemIconByID(step.itemID)
			elseif GetItemIcon then
				icon = GetItemIcon(step.itemID)
			end
		end
	end

	return {
		name = step.name or RGXProf.L.LOADING,
		link = link or step.name or "",
		icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark"
	}
end
