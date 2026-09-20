--------------------------------------------------------------------
-- Blizzard_CraftUI Adapter (Classic)
--------------------------------------------------------------------

RGXProf.AdapterFactories["Blizzard_CraftUI"] = function()
    local adapter = RGXProf.AddonAdapter:new("Blizzard_Craft")
    adapter.type = "craft"
    adapter.isCraft = true

    function adapter:tradeFrame()
        return CraftFrame
    end

    function adapter:select(skillIndex)
        if not skillIndex then return end
        if self:isShown() then
            CraftFrame.selectedCraft = skillIndex
            CraftFrame_SetSelection(skillIndex)
            CraftFrame_Update()
        end
    end

    --- @return boolean
    function adapter:isShown()
        return CraftFrame and CraftFrame:IsShown()
    end

    function adapter:getSkillLink(index)
        return GetCraftRecipeLink(index)
    end

    function adapter:getDetailsAtIndex(i)
        local name, _, skillType = GetCraftInfo(i)
        return {
            name = name,
            skillType = skillType,
            isHeader = false,
            isExpanded = true
        }
    end

    function adapter:expandAllHeaders()
        -- Craft UI has no headers or collapsible sections
    end

    function adapter:getNumEntries()
        return GetNumCrafts()
    end

    function adapter:getSpellID(i)
        local link = GetCraftRecipeLink(i)
        return link and tonumber(link:match("enchant:(%d+)"))
    end

    function adapter:getProfessionInfo()
        return GetCraftDisplaySkillLine()
    end

    return adapter
end
