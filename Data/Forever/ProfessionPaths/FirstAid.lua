RGXProf.ForeverPaths = RGXProf.ForeverPaths or {}

-- WoW Forever First Aid 1-300. Beta data 2026-09-23 (source:
-- wowsod.pro/wow-forever/professions/firstaid, mined from the beta client).
-- Forever changed the skill-up economy: most old recipes grey 25-35 points
-- sooner than Classic. Train ranks at skill 50/125/200.
RGXProf.ForeverPaths.FirstAid = {
  { keep = 0, minSkill = 1,   maxSkill = 40,  itemID = 3267,  spellID = 3273,    name = "Linen Bandage",                    colors = { y = 25,  g = 40,  r = 55 }, learnAt = 1 },
  { keep = 0, minSkill = 40,  maxSkill = 80,  itemID = 3268,  spellID = 3274,    name = "Heavy Linen Bandage",              colors = { y = 55,  g = 80,  r = 95 }, learnAt = 30 },
  { keep = 0, minSkill = 80,  maxSkill = 115, itemID = 3269,  spellID = 3275,    name = "Wool Bandage",                     colors = { y = 100, g = 115, r = 130 }, learnAt = 75 },
  { keep = 0, minSkill = 115, maxSkill = 150, itemID = 3270,  spellID = 3276,    name = "Heavy Wool Bandage",               colors = { y = 130, g = 150, r = 165 }, learnAt = 110 },
  { keep = 0, minSkill = 150, maxSkill = 180, itemID = 6450,  spellID = 7926,    name = "Silk Bandage",                     colors = { y = 165, g = 180, r = 195 }, learnAt = 145 },
  { keep = 0, minSkill = 180, maxSkill = 210, itemID = 6451,  spellID = 7927,    name = "Heavy Silk Bandage",               colors = { y = 200, g = 210, r = 220 }, learnAt = 175 },
  { keep = 0, minSkill = 210, maxSkill = 225, itemID = 8544,  spellID = 10840,   name = "Mageweave Bandage",                colors = { y = 220, g = 225, r = 230 }, learnAt = 205 },
  { keep = 0, minSkill = 225, maxSkill = 240, itemID = 8545,  spellID = 10841,   name = "Heavy Mageweave Bandage",          colors = { y = 235, g = 240, r = 245 }, learnAt = 220 },
  { keep = 0, minSkill = 240, maxSkill = 260, itemID = 14529, spellID = 18629,   name = "Runecloth Bandage",                colors = { y = 255, g = 260, r = 270 }, learnAt = 235 },
  { keep = 0, minSkill = 260, maxSkill = 280, itemID = 14530, spellID = 18630,   name = "Heavy Runecloth Bandage",          colors = { y = 275, g = 280, r = 285 }, learnAt = 255 },
  { keep = 0, minSkill = 280, maxSkill = 300, itemID = 19440, spellID = 23787,   name = "Powerful Anti-Venom",              colors = { y = 295, g = 300, r = 305 }, learnAt = 275 },
}