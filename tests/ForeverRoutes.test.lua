-- The Forever crafting routes are internally sound: each runs from 1 to 300 without gaps, no step goes past the
-- point where its recipe turns gray, colours are in order, every recipe has reagents, and sources are known.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
RGXProf = { Data = {} }
assert(loadfile("Data/Classic/Recipes.lua"))()
assert(loadfile("Data/Forever/Recipes.lua"))()
local PROFS = { "Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering", "FirstAid", "Leatherworking", "Tailoring" }
local SOURCES = { trainer = true, vendor = true, quest = true, new = true }
local total = 0
for _, prof in ipairs(PROFS) do
  assert(loadfile("Data/Forever/ProfessionPaths/" .. prof .. ".lua"))()
  local steps = RGXProf.ForeverPaths[prof]
  check(type(steps) == "table" and #steps >= 5, prof .. " has a route")
  check(steps[1].minSkill == 1, prof .. " starts at skill 1")
  check(steps[#steps].maxSkill == 300, prof .. " ends at skill 300")
  for i, s in ipairs(steps) do
    local where = prof .. " step " .. i .. " (" .. tostring(s.name) .. ")"
    total = total + 1
    check(type(s.spellID) == "number" and s.name and s.crafts and s.crafts > 0, where .. " is complete")
    check(s.minSkill < s.maxSkill, where .. " has a positive range")
    if i > 1 then check(s.minSkill == steps[i - 1].maxSkill, where .. " continues where the last step ended") end
    check(s.colors.y < s.colors.g and s.colors.g < s.colors.r, where .. " has ordered colours")
    check(s.maxSkill <= s.colors.r, where .. " does not run past the point it turns gray (" .. s.maxSkill .. " > " .. s.colors.r .. ")")
    check(SOURCES[s.source], where .. " has a known source (" .. tostring(s.source) .. ")")
    check(type(s.learnAt) == "number" and s.learnAt <= s.minSkill, where .. " is learned before its step starts (" .. tostring(s.learnAt) .. " > " .. s.minSkill .. ")")
    local reagents = RGXProf.Data.Recipes[s.spellID]
    check(type(reagents) == "table" and next(reagents) ~= nil, where .. " has reagents")
  end
end
io.write("ForeverRoutes OK: " .. #PROFS .. " routes, " .. total .. " steps\n")
