RGXProf.ForeverPaths = RGXProf.ForeverPaths or {}

-- WoW Forever Skinning 1-300. Beta data 2026-09-23 (source:
-- wowsod.pro/wow-forever/professions/skinnying, mined from the beta client).
-- Forever changed the skill-up economy: skinning mobs gives 0 skill past their
-- optimal level range 25-35 points sooner than Classic. Train ranks at skill 50/125/200.
RGXProf.ForeverPaths.Skinning = {
  { keep = 0, minSkill = 1,   maxSkill = 50,  itemID = 2934,  spellID = 8613,    name = "Ruined Leather Scraps",            colors = { y = 35,  g = 50,  r = 65 }, learnAt = 1 },
  { keep = 0, minSkill = 50,  maxSkill = 70,  itemID = 2318,  spellID = 8617,    name = "Light Leather",                    colors = { y = 60,  g = 70,  r = 80 }, learnAt = 40 },
  { keep = 0, minSkill = 70,  maxSkill = 90,  itemID = 2319,  spellID = 8618,    name = "Medium Leather",                   colors = { y = 80,  g = 90,  r = 100 }, learnAt = 60 },
  { keep = 1, minSkill = 90,  maxSkill = 110, itemID = 2319,  spellID = 8618,    name = "Medium Leather",                   colors = { y = 100, g = 110, r = 120 }, learnAt = 80, keepNote = "Used by Heavy Leather (3:1)." },
  { keep = 0, minSkill = 110, maxSkill = 130, itemID = 4234,  spellID = 8619,    name = "Heavy Leather",                    colors = { y = 120, g = 130, r = 140 }, learnAt = 100 },
  { keep = 1, minSkill = 130, maxSkill = 150, itemID = 4234,  spellID = 8619,    name = "Heavy Leather",                    colors = { y = 140, g = 150, r = 160 }, learnAt = 120, keepNote = "Used by Thick Leather (3:1)." },
  { keep = 0, minSkill = 150, maxSkill = 170, itemID = 4304,  spellID = 8620,    name = "Thick Leather",                    colors = { y = 160, g = 170, r = 180 }, learnAt = 140 },
  { keep = 1, minSkill = 170, maxSkill = 190, itemID = 4304,  spellID = 8620,    name = "Thick Leather",                    colors = { y = 180, g = 190, r = 200 }, learnAt = 160, keepNote = "Used by Rugged Leather (3:1)." },
  { keep = 0, minSkill = 190, maxSkill = 210, itemID = 8170,  spellID = 8621,    name = "Rugged Leather",                   colors = { y = 200, g = 210, r = 220 }, learnAt = 180 },
  { keep = 1, minSkill = 210, maxSkill = 230, itemID = 8170,  spellID = 8621,    name = "Rugged Leather",                   colors = { y = 220, g = 230, r = 240 }, learnAt = 200, keepNote = "Used by Runed Leather (3:1)." },
  { keep = 0, minSkill = 230, maxSkill = 250, itemID = 19767, spellID = 8622,    name = "Runed Leather",                    colors = { y = 240, g = 250, r = 260 }, learnAt = 220 },
  { keep = 0, minSkill = 250, maxSkill = 270, itemID = 19768, spellID = 8623,    name = "Runed Leather",                    colors = { y = 260, g = 270, r = 280 }, learnAt = 240 },
  { keep = 0, minSkill = 270, maxSkill = 290, itemID = 19768, spellID = 8623,    name = "Runed Leather",                    colors = { y = 280, g = 290, r = 300 }, learnAt = 260 },
  { keep = 0, minSkill = 290, maxSkill = 300, itemID = 19768, spellID = 8623,    name = "Runed Leather",                    colors = { y = 295, g = 300, r = 305 }, learnAt = 280 },
}