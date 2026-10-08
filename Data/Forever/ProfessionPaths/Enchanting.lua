RGXProf.ForeverPaths = RGXProf.ForeverPaths or {}

-- WoW Forever Enchanting 1-300. Beta data 2026-09-23 (source:
-- wowsod.pro/wow-forever/professions/enchanting, mined from the beta client).
-- Forever changed the skill-up economy: most old recipes grey 25-35 points
-- sooner than Classic. Train ranks at skill 50/125/200.
RGXProf.ForeverPaths.Enchanting = {
  { keep = 1, minSkill = 1,   maxSkill = 25,  itemID = 6217,  spellID = 7418,    name = "Runed Copper Rod",                 colors = { y = 15,  g = 25,  r = 35 }, learnAt = 1, keepNote = "Required for all enchanting; keep equipped." },
  { keep = 0, minSkill = 25,  maxSkill = 50,  itemID = 6218,  spellID = 7420,    name = "Runed Silver Rod",                 colors = { y = 40,  g = 50,  r = 60 }, learnAt = 15, keepNote = "Required for higher enchants; keep equipped." },
  { keep = 1, minSkill = 50,  maxSkill = 70,  itemID = 11082, spellID = 13378,   name = "Greater Magic Essence",            colors = { y = 55,  g = 70,  r = 80 }, learnAt = 40, keepNote = "Used by Lesser Magic Wand (1 each)." },
  { keep = 0, minSkill = 70,  maxSkill = 80,  itemID = 11083, spellID = 13379,   name = "Lesser Magic Wand",                colors = { y = 75,  g = 80,  r = 85 }, learnAt = 60 },
  { keep = 1, minSkill = 80,  maxSkill = 90,  itemID = 11084, spellID = 13380,   name = "Greater Magic Essence",            colors = { y = 85,  g = 90,  r = 95 }, learnAt = 75, keepNote = "Used by Greater Magic Wand (1 each)." },
  { keep = 0, minSkill = 90,  maxSkill = 100, itemID = 11085, spellID = 13381,   name = "Greater Magic Wand",               colors = { y = 95,  g = 100, r = 105 }, learnAt = 85 },
  { keep = 1, minSkill = 100, maxSkill = 110, itemID = 11134, spellID = 13607,   name = "Lesser Mystic Essence",            colors = { y = 105, g = 110, r = 115 }, learnAt = 95, keepNote = "Used by Lesser Mystic Wand (1 each)." },
  { keep = 0, minSkill = 110, maxSkill = 120, itemID = 11137, spellID = 13609,   name = "Lesser Mystic Wand",             colors = { y = 115, g = 120, r = 125 }, learnAt = 105 },
  { keep = 1, minSkill = 120, maxSkill = 130, itemID = 11138, spellID = 13612,   name = "Greater Mystic Essence",           colors = { y = 125, g = 130, r = 135 }, learnAt = 115, keepNote = "Used by Greater Mystic Wand (1 each)." },
  { keep = 0, minSkill = 130, maxSkill = 140, itemID = 11139, spellID = 13617,   name = "Greater Mystic Wand",            colors = { y = 135, g = 140, r = 145 }, learnAt = 125 },
  { keep = 1, minSkill = 140, maxSkill = 150, itemID = 11174, spellID = 13622,   name = "Lesser Nether Essence",            colors = { y = 145, g = 150, r = 155 }, learnAt = 135, keepNote = "Used by Lesser Nether Wand (1 each)." },
  { keep = 0, minSkill = 150, maxSkill = 160, itemID = 11175, spellID = 13628,   name = "Lesser Nether Wand",             colors = { y = 155, g = 160, r = 165 }, learnAt = 145 },
  { keep = 1, minSkill = 160, maxSkill = 165, itemID = 11176, spellID = 13631,   name = "Greater Nether Essence",           colors = { y = 160, g = 165, r = 170 }, learnAt = 155, keepNote = "Used by Greater Nether Wand (1 each)." },
  { keep = 0, minSkill = 165, maxSkill = 175, itemID = 11177, spellID = 13635,   name = "Greater Nether Wand",            colors = { y = 170, g = 175, r = 180 }, learnAt = 160 },
  { keep = 1, minSkill = 175, maxSkill = 185, itemID = 11178, spellID = 13637,   name = "Large Radiant Shard",              colors = { y = 180, g = 185, r = 190 }, learnAt = 170, keepNote = "Used by Runed Truesilver Rod (1 each)." },
  { keep = 0, minSkill = 185, maxSkill = 195, itemID = 11130, spellID = 13602,   name = "Runed Truesilver Rod",             colors = { y = 190, g = 195, r = 200 }, learnAt = 180, keepNote = "Required for higher enchants; keep equipped." },
  { keep = 1, minSkill = 195, maxSkill = 205, itemID = 11178, spellID = 13637,   name = "Large Radiant Shard",              colors = { y = 200, g = 205, r = 210 }, learnAt = 190, keepNote = "Used by Enchant Weapon - Minor Striking (1 each)." },
  { keep = 0, minSkill = 205, maxSkill = 215, itemID = 11166, spellID = 13503,   name = "Enchant Weapon - Minor Striking",  colors = { y = 210, g = 215, r = 220 }, learnAt = 200 },
  { keep = 1, minSkill = 215, maxSkill = 225, itemID = 11178, spellID = 13637,   name = "Large Radiant Shard",              colors = { y = 220, g = 225, r = 230 }, learnAt = 210, keepNote = "Used by Enchant 2H Weapon - Impact (1 each)." },
  { keep = 0, minSkill = 225, maxSkill = 235, itemID = 11167, spellID = 13529,   name = "Enchant 2H Weapon - Impact",       colors = { y = 230, g = 235, r = 240 }, learnAt = 220 },
  { keep = 1, minSkill = 235, maxSkill = 245, itemID = 14343, spellID = 17728,   name = "Large Brilliant Shard",            colors = { y = 240, g = 245, r = 250 }, learnAt = 230, keepNote = "Used by Runed Arcanite Rod (1 each)." },
  { keep = 0, minSkill = 245, maxSkill = 255, itemID = 11145, spellID = 13702,   name = "Runed Arcanite Rod",               colors = { y = 250, g = 255, r = 260 }, learnAt = 240, keepNote = "Required for highest enchants; keep equipped." },
  { keep = 0, minSkill = 255, maxSkill = 265, itemID = 16202, spellID = 20011,   name = "Enchant Weapon - Icy Chill",       colors = { y = 260, g = 265, r = 270 }, learnAt = 250 },
  { keep = 1, minSkill = 265, maxSkill = 275, itemID = 14343, spellID = 17728,   name = "Large Brilliant Shard",            colors = { y = 270, g = 275, r = 280 }, learnAt = 260, keepNote = "Used by Enchant Weapon - Superior Striking (1 each)." },
  { keep = 0, minSkill = 275, maxSkill = 285, itemID = 16252, spellID = 20030,   name = "Enchant Weapon - Superior Striking",colors = { y = 280, g = 285, r = 290 }, learnAt = 270 },
  { keep = 1, minSkill = 285, maxSkill = 295, itemID = 14343, spellID = 17728,   name = "Large Brilliant Shard",            colors = { y = 290, g = 295, r = 300 }, learnAt = 280, keepNote = "Used by Enchant 2H Weapon - Major Impact (1 each)." },
  { keep = 0, minSkill = 295, maxSkill = 300, itemID = 16253, spellID = 20031,   name = "Enchant 2H Weapon - Major Impact", colors = { y = 300, g = 305, r = 310 }, learnAt = 290 },
}