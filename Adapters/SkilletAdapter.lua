--------------------------------------------------------------------
-- Skillet Adapter
--------------------------------------------------------------------

RGXProf.AdapterFactories = RGXProf.AdapterFactories or {}
local function getSpellIDFromRecipeLink(link)
    if not link then return nil end
    -- Recipe link format: "|cff...|Hrecipe:spellID:...|h[Name]|h|r"
    local spellID = tonumber(link:match("Hrecipe:(%d+):"))
    return spellID
end

RGXProf.AdapterFactories["Skillet-Classic"] = function()
    local adapter = setmetatable({}, { __index = RGXProf.AddonAdapter })
    adapter.name = "Skillet-Classic"
    adapter.type = "trade"
    
    function adapter:tradeFrame()
        return SkilletFrame
    end

    function adapter:select(skillIndex)
        if SkilletFrame and SkilletFrame.SetSelection then
            SkilletFrame:SetSelection(skillIndex)
        end
    end

    function adapter:isShown()
        return SkilletFrame and SkilletFrame:IsShown()
    end

    function adapter:selectBySpellID(spellID)
        if not spellID then return false end
        for i = 1, 50 do
            local button = _G["SkilletScrollButton" .. i]
            if button and button:IsShown() and button.skill then
                local skill = button.skill
                if skill.spellID == spellID then
                    -- Emulate a click  
                    local onClick = button:GetScript("OnClick")
                    if onClick then
                        onClick(button, "LeftButton")
                        return
                    end
                end
            end
        end
    end

    function adapter:getRecipeLineInfo(spellID)
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

    function adapter:getProfessionInfo()
        local name, cur, max = Skillet:GetTradeSkillLine()
        if not name or name == "" then
            if Skillet:IsCraft() then
                name, cur, max = GetCraftDisplaySkillLine()
            end
        end

        if not name or name == "" then
            local txt = SkilletRankFrameSkillRank and SkilletRankFrameSkillRank:GetText()
            if txt then
                name, cur, max = txt:match("^(%S+)%s+(%d+)%/(%d+)$")
                cur, max = tonumber(cur), tonumber(max)
            end
        end
        return name, cur, max
    end

    -- function adapter:findSkillIndexBySpellID(targetSpellID)
    --     local numSkills = GetNumTradeSkills()
    --     for i = 1, numSkills do
    --         local link = GetTradeSkillRecipeLink(i)
    --         local spellID = getSpellIDFromRecipeLink(link)
    --         if spellID == targetSpellID then
    --             return i
    --         end
    --     end
    --     return nil
    -- end

    -- function adapter:selectBySpellID(targetSpellID)
    --     for i = 1, 50 do
    --         local button = _G["SkilletScrollButton" .. i]
    --         if button and button:IsShown() and button.skill then
    --             local skill = button.skill
    --             if skill.spellID == targetSpellID then
    --                 -- Emulate a click
    --                 local onClick = button:GetScript("OnClick")
    --                 if onClick then
    --                     onClick(button, "LeftButton")
    --                     return true
    --                 end
    --             end
    --         end
    --     end
    --     return false -- Spell not found or not visible
    -- end

    return adapter
end
