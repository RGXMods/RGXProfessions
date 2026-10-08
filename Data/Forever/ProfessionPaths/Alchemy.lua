RGXProf.ForeverPaths = RGXProf.ForeverPaths or {}

-- WoW Forever Alchemy 1-300. Beta data 2026-09-23 (source:
-- wowsod.pro/wow-forever/professions/alchemy, mined from the beta client).
-- Forever changed the skill-up economy: many old recipes grey 25-35 points
-- sooner than Classic. Train ranks at skill 50/125/200.
RGXProf.ForeverPaths.Alchemy = {
  { keep = 0, minSkill = 1,   maxSkill = 50,  itemID = 2449,  spellID = 2329,    name = "Minor Healing Potion",             colors = { y = 35,  g = 50,  r = 65 }, learnAt = 1 },
  { keep = 1, minSkill = 50,  maxSkill = 65,  itemID = 2581,  spellID = 2330,    name = "Minor Rejuvenation Potion",        colors = { y = 55,  g = 65,  r = 75 }, learnAt = 35, keepNote = "Used by Lesser Healing Potion (1 each)." },
  { keep = 0, minSkill = 65,  maxSkill = 75,  itemID = 2455,  spellID = 2331,    name = "Minor Mana Potion",                colors = { y = 70,  g = 75,  r = 80 }, learnAt = 50 },
  { keep = 0, minSkill = 75,  maxSkill = 90,  itemID = 858,   spellID = 3273,    name = "Lesser Healing Potion",            colors = { y = 80,  g = 90,  r = 95 }, learnAt = 55 },
  { keep = 1, minSkill = 90,  maxSkill = 100, itemID = 3826,  spellID = 3448,    name = "Weak Troll's Blood Potion",        colors = { y = 95,  g = 100, r = 105 }, learnAt = 85, keepNote = "Used by Elixir of Minor Defense (1 each)." },
  { keep = 0, minSkill = 100, maxSkill = 110, itemID = 3382,  spellID = 3170,    name = "Elixir of Minor Defense",          colors = { y = 100, g = 110, r = 115 }, learnAt = 95 },
  { keep = 1, minSkill = 110, maxSkill = 120, itemID = 2454,  spellID = 3171,    name = "Elixir of Minor Fortitude",        colors = { y = 110, g = 120, r = 125 }, learnAt = 105, keepNote = "Used by Elixir of Wisdom (1 each)." },
  { keep = 0, minSkill = 120, maxSkill = 130, itemID = 2457,  spellID = 3172,    name = "Elixir of Wisdom",                 colors = { y = 120, g = 130, r = 135 }, learnAt = 115 },
  { keep = 0, minSkill = 130, maxSkill = 140, itemID = 3388,  spellID = 3173,    name = "Strong Troll's Blood Potion",      colors = { y = 130, g = 140, r = 145 }, learnAt = 125 },
  { keep = 0, minSkill = 140, maxSkill = 150, itemID = 2459,  spellID = 3174,    name = "Swiftness Potion",                 colors = { y = 140, g = 150, r = 155 }, learnAt = 135 },
  { keep = 1, minSkill = 150, maxSkill = 160, itemID = 2458,  spellID = 3175,    name = "Lesser Invisibility Potion",       colors = { y = 150, g = 160, r = 165 }, learnAt = 145, keepNote = "Used by Elixir of Giant Growth (1 each)." },
  { keep = 0, minSkill = 160, maxSkill = 170, itemID = 3827,  spellID = 3453,    name = "Elixir of Giant Growth",           colors = { y = 160, g = 170, r = 175 }, learnAt = 155 },
  { keep = 0, minSkill = 170, maxSkill = 180, itemID = 2456,  spellID = 3176,    name = "Elixir of Minor Agility",          colors = { y = 170, g = 180, r = 185 }, learnAt = 165 },
  { keep = 1, minSkill = 180, maxSkill = 190, itemID = 3823,  spellID = 3450,    name = "Elixir of Minor Fortitude",        colors = { y = 180, g = 190, r = 195 }, learnAt = 175, keepNote = "Used by Greater Healing Potion (1 each)." },
  { keep = 0, minSkill = 190, maxSkill = 200, itemID = 3385,  spellID = 7181,    name = "Greater Healing Potion",           colors = { y = 190, g = 200, r = 205 }, learnAt = 185 },
  { keep = 0, minSkill = 200, maxSkill = 210, itemID = 3825,  spellID = 3451,    name = "Elixir of Defense",                colors = { y = 200, g = 210, r = 215 }, learnAt = 195 },
  { keep = 0, minSkill = 210, maxSkill = 220, itemID = 6049,  spellID = 7257,    name = "Fire Protection Potion",           colors = { y = 210, g = 220, r = 225 }, learnAt = 205 },
  { keep = 0, minSkill = 220, maxSkill = 230, itemID = 6050,  spellID = 7258,    name = "Frost Protection Potion",          colors = { y = 220, g = 230, r = 235 }, learnAt = 215 },
  { keep = 0, minSkill = 230, maxSkill = 240, itemID = 6052,  spellID = 7259,    name = "Nature Protection Potion",         colors = { y = 230, g = 240, r = 245 }, learnAt = 225 },
  { keep = 0, minSkill = 240, maxSkill = 250, itemID = 6052,  spellID = 7259,    name = "Shadow Protection Potion",         colors = { y = 240, g = 250, r = 255 }, learnAt = 235 },
  { keep = 1, minSkill = 250, maxSkill = 260, itemID = 9144,  spellID = 11456,   name = "Wildvine Potion",                  colors = { y = 250, g = 260, r = 265 }, learnAt = 245, keepNote = "Used by Elixir of Detect Demon (1 each)." },
  { keep = 0, minSkill = 260, maxSkill = 270, itemID = 9154,  spellID = 11457,   name = "Elixir of Detect Demon",           colors = { y = 260, g = 270, r = 275 }, learnAt = 255 },
  { keep = 0, minSkill = 270, maxSkill = 280, itemID = 6048,  spellID = 7256,    name = "Shadow Oil",                       colors = { y = 270, g = 280, r = 285 }, learnAt = 265 },
  { keep = 1, minSkill = 280, maxSkill = 290, itemID = 8949,  spellID = 11452,   name = "Elixir of Agility",                colors = { y = 280, g = 290, r = 295 }, learnAt = 275, keepNote = "Used by Elixir of Greater Agility (1 each)." },
  { keep = 0, minSkill = 290, maxSkill = 300, itemID = 8951,  spellID = 11459,   name = "Elixir of Greater Agility",        colors = { y = 290, g = 300, r = 305 }, learnAt = 285 },
}