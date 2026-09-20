RGXProf.MistsPaths = RGXProf.MistsPaths or {}

RGXProf.MistsPaths.Jewelcrafting = {
 -- Classic
  { minSkill = 1, maxSkill = 35, name = "Delicate Copper Wire", itemID = 20816, spellID = 25255 },
  { minSkill = 35, maxSkill = 50, name = "Tigerseye Band", itemID = 25439, spellID = 32179 },
  { minSkill = 35, maxSkill = 50, name = "Malachite Pendant", alternate = true, itemID = 25438, spellID = 32178 },

  -- Journeyman
  { minSkill = 50, maxSkill = 80, name = "Bronze Setting", itemID = 20817, spellID = 25278 },
  { minSkill = 80, maxSkill = 100, name = "Gloom Band", itemID = 20823, spellID = 25287 },
  { minSkill = 80, maxSkill = 100, name = "Simple Pearl Ring", alternate = true, itemID = 20820, spellID = 25284, note = "or Ring of Silver Might" },

  { minSkill = 100, maxSkill = 110, name = "Ring of Twilight Shadows", itemID = 20828, spellID = 25318 },
  { minSkill = 100, maxSkill = 110, name = "Heavy Jade Ring", alternate = true, itemID = 30420, spellID = 36524 },

  { minSkill = 110, maxSkill = 120, name = "Heavy Stone Statue", itemID = 25881, spellID = 32807 },
  { minSkill = 120, maxSkill = 150, name = "Pendant of the Agate Shield", itemID = 20950, spellID = 25610 },
  { minSkill = 120, maxSkill = 150, name = "Amulet of the Moon", alternate = true, itemID = 20854, spellID = 25339 },

  -- Expert
  { minSkill = 150, maxSkill = 180, name = "Mithril Filigree", itemID = 20963, spellID = 25615 },
  { minSkill = 180, maxSkill = 185, name = "Solid Stone Statue", itemID = 25882, spellID = 32808 },
  { minSkill = 180, maxSkill = 185, name = "Blazing Citrine Ring", alternate = true, itemID = 20958, spellID = 25617 },

  { minSkill = 185, maxSkill = 210, name = "Engraved Truesilver Ring", itemID = 0, spellID = 25620 },
  { minSkill = 185, maxSkill = 210, name = "Citrine Ring of Rapid Healing", alternate = true, itemID = 0, spellID = 25621 },

  { minSkill = 210, maxSkill = 220, name = "Aquamarine Signet", itemID = 0, spellID = 26874 },
  { minSkill = 220, maxSkill = 225, name = "Aquamarine Pendant of the Warrior", itemID = 0, spellID = 26876 },

  -- Artisan
  { minSkill = 225, maxSkill = 250, name = "Thorium Setting", itemID = 0, spellID = 26880 },
  { minSkill = 250, maxSkill = 260, name = "Ruby Pendant of Fire", itemID = 0, spellID = 26883 },
  { minSkill = 260, maxSkill = 281, name = "Simple Opal Ring", itemID = 0, spellID = 26902 },
  { minSkill = 265, maxSkill = 281, name = "Diamond Focus Ring", alternate = true, itemID = 0, spellID = 36526},
  { minSkill = 281, maxSkill = 295, name = "Diamond Focus Ring", itemID = 0, spellID = 36526 },
  { minSkill = 295, maxSkill = 300, name = "Emerald Lion Ring", itemID = 0, spellID = 34961, note="or Sapphire Pendant of Winter Night"},
  { minSkill = 295, maxSkill = 300, name = "Onslaught Ring", alternate = true, itemID = 0, spellID = 26907, note="or Glowing Thorium Band" },

  -- Master (Outland)
  { minSkill = 300, maxSkill = 320, name = "Timeless Shadow Draenite", itemID = 23108, spellID = 28925, note="or Radiant Deep Peridot" },
  { minSkill = 300, maxSkill = 320, name = "Inscribed Flame Spessarite", itemID = 23098, spellID = 28910, note="or Solid Azure Moonstone", alternate = true },
  { minSkill = 320, maxSkill = 325, name = "Glinting Shadow Draenite", itemID = 23100, spellID = 28914, note="or Jagged Deep Peridot" },
  { minSkill = 320, maxSkill = 325, name = "Delicate Blood Garnet", itemID = 28595, spellID = 34590, note="or Sparkling Azure Moonstone", alternate = true },
  { minSkill = 325, maxSkill = 335, name = "Mercurial Adamantite", itemID = 31079, spellID = 38068 },
  { minSkill = 335, maxSkill = 340, name = "Rigid Azure Moonstone", itemID = 23116, spellID = 28948, note = "or Soverign Shadow Draenite" },
  { minSkill = 335, maxSkill = 340, name = "Potent Flame Spessarite", itemID = 23101, spellID = 28915, npcs = {21655}, note="requires friendly lower city rep", alternate = true },
  { minSkill = 340, maxSkill = 350, name = "Heavy Adamantite Ring", itemID = 24078, spellID = 31052 },

  -- Grand Master (WotLK)
  { minSkill = 350, maxSkill = 395, name = "Bold Bloodstone", itemID = 39900, spellID = 53831, note="or any uncomment Northrend gems" },
  { minSkill = 350, maxSkill = 395, name = "Rigid Chalcedony", itemID = 39915, spellID = 53854, note="or any uncomment Northrend gems", alternate = true },
  { minSkill = 395, maxSkill = 400, name = "Bloodstone Band", itemID = 42336, spellID = 56193, note="or sun rock ring" },  
  { minSkill = 395, maxSkill = 400, name = "Crystal Chalcedony Amulet", alternate = true, itemID = 43245, spellID = 58142, note="or crystal citrine necklace" },

  { minSkill = 400, maxSkill = 420, name = "Stoneguard Band", itemID = 43248, spellID = 58145 },
  { minSkill = 400, maxSkill = 420, name = "Shadowmight Ring", alternate = true, itemID = 43249, spellID = 58146 },
  { minSkill = 420, maxSkill = 425, name = "Dream Signet", itemID = 42340, spellID = 56197 },

  -- Illustrious (Cataclysm)
  { minSkill = 420, maxSkill = 467, name = "Jasper Ring", itemID = 52306, spellID = 73494, note="or other uncommon Cata gems but avoid avoid using Nightstone and Hessonite" },
  { minSkill = 467, maxSkill = 475, name = "Hessonite Band", itemID = 52308, spellID = 73495 },
  { minSkill = 467, maxSkill = 475, name = "Carnelian Spikes", alternate = true, itemID = 52492, spellID = 73620 },
  { minSkill = 475, maxSkill = 500, name = "Nightstone Choker", itemID = 52309, spellID = 73497 },
  { minSkill = 490, maxSkill = 500, name = "The Perforator", alternate = true, itemID = 52493, spellID = 73621 },

  -- MoP
  { minSkill = 500, maxSkill = 527, name = "Ornate Band", itemID = 83793, spellID = 122661 },
  { minSkill = 512, maxSkill = 527, name = "Shadowfire Necklace", itemID = 83794, spellID = 122662 },
  { minSkill = 527, maxSkill = 575, name = "Defender's Roguestone", note = "MoP Rings/Necks or Gem Cuts", itemID = 76558, spellID = 107628 },
  { minSkill = 575, maxSkill = 585, name = "Assassin's Roguestone", note = "Uncommon Gem Cuts x 20", itemID = 89678, spellID = 130656 },
  { minSkill = 585, maxSkill = 588, name = "Primordial Ruby", note = "or other MoP Gem Research", itemID = 90401, spellID = 131686 },
  { minSkill = 588, maxSkill = 600, name = "Bold Primordial Ruby", note = "or other Rare Gem Cuts", itemID = 76696, spellID = 107705 },
}
