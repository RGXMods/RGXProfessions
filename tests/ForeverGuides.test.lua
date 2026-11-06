-- Run: lua5.1 tests/ForeverGuides.test.lua   (from the repository root)
-- Invariants of the generated Forever guide data and the remaining-materials maths.
local function check(cond, msg) if not cond then error("CHECK FAILED: " .. msg, 2) end end

RGXProf = {}
for _, f in ipairs({
  "Data/Forever/ProfessionPaths/Alchemy.lua", "Data/Forever/ProfessionPaths/Blacksmithing.lua",
  "Data/Forever/ProfessionPaths/Cooking.lua", "Data/Forever/ProfessionPaths/Enchanting.lua",
  "Data/Forever/ProfessionPaths/Engineering.lua", "Data/Forever/ProfessionPaths/FirstAid.lua",
  "Data/Forever/ProfessionPaths/Leatherworking.lua", "Data/Forever/ProfessionPaths/Tailoring.lua",
  "Data/Forever/ProfessionPaths/Fishing.lua", "Data/Forever/ProfessionPaths/Herbalism.lua",
  "Data/Forever/ProfessionPaths/Mining.lua", "Data/Forever/ProfessionPaths/Skinning.lua",
  "Data/Forever/ProfessionNotes.lua",
}) do assert(loadfile(f))() end
RGXProf.Data = { Recipes = {} }
assert(loadfile("Data/Forever/Recipes.lua"))()

local professionIDs = {
  Alchemy = 171, Blacksmithing = 164, Cooking = 185, Enchanting = 333, Engineering = 202, FirstAid = 129,
  Leatherworking = 165, Tailoring = 197, Fishing = 356, Herbalism = 182, Mining = 186, Skinning = 393,
}
local crafting = { Alchemy = true, Blacksmithing = true, Cooking = true, Enchanting = true, Engineering = true,
  FirstAid = true, Leatherworking = true, Tailoring = true }

for name, id in pairs(professionIDs) do
  local path = RGXProf.ForeverPaths[name]
  check(path and #path > 0, name .. " has a route")
  check(path[1].minSkill == 1, name .. " starts at skill 1")
  check(path[#path].maxSkill == 300, name .. " ends at skill 300")
  for i, step in ipairs(path) do
    check(step.minSkill < step.maxSkill, name .. " step " .. i .. " has a positive span")
    if i > 1 then check(step.minSkill == path[i - 1].maxSkill, name .. " step " .. i .. " continues the previous one") end
    check(type(step.name) == "string" and step.name ~= "", name .. " step " .. i .. " is named")
    if crafting[name] then
      check(step.spellID, name .. " step " .. i .. " has a spell")
      check(step.colors and step.colors.y <= step.colors.g and step.colors.g <= step.colors.r, name .. " step " .. i .. " colours never descend")
      check(step.crafts and step.crafts > 0, name .. " step " .. i .. " has an expected craft count")
      check(RGXProf.Data.Recipes[step.spellID] and next(RGXProf.Data.Recipes[step.spellID]), name .. " step " .. i .. " has reagents")
    else
      check(step.source == "gather" and step.zones, name .. " step " .. i .. " is a gathering bracket with zones")
    end
  end
  local notes = RGXProf.ForeverNotes[id]
  check(notes and notes.tagline ~= "", name .. " has notes with a tagline")
  check(#notes.tips > 0, name .. " has tips")
end

-- Estimated crafts: use the route's own count, scaled for the part still to do.
local dm = assert(io.open("Core/DataManager.lua", "r")):read("*a")
local a = assert(dm:find("function RGXProf.DataManager:GetEstimatedCrafts", 1, true))
local b = assert(dm:find("\nend\n", a, true))
RGXProf.DataManager = {}
assert(loadstring(dm:sub(a, b + 4)))()
local step = { minSkill = 1, maxSkill = 90, crafts = 134 }
check(RGXProf.DataManager:GetEstimatedCrafts(1, step) == 134, "full step uses the route's craft count")
check(RGXProf.DataManager:GetEstimatedCrafts(46, step) == math.ceil(134 * 44 / 89), "half-done step scales the count")
check(RGXProf.DataManager:GetEstimatedCrafts(90, step) == 0, "finished step needs no crafts")

print("ForeverGuides test OK (" .. 12 .. " professions)")
