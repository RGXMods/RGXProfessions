RGXProf = RGXProf or {}
RGXProf.Utils = RGXProf.Utils or {}

-- One chat voice for every RGX addon: the framework's shared chat ("<icon> - [Professions] message"), driven by
-- the standard options. Without it (an older framework) the addon's own line below is used.
local function SharedChat()
	if RGXProf._chat == nil then
		local RGX = _G.RGXFramework
		RGXProf._chat = RGX and type(RGX.CreateChat) == "function" and RGX:CreateChat({
			storage = function() return RGXProf_Settings end,
			name = "RGX Professions",
			label = "Professions",
			icon = "Interface\\AddOns\\RGX-Framework\\media\\round.tga",
			tagColor = "8B1538",   -- the addon's primary brand colour
			tag = "[RGXProf]",
		}) or false
	end
	return RGXProf._chat or nil
end

-- The "loaded" line at login: also obeys the framework-wide login switch.
function RGXProf.Utils:SendLogin(text)
	local chat = SharedChat()
	if chat then return chat:Login(text) end
	local settings = RGXProf.Settings or RGXProf_Settings or {}
	if settings.loginMessage ~= false then self:SendMsg(text) end
end

function RGXProf.Utils:SendMsg(text)
	local chat = SharedChat()
	if chat then return chat:Print(text) end
	local settings = RGXProf.Settings or RGXProf_Settings or {}
	if settings.chatOutput == false then return end
	-- the prefix is added here: drop a "[RGXProf]" tag the message string may still carry
	text = tostring(text):gsub("^|c%x%x%x%x%x%x%x%x%[RGXProf%]|r%s*", ""):gsub("^%[RGXProf%]%s*", "")
	local prefix = settings.chatPrefix
	if type(prefix) ~= "string" or prefix == "" or prefix == "RGX Professions" then
		-- the default prefix is the branded title; a prefix the player typed is used as written
		if RGXProf.BrandTitle then
			print(RGXProf.BrandTitle("Professions") .. ": " .. tostring(text))
			return
		end
		prefix = "RGX Professions"
	end
	print(RGXProf.Constants.Colors.Hex.BLUE..prefix..":|r "..tostring(text))
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
			local itemName = select(1, RGXProf.WowAPI:GetItemInfo(itemID)) or ("ItemID:"..itemID)
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