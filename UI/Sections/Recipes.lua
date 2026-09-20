RGXProf.Recipes = {}

function RGXProf.Recipes:Render(state)
    self:RenderRecipeSlot(RGXProf.Constants.MAIN, state.mainRecipe, state.selectedRecipe)
    self:RenderRecipeSlot(RGXProf.Constants.ALTERNATE, state.altRecipe, state.selectedRecipe)
end

function RGXProf.Recipes:RenderRecipeSlot(slot, recipe, selectedSlot)
    local slotName = (slot == RGXProf.Constants.MAIN) and "MainSlot" or "AltSlot"
    local parent = RGXProf.MainWindow.UIElements[slotName .. "_Recipe"]
    local slotFrame = parent:GetParent()
    local icon = RGXProf.LayoutManager:GetChildFrame(parent, "_Button")
    local spellName = RGXProf.LayoutManager:GetChildFrame(parent, "_SpellName")
    local bar = RGXProf.LayoutManager:GetChildFrame(parent, "_ColorBar")
    if not recipe or not recipe.name then
        slotFrame:Hide()
        return
    end
    slotFrame:Show()
    RGXProf.FrameRegistry:Register(icon, { link = recipe.link, spellID = recipe.spellID, slot = recipe.slot })
    local selected = (slot == selectedSlot)
    local alpha = selected and 1 or 0.5
    RGXProf.Utils:SetText(spellName.fontString, recipe.name)
    spellName.fontString:SetTextColor(recipe.skillColor.r, recipe.skillColor.g, recipe.skillColor.b, 1)
    icon:SetNormalTexture(recipe.icon)
    icon:GetNormalTexture():SetVertexColor(alpha, alpha, alpha)

    bar.texture:SetColorTexture(recipe.skillColor.r, recipe.skillColor.g, recipe.skillColor.b, 1)

    parent.texture:SetTexture(0, 0, 0, selected and 0.2 or 0.4)
    
    parent:Show()
end
