RGXProf = RGXProf or {}

--------------------------------------------------------------------
-- Addon Adapter Base Class
--------------------------------------------------------------------
---@class AddonAdapter
---@field name string
---@field type string
---@field tradeFrame fun(self: AddonAdapter): table -- Returns the frame used for trade skills (should override)
---@field getProfessionInfo fun(self: AddonAdapter): string, number, number
---@field select fun(self: AddonAdapter, skillIndex: number) -- Selects a skill by index (should override)
---@field isShown fun(self: AddonAdapter): boolean -- Checks if the trade frame is shown (should override)
---@field getSkillLink fun(self: AddonAdapter, index: number): string (should override)
---@field getDetailsAtIndex fun(self: AddonAdapter, i: number): table (should override)
---@field expandAllHeaders fun(self: AddonAdapter) (should override)
---@field getNumEntries fun(self: AddonAdapter): number (should override)
---@field getSpellID fun(self: AddonAdapter, i: number): number (should override)
---@field hook fun(self: AddonAdapter) -- Hook the addon frame for OnShow events
---@field position fun(self: AddonAdapter, frame: table) -- Positions the frame
---@field withExpandedHeaders fun(self: AddonAdapter, preserveState: boolean, callback: function): any
---@field matchedIndexOnSpellLink fun(self: AddonAdapter, index: number): boolean
---@field matchedIndexOnSpellName fun(self: AddonAdapter, index: number, spellID: number): boolean
---@field getRecipeLineInfo fun(self: AddonAdapter, spellID: number, name: string): number, boolean, table
---@field selectBySpellID fun(self: AddonAdapter, spellID: number): boolean


RGXProf.AddonAdapter = {}   
RGXProf.AddonAdapter.__index = RGXProf.AddonAdapter

function RGXProf.AddonAdapter:new(name)
    local obj = {
        name = name or "UnnamedAdapter",
        type = "trade",
        loaded = false,
        skill = 0,
        tryingToShow = false,
        knownRecipes = {}
    }
    setmetatable(obj, self)
    
    return obj
end

-- Functions to be overridden by specific adapters
function RGXProf.AddonAdapter:tradeFrame()
    return UIParent
end

function RGXProf.AddonAdapter:getProfessionInfo()
    --only override for CraftFrame
    return GetTradeSkillLine()
end
function RGXProf.AddonAdapter:select(skillIndex)
end
function RGXProf.AddonAdapter:isShown()
    return false
end
function RGXProf.AddonAdapter:getSkillLink(index)
    return nil
end
function RGXProf.AddonAdapter:getDetailsAtIndex(i)
    return {
        name = "Unknown",
        isHeader = false,
        isExpanded = false,
        skillType = "unknown"
    }
end
function RGXProf.AddonAdapter:expandAllHeaders()
end
function RGXProf.AddonAdapter:withExpandedHeaders(preserveState, callback)
    self:expandAllHeaders()
    return callback()
end
function RGXProf.AddonAdapter:getNumEntries() 
    return 0
end
function RGXProf.AddonAdapter:getSpellID(i)
    return 0
end


---------
-- Functions to use default behavior

function RGXProf.AddonAdapter:hook()
    if not self._hooked and self.tradeFrame and self:tradeFrame() then
        local frame = self:tradeFrame()
        if frame.HookScript then
            frame:HookScript("OnShow", function()
                RGXProf.AdapterManager:SetCurrentAdapter(self)
                RGXProf.StateManager:RequestRefresh()
            end)
            self._hooked = true
            if frame:IsShown() then
                RGXProf.AdapterManager:SetCurrentAdapter(self)
                RGXProf.StateManager:RequestRefresh()
            end
        end
    end
end

function RGXProf.AddonAdapter:position(frame)
    if not frame or not self.tradeFrame then
        return
    end
    local anchor = self.tradeFrame and self:tradeFrame() or nil
    RGXProf.LayoutManager:RestoreOrAlignToAnchor(frame, anchor)
end

function RGXProf.AddonAdapter:matchedIndexOnSpellLink(index, spellID)
    local link = self:getSkillLink(index)
    if not link then return false end

    local id = tonumber(link:match("H(?:enchant|recipe):(%d+):"))
    return id == spellID
end

function RGXProf.AddonAdapter:matchedIndexOnSpellName(index, spellName) 
    local details = self:getDetailsAtIndex(index)
    return (not details.isHeader and details.name == spellName)
    
end

function RGXProf.AddonAdapter:getThresholdSkillColor(spellID)
    local thresholds = RGXProf.Data.Skill and RGXProf.Data.Skill[spellID]
    if not thresholds or not thresholds.y or not thresholds.g or not thresholds.r then
        return RGXProf.Constants.SkillUpColors.none
    end

    local _, currentSkill = self:getProfessionInfo()
    currentSkill = tonumber(currentSkill)
        or (RGXProf.CurrentState and RGXProf.CurrentState.profession and RGXProf.CurrentState.profession.pointsEarned)
    if not currentSkill then
        return RGXProf.Constants.SkillUpColors.none
    end

    local skillType
    if currentSkill < thresholds.y then
        skillType = "optimal"
    elseif currentSkill < thresholds.g then
        skillType = "medium"
    elseif currentSkill < thresholds.r then
        skillType = "easy"
    else
        skillType = "trivial"
    end
    return RGXProf.Constants.SkillUpColors[skillType] or RGXProf.Constants.SkillUpColors.none
end

--- Returns index, skill color info, and a boolean indicating if the recipe was found
---@param spellID number
---@param spellName string
---@return number, boolean, {}
function RGXProf.AddonAdapter:getRecipeLineInfo(spellID, spellName)
    -- Background refreshes must not expand profession headers. Expanding here
    -- fires another trade-skill update and makes a user's collapsed category
    -- immediately reopen. Explicit recipe selection expands before calling us.
    local count = self:getNumEntries()
    local cacheKey = spellID or spellName
    for i = 1, count do
        local details = self:getDetailsAtIndex(i)

        if not details.isHeader then
            if self:matchedIndexOnSpellLink(i, spellID) or self:matchedIndexOnSpellName(i, spellName) then
                local color = RGXProf.Constants.SkillUpColors[details.skillType] or RGXProf.Constants.SkillUpColors.none
                if cacheKey then
                    self.knownRecipes = self.knownRecipes or {}
                    self.knownRecipes[cacheKey] = true
                end
                return i, true, color
            end
        end
    end

    local known = cacheKey and self.knownRecipes and self.knownRecipes[cacheKey] == true or false
    return 0, known, self:getThresholdSkillColor(spellID)
end

--- Used by click handler to select a skill by spell ID
function RGXProf.AddonAdapter:selectBySpellID(spellID, spellName)
    if not spellID then return false end

    -- A collapsed legacy trade-skill tree can contain multiple nested header
    -- levels. Expand and rescan until the actual row index becomes visible;
    -- the cached "known" result alone is not a selectable row.
    for _ = 1, 5 do
        local index = self:getRecipeLineInfo(spellID, spellName)
        if index and index > 0 then
            self:select(index)
            return true
        end

        local countBefore = self:getNumEntries()
        self:expandAllHeaders()
        local countAfter = self:getNumEntries()
        if countAfter == countBefore then break end
    end

    return false
end
