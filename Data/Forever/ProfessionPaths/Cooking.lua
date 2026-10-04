RGXProf.ForeverPaths = RGXProf.ForeverPaths or {}

-- WoW Forever Cooking 1-300. Beta data 2026-09-23 (source:
-- wowsod.pro/wow-forever/professions/cooking, mined from the beta client).
-- Forever changed the skill-up economy: most old recipes grey 25-35 points
-- sooner than Classic. Train ranks at skill 50/125/200.
RGXProf.ForeverPaths.Cooking = {
  { keep = 0, minSkill = 1,   maxSkill = 40,  itemID = 2680,  spellID = 2538,    name = "Spiced Wolf Meat",                 colors = { y = 25,  g = 40,  r = 55 }, learnAt = 1 },
  { keep = 0, minSkill = 40,  maxSkill = 60,  itemID = 2681,  spellID = 2540,    name = "Roasted Boar Meat",                colors = { y = 50,  g = 60,  r = 70 }, learnAt = 30 },
  { keep = 0, minSkill = 60,  maxSkill = 80,  itemID = 3726,  spellID = 3376,    name = "Charred Wolf Meat",                colors = { y = 70,  g = 80,  r = 85 }, learnAt = 55 },
  { keep = 0, minSkill = 80,  maxSkill = 100, itemID = 2682,  spellID = 2541,    name = "Cooked Crab Claw",                 colors = { y = 90,  g = 100, r = 105 }, learnAt = 75 },
  { keep = 0, minSkill = 100, maxSkill = 115, itemID = 2683,  spellID = 2542,    name = "Cooked Bigmouth Bass",             colors = { y = 105, g = 115, r = 120 }, learnAt = 95 },
  { keep = 0, minSkill = 115, maxSkill = 125, itemID = 5477,  spellID = 6413,    name = "Strider Stew",                     colors = { y = 120, g = 125, r = 130 }, learnAt = 110 },
  { keep = 0, minSkill = 125, maxSkill = 135, itemID = 5472,  spellID = 6414,    name = "Kaldorei Spider Kabob",            colors = { y = 130, g = 135, r = 140 }, learnAt = 120 },
  { keep = 0, minSkill = 135, maxSkill = 150, itemID = 5476,  spellID = 6415,    name = "Roasted Kodo Meat",                colors = { y = 140, g = 150, r = 155 }, learnAt = 130 },
  { keep = 1, minSkill = 150, maxSkill = 160, itemID = 5479,  spellID = 6416,    name = "Scorpid Surprise",                 colors = { y = 155, g = 160, r = 165 }, learnAt = 145, keepNote = "Used by Heavy Kodo Stew (1 each)." },
  { keep = 0, minSkill = 160, maxSkill = 170, itemID = 5479,  spellID = 6417,    name = "Heavy Kodo Stew",                  colors = { y = 165, g = 170, r = 175 }, learnAt = 155 },
  { keep = 0, minSkill = 170, maxSkill = 180, itemID = 12212, spellID = 15863,   name = "Giant Clam Scorcho",               colors = { y = 175, g = 180, r = 185 }, learnAt = 165 },
  { keep = 0, minSkill = 180, maxSkill = 190, itemID = 12210, spellID = 15855,   name = "Roast Raptor",                     colors = { y = 185, g = 190, r = 195 }, learnAt = 175 },
  { keep = 0, minSkill = 190, maxSkill = 200, itemID = 12213, spellID = 15861,   name = "Monster Omelet",                   colors = { y = 195, g = 200, r = 205 }, learnAt = 185 },
  { keep = 0, minSkill = 200, maxSkill = 210, itemID = 12216, spellID = 15856,   name = "Sanctified Solar Spiced Sausage",    colors = { y = 205, g = 210, r = 215 }, learnAt = 195 },
  { keep = 0, minSkill = 210, maxSkill = 220, itemID = 12224, spellID = 15852,   name = "Mystery Stew",                     colors = { y = 215, g = 220, r = 225 }, learnAt = 205 },
  { keep = 0, minSkill = 220, maxSkill = 230, itemID = 12208, spellID = 15853,   name = "Heavy Crocolisk Stew",             colors = { y = 225, g = 230, r = 235 }, learnAt = 215 },
  { keep = 1, minSkill = 230, maxSkill = 240, itemID = 13935, spellID = 18238,   name = "Baked Salmon",                     colors = { y = 235, g = 240, r = 245 }, learnAt = 225, keepNote = "Used by Lobster Stew (1 each)." },
  { keep = 0, minSkill = 240, maxSkill = 250, itemID = 13928, spellID = 18240,   name = "Lobster Stew",                     colors = { y = 245, g = 250, r = 255 }, learnAt = 235 },
  { keep = 0, minSkill = 250, maxSkill = 260, itemID = 13934, spellID = 18242,   name = "Mightfish Steak",                  colors = { y = 255, g = 260, r = 265 }, learnAt = 245 },
  { keep = 0, minSkill = 260, maxSkill = 270, itemID = 13930, spellID = 18241,   name = "Filet of Redgill",                 colors = { y = 265, g = 270, r = 275 }, learnAt = 255 },
  { keep = 1, minSkill = 270, maxSkill = 280, itemID = 13931, spellID = 18243,   name = "Poached Sunscale Salmon",          colors = { y = 275, g = 280, r = 285 }, learnAt = 265, keepNote = "Used by Lobster Stew (1 each)." },
  { keep = 0, minSkill = 280, maxSkill = 290, itemID = 13933, spellID = 18244,   name = "Lobster Stew",                     colors = { y = 285, g = 290, r = 295 }, learnAt = 275 },
  { keep = 0, minSkill = 290, maxSkill = 300, itemID = 13927, spellID = 18239,   name = "Cooked Glossy Mightfish",          colors = { y = 295, g = 300, r = 305 }, learnAt = 285 },
}