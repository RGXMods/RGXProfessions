--------------------------------------------------------------------
-- TradeSkillMaster Adapter
--------------------------------------------------------------------

RGXProf.AdapterFactories = RGXProf.AdapterFactories or {}

RGXProf.AdapterFactories["TradeSkillMaster"] = function()
    local adapter = setmetatable({}, { __index = RGXProf.AddonAdapter })
    adapter.name = "TSM"
    adapter.type = "trade"


    function adapter:tradeFrame()
        return UIParent
    end

    function adapter:select(skillIndex)
        -- not exposed in TSM API, so we can't implement this
    end

    function adapter:isShown()
        local visible = TSM_API and TSM_API.IsUIVisible("CRAFTING") or false
        return visible
    end

    function adapter:position(frame)        
        local anchor = self.tradeFrame and self:tradeFrame() or nil
        RGXProf.LayoutManager:RestoreOrAlignToAnchor(frame, anchor, -25, -100, { first = "TOPRIGHT", second = "TOPRIGHT" })
        frame:SetScale(1.0)
    end

    function adapter:getRecipeLineInfo(spellID, spellName)
        local profession = RGXProf.DataManager:GetProfession() 
        local skill = profession.pointsEarned
        local thresholds = RGXProf.Data.Skill[spellID]

        local skillType

        if thresholds then
            if skill < thresholds.y then
                skillType = "optimal"
            elseif skill < thresholds.g then
                skillType = "medium"
            elseif skill < thresholds.r then
                skillType = "easy"
            else
                skillType = "trivial"
            end
        else
            skillType = "unknown"
        end
                
        local color = RGXProf.Constants.SkillUpColors[skillType] or RGXProf.Constants.SkillUpColors.none
        return nil, true, color
    end

    return adapter

end