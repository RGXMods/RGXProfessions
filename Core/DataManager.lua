RGXProf.DataManager = {}

----------------------------------------------------------------------------------------------
--- PROFESSION queries
----------------------------------------------------------------------------------------------
---@class Profession
---@field id number The internal RGXProf profession ID.
---@field icon number The profession icon
---@field pointsEarned number Current points earned in the profession.
---@field pointsTotal number Maximum points achievable.
---@field racialBonus number Bonus points due to racial abilities (currently always 0).
---@field name string The localized name of the profession.
---@field path Step[] The ordered list of Steps for leveling this profession.
---@field pointsRemaining number Points remaining at this skill level

------------------------------------------------------------------------------------
--- Gets the current profession information from the TradeSkill/Craft window.
--- @return Profession|nil An object containing profession data.
------------------------------------------------------------------------------------
function RGXProf.DataManager:GetProfession()

	local adapter = RGXProf.AdapterManager:GetCurrent()
	if not adapter then
		return
	end

	local pName, pEarned, pTotal = adapter:getProfessionInfo()
	local professionID = RGXProf.Constants.ProfessionNameToID[pName]
	if not professionID then
		print("|cffff0000[RGXProf]|r Unknown profession name:", pName)
		return
	end

	local professionPath = RGXProf.currentExpansion and RGXProf.currentExpansion.paths and RGXProf.currentExpansion.paths[professionID]
	local professionIcon = RGXProf.Constants.Professions[professionID].icon or RGXProf.Constants.Professions.Default.icon

	return {
		id = professionID,
		icon = professionIcon,
		pointsEarned = pEarned,
		pointsTotal = pTotal, --for current rank
		racialBonus = 0,
		name = pName,
		path = professionPath,
		pointsRemaining = pTotal - pEarned
	}
end

----------------------------------------------------------------------------------------------

function RGXProf.DataManager:GetOtherProfession(pName)

	local prof = pName:sub(1, 1):upper() .. pName:sub(2):lower()


	local professionID = RGXProf.Constants.ProfessionNameToID[prof]
	if not professionID then
		print("|cffff0000[RGXProf]|r Unknown profession name:", prof)
		return
	end

	local professionPath = RGXProf.currentExpansion and RGXProf.currentExpansion.paths and RGXProf.currentExpansion.paths[professionID]
	local professionIcon = RGXProf.Constants.Professions[professionID].icon or RGXProf.Constants.Professions.Default.icon

	return {
		id = professionID,
		icon = professionIcon,
		name = prof,
		path = professionPath
	}
end

----------------------------------------------------------------------------------------------
--- STEP queries
----------------------------------------------------------------------------------------------
---@class Step
---@field minSkill number The minimum profession skill required for this step.
---@field maxSkill number The maximum profession skill before moving to next step.
---@field spellID number|nil Optional. The spell ID for the recipe, if it's a spell.
---@field itemID number|nil Optional. The item ID for the recipe, if it's an item.
---@field keep boolean|nil Optional. Whether crafted items should be kept.
---@field note string|nil Optional. Additional player-visible notes.
---@field alternate boolean|nil Optional. Whether this step is an alternate option.
---@field npcs {} Optional. Neutral vendor or quest giver NPC ID.
---@field quests {} Optional. Quest ID associated with the step.
--------------------------------------------------------------------

---------------------------------------------------------------------------------
--- Get current, next, and alternate step from the profession path based on earned points.
--- @param playerFaction string
--- @param profession Profession
--- @return Step|nil, Step|nil, Step|nil steps current step, next step, alternate step
---------------------------------------------------------------------------------
function RGXProf.DataManager:GetSteps(playerFaction, profession)
	if not profession.path or profession.pointsRemaining <= 0 then
		return nil, nil
	end

	local path = profession.path
	-- Find highest available step
	for i = #path, 1, -1 do
		---@type Step
		local step = path[i]

		if (profession.pointsEarned >= (step.minSkill + profession.racialBonus))
				and (profession.pointsEarned < (step.maxSkill + profession.racialBonus))
				and (not step.alternate) then
			
				step._vendors = self:GetVendors(step, playerFaction)

			local altStep, nextStep
			local checkStep = profession.path[i+1]
			if checkStep and checkStep.alternate then
				altStep = checkStep
				nextStep = profession.path[i+2] or nil

				altStep._vendors = self:GetVendors(altStep, playerFaction)

			else
				nextStep = checkStep
			end

			return step, nextStep, altStep
		end
	end
