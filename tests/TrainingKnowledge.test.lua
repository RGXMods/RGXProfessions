local function check(value, message)
    if not value then error("CHECK FAILED: " .. message, 2) end
end
local function read(path)
    local f = assert(io.open(path))
    local text = f:read("*a")
    f:close()
    return text
end
local none = {}
RGXProf = {
    Constants = { SkillUpColors = { none = none }, ProfessionNameToID = { Alchemy = 171, Cooking = 185 } },
    Data = {}, L = { TRAIN_AVAILABLE = "Available to train", TRAIN_AT = "Train at %d" },
}
assert(loadfile("Core/WowAPI.lua"))()
assert(loadfile("Core/DataManager.lua"))()
assert(loadfile("Adapters/AddonAdapter.lua"))()
local api, dm = RGXProf.WowAPI, RGXProf.DataManager
local step = { spellID = 7183, name = "Guide recipe", learnAt = 1, source = "trainer" }
C_TradeSkillUI = { GetRecipeInfo = function(id) return { recipeID = id, learned = true } end }
check(api:GetRecipeKnowledge(7183) == true, "modern learned flag")
C_TradeSkillUI.GetRecipeInfo = function(id) return { recipeID = id, learned = false } end
check(api:GetRecipeKnowledge(7183) == false, "explicit modern unlearned flag preserves false")
for _, result in ipairs({ {}, { recipeID = 99, learned = true }, { recipeID = 7183, learned = "yes" } }) do
    C_TradeSkillUI.GetRecipeInfo = function() return result end
    check(api:GetRecipeKnowledge(7183) == nil, "malformed or mismatched recipe metadata is unknown")
end
C_TradeSkillUI.GetRecipeInfo = function() error("data unavailable") end
check(api:GetRecipeKnowledge(7183) == nil, "provider errors remain unknown")
C_TradeSkillUI = nil
C_SpellBook = { IsSpellKnown = function() return true end }
check(api:GetRecipeKnowledge(7183) == true, "spellbook knowledge is positive evidence")
C_TradeSkillUI = { GetRecipeInfo = function(id) return { recipeID = id, learned = false } end }
check(api:GetRecipeKnowledge(7183) == true, "positive spellbook evidence wins over stale unlearned metadata")
C_TradeSkillUI = nil
C_SpellBook.IsSpellKnown = function() return false end
check(api:GetRecipeKnowledge(7183) == nil, "absence from the spellbook alone is not proof of an unlearned recipe")
C_SpellBook = nil
check(api:GetRecipeKnowledge(nil) == nil, "missing recipe ID is unknown")

local adapter = RGXProf.AddonAdapter:new("legacy")
local profession, visible = "Alchemy", true
function adapter:getProfessionInfo() return profession, 100, 150 end
function adapter:getNumEntries() return visible and 1 or 0 end
function adapter:getDetailsAtIndex() return { name = "Localized recipe", skillType = "unknown" } end
function adapter:getSkillLink() return "|Henchant:7183|h[Localized recipe]|h" end
RGXProf.AdapterManager = { GetCurrent = function() return adapter end, registeredAdapters = { legacy = adapter } }
check(dm:GetRecipeKnowledge(step, 171) == true, "legacy visible recipe establishes knowledge by ID")
visible = false
check(dm:GetRecipeKnowledge(step, 171) == true, "collapsed legacy rows retain positive knowledge")
check(dm:GetRecipeKnowledge(step, 185) == nil, "a different profession's adapter is not evidence")
profession = "Cooking"
adapter:getRecipeLineInfo(7183, step.name)
check(next(adapter.knownRecipes) == nil, "switching professions clears observed recipe knowledge")
profession = "Alchemy"
check(dm:GetRecipeKnowledge(step, 171) == nil, "unobserved collapsed or filtered recipes stay unknown")
visible = true
dm:GetRecipeKnowledge(step, 171)
C_TradeSkillUI = { GetRecipeInfo = function(id) return { recipeID = id, learned = false } end }
check(dm:GetRecipeKnowledge(step, 171) == false, "fresh explicit unlearned metadata wins over observed cache")
C_TradeSkillUI = nil
RGXProf.IsSimulation = true
check(dm:GetRecipeKnowledge(step, 171) == nil, "simulation does not claim character recipe knowledge")
RGXProf.IsSimulation = nil

-- Run the real book metadata block without replacing its decision logic.
local book = read("UI/BookWindow.lua")
local a = assert(book:find("    -- Extra lines", 1, true))
local b = assert(book:find("    -- Progress through this step.", a, true))
local render = assert(loadstring("return function(step, skill, professionID, detail, C, Dim)\n"
    .. book:sub(a, b - 1) .. "\nend"))()
local text
local detail = { meta = { SetText = function(_, value) text = value end } }
local getKnowledge = dm.GetRecipeKnowledge
local function show(known, skill, source)
    dm.GetRecipeKnowledge = function() return known end
    step.source = source or "trainer"
    render(step, skill, 171, detail, function() return "" end, function() return "" end)
    return text
end
check(show(true, 100) == "", "learned recipes never show a trainable label")
check(show(false, 100) == RGXProf.L.TRAIN_AVAILABLE, "explicitly unlearned trainer recipe at threshold is trainable")
check(show(nil, 100) == "Train at 1", "unknown recipe data only shows the neutral threshold")
check(show(false, 0) == "Train at 1", "below threshold is not trainable")
check(show(false, 100, "vendor") ~= RGXProf.L.TRAIN_AVAILABLE, "vendor recipes are not advertised as trainer recipes")
check(show(false, nil) ~= RGXProf.L.TRAIN_AVAILABLE, "unknown skill is not trainable")
dm.GetRecipeKnowledge = getKnowledge

-- The profession-window guide uses the same tri-state policy, not `not known`.
RGXProf.Constants.Train_Threshold = 10
RGXProf.Utils = { DeepCopy = function(_, template)
    return { instructions = template.instructions, icon = template.icon, layout = template.layout }
end }
RGXProf.Training = {
    TRAINER_RECIPE = { instructions = "Train recipe" },
    SKILLED = { instructions = "Craft %d to %d" },
}
dm.GetEstimatedCrafts = function() return 2 end
dm.GetTrainers = function() return {} end
local guideProfession = { id = 171, pointsEarned = 10, pointsTotal = 75, pointsRemaining = 65 }
step.maxSkill = 30
check(dm:DetermineTraining("Alliance", step, { hasSkill = true }, guideProfession).instructions == "Craft 2 to 30",
    "learned legacy guide recipe has crafting instructions, not training")
check(dm:DetermineTraining("Alliance", step, {}, guideProfession).instructions == "",
    "unknown legacy guide recipe never claims it needs training")
check(dm:DetermineTraining("Alliance", step, { hasSkill = false }, guideProfession).instructions == "Train recipe",
    "explicitly unlearned legacy guide recipe can show training")

local refreshes = 0
RGXProf.StateManager = { RequestRefresh = function() refreshes = refreshes + 1 end }
assert(loadfile("Core/Events.lua"))()
adapter.knownRecipes[7183] = true
RGXProf.Events.SPELLS_CHANGED(RGXProf)
check(next(adapter.knownRecipes) == nil and refreshes == 1, "spell changes clear observations and refresh the open guide")
adapter.knownRecipes[7183] = true
RGXProf.Events.SKILL_LINES_CHANGED(RGXProf)
check(next(adapter.knownRecipes) == nil and refreshes == 2, "profession changes invalidate observations")
adapter.knownRecipes[7183] = true
RGXProf.Events.NEW_RECIPE_LEARNED(RGXProf)
check(next(adapter.knownRecipes) == nil and refreshes == 3, "learning a recipe invalidates observations and refreshes")
print("TrainingKnowledge.test OK")
