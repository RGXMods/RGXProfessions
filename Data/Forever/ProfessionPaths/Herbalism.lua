RGXProf.ForeverPaths = RGXProf.ForeverPaths or {}

-- WoW Forever Herbalism 1-300. Beta data 2026-09-23 (source:
-- wowsod.pro/wow-forever/professions/herbalism, mined from the beta client).
-- Forever changed the skill-up economy: herb nodes give 0 skill past their
-- optimal range 25-35 points sooner than Classic. Train ranks at skill 50/125/200.
RGXProf.ForeverPaths.Herbalism = {
  { keep = 0, minSkill = 1,   maxSkill = 50,  itemID = 2447,  spellID = 2366,    name = "Peacebloom",                       colors = { y = 35,  g = 50,  r = 65 }, learnAt = 1 },
  { keep = 0, minSkill = 50,  maxSkill = 70,  itemID = 2449,  spellID = 2367,    name = "Silverleaf",                       colors = { y = 55,  g = 70,  r = 85 }, learnAt = 35 },
  { keep = 0, minSkill = 70,  maxSkill = 85,  itemID = 2450,  spellID = 2368,    name = "Briarthorn",                       colors = { y = 75,  g = 85,  r = 95 }, learnAt = 55 },
  { keep = 0, minSkill = 85,  maxSkill = 100, itemID = 2452,  spellID = 2369,    name = "Swiftthistle",                     colors = { y = 90,  g = 100, r = 110 }, learnAt = 70 },
  { keep = 0, minSkill = 100, maxSkill = 115, itemID = 2453,  spellID = 2370,    name = "Bruiseweed",                       colors = { y = 105, g = 115, r = 125 }, learnAt = 85 },
  { keep = 0, minSkill = 115, maxSkill = 130, itemID = 3355,  spellID = 2371,    name = "Wild Steelbloom",                  colors = { y = 120, g = 130, r = 140 }, learnAt = 100 },
  { keep = 0, minSkill = 130, maxSkill = 145, itemID = 3356,  spellID = 2372,    name = "Kingsblood",                       colors = { y = 135, g = 145, r = 155 }, learnAt = 115 },
  { keep = 0, minSkill = 145, maxSkill = 160, itemID = 3357,  spellID = 2373,    name = "Liferoot",                         colors = { y = 150, g = 160, r = 170 }, learnAt = 130 },
  { keep = 0, minSkill = 160, maxSkill = 175, itemID = 3358,  spellID = 2374,    name = "Khadgar's Whisker",                colors = { y = 165, g = 175, r = 185 }, learnAt = 145 },
  { keep = 0, minSkill = 175, maxSkill = 190, itemID = 3818,  spellID = 2375,    name = "Fadeleaf",                         colors = { y = 180, g = 190, r = 200 }, learnAt = 160 },
  { keep = 0, minSkill = 190, maxSkill = 205, itemID = 3819,  spellID = 2376,    name = "Goldthorn",                        colors = { y = 195, g = 205, r = 215 }, learnAt = 175 },
  { keep = 0, minSkill = 205, maxSkill = 220, itemID = 3820,  spellID = 2377,    name = "Khadgar's Whisker",                colors = { y = 210, g = 220, r = 230 }, learnAt = 190 },
  { keep = 0, minSkill = 220, maxSkill = 235, itemID = 3821,  spellID = 2378,    name = "Wintersbite",                      colors = { y = 225, g = 235, r = 245 }, learnAt = 205 },
  { keep = 0, minSkill = 235, maxSkill = 250, itemID = 8831,  spellID = 2379,    name = "Purple Lotus",                     colors = { y = 240, g = 250, r = 260 }, learnAt = 220 },
  { keep = 0, minSkill = 250, maxSkill = 265, itemID = 8836,  spellID = 2380,    name = "Arthas' Tears",                    colors = { y = 255, g = 265, r = 275 }, learnAt = 235 },
  { keep = 0, minSkill = 265, maxSkill = 280, itemID = 8838,  spellID = 2381,    name = "Sungrass",                         colors = { y = 270, g = 280, r = 290 }, learnAt = 250 },
  { keep = 0, minSkill = 280, maxSkill = 295, itemID = 8839,  spellID = 2382,    name = "Blindweed",                        colors = { y = 285, g = 295, r = 305 }, learnAt = 265 },
  { keep = 0, minSkill = 295, maxSkill = 300, itemID = 8845,  spellID = 2383,    name = "Ghost Mushroom",                   colors = { y = 295, g = 300, r = 305 }, learnAt = 280 },
  { keep = 0, minSkill = 300, maxSkill = 300, itemID = 8846,  spellID = 2384,    name = "Gromsblood",                       colors = { y = 300, g = 305, r = 310 }, learnAt = 285 },
}