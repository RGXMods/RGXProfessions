RGXProf = RGXProf or {}
RGXProf.Utils = RGXProf.Utils or {}

function RGXProf.Utils:SendMsg(text)
	print(RGXProf.Constants.Colors.Hex.BLUE.."RGXProf"..":|r "..tostring(text))
end

function RGXProf.Utils:GetItemID(itemLink)
	local itemID = string.match(itemLink or "", "item:(%d+)")
	return tonumber(itemID)
end

function RGXProf.Utils:DeepCopy(orig)
	local lookup = {}
	local function _copy(value)
		if type(value) ~= "table" then
			return value
		elseif lookup[value] then
			return lookup[value]
		end
		local newTable = {}
		lookup[value] = newTable
		for k, v in pairs(value) do
			newTable[_copy(k)] = _copy(v)
		end
		return setmetatable(newTable, getmetatable(value))
	end
	return _copy(orig)
end

--- Decides if the passed faction is friendly or at least neutral to player
--- @param playerFaction string
--- @param faction string
function RGXProf.Utils:IsFaction(playerFaction, faction)
	return (playerFaction == faction) or (faction == "Neutral")
end

---------------------------------------------------------------------------------
--- Used as part of the calculate print out
--- @param reagents table the IDs and needed quantities for the reagents
---------------------------------------------------------------------------------
function RGXProf.Utils:GetMatString(reagents)
	if not reagents then return "" end

	local parts = {}

	for itemID, quantity in pairs(reagents) do
		if tonumber(quantity) and quantity > 0 then
			local itemName = select(2, RGXProf.WowAPI:GetItemInfo(itemID)) or ("ItemID:"..itemID)
			table.insert(parts, string.format("%dx %s", quantity, itemName))
		end
	end

	return table.concat(parts, ", ")
end

function RGXProf.Utils:NpcSort(npcArray)
	table.sort(npcArray, function(a, b)
		return RGXProf.WowAPI:GetMapName(a.zoneID) < RGXProf.WowAPI:GetMapName(b.zoneID)
	end)

	return npcArray
end

function RGXProf.Utils:SetText(fs, text, substring1, substring2)
	if (fs) then
		if (substring1) or (substring2) then
			fs:SetFormattedText(tostring(text),substring1,substring2)
		else
			fs:SetText(tostring(text))
		end
	end
end