end

--- @param profession Profession 
--- @param steps Step[]
--- @param currentSkill number
--- @return {}[]|nil previews
--- Returns a list of step previews for the given profession and steps.B
function RGXProf.DataManager:GetStepPreviews(profession, steps, currentSkill)
	if not steps or #steps == 0 then return end

	local previews = {}

	for _, step in ipairs(steps) do
		if step.maxSkill > currentSkill then
			local recipeDetails = RGXProf.WowAPI:GetItemLinkAndIconOrSpell(step)
			local low = math.max(step.minSkill, profession.pointsEarned or 0)
			local estimatedCrafts = self:GetEstimatedCrafts(low, step)

			local preview = {}

			preview.text = string.format(RGXProf.L.PREVIEW_STEP, estimatedCrafts, recipeDetails.link or recipeDetails.name or "?", step.minSkill, step.maxSkill)
			preview.link = recipeDetails.link
			preview.icon = recipeDetails.icon
			table.insert(previews, preview)
		end
	end

	return previews
end

----------------------------------------------------------------------------------------------
--- RECIPE queries
----------------------------------------------------------------------------------------------
---@class Recipe
--- @field name string The localized name of the recipe.
--- @field link string The in-game link for the item or spell.
--- @field icon string The file path to the icon texture.
--- @field skillColor table RGB colors for the skill
--- @field craftCount number how many times to craft
--- @field hasSkill boolean Has the player learned this recipe yet?
--- @field itemID number The itemID produced by the recipe, if applicable.
--- @field spellID number The spellID of the recipe, if applicable.
--- @field slot number MAIN or ALTERNATE
--- @field reagents Reagent[]
----------------------------------------------------------------------------------------------


--- Gets recipe details for displaying a given step.
--- @param step Step
--- @param pointsEarned number Current or simulated profession skill.
--- @return Recipe recipe An object containing recipe and reagent information
function RGXProf.DataManager:GetRecipeDetails(step, pointsEarned)

	-- The item link from the wow api has more info and is clickable automatically.
	-- Prefer item link over the constructed spell link.

	local adapter = RGXProf.AdapterManager:GetCurrent()
	local displayInfo = RGXProf.WowAPI:GetItemLinkAndIconOrSpell(step)
	local hasSkill = false
	local skillColor = RGXProf.Constants.SkillUpColors.none
	if adapter and not RGXProf.IsSimulation then
		local _, detectedHasSkill, detectedSkillColor = adapter:getRecipeLineInfo(step.spellID, step.name)
		hasSkill, skillColor = detectedHasSkill, detectedSkillColor
	elseif RGXProf.IsSimulation then
		local thresholds = RGXProf.Data.Skill and RGXProf.Data.Skill[step.spellID]
		if thresholds and thresholds.y and thresholds.g and thresholds.r and pointsEarned then
			local skillType
			if pointsEarned < thresholds.y then
				skillType = "optimal"
			elseif pointsEarned < thresholds.g then
				skillType = "medium"
			elseif pointsEarned < thresholds.r then
				skillType = "easy"
			else
				skillType = "trivial"
			end
			skillColor = RGXProf.Constants.SkillUpColors[skillType] or skillColor
		end
	end

	return {
		name = step.name,
		link = displayInfo.link,
		icon = displayInfo.icon,
		skillColor = skillColor,
		craftCount = 1,
		hasSkill = hasSkill,
		itemID = step.itemID,
		spellID = step.spellID,
		slot = step.alternate and RGXProf.Constants.ALTERNATE or RGXProf.Constants.MAIN
	}

