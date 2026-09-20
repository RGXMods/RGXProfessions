--------------------------------------------------------------------
-- Blizzard_TradeSkill Adapter
--------------------------------------------------------------------

RGXProf.AdapterFactories = RGXProf.AdapterFactories or {}

RGXProf.AdapterFactories["Blizzard_TradeSkillUI"] = function()
    local adapter = RGXProf.AddonAdapter:new("Blizzard_TradeSkill")
    adapter.type = "trade"
    adapter.isCraft = false

    function adapter:tradeFrame()
        return TradeSkillFrame
    end

    function adapter:select(skillIndex)
        if not skillIndex then return end
        if self:isShown() then
            TradeSkillFrame.selectedSkill = skillIndex
            TradeSkillListScrollFrame.selectedSkill = skillIndex
            TradeSkillFrame_SetSelection(skillIndex)
            TradeSkillFrame_Update()
        end
    end

    --- @return boolean
    function adapter:isShown()
        return TradeSkillFrame and TradeSkillFrame:IsShown()
    end

    function adapter:getSkillLink(index)
        return GetTradeSkillRecipeLink(index)
    end

    function adapter:getDetailsAtIndex(i)
        local name, skillType, _, _, _, _, expanded = GetTradeSkillInfo(i)
        return {
            name = name,
            skillType = skillType,
            isHeader = skillType == "header" or skillType == "subheader",
            isExpanded = expanded
        }
    end

    function adapter:expandAllHeaders()
        local numSkills = GetNumTradeSkills()
        for i = 1, numSkills do
            local name, skillType = GetTradeSkillInfo(i)
            if skillType == "header" then
                ExpandTradeSkillSubClass(i)
            end
        end
    end

    function adapter:withExpandedHeaders(preserveState, callback)
        if not preserveState then
            self:expandAllHeaders()
            return callback()
        end

        local collapsedHeaders = {}
        local numSkills = GetNumTradeSkills()
        for i = 1, numSkills do
            local name, skillType, _, _, _, _, expanded = GetTradeSkillInfo(i)
            if skillType == "header" and not expanded then
                collapsedHeaders[name] = true
            end
        end

        self:expandAllHeaders()
        local result1, result2, result3 = callback()

        if CollapseTradeSkillSubClass then
            for i = GetNumTradeSkills(), 1, -1 do
                local name, skillType = GetTradeSkillInfo(i)
                if skillType == "header" and collapsedHeaders[name] then
                    CollapseTradeSkillSubClass(i)
                end
            end
        end

        return result1, result2, result3
    end

    function adapter:getNumEntries()
        return GetNumTradeSkills()
    end

    function adapter:getSpellID(i)
        local link = GetTradeSkillRecipeLink(i)
        return link and tonumber(link:match("enchant:(%d+)"))
    end


    return adapter
end
