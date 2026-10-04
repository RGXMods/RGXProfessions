RGXProf.ForeverPaths = RGXProf.ForeverPaths or {}

-- WoW Forever Leatherworking 1-300. Beta data 2026-09-23 (source:
-- wowsod.pro/wow-forever/professions/leatherworking, mined from the beta client).
-- Forever changed the skill-up economy: most old recipes grey 25-35 points
-- sooner than Classic. Train ranks at skill 50/125/200.
RGXProf.ForeverPaths.Leatherworking = {
  { keep = 0, minSkill = 1,   maxSkill = 25,  itemID = 2318,  spellID = 2149,    name = "Light Leather",                    colors = { y = 15,  g = 25,  r = 35 }, learnAt = 1 },
  { keep = 1, minSkill = 25,  maxSkill = 50,  itemID = 4231,  spellID = 2152,    name = "Light Armor Kit",                  colors = { y = 40,  g = 55,  r = 65 }, learnAt = 15, keepNote = "Used by Handstitched Leather Vest (2 each)." },
  { keep = 0, minSkill = 50,  maxSkill = 60,  itemID = 2319,  spellID = 2153,    name = "Handstitched Leather Vest",        colors = { y = 55,  g = 65,  r = 75 }, learnAt = 30 },
  { keep = 0, minSkill = 60,  maxSkill = 70,  itemID = 2311,  spellID = 2154,    name = "Light Armor Kit",                  colors = { y = 65,  g = 75,  r = 80 }, learnAt = 50 },
  { keep = 0, minSkill = 70,  maxSkill = 80,  itemID = 2309,  spellID = 2155,    name = "Embossed Leather Vest",            colors = { y = 75,  g = 85,  r = 90 }, learnAt = 65 },
  { keep = 1, minSkill = 80,  maxSkill = 90,  itemID = 4232,  spellID = 2156,    name = "Medium Armor Kit",                 colors = { y = 85,  g = 90,  r = 95 }, learnAt = 75, keepNote = "Used by Embossed Leather Gloves (2 each)." },
  { keep = 0, minSkill = 90,  maxSkill = 100, itemID = 4238,  spellID = 2158,    name = "Embossed Leather Gloves",          colors = { y = 90,  g = 100, r = 105 }, learnAt = 85 },
  { keep = 0, minSkill = 100, maxSkill = 110, itemID = 2307,  spellID = 2159,    name = "Fine Leather Belt",                colors = { y = 100, g = 110, r = 115 }, learnAt = 95 },
  { keep = 0, minSkill = 110, maxSkill = 120, itemID = 2304,  spellID = 2160,    name = "Fine Leather Gloves",              colors = { y = 110, g = 120, r = 120 }, learnAt = 105 },
  { keep = 1, minSkill = 120, maxSkill = 130, itemID = 4289,  spellID = 3753,    name = "Heavy Armor Kit",                  colors = { y = 120, g = 130, r = 135 }, learnAt = 115, keepNote = "Used by Fine Leather Belt (2 each)." },
  { keep = 0, minSkill = 130, maxSkill = 140, itemID = 4239,  spellID = 2161,    name = "Hillman's Leather Vest",           colors = { y = 130, g = 140, r = 145 }, learnAt = 125 },
  { keep = 0, minSkill = 140, maxSkill = 150, itemID = 2302,  spellID = 2162,    name = "Handstitched Leather Cloak",       colors = { y = 140, g = 150, r = 155 }, learnAt = 135 },
  { keep = 0, minSkill = 150, maxSkill = 160, itemID = 4240,  spellID = 2163,    name = "Hillman's Leather Gloves",         colors = { y = 150, g = 160, r = 155 }, learnAt = 145 },
  { keep = 1, minSkill = 160, maxSkill = 170, itemID = 4265,  spellID = 2164,    name = "Heavy Armor Kit",                  colors = { y = 160, g = 170, r = 175 }, learnAt = 155, keepNote = "Used by Toughened Leather Armor (2 each)." },
  { keep = 0, minSkill = 170, maxSkill = 180, itemID = 4241,  spellID = 2165,    name = "Toughened Leather Armor",          colors = { y = 170, g = 180, r = 185 }, learnAt = 165 },
  { keep = 0, minSkill = 180, maxSkill = 190, itemID = 4245,  spellID = 2166,    name = "Hillman's Cloak",                  colors = { y = 180, g = 190, r = 195 }, learnAt = 175 },
  { keep = 0, minSkill = 190, maxSkill = 200, itemID = 4244,  spellID = 2167,    name = "Fine Leather Tunic",               colors = { y = 190, g = 200, r = 205 }, learnAt = 190 },
  { keep = 1, minSkill = 200, maxSkill = 210, itemID = 4289,  spellID = 3753,    name = "Heavy Armor Kit",                  colors = { y = 200, g = 210, r = 215 }, learnAt = 195, keepNote = "Used by Barbaric Belt (2 each)." },
  { keep = 0, minSkill = 210, maxSkill = 220, itemID = 4247,  spellID = 2168,    name = "Barbaric Belt",                    colors = { y = 210, g = 220, r = 225 }, learnAt = 205 },
  { keep = 0, minSkill = 220, maxSkill = 230, itemID = 4246,  spellID = 2169,    name = "Dark Leather Belt",                colors = { y = 220, g = 230, r = 235 }, learnAt = 215 },
  { keep = 0, minSkill = 230, maxSkill = 240, itemID = 4254,  spellID = 2172,    name = "Barbaric Gloves",                  colors = { y = 230, g = 240, r = 245 }, learnAt = 225 },
  { keep = 0, minSkill = 240, maxSkill = 250, itemID = 4252,  spellID = 2173,    name = "Dark Leather Boots",               colors = { y = 240, g = 250, r = 255 }, learnAt = 235 },
  { keep = 0, minSkill = 250, maxSkill = 260, itemID = 4256,  spellID = 2174,    name = "Dark Leather Cloak",               colors = { y = 250, g = 260, r = 265 }, learnAt = 245 },
  { keep = 0, minSkill = 260, maxSkill = 270, itemID = 4255,  spellID = 2175,    name = "Green Leather Armor",              colors = { y = 260, g = 270, r = 275 }, learnAt = 255 },
  { keep = 0, minSkill = 270, maxSkill = 280, itemID = 4250,  spellID = 2176,    name = "Guardian Armor Kit",               colors = { y = 270, g = 280, r = 285 }, learnAt = 265 },
  { keep = 0, minSkill = 280, maxSkill = 290, itemID = 4248,  spellID = 2177,    name = "Dark Leather Gloves",              colors = { y = 280, g = 290, r = 295 }, learnAt = 275 },
  { keep = 0, minSkill = 290, maxSkill = 300, itemID = 4251,  spellID = 2178,    name = "Green Leather Belt",               colors = { y = 290, g = 300, r = 305 }, learnAt = 285 },
}