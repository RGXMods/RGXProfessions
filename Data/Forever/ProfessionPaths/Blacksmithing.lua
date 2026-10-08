RGXProf.ForeverPaths = RGXProf.ForeverPaths or {}

-- WoW Forever Blacksmithing 1-300. Beta data 2026-09-23 (source:
-- wowsod.pro/wow-forever/professions/blacksmithing, mined from the beta client).
-- Forever changed the skill-up economy: most old recipes grey 25-35 points
-- sooner than Classic. Train ranks at skill 50/125/200.
RGXProf.ForeverPaths.Blacksmithing = {
  { keep = 1, minSkill = 1,   maxSkill = 25,  itemID = 2835,  spellID = 2572,    name = "Rough Sharpening Stone",           colors = { y = 15,  g = 25,  r = 35 }, learnAt = 1, keepNote = "Used by Copper Battle Axe (2 each)." },
  { keep = 0, minSkill = 25,  maxSkill = 45,  itemID = 2830,  spellID = 2575,    name = "Rough Grinding Stone",             colors = { y = 40,  g = 55,  r = 70 }, learnAt = 15 },
  { keep = 0, minSkill = 45,  maxSkill = 65,  itemID = 2738,  spellID = 2656,    name = "Copper Battle Axe",                colors = { y = 55,  g = 70,  r = 85 }, learnAt = 30 },
  { keep = 1, minSkill = 65,  maxSkill = 75,  itemID = 2836,  spellID = 2577,    name = "Coarse Sharpening Stone",          colors = { y = 70,  g = 75,  r = 80 }, learnAt = 65, keepNote = "Used by Copper Chain Belt (2 each)." },
  { keep = 0, minSkill = 75,  maxSkill = 90,  itemID = 2838,  spellID = 2578,    name = "Coarse Grinding Stone",            colors = { y = 80,  g = 90,  r = 95 }, learnAt = 70 },
  { keep = 0, minSkill = 90,  maxSkill = 100, itemID = 2853,  spellID = 2662,    name = "Copper Chain Belt",                colors = { y = 90,  g = 100, r = 110 }, learnAt = 85 },
  { keep = 1, minSkill = 100, maxSkill = 110, itemID = 2837,  spellID = 2579,    name = "Heavy Sharpening Stone",           colors = { y = 100, g = 110, r = 115 }, learnAt = 95, keepNote = "Used by Copper Chain Boots (2 each)." },
  { keep = 0, minSkill = 110, maxSkill = 120, itemID = 2839,  spellID = 2580,    name = "Heavy Grinding Stone",             colors = { y = 110, g = 120, r = 125 }, learnAt = 105 },
  { keep = 0, minSkill = 120, maxSkill = 130, itemID = 2852,  spellID = 2664,    name = "Copper Chain Boots",               colors = { y = 120, g = 130, r = 135 }, learnAt = 115 },
  { keep = 0, minSkill = 130, maxSkill = 140, itemID = 2848,  spellID = 2668,    name = "Bronze Battle Axe",                colors = { y = 130, g = 140, r = 145 }, learnAt = 130 },
  { keep = 0, minSkill = 140, maxSkill = 150, itemID = 3481,  spellID = 2737,    name = "Bronze Axe",                       colors = { y = 140, g = 150, r = 155 }, learnAt = 140 },
  { keep = 0, minSkill = 150, maxSkill = 160, itemID = 3488,  spellID = 2740,    name = "Bronze Mace",                      colors = { y = 150, g = 160, r = 165 }, learnAt = 150 },
  { keep = 1, minSkill = 160, maxSkill = 170, itemID = 2871,  spellID = 2775,    name = "Solid Sharpening Stone",           colors = { y = 160, g = 170, r = 175 }, learnAt = 155, keepNote = "Used by Bronze Warhammer (2 each)." },
  { keep = 0, minSkill = 170, maxSkill = 180, itemID = 2870,  spellID = 2774,    name = "Solid Grinding Stone",             colors = { y = 170, g = 180, r = 185 }, learnAt = 165 },
  { keep = 0, minSkill = 180, maxSkill = 190, itemID = 2849,  spellID = 2669,    name = "Bronze Warhammer",                 colors = { y = 180, g = 190, r = 195 }, learnAt = 180 },
  { keep = 0, minSkill = 190, maxSkill = 200, itemID = 2850,  spellID = 2670,    name = "Bronze Greatsword",                colors = { y = 190, g = 200, r = 205 }, learnAt = 190 },
  { keep = 0, minSkill = 200, maxSkill = 210, itemID = 2851,  spellID = 2671,    name = "Bronze Greaves",                   colors = { y = 200, g = 210, r = 215 }, learnAt = 200 },
  { keep = 1, minSkill = 210, maxSkill = 220, itemID = 7964,  spellID = 9920,    name = "Solid Weightstone",                colors = { y = 210, g = 220, r = 225 }, learnAt = 205, keepNote = "Used by Iron Shield Spike (1 each)." },
  { keep = 0, minSkill = 220, maxSkill = 230, itemID = 3855,  spellID = 7221,    name = "Iron Shield Spike",                colors = { y = 220, g = 230, r = 235 }, learnAt = 220 },
  { keep = 0, minSkill = 230, maxSkill = 240, itemID = 3854,  spellID = 7220,    name = "Iron Counterweight",               colors = { y = 230, g = 240, r = 245 }, learnAt = 230 },
  { keep = 0, minSkill = 240, maxSkill = 250, itemID = 3850,  spellID = 7218,    name = "Golden Scale Coif",                colors = { y = 240, g = 250, r = 255 }, learnAt = 240 },
  { keep = 0, minSkill = 250, maxSkill = 260, itemID = 3849,  spellID = 7217,    name = "Golden Scale Cuirass",             colors = { y = 250, g = 260, r = 265 }, learnAt = 250 },
  { keep = 0, minSkill = 260, maxSkill = 270, itemID = 3853,  spellID = 7219,    name = "Golden Scale Shoulders",           colors = { y = 260, g = 270, r = 275 }, learnAt = 260 },
  { keep = 0, minSkill = 270, maxSkill = 280, itemID = 3852,  spellID = 7222,    name = "Golden Scale Leggings",            colors = { y = 270, g = 280, r = 285 }, learnAt = 270 },
  { keep = 0, minSkill = 280, maxSkill = 290, itemID = 3848,  spellID = 7216,    name = "Golden Scale Boots",               colors = { y = 280, g = 290, r = 295 }, learnAt = 280 },
  { keep = 0, minSkill = 290, maxSkill = 300, itemID = 3851,  spellID = 7215,    name = "Golden Scale Gauntlets",           colors = { y = 290, g = 300, r = 305 }, learnAt = 290 },
}