RGXProf.ForeverPaths = RGXProf.ForeverPaths or {}

-- WoW Forever Engineering 1-300. Beta data (source:
-- wowsod.pro/wow-forever/professions/engineering, mined from the beta
-- client). Skill-up colors are unchanged from Classic on every Engineering
-- recipe, but reagent costs moved (Rough Dynamite needs one powder, EZ-Thro
-- Dynamite takes new vendor parts), so this route shares its shape with
-- Classic while carrying its own beta color numbers inline. The blasting
-- powders are keep=1 intermediates: craft them in full while they still
-- give skill and bank them for the bombs and ammunition later.
RGXProf.ForeverPaths.Engineering = {
  { keep = 1, minSkill = 1,   maxSkill = 39,  itemID = 4357,  spellID = 3918,    name = "Rough Blasting Powder",         colors = { y = 20,  g = 30,  r = 40 }, learnAt = 1, keepNote = "Used by Rough Copper Bomb (1 each)." },
  { keep = 0, minSkill = 39,  maxSkill = 75,  itemID = 4360,  spellID = 3923,    name = "Rough Copper Bomb",            colors = { y = 60,  g = 75,  r = 90 }, learnAt = 30 },
  { keep = 1, minSkill = 75,  maxSkill = 95,  itemID = 4364,  spellID = 3929,    name = "Coarse Blasting Powder",        colors = { y = 85,  g = 90,  r = 95 }, learnAt = 75 },
  { keep = 0, minSkill = 95,  maxSkill = 125, itemID = 4404,  spellID = 3973,    name = "Silver Contact",               colors = { y = 110, g = 125, r = 140 }, learnAt = 90 },
  { keep = 1, minSkill = 125, maxSkill = 145, itemID = 4377,  spellID = 3945,    name = "Heavy Blasting Powder",        colors = { y = 125, g = 135, r = 145 }, learnAt = 125 },
  { keep = 1, minSkill = 145, maxSkill = 175, itemID = 4382,  spellID = 3953,    name = "Bronze Framework",             colors = { y = 145, g = 170, r = 195 }, learnAt = 145 },
  { keep = 1, minSkill = 175, maxSkill = 193, itemID = 10505, spellID = 12585,   name = "Solid Blasting Powder",        colors = { y = 175, g = 185, r = 195 }, learnAt = 175, keepNote = "Banked for Hi-Impact Mithril Slugs and Mithril Gyro-Shot.", note = "Craft all of it while it gives skill - banked for slugs and gyro-shot." },
  { keep = 0, minSkill = 193, maxSkill = 200, spellID = 3967,                    name = "Big Iron Bomb",                colors = { y = 190, g = 210, r = 230 }, learnAt = 190 },
  { keep = 1, minSkill = 200, maxSkill = 210, itemID = 10560, spellID = 12591,   name = "Unstable Trigger",             colors = { y = 200, g = 220, r = 240 }, learnAt = 200 },
  { keep = 0, minSkill = 210, maxSkill = 245, spellID = 12596,                   name = "Hi-Impact Mithril Slugs",      colors = { y = 210, g = 230, r = 250 }, learnAt = 210 },
  { keep = 0, minSkill = 245, maxSkill = 275, spellID = 12621,                   name = "Mithril Gyro-Shot",            colors = { y = 245, g = 265, r = 285 }, learnAt = 245 },
  { keep = 0, minSkill = 275, maxSkill = 282, spellID = 1319163,                 name = "Large Purple Rocket Cluster",  colors = { y = 275, g = 280, r = 285 }, learnAt = 275, note = "New in Forever beta - acquisition not confirmed." },
  { keep = 0, minSkill = 282, maxSkill = 300, itemID = 16000, spellID = 19795,   name = "Thorium Tube",                 colors = { y = 295, g = 305, r = 315 }, learnAt = 275, note = "Vendor pattern - buy the schematic before reaching 275." },
}