end

--- Retrieves detailed information about a recipe from step data.
--- @param pointsEarned number Skill points so far
--- @param step table Step data containing spellID and/or itemID fields.
--- @return Recipe recipe An object containing recipe and reagent information
function RGXProf.DataManager:GetRecipeWithReagents(pointsEarned, step)

	local recipe = self:GetRecipeDetails(step, pointsEarned)
	recipe.craftCount = step.maxSkill - pointsEarned
	recipe.reagents = self:GetReagentListWithDetails(step.spellID, recipe.craftCount)

	return recipe

end

----------------------------------------------------------------------------------------------
--- REAGENT queries
----------------------------------------------------------------------------------------------
local function NormalizeReagentList(reagents)
	local normalized = {}
	if not reagents then return normalized end

	for itemID, count in pairs(reagents) do
		if type(count) == "number" then
			normalized[itemID] = (normalized[itemID] or 0) + count
		elseif type(count) == "table" then
			local nestedItemID = count.itemID
			local nestedCount = count.count or count.quantity
			if nestedItemID and type(nestedCount) == "number" then
				normalized[nestedItemID] = (normalized[nestedItemID] or 0) + nestedCount
			else
				for nestedItemID, nestedCount in pairs(count) do
					if type(nestedCount) == "number" then
						normalized[nestedItemID] = (normalized[nestedItemID] or 0) + nestedCount
					end
				end
			end
		end
	end

	return normalized
end

---@class Reagent
---@field itemID string
---@field slot number
---@field name string
---@field displayText string
---@field tooltip number[]
---@field icon string
---@field link string?
---@field requiredCount number
---@field onHandCount number

---------------------------
--- get reagent info from the trade skill window
--- This only works if the player knows the recipe and it's in the trade skill frame
--- @param spellID number
--- @param craftCount number the number of times to craft the item
--- @return Reagent[]
---------------------------
function RGXProf.DataManager:GetReagentListWithDetails(spellID, craftCount)

	local reagents = NormalizeReagentList(RGXProf.Data.Recipes[spellID])
	local currentSlot = 1
	local output = {}

	for itemID, count in pairs(reagents) do
		local name, link, icon, onHand = RGXProf.WowAPI:GetReagentInfoByItemID(itemID)
		local text = string.format("%d/%d", onHand, count * craftCount)
		local tooltip = {count * craftCount, count, craftCount}

		local reagent = {
			itemID = itemID,
			slot = currentSlot,
			name = name or "Unknown",
			displayText = text,
			icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark",
			link = link or "",
			requiredCount = count * craftCount,
			onHandCount = onHand or 0,
			tooltip = tooltip
		}

		table.insert(output, reagent)
		currentSlot = currentSlot + 1
	end
	return output
end

--- Builds a reagent usage index for all steps in the current expansion's paths.
function RGXProf.DataManager:BuildReagentUsageIndex()
	self.ReagentUsage = {}
	self.MissingReagents = self.MissingReagents or {}

	for professionID, steps in pairs(RGXProf.currentExpansion.paths) do
		for _, stepData in ipairs(steps) do
			if stepData.spellID then
				local recipeReagents = RGXProf.Data.Recipes[stepData.spellID]
				if recipeReagents then
					local reagents = NormalizeReagentList(recipeReagents)
					for reagentID, count in pairs(reagents) do
						self.ReagentUsage[reagentID] = self.ReagentUsage[reagentID] or {}
						local existing = self.ReagentUsage[reagentID][professionID]
						if existing then
							existing.minSkill = math.min(existing.minSkill, stepData.minSkill)
							existing.maxSkill = math.max(existing.maxSkill, stepData.minSkill)
						else
							self.ReagentUsage[reagentID][professionID] = {
								name = RGXProf.Constants.Professions[professionID].name,
								minSkill = stepData.minSkill,
								maxSkill = stepData.minSkill
							}
						end
					end
				else
					self.MissingReagents[stepData.spellID] = true
				end
			end
		end
	end
end


------------------------------------
-- Check to see if given reagent is needed
-- anywhere in guides
--- @param itemID number
--- @return {}[] array of {profession id, minSkill}
------------------------------------
function RGXProf.DataManager:WhereNeeded(itemID)
	itemID = tonumber(itemID)
	return RGXProf.Data.ReagentUsage[itemID] or {}
end

----------------------------------------------------------------------------------------------
--- TRAINING queries
----------------------------------------------------------------------------------------------
--- Get training object and npc/quest array
--- @param playerFaction string
--- @param step Step
--- @param recipe Recipe
--- @param profession Profession
--- @return Training
function RGXProf.DataManager:DetermineTraining(playerFaction, step, recipe, profession)

	local currentSkill = profession.pointsEarned
	local maxed = ( profession.pointsRemaining <= 0 )
	local lowerMax = profession.pointsTotal - RGXProf.Constants.Train_Threshold
	local closeToMax = currentSkill >= lowerMax
	local hasSkill = recipe.hasSkill

	local estimatedCrafts = self:GetEstimatedCrafts(profession.pointsEarned, step)

	local template = nil
	local list = {}
	local instructions = {}

	if closeToMax then
		template = RGXProf.Utils:DeepCopy(maxed and RGXProf.Training.TRAIN_MAX or RGXProf.Training.TRAINER)
		template.list = self:GetTrainers(playerFaction, lowerMax, profession.id)
		table.insert(instructions, template.instructions)
	end

	if not hasSkill then
		if step._vendors and #(step._vendors) > 0 then
			template = RGXProf.Utils:DeepCopy(RGXProf.Training.VENDOR_RECIPE)
			list = step._vendors
			table.insert(instructions, template.instructions)

		elseif step.quests and #(step.quests) > 0 then
			template = RGXProf.Utils:DeepCopy(RGXProf.Training.QUEST_RECIPE)
			list = self:GetQuests(step, playerFaction)
			table.insert(instructions, template.instructions)

		else
			template = RGXProf.Utils:DeepCopy(RGXProf.Training.TRAINER_RECIPE)
			list = self:GetTrainers(playerFaction, step.minSkill, profession.id)
			table.insert(instructions, template.instructions)
		end
	end

	if hasSkill then
		local craftText = string.format(
			RGXProf.Training.SKILLED.instructions,
			estimatedCrafts,
			step.maxSkill
			)
		table.insert(instructions, craftText)
		if step.keep then table.insert(instructions, RGXProf.L.KEEP) end
	end

	if step.note then
		table.insert(instructions, step.note)
	end
	local result = {
		icon = (template and template.icon) or profession.icon,
		layout = (template and template.layout) or nil,
		list = list,
		instructions = table.concat(instructions, "\n")  --or " " or ". "
	}
	return result
end

---@class Trainer
---@field npcID number The NPC ID of the trainer.
---@field locationID number Map ID where the trainer is located.
---@field x number X coordinate on the map.
---@field y number Y coordinate on the map.
---@field professionID number The RGXProf profession ID this trainer teaches.
---@field minSkill number Minimum skill required to train.
---@field faction string|nil "Horde", "Alliance", or nil.

--- Searches the db for the trainers that can progress training for the player
--- @param playerFaction string
--- @param searchLevel number
--- @param professionID number
function RGXProf.DataManager:GetTrainers(playerFaction, searchLevel, professionID)
	local results = {}
	for _, trainer in pairs(RGXProf.TrainerData) do
		local minSkill = trainer.minSkill or 0
		local maxSkill = trainer.maxSkill or 9999
		local teachesThisSkill = (searchLevel >= minSkill) and (searchLevel <= maxSkill)

		local matchesFaction = RGXProf.Utils:IsFaction(playerFaction, trainer.faction)
		local matchesProfession = (trainer.professionID == professionID or not trainer.professionID)
		if matchesFaction and matchesProfession and teachesThisSkill then
			table.insert(results, trainer)
		end
	end

	return RGXProf.Utils:NpcSort(results)
end

--- Shows all the vendors that sell a recipe and are friendly or neutral to the player
--- @param step Step 
--- @param playerFaction string
function RGXProf.DataManager:GetVendors(step, playerFaction)
	local result = {}

	if step.npcs then
		for _, vendorID in ipairs(step.npcs) do
			local vendor = RGXProf.VendorData[vendorID]
			if vendor then
				local matchesFaction = RGXProf.Utils:IsFaction(playerFaction, vendor.faction)
				if matchesFaction then
					table.insert(result, vendor)
				end
			else
				RGXProf.Utils:SendMsg(string.format(RGXProf.L.REPORT_MISSING_VENDOR, vendorID))
			end
		end
	end

	return RGXProf.Utils:NpcSort(result)
end

----------------------------------------------------------------------------------------------
--- QUESTS queries
----------------------------------------------------------------------------------------------
---@class Quest
---@field questID number The unique ID of the quest.
---@field name string The name of the quest.
---@field npcID number The NPC ID who offers or is related to the quest.
---@field faction string|nil "Horde", "Alliance", or nil for neutral.
---@field note string|nil Extra player-visible notes about the quest.
---@field minSkill number The minimum profession skill needed for this quest.
---@field maxSkill number The maximum skill this quest covers.
---@field professionID number The internal RGXProf profession ID associated with the quest.

--- Searches Quests db to find a quest to progress training
--- @param step Step
--- @param playerFaction string
function RGXProf.DataManager:GetQuests(step, playerFaction)
	local results = {}

	if step.quests then

		for _, questID in ipairs(step.quests) do
			local quest = RGXProf.QuestData[questID]
			if quest and RGXProf.Utils:IsFaction(playerFaction, quest.faction) then
				local npc = self:GetNPC(quest.npcID)
				if npc then
					quest.name = npc.name
					quest.zoneID = npc.zoneID
					table.insert(results, quest)
				else
					RGXProf.Utils:SendMsg(string.format(RGXProf.L.REPORT_MISSING_QUEST_NPC, quest.npcID, questID))
				end
			end
		end
	end
	return RGXProf.Utils:NpcSort(results)
end

----------------------------------------------------------------------------------------------
--- VENDOR queries
----------------------------------------------------------------------------------------------

---@class Vendor
---@field npcID number The NPC ID of the vendor.
---@field locationID number The internal map ID or zone ID where the vendor is located.
---@field x number X coordinate of the vendor's location (0-100).
---@field y number Y coordinate of the vendor's location (0-100).
---@field faction string|nil "Horde", "Alliance", or nil for neutral vendors.
---@field questName string filled when this quest is requested for training

--- Gets Quest and the ID of the quest giver
--- @param id number ID of the quest to get
--- @return Vendor|nil vendor
function RGXProf.DataManager:GetVendorForQuest(id)
	local quest = RGXProf.QuestData[id]
	if not quest then return nil end
	local result = RGXProf.VendorData[quest.npcID]
	if not result then return nil end

	result.questName = quest.name
	return result
end

--- Gets Vendor
--- @param id number ID of the vendor to get
--- @return Vendor|nil
function RGXProf.DataManager:GetNPC(id)
	local vendor = RGXProf.VendorData[id]
	if not vendor then return nil end
	return vendor
end

--------------------------
-- calculate remaining mats
--------------------------
function RGXProf.DataManager:GetRemainingMaterials(currentSkillLevel, professionPath)
	local lines = {}
    local bucketsWithMats = {}
    local buckets = RGXProf.currentExpansion.tiers
    if not buckets or #buckets == 0 then return end

    for _, skillCap in ipairs(buckets) do
        if skillCap > currentSkillLevel then
            table.insert(bucketsWithMats, { skillCap = skillCap, mats = {} })
        end
    end

    local progressedSkillLevel = currentSkillLevel

	for _, step in ipairs(professionPath) do
        local stepMin, stepMax = step.minSkill, step.maxSkill
        local spellID = step.spellID

		while progressedSkillLevel < stepMax do
			for i, bucket in ipairs(bucketsWithMats) do

				if bucket.skillCap > progressedSkillLevel and bucket.skillCap > stepMin then
					local crafts = self:GetEstimatedCrafts(progressedSkillLevel, step, math.min(stepMax, bucket.skillCap))

					if crafts > 0 then
						local reagents = NormalizeReagentList(RGXProf.Data.Recipes[spellID])
  						
						for c = 1, crafts do					
							factor = self:GetRecipeCraftFactor(spellID, progressedSkillLevel)
							if not factor or factor <= 0 or factor ~= factor then
								progressedSkillLevel = stepMax
								break
							end

							local skillUps = 1 / factor
							if skillUps < 0.01 then
								progressedSkillLevel = stepMax
								break
							end

							--accumulate in higher buckets
							for j = i, #bucketsWithMats do
								local targetBucket = bucketsWithMats[j]
								for itemID, countPerCraft in pairs(reagents) do
									targetBucket.mats[itemID] = (targetBucket.mats[itemID] or 0) + countPerCraft
								end
							end
    						progressedSkillLevel = progressedSkillLevel + skillUps

						    if progressedSkillLevel >= stepMax then break end
						end
					end
					break

      			end
    		end
  		end
	end


    -- Convert to display lines
    for _, bucket in ipairs(bucketsWithMats) do
        local skillCap = bucket.skillCap
        local tierName = self:getTierLabel(skillCap)
        table.insert(lines, { text = string.format(RGXProf.L.MATS_TO_REACH, tierName, skillCap) })

        local sorted = {}
        for itemID, count in pairs(bucket.mats or {}) do
            local name = select(1, RGXProf.WowAPI:GetItemInfo(itemID)) or (RGXProf.L.ITEM_ID_FALLBACK .. itemID)
            table.insert(sorted, { name = name, count = count, itemID = itemID })
        end
        table.sort(sorted, function(a, b) return a.name < b.name end)

        for _, reagent in ipairs(sorted) do
            table.insert(lines, {
                text = string.format("  - %s x%d", reagent.name, reagent.count),
                link = "item:" .. reagent.itemID
            })
        end
    end


  	return lines
end

function RGXProf.DataManager:getTierLabel(skillCap)
	return RGXProf.Constants.TierLabels[skillCap] or string.format(RGXProf.L.SKILL_TIER_FALLBACK, skillCap)
end

---Calculate the estimated crafts needed to reach the next step
--- @param pointsEarned number
--- @param step Step
--- @param workingHighSkill number|nil a number that might not be the same as step.maxSkill
--- @return number --estimated crafts needed
function RGXProf.DataManager:GetEstimatedCrafts(pointsEarned, step, workingHighSkill)

	local currentSkill = pointsEarned
	local skillGap = math.max(0, (workingHighSkill or step.maxSkill)- currentSkill)
	local factor = self:GetRecipeCraftFactor(step.spellID, step.minSkill) or 1.0
	return math.ceil(skillGap * factor)
	
end


---Returns the adjusted craft factor based on skill level and NumSkillUps.
---@param spellID integer
---@param skill integer
---@return number  @craftFactor (e.g., 1.0, 1.67, 0.33, etc.)
function RGXProf.DataManager:GetRecipeCraftFactor(spellID, skill)
  local t = RGXProf.Data.Skill[spellID]
  if not t then return 1.0 end

  local base
  if skill < t.y then
    base = 1.0
  elseif skill < t.g then
    base = 1.67
  elseif skill < t.r then
    base = 5.0
  else
    base = math.huge 
  end

  local skillUps = t.up or 1
  return base / skillUps
end
