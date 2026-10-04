RGXProf.ForeverPaths = RGXProf.ForeverPaths or {}

-- WoW Forever Mining 1-300. Beta data 2026-09-23 (source:
-- wowsod.pro/wow-forever/professions/mining, mined from the beta client).
-- Forever changed the skill-up economy: mining nodes give 0 skill past their
-- optimal range 25-35 points sooner than Classic. Train ranks at skill 50/125/200.
RGXProf.ForeverPaths.Mining = {
  { keep = 0, minSkill = 1,   maxSkill = 50,  itemID = 2770,  spellID = 2580,    name = "Copper Ore",                       colors = { y = 35,  g = 50,  r = 65 }, learnAt = 1 },
  { keep = 1, minSkill = 50,  maxSkill = 65,  itemID = 2771,  spellID = 2656,    name = "Tin Ore",                          colors = { y = 55,  g = 65,  r = 75 }, learnAt = 35, keepNote = "Used by Bronze Bar (1:1 with Copper)." },
  { keep = 0, minSkill = 65,  maxSkill = 75,  itemID = 2772,  spellID = 2657,    name = "Iron Ore",                         colors = { y = 70,  g = 75,  r = 80 }, learnAt = 55 },
  { keep = 1, minSkill = 75,  maxSkill = 90,  itemID = 2772,  spellID = 2657,    name = "Iron Ore",                         colors = { y = 80,  g = 90,  r = 95 }, learnAt = 70, keepNote = "Used by Steel Bar (1:1 with Coal)." },
  { keep = 0, minSkill = 90,  maxSkill = 105, itemID = 2775,  spellID = 3304,    name = "Silver Ore",                       colors = { y = 95,  g = 105, r = 115 }, learnAt = 85 },
  { keep = 1, minSkill = 105, maxSkill = 120, itemID = 2775,  spellID = 3304,    name = "Silver Ore",                       colors = { y = 110, g = 120, r = 125 }, learnAt = 100, keepNote = "Used by Truesilver Bar (1:1 with Iron)." },
  { keep = 0, minSkill = 120, maxSkill = 135, itemID = 3858,  spellID = 10059,   name = "Mithril Ore",                      colors = { y = 125, g = 135, r = 145 }, learnAt = 115 },
  { keep = 1, minSkill = 135, maxSkill = 150, itemID = 3858,  spellID = 10059,   name = "Mithril Ore",                      colors = { y = 140, g = 150, r = 155 }, learnAt = 130, keepNote = "Used by Truesilver Bar (1:1 with Mithril)." },
  { keep = 0, minSkill = 150, maxSkill = 165, itemID = 7911,  spellID = 10060,   name = "Truesilver Ore",                   colors = { y = 155, g = 165, r = 175 }, learnAt = 145 },
  { keep = 1, minSkill = 165, maxSkill = 180, itemID = 7911,  spellID = 10060,   name = "Truesilver Ore",                   colors = { y = 170, g = 180, r = 185 }, learnAt = 160, keepNote = "Used by Thorium Bar (1:1 with Mithril)." },
  { keep = 0, minSkill = 180, maxSkill = 195, itemID = 10620, spellID = 10618,   name = "Thorium Ore",                      colors = { y = 185, g = 195, r = 205 }, learnAt = 175 },
  { keep = 1, minSkill = 195, maxSkill = 210, itemID = 10620, spellID = 10618,   name = "Thorium Ore",                      colors = { y = 200, g = 210, r = 215 }, learnAt = 190, keepNote = "Used by Arcanite Bar (1:1 with Arcane Crystal)." },
  { keep = 0, minSkill = 210, maxSkill = 225, itemID = 12364, spellID = 14004,   name = "Huge Emerald",                     colors = { y = 215, g = 225, r = 230 }, learnAt = 205 },
  { keep = 0, minSkill = 225, maxSkill = 240, itemID = 12365, spellID = 14005,   name = "Star Ruby",                        colors = { y = 230, g = 240, r = 245 }, learnAt = 220 },
  { keep = 0, minSkill = 240, maxSkill = 255, itemID = 12800, spellID = 14006,   name = "Azerothian Diamond",               colors = { y = 245, g = 255, r = 260 }, learnAt = 235 },
  { keep = 0, minSkill = 255, maxSkill = 270, itemID = 12363, spellID = 14007,   name = "Arcane Crystal",                   colors = { y = 260, g = 270, r = 280 }, learnAt = 250 },
  { keep = 0, minSkill = 270, maxSkill = 285, itemID = 12363, spellID = 14007,   name = "Arcane Crystal",                   colors = { y = 275, g = 285, r = 295 }, learnAt = 265, keepNote = "Used by Arcanite Bar (1:1 with Thorium)." },
  { keep = 0, minSkill = 285, maxSkill = 300, itemID = 12363, spellID = 14007,   name = "Arcane Crystal",                   colors = { y = 290, g = 300, r = 305 }, learnAt = 280 },
}