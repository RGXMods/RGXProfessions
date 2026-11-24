-- Exercise the shared adapter, not a copy of its matching logic.
local function check(value, message)
    if not value then error("CHECK FAILED: " .. message, 2) end
end

local none, optimal = {}, {}
RGXProf = {
    Constants = { SkillUpColors = { none = none, optimal = optimal } },
    Data = {},
}
assert(loadfile("Adapters/AddonAdapter.lua"))()
local adapter = RGXProf.AddonAdapter:new("knowledge fixture")
local rows = {}
function adapter:getNumEntries() return #rows end
function adapter:getSkillLink(i) return rows[i].link end
function adapter:getDetailsAtIndex(i) return rows[i] end
function adapter:getProfessionInfo() return "Alchemy", 1, 75 end
function adapter:expandAllHeaders() error("background scans must not expand headers") end

for _, kind in ipairs({ "enchant", "recipe" }) do
    rows = { { name = "Localized recipe", link = "|cffffffff|H" .. kind .. ":2152|h[Localized recipe]|h|r",
        skillType = "optimal" } }
    local index, known, color = adapter:getRecipeLineInfo(2152, "English guide name")
    check(index == 1 and known and color == optimal, kind .. ": ID matches despite a different localized name")
    rows[1].link = "|H" .. kind .. ":2152:0:0|h[Recipe]|h"
    check(adapter:matchedIndexOnSpellLink(1, 2152), kind .. ": optional link fields are supported")
    check(not adapter:matchedIndexOnSpellLink(1, 215), kind .. ": no partial ID match")
end

rows = {}
local index, known = adapter:getRecipeLineInfo(2152, "English guide name")
check(index == 0 and known, "a previously observed recipe stays known when its category is collapsed")
check(adapter:getRecipeLineInfo(9999, "Not observed") == 0, "a different spell has no visible index")
local _, otherKnown = adapter:getRecipeLineInfo(9999, "Not observed")
check(not otherKnown, "unobserved recipes do not inherit another recipe's knowledge")

rows = { { name = "Named recipe", skillType = "optimal" } }
check(select(2, adapter:getRecipeLineInfo(9999, "Named recipe")), "name fallback survives a missing link")
rows = { { name = "Same name", link = "|Henchant:9997|h[Same name]|h", skillType = "optimal" } }
check(not select(2, adapter:getRecipeLineInfo(9996, "Same name")), "a matching name cannot override a different explicit recipe ID")
rows = { { name = "Header", isHeader = true, link = "|Hrecipe:9998|h[Header]|h" } }
check(not select(2, adapter:getRecipeLineInfo(9998, "Header")), "headers never establish recipe knowledge")
rows = { {} }
check(not adapter:matchedIndexOnSpellLink(1, nil), "missing link and missing spell ID cannot match")
check(not adapter:matchedIndexOnSpellName(1, nil), "missing names cannot establish knowledge")
for _, link in ipairs({ "|Hitem:2152|h[Product]|h", "|Hspell:2152|h[Spell]|h", "|Hrecipe:bad|h[Bad]|h", "recipe:2152" }) do
    rows = { { link = link } }
    check(not adapter:matchedIndexOnSpellLink(1, 2152), "unrelated or malformed link is rejected: " .. link)
end
rows = { { link = "|Hrecipe:21520|h[Other]|h" } }
check(not adapter:matchedIndexOnSpellLink(1, 2152), "longer IDs are not truncated")
local fresh = RGXProf.AddonAdapter:new("fresh adapter")
check(next(fresh.knownRecipes) == nil, "knowledge is not shared across adapter instances")
print("RecipeKnowledge.test OK")
