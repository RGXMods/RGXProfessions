-- In-game notes must match the guide data: crafting steps there have no per-step notes, so
-- the addon must show none (the old keep = 0 flag made every step say "keep the crafted items"), and
-- a gathering bracket shows its guide note exactly once.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local function read(p) local f = assert(io.open(p)); local s = f:read("*a"); f:close(); return s end

local src = read("UI/BookWindow.lua")
local a = assert(src:find("local function IsKeep", 1, true))
local b = assert(src:find("\nend\n", a, true))
local IsKeep = assert(loadstring(src:sub(a, b + 4) .. "\nreturn IsKeep"))()
check(IsKeep({ keep = true }) and IsKeep({ keep = 1 }), "true and 1 mean keep")
check(not IsKeep({ keep = 0 }) and not IsKeep({ keep = false }) and not IsKeep({}), "0, false and nil do not")

RGXProf = {}
local files = { "Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering", "FirstAid", "Leatherworking",
  "Tailoring", "Fishing", "Herbalism", "Mining", "Skinning" }
local crafted, gathered, withNote = 0, 0, 0
for _, name in ipairs(files) do
  assert(loadfile("Data/Forever/ProfessionPaths/" .. name .. ".lua"))()
  for i, step in ipairs(RGXProf.ForeverPaths[name]) do
    check(not IsKeep(step), name .. " step " .. i .. ": the guide has no keep-for-later note")
    if step.source == "gather" then
      gathered = gathered + 1
      if step.note then withNote = withNote + 1 end
    else
      crafted = crafted + 1
      check(step.note == nil, name .. " step " .. i .. ": crafting steps carry no note on the guide")
    end
  end
end
check(crafted == 100 and withNote == 7, "every Forever route loaded (" .. crafted .. " craft steps, " .. withNote .. " gathering notes)")

-- The step note is rendered once, in the Notes card, not again in the recipe card's meta lines.
local render = src:sub(assert(src:find("RenderDetail = function(self)", 1, true)), assert(src:find("LayoutDetail = function(self)", 1, true)))
local metaPart = render:sub(1, assert(render:find("detail.meta:SetText", 1, true)))
check(not metaPart:find("step.note", 1, true), "the recipe card does not repeat the step note")
check(select(2, render:gsub("step%.note", "")) >= 1, "the Notes card still shows the step note")

-- Step-list rows span the list with TOPLEFT + TOPRIGHT only (no vertically-centred RIGHT anchor).
check(not src:find('row:SetPoint("RIGHT")', 1, true), "rows are not anchored by a centred RIGHT point")
check(src:find('row:SetPoint("TOPRIGHT", f.stepContent', 1, true), "rows span the list width from the top edge")
print("GuideNotes.test OK (" .. crafted .. " craft steps, " .. gathered .. " gathering brackets)")
