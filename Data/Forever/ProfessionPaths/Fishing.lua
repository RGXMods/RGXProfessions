RGXProf.ForeverPaths = RGXProf.ForeverPaths or {}

-- WoW Forever Fishing 1-300. Beta data 2026-09-23 (source:
-- wowsod.pro/wow-forever/professions/fishing, mined from the beta client).
-- Forever changed the skill-up economy: skill gains from fishing pools are
-- unchanged, but open water fishing greys 25-35 points sooner than Classic.
-- Train ranks at skill 50/125/200.
RGXProf.ForeverPaths.Fishing = {
  { keep = 0, minSkill = 1,   maxSkill = 50,  itemID = 6291,  spellID = 7620,    name = "Raw Brilliant Smallfish",          colors = { y = 35,  g = 50,  r = 65 }, learnAt = 1 },
  { keep = 0, minSkill = 50,  maxSkill = 75,  itemID = 6303,  spellID = 7731,    name = "Raw Slitherskin Mackerel",         colors = { y = 60,  g = 75,  r = 90 }, learnAt = 40 },
  { keep = 0, minSkill = 75,  maxSkill = 100, itemID = 6317,  spellID = 7732,    name = "Raw Loch Frenzy",                  colors = { y = 85,  g = 100, r = 115 }, learnAt = 70 },
  { keep = 0, minSkill = 100, maxSkill = 125, itemID = 6361,  spellID = 7733,    name = "Raw Rainbow Fin Albacore",         colors = { y = 110, g = 125, r = 140 }, learnAt = 95 },
  { keep = 0, minSkill = 125, maxSkill = 150, itemID = 13422, spellID = 18247,   name = "Stonescale Eel",                   colors = { y = 140, g = 150, r = 160 }, learnAt = 120 },
  { keep = 0, minSkill = 150, maxSkill = 175, itemID = 13754, spellID = 18248,   name = "Raw Glossy Mightfish",             colors = { y = 165, g = 175, r = 185 }, learnAt = 145 },
  { keep = 0, minSkill = 175, maxSkill = 200, itemID = 13889, spellID = 18249,   name = "Raw Whitescale Salmon",            colors = { y = 190, g = 200, r = 210 }, learnAt = 170 },
  { keep = 0, minSkill = 200, maxSkill = 225, itemID = 13893, spellID = 18250,   name = "Raw Sunscale Salmon",              colors = { y = 215, g = 225, r = 235 }, learnAt = 195 },
  { keep = 0, minSkill = 225, maxSkill = 250, itemID = 13888, spellID = 18251,   name = "Darkclaw Lobster",                 colors = { y = 235, g = 250, r = 260 }, learnAt = 220 },
  { keep = 0, minSkill = 250, maxSkill = 275, itemID = 13891, spellID = 18252,   name = "Raw Sagefish",                     colors = { y = 265, g = 275, r = 285 }, learnAt = 245 },
  { keep = 0, minSkill = 275, maxSkill = 300, itemID = 13892, spellID = 18253,   name = "Raw Greater Sagefish",             colors = { y = 290, g = 300, r = 305 }, learnAt = 270 },
}