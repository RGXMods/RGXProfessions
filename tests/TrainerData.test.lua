-- Trainer data: every profession the guide covers has trainers for both factions, with map coordinates in range
-- and zone ids from the known zone set, and factions labelled as stored (no load-time swapping).
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
RGXProf = {}
assert(loadfile("Data/Classic/NPCs/Trainers.lua"))()
local rows = RGXProf.Classic.Trainers
local zones = {}
for id = 1411, 1460 do zones[id] = true end
local seen = {}
for i, t in ipairs(rows) do
  check(type(t.name) == "string" and t.name ~= "", "row " .. i .. " has a name")
  check(t.faction == "Alliance" or t.faction == "Horde" or t.faction == "Neutral", t.name .. ": known faction")
  check(zones[t.zoneID], t.name .. ": zone id " .. tostring(t.zoneID) .. " is in the known zone set")
  check(type(t.x) == "number" and t.x >= 0 and t.x <= 100 and type(t.y) == "number" and t.y >= 0 and t.y <= 100, t.name .. ": coordinates in 0-100")
  check(t.maxSkill >= 75 and t.maxSkill <= 300, t.name .. ": skill cap in range")
  seen[t.professionID] = seen[t.professionID] or {}
  seen[t.professionID][t.faction] = true
end
for _, id in ipairs({ 129, 164, 165, 171, 182, 185, 186, 197, 202, 333, 356, 393 }) do
  local s = seen[id] or {}
  check((s.Alliance or s.Neutral) and (s.Horde or s.Neutral), "profession " .. id .. " has a trainer for both factions")
end
-- Stormwind and Orgrimmar trainers carry their own faction.
for _, t in ipairs(rows) do
  if t.zoneID == 1453 then check(t.faction == "Alliance", t.name .. " (Stormwind) is Alliance") end
  if t.zoneID == 1454 then check(t.faction == "Horde", t.name .. " (Orgrimmar) is Horde") end
end
io.write("TrainerData OK (" .. #rows .. " trainers)\n")
