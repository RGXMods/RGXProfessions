RGXProf.ForeverPaths = RGXProf.ForeverPaths or {}

-- WoW Forever Tailoring 1-300. Beta data 2026-09-23 (source:
-- wowsod.pro/wow-forever/professions/tailoring, mined from the beta client).
-- Forever changed the skill-up economy: bolts of Silk, Mageweave and
-- Runecloth give no skill, Bolt of Woolen Cloth greys at 85, and most older
-- recipes grey 25-35 points sooner than Classic, so this route shares few
-- ranges with the Classic path. Every step carries its own Forever
-- skill-up colors (yellow/green/grey) inline; the craft estimator reads
-- step.colors before the global spell table.
RGXProf.ForeverPaths.Tailoring = {
  { keep = 1, minSkill = 1,   maxSkill = 30,  itemID = 2996,  spellID = 2963,    name = "Bolt of Linen Cloth",              colors = { y = 25,  g = 37,  r = 50 }, learnAt = 1 },
  { keep = 0, minSkill = 30,  maxSkill = 78,  itemID = 7026,  spellID = 8776,    name = "Linen Belt",                       colors = { y = 50,  g = 67,  r = 85 }, learnAt = 15 },
  { keep = 0, minSkill = 78,  maxSkill = 110, itemID = 2580,  spellID = 2402,    name = "Woolen Cape",                      colors = { y = 80,  g = 97,  r = 115 }, learnAt = 55 },
  { keep = 0, minSkill = 110, maxSkill = 130, itemID = 4314,  spellID = 3848,    name = "Double-stitched Woolen Shoulders", colors = { y = 110, g = 127, r = 145 }, learnAt = 110 },
  { keep = 0, minSkill = 130, maxSkill = 145, spellID = 3852,                    name = "Gloves of Meditation",            colors = { y = 130, g = 140, r = 155 }, learnAt = 130 },
  { keep = 0, minSkill = 145, maxSkill = 150, spellID = 3854,                    name = "Azure Silk Gloves",                colors = { y = 145, g = 155, r = 170 }, learnAt = 145, note = "Vendor pattern - buy from a trade supplier." },
  { keep = 0, minSkill = 150, maxSkill = 165, spellID = 3813,                    name = "Small Silk Pack",                  colors = { y = 150, g = 160, r = 175 }, learnAt = 150 },
  { keep = 0, minSkill = 165, maxSkill = 170, spellID = 3857,                    name = "Enchanter's Cowl",                 colors = { y = 165, g = 165, r = 180 }, learnAt = 165, note = "Vendor pattern - buy from a trade supplier." },
  { keep = 0, minSkill = 170, maxSkill = 175, spellID = 8764,                    name = "Earthen Vest",                     colors = { y = 170, g = 170, r = 185 }, learnAt = 170 },
  { keep = 0, minSkill = 175, maxSkill = 185, spellID = 8786,                    name = "Azure Silk Cloak",                 colors = { y = 175, g = 175, r = 190 }, learnAt = 175, note = "Vendor pattern - buy from a trade supplier." },
  { keep = 0, minSkill = 185, maxSkill = 195, spellID = 3861,                    name = "Long Silken Cloak",                colors = { y = 185, g = 185, r = 200 }, learnAt = 185 },
  { keep = 0, minSkill = 195, maxSkill = 200, itemID = 7062,  spellID = 8799,    name = "Crimson Silk Pantaloons",         colors = { y = 195, g = 195, r = 200 }, learnAt = 195 },
  { keep = 0, minSkill = 200, maxSkill = 205, spellID = 3862,                    name = "Icy Cloak",                        colors = { y = 200, g = 200, r = 215 }, learnAt = 200, note = "Vendor pattern - buy from a trade supplier." },
  { keep = 0, minSkill = 205, maxSkill = 210, spellID = 12048,                   name = "Black Mageweave Vest",             colors = { y = 205, g = 205, r = 215 }, learnAt = 205 },
  { keep = 0, minSkill = 210, maxSkill = 215, spellID = 12050,                   name = "Black Mageweave Robe",             colors = { y = 210, g = 210, r = 220 }, learnAt = 210 },
  { keep = 0, minSkill = 215, maxSkill = 225, itemID = 10003, spellID = 12053,   name = "Black Mageweave Gloves",           colors = { y = 215, g = 215, r = 225 }, learnAt = 215 },
  { keep = 0, minSkill = 225, maxSkill = 230, spellID = 12065,                   name = "Mageweave Bag",                    colors = { y = 225, g = 225, r = 235 }, learnAt = 225 },
  { keep = 0, minSkill = 230, maxSkill = 235, itemID = 10024, spellID = 12072,   name = "Black Mageweave Headband",        colors = { y = 230, g = 230, r = 235 }, learnAt = 230 },
  { keep = 0, minSkill = 235, maxSkill = 240, spellID = 12079,                   name = "Red Mageweave Bag",                colors = { y = 235, g = 235, r = 240 }, learnAt = 235 },
  { keep = 0, minSkill = 240, maxSkill = 243, spellID = 12081,                   name = "Admiral's Hat",                    colors = { y = 240, g = 240, r = 245 }, learnAt = 240, note = "Vendor pattern - buy from a trade supplier." },
  { keep = 0, minSkill = 243, maxSkill = 255, spellID = 1257472,                 name = "Earthenweave Boots",              colors = { y = 240, g = 255, r = 270 }, learnAt = 240, note = "New in Forever beta - acquisition not confirmed." },
  { keep = 0, minSkill = 255, maxSkill = 260, spellID = 1257485,                 name = "Earthenweave Mantle",             colors = { y = 255, g = 270, r = 285 }, learnAt = 255, note = "New in Forever beta - acquisition not confirmed." },
  { keep = 0, minSkill = 260, maxSkill = 267, spellID = 1257488,                 name = "Earthenweave Leggings",           colors = { y = 260, g = 275, r = 290 }, learnAt = 260, note = "New in Forever beta - acquisition not confirmed." },
  { keep = 0, minSkill = 267, maxSkill = 270, spellID = 1257487,                 name = "Runecloth Cuffs",                 colors = { y = 265, g = 280, r = 295 }, learnAt = 265, note = "New in Forever beta - acquisition not confirmed." },
  { keep = 0, minSkill = 270, maxSkill = 285, spellID = 1257491,                 name = "Earthenweave Cuffs",              colors = { y = 270, g = 285, r = 300 }, learnAt = 270, note = "New in Forever beta - acquisition not confirmed." },
  { keep = 0, minSkill = 285, maxSkill = 296, spellID = 1257494,                 name = "Earthenweave Crown",              colors = { y = 275, g = 290, r = 305 }, learnAt = 275, note = "New in Forever beta - acquisition not confirmed." },
  { keep = 0, minSkill = 296, maxSkill = 300, spellID = 19435,                   name = "Mooncloth Boots",                  colors = { y = 290, g = 300, r = 315 }, learnAt = 290, note = "Quest reward pattern." },
}
