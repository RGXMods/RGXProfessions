RGXProf.ForeverNotes = RGXProf.ForeverNotes or {}

-- WoW Forever leveling data.
RGXProf.ForeverNotes[171] = { -- Alchemy
  tagline = "No more healing potions. Elixirs carry you instead.",
  summary = "Forever took the healing potion ladder away from Alchemy and handed it to First Aid, which kills the route every Classic guide uses. What is left is still the cheapest crafting profession to level: elixirs and mana potions from 1 to 232, two Detect draughts to 286, then Greater Dreamless Sleep from a vendor pattern to finish.",
  changes = {
    { text = "Minor through Major Healing Potion are gone from Alchemy and now sit in First Aid. Alchemy keeps a separate Discolored Healing Potion line that uses Murloc Eyes.", source = "Beta data" },
    { text = "Elixir of Minor Defense now takes Silverleaf, Peacebloom and a vial instead of two Silverleaf. It carries you from 1 to 90 on its own.", source = "Beta data" },
    { text = "Over 70 new recipes: Mender’s, Spellblasting and Frenzy potions, Cleric’s and Mageblood elixirs. Almost all of them start yellow and go grey five points later, so they are gear, not levelling recipes.", source = "Beta data" },
    { text = "Camp objects: Mana Well at 20, Fermenter at 140, Alchemy Laboratory at 300. The 300 one needs a Blueprint from a dungeon boss.", source = "Blizzard" },
  },
  tips = {
    "Buy vials in bulk from any alchemy supplier before you start. The route eats 210 Empty Vials, 80 Leaded and 84 Crystal.",
    "Stranglekelp is the herb people forget. You need 84 of it for the mana potions between 120 and 195, so pick it up while you are fishing or swimming past.",
    "Greater Dreamless Sleep Potion is a vendor pattern. Buy it before 275 so you are not stuck at 286.",
  },
  ranks = {
    "Journeyman unlocks at skill 50, Expert at 125 and Artisan at 200, each raising the cap by 75.",
    "Character level gates of 5, 10, 20 and 35 for the four ranks carry over from Classic. Beta players report Cooking reaching 150 before level 10, and a forum moderator called that a bug.",
    "Hitting 150, 225 and 300 in a profession each award a Legacy point the first time you do it on the account.",
  },
}
RGXProf.ForeverNotes[164] = { -- Blacksmithing
  tagline = "Every plan moved down 25 points. Bring a lot of bars.",
  summary = "Forever made Blacksmithing the hungriest route in the game. Plans, stones and weightstones all moved about 25 points down the skill ladder: you learn them sooner and they go grey sooner, and every stone past Rough only gives skill for 10 to 15 points. The route below still does 1 to 84 almost for free on Rough Stone. After that you are feeding bars into gear and selling what you can.",
  changes = {
    { text = "Coarse, Heavy, Solid and Dense stones are learned 25 points earlier than in Classic and go grey 10 to 15 points later. That is enough for Heavy Grinding Stone (100 to 121), Solid Sharpening Stone (175 to 185) and Dense Weightstone (225 to 235) to earn a place in the route.", source = "Beta data" },
    { text = "Rough Grinding Stone runs orange to 45 and grey at 85, which makes it the 35 to 84 recipe.", source = "Beta data" },
    { text = "Older plate and mail plans moved down about 25 points. Green Iron Bracers is learned at 140 and goes grey at 190, against 165 and 215 in Classic.", source = "Beta data" },
    { text = "New sets appear from Skyforged at 55 through Sterling Silver, Hard Gold and Shining Mithril to Blessed Plate at 260 to 300. Blizzard has not said whether trainers teach them or Merchant’s Favor buys them.", source = "Beta data" },
    { text = "Removed plans: Wildthorn Mail, Storm Gauntlets, Helm of the Great Chief, Invulnerable Mail and the Heavy Timbermaw Belt and Boots.", source = "Beta data" },
    { text = "Camp objects: Sharpening Wheel at 20 (an Attack Power buff), Anvil at 140, Master Forge at 300.", source = "Blizzard" },
  },
  tips = {
    "Take Mining with it. Buying 1,046 Thorium and 650 Mithril Bars on a launch auction house is how guilds go bankrupt.",
    "Ornate Mithril and Imperial Plate plans are quest rewards. Look the quests up before 225 and 265 so the plans are waiting when you get there.",
    "Keep the Blessed Plate and Imperial pieces you make: they vendor, disenchant or go on alts.",
  },
  ranks = {
    "Journeyman unlocks at skill 50, Expert at 125 and Artisan at 200, each raising the cap by 75.",
    "Character level gates of 5, 10, 20 and 35 for the four ranks carry over from Classic. Beta players report Cooking reaching 150 before level 10, and a forum moderator called that a bug.",
    "Hitting 150, 225 and 300 in a profession each award a Legacy point the first time you do it on the account.",
  },
}
RGXProf.ForeverNotes[185] = { -- Cooking
  tagline = "Fish it, cook it, done by 60.",
  summary = "Cooking colours did not change, and Cooking now unlocks camping, so everybody wants it. The cheapest route is almost all fish: catch it yourself with Fishing and Cooking costs you nothing but Mild Spices. Only Lean Wolf Steak, from 125 to 179, needs meat off a mob.",
  changes = {
    { text = "Skill-up colours are unchanged from Classic.", source = "Beta data" },
    { text = "Cooking unlocks camping. Campfires come in tiers: Basic at 1, Journeyman at 90, Expert at 200 and an Iron Oven at 300.", source = "Beta data" },
    { text = "Nearly every cooked item gives a stat bonus and a small experience trickle.", source = "Blizzard" },
    { text = "Around 44 new recipes, including Venomous Smoothie, Tasty Raptor Bites and Breakfast Omelette.", source = "Beta data" },
  },
  tips = {
    "All the fish recipes here are sold by fishing and cooking suppliers. Buy them as soon as you can.",
    "Lean Wolf Flank drops from wolves in the level 30s, and Lean Wolf Steak is a vendor recipe. Farm the flanks while you quest through that bracket.",
    "Level Fishing first or at the same time: every fish you catch on the Fishing route below is a Cooking skill-up waiting to happen.",
  },
  ranks = {
    "Journeyman unlocks at skill 50, Expert at 125 and Artisan at 200, each raising the cap by 75.",
    "Character level gates of 5, 10, 20 and 35 for the four ranks carry over from Classic. Beta players report Cooking reaching 150 before level 10, and a forum moderator called that a bug.",
    "Hitting 150, 225 and 300 in a profession each award a Legacy point the first time you do it on the account.",
  },
}
RGXProf.ForeverNotes[333] = { -- Enchanting
  tagline = "Half the dust it used to cost.",
  summary = "Enchanting got the kindest treatment of any profession. Most early formulas need half the dust they did in Classic, and the skill-up colours did not move, so this route is cheaper than any Classic Enchanting guide you have used. You still need a steady supply of greens to disenchant, and that is the real cost.",
  changes = {
    { text = "Early formulas need roughly half the materials: Lesser Stamina on chest is 1 dust and 1 essence (was 2 and 2), Minor Protection on cloak is 2 dust (was 3 dust and a Greater Magic Essence).", source = "Beta data" },
    { text = "Runed Copper Rod now needs a Copper Rod and a Mote of Magic, a new reagent from enchanting suppliers. Dust to Motes and a Novice’s Practice Wand arrive at 10.", source = "Beta data" },
    { text = "Enchant Chest - Minor Health is now Enchant Chest - Inferior Stamina, and a bracer version appears at 20.", source = "Beta data" },
    { text = "Enchanters gain staves, wands and necklace enchants, plus ring enchants in five tiers that the demo showed but the beta data does not list yet.", source = "Reported" },
    { text = "Camp objects: Enchanted Lute at 20, Arcane Salvager at 140, Arcane Forge at 300.", source = "Blizzard" },
  },
  tips = {
    "You only need one Runed Copper Rod. The extra rods from 1 to 10 are just the cheapest points, so vendor them.",
    "Disenchant every green you or your guild does not need from the start. The route wants 179 Strange Dust, 105 Soul Dust, 74 Vision Dust and 143 Dream Dust.",
    "Lesser Mana Oil and Greater Stamina on shields are vendor formulas. Buy them before 260.",
  },
  ranks = {
    "Journeyman unlocks at skill 50, Expert at 125 and Artisan at 200, each raising the cap by 75.",
    "Character level gates of 5, 10, 20 and 35 for the four ranks carry over from Classic. Beta players report Cooking reaching 150 before level 10, and a forum moderator called that a bug.",
    "Hitting 150, 225 and 300 in a profession each award a Legacy point the first time you do it on the account.",
  },
}
RGXProf.ForeverNotes[202] = { -- Engineering
  tagline = "The one crafting profession Forever left alone.",
  summary = "Engineering is the only crafting profession where the beta data shows no colour changes at all, so this route looks like a Classic one. It lives on stone: blasting powder at every tier, bombs and parts in between, and a Mithril slug and Gyro-Shot grind from 210 to 275.",
  changes = {
    { text = "Skill-up colours are unchanged from Classic on every Engineering recipe.", source = "Beta data" },
    { text = "Rough Dynamite needs one Rough Blasting Powder instead of two. EZ-Thro Dynamite takes new vendor parts (EZ-Thro Wrap and Fireproof Fuse). Firework launchers take a different mix of parts.", source = "Beta data" },
    { text = "Goblin and Gnomish specializations return with new toys, plus over 80 new recipes, many of them rockets and gadgets.", source = "Reported" },
    { text = "Engineering has no trained passive in Forever. The gadgets are the bonus.", source = "Reported" },
  },
  tips = {
    "Mining is close to mandatory: this route needs 400 Solid Stone and 84 Rough Stone on top of the bars.",
    "Craft all 158 Solid Blasting Powder you need at 175 while it still gives skill, then bank them for the slugs and Gyro-Shots.",
    "Thorium Tube is a vendor schematic. Pick it up before you reach 275.",
  },
  ranks = {
    "Journeyman unlocks at skill 50, Expert at 125 and Artisan at 200, each raising the cap by 75.",
    "Character level gates of 5, 10, 20 and 35 for the four ranks carry over from Classic. Beta players report Cooking reaching 150 before level 10, and a forum moderator called that a bug.",
    "Hitting 150, 225 and 300 in a profession each award a Legacy point the first time you do it on the account.",
  },
}
RGXProf.ForeverNotes[129] = { -- FirstAid
  tagline = "Bandages as always, plus the healing potions Alchemy lost.",
  summary = "First Aid is still the cheapest skill to max: every step is cloth you already loot. Forever gives it the healing potion line from Alchemy, plus poultices and tourniquets, but none of them beats bandages on cost, so the route is the bandage ladder you remember.",
  changes = {
    { text = "Minor to Major Healing Potion moved here from Alchemy, learned from 1 (Minor) to 290 (Major) and made from herbs, spices and vials.", source = "Beta data" },
    { text = "New poultices and tourniquets. Bandage recipes and colours are unchanged.", source = "Beta data" },
    { text = "Camp objects: First Aid Kit at 20 (a Stamina buff that competes with Power Word: Fortitude), Toxin Study at 140, Plague Doctor’s Laboratory at 300.", source = "Beta data" },
    { text = "Heavy Silk, Mageweave and Heavy Mageweave Bandage manuals come from Deneb Walker in Arathi and Balai Lok’Wein in Dustwallow Marsh. Artisan needs the Triage quest from Theramore or Hammerfall, and the Triage doctor then teaches the Runecloth bandages. No changes to either were found.", source = "Classic" },
  },
  tips = {
    "Keep 152 Linen, 144 Wool, 127 Silk, 92 Mageweave and 65 Runecloth back from the auction house.",
    "Heavy Linen Bandage carries you from 45 to 80. Make the Minor Healing Potions for your own bags if you like, but they cost more per point than bandages.",
    "Do the Triage quest at 225. It needs level 35 in Classic.",
  },
  ranks = {
    "Journeyman unlocks at skill 50, Expert at 125 and Artisan at 200, each raising the cap by 75.",
    "Character level gates of 5, 10, 20 and 35 for the four ranks carry over from Classic. Beta players report Cooking reaching 150 before level 10, and a forum moderator called that a bug.",
    "Hitting 150, 225 and 300 in a profession each award a Legacy point the first time you do it on the account.",
  },
}
RGXProf.ForeverNotes[165] = { -- Leatherworking
  tagline = "Every pattern moved down. A mountain of Rugged and Thick Leather.",
  summary = "Most Leatherworking patterns moved 15 to 25 points down the skill ladder, so you learn them sooner and they go grey sooner, and the leather conversions only give skill for a few points. The route changes recipe 17 times. Light Armor Kits take you from 1 to 52 for a stack of Light Leather. From 250 onward the old patterns run dry and the route leans on the new Skulker’s and Blue Suede patterns.",
  changes = {
    { text = "Medium and Heavy Leather conversions give skill for 10 points after you learn them and Thick Leather for 5. Rugged Leather is grey at once.", source = "Beta data" },
    { text = "Most older patterns are learned and go grey 15 to 25 points sooner than in Classic. Heavy Armor Kit is learned at 125 and goes grey at 165, against 150 and 190.", source = "Beta data" },
    { text = "New Forceful and Mystic armor kits at 95, 155, 205 and 235 build on the old kits with dust and elixirs. New Totemic Leather, Blue Suede and Tooled Leather sets fill the gaps. Their source is not confirmed.", source = "Beta data" },
    { text = "Camp object: Tanning Rack at 140, which enables the advanced patterns.", source = "Blizzard" },
  },
  tips = {
    "Skinning pays for this entirely. The route needs 554 Thick Leather, 377 Light and 634 Rugged.",
    "The Wild Leather patterns are quest rewards in Feralas. Do that chain before 205 or you will be buying worse patterns.",
    "Buy salt from any leatherworking supplier. You need 116 for the cured hides.",
  },
  ranks = {
    "Journeyman unlocks at skill 50, Expert at 125 and Artisan at 200, each raising the cap by 75.",
    "Character level gates of 5, 10, 20 and 35 for the four ranks carry over from Classic. Beta players report Cooking reaching 150 before level 10, and a forum moderator called that a bug.",
    "Hitting 150, 225 and 300 in a profession each award a Legacy point the first time you do it on the account.",
  },
}
RGXProf.ForeverNotes[197] = { -- Tailoring
  tagline = "Every pattern moved down the ladder. Runecloth is the bill.",
  summary = "Tailoring is still the most expensive profession to level in Forever. Almost every pattern moved 20 to 35 points down the skill ladder, so you can learn it sooner and it goes grey sooner by the same amount, and bolts only give a few points each. The route below is the cheapest the data allows, and it still asks for about 2,500 Runecloth. Level it alongside your character and keep every scrap.",
  changes = {
    { text = "Bolts moved down too and give skill for 10 to 20 points: Silk is learned at 100 and grey at 120, Mageweave at 140 and 150, Runecloth at 205 and 215. Bolt of Woolen Cloth goes grey at 85 instead of 105.", source = "Beta data" },
    { text = "Most older patterns are learned and go grey 20 to 35 points sooner than in Classic. Enchanter’s Cowl is learned at 130 and goes grey at 180, against 165 and 215.", source = "Beta data" },
    { text = "Around 180 new recipes, including Earthenweave and Ghostweave sets past 230 and reagent bags at 30, 75, 135, 205, 230 and 270. Some top-end crafts now need alchemist-made dyes. Their source is not confirmed.", source = "Beta data" },
    { text = "Tailors get gear embroidery, including five tiers of cloak embroidery that the beta data does not list yet.", source = "Blizzard" },
    { text = "Camp objects: Faction Banner at 20 (a Spirit buff), Spinning Wheel at 140, Loom at 300.", source = "Blizzard" },
  },
  tips = {
    "Do not sell cloth while levelling your character. The route wants 150 Linen, 93 Wool, 664 Silk, 690 Mageweave and 2,530 Runecloth.",
    "Several steps are vendor patterns (Bright Yellow Shirt, Azure Silk Cloak, Runecloth Gloves and Boots, Mooncloth Robe). Buy them as you pass the vendor.",
    "Pair it with Enchanting and disenchant what you make, or send the greens to an enchanter friend.",
  },
  ranks = {
    "Journeyman unlocks at skill 50, Expert at 125 and Artisan at 200, each raising the cap by 75.",
    "Character level gates of 5, 10, 20 and 35 for the four ranks carry over from Classic. Beta players report Cooking reaching 150 before level 10, and a forum moderator called that a bug.",
    "Hitting 150, 225 and 300 in a profession each award a Legacy point the first time you do it on the account.",
  },
}
RGXProf.ForeverNotes[356] = { -- Fishing
  tagline = "Two books, one quest, a lot of standing still.",
  summary = "Fishing works the way it did in Classic: every catch below your zone’s cap is a skill point until it slows down around the cap. You need the Expert book from Booty Bay at 150 and Nat Pagle’s quest at 225. Level it next to Cooking and every fish turns into a second skill-up.",
  changes = {
    { text = "Tackle boxes store lures, and lava fishing needs a specialized rod.", source = "Reported" },
    { text = "Fishing dailies in Blackmaw Village at launch, with a meta-achievement that awards the “Salty” title.", source = "Reported" },
    { text = "Camp objects: Fish Bowl at 20 (an all-stats buff), Fishing Rack at 140, Fishing Hut at 300.", source = "Beta data" },
    { text = "Players report Fishing still needs character level 10 to train, even though Cooking does not.", source = "Reported" },
    { text = "Expert Fishing is a book from Old Man Heming in Booty Bay. Artisan is Nat Pagle’s quest in Dustwallow Marsh. No changes found to either.", source = "Classic" },
  },
  tips = {
    "Buy Nightcrawlers (+50) from any fishing supplier and keep one on at all times until 150.",
    "Fish in the zone that matches your skill. Low zones cap out and slow you down; high zones make you miss catches.",
    "Every raw fish on this route is a Cooking recipe. Bring Mild Spices.",
  },
  ranks = {
    "Journeyman unlocks at skill 50, Expert at 125 and Artisan at 200, each raising the cap by 75.",
    "Character level gates of 5, 10, 20 and 35 for the four ranks carry over from Classic. Beta players report Cooking reaching 150 before level 10, and a forum moderator called that a bug.",
    "Hitting 150, 225 and 300 in a profession each award a Legacy point the first time you do it on the account.",
  },
  tools = {
    { itemID = 6256, name = "Fishing Pole", note = "Fishing Pole, from any fishing supplier" },
    { itemID = 6365, name = "Strong Fishing Pole", note = "Strong Fishing Pole, +5, sold in Booty Bay and Ratchet" },
    { itemID = 6530, name = "Nightcrawlers", note = "Nightcrawlers, +50 lure, vendor" },
    { itemID = 6532, name = "Bright Baubles", note = "Bright Baubles, +75 lure, vendor and engineering" },
  },
  brackets = {
    { minSkill = 1, maxSkill = 75, what = "Raw Brilliant Smallfish, Slitherskin Mackerel, Longjaw Mud Snapper", note = "",
      alliance = "Elwynn Forest, Dun Morogh, Teldrassil", horde = "Durotar, Mulgore, Tirisfal Glades", items = { { itemID = 6291, name = "Raw Brilliant Smallfish" }, { itemID = 6303, name = "Raw Slitherskin Mackerel" }, { itemID = 6289, name = "Raw Longjaw Mud Snapper" } } },
    { minSkill = 75, maxSkill = 150, what = "Longjaw Mud Snapper, Bristle Whisker Catfish", note = "Buy Expert Fishing from Old Man Heming in Booty Bay at 150.",
      alliance = "Westfall, Loch Modan, Redridge Mountains", horde = "The Barrens, Silverpine Forest, Ashenvale", items = { { itemID = 6289, name = "Raw Longjaw Mud Snapper" }, { itemID = 6308, name = "Raw Bristle Whisker Catfish" } } },
    { minSkill = 150, maxSkill = 225, what = "Bristle Whisker Catfish, Mithril Head Trout, Rockscale Cod", note = "Do Nat Pagle’s Artisan quest in Dustwallow at 225.",
      alliance = "Stranglethorn Vale, Desolace, Dustwallow Marsh", horde = "Stranglethorn Vale, Desolace, Dustwallow Marsh", items = { { itemID = 6308, name = "Raw Bristle Whisker Catfish" }, { itemID = 8365, name = "Raw Mithril Head Trout" }, { itemID = 6362, name = "Raw Rockscale Cod" } } },
    { minSkill = 225, maxSkill = 300, what = "Spotted Yellowtail, Sunscale Salmon, Nightfin Snapper", note = "Un’Goro and Winterspring once you are past 275.",
      alliance = "Tanaris, Feralas, Azshara", horde = "Tanaris, Feralas, Azshara", items = { { itemID = 13760, name = "Raw Sunscale Salmon" }, { itemID = 13759, name = "Raw Nightfin Snapper" } } },
  },
}
RGXProf.ForeverNotes[182] = { -- Herbalism
  tagline = "Same herbs, same skill. Pick everything.",
  summary = "Every herb needs the skill it needed in Classic, checked against the Forever tooltips, so you can level Herbalism by questing and picking whatever you pass. The table below lists every herb and the skill it needs. The route is the zone order that keeps a yellow or orange herb in front of you the whole way.",
  changes = {
    { text = "Herb skill requirements match Classic, from Peacebloom at 1 to Black Lotus at 300.", source = "Beta data" },
    { text = "Natural Talent: resistance to all schools of magic, scaling with skill.", source = "Reported" },
    { text = "Specialize toward rare lotus or raw volume. Some dead creatures can be herbed.", source = "Blizzard" },
    { text = "Camp object: Incense Candle at 20, an Intellect buff that competes with Arcane Intellect.", source = "Blizzard" },
  },
  tips = {
    "Herbalism needs no tool. Train it the moment you leave your starting area.",
    "Track Herbs is free and permanent. Turn it on and keep it on.",
    "Sell early herbs rather than hoarding them unless you are levelling Alchemy: Peacebloom and Silverleaf are worth more to an alchemist at 1 to 90 than to you.",
  },
  ranks = {
    "Journeyman unlocks at skill 50, Expert at 125 and Artisan at 200, each raising the cap by 75.",
    "Character level gates of 5, 10, 20 and 35 for the four ranks carry over from Classic. Beta players report Cooking reaching 150 before level 10, and a forum moderator called that a bug.",
    "Hitting 150, 225 and 300 in a profession each award a Legacy point the first time you do it on the account.",
  },
  brackets = {
    { minSkill = 1, maxSkill = 50, what = "Peacebloom, Silverleaf, Earthroot", note = "",
      alliance = "Elwynn Forest, Dun Morogh, Teldrassil", horde = "Durotar, Mulgore, Tirisfal Glades", items = { { itemID = 2447, name = "Peacebloom" }, { itemID = 765, name = "Silverleaf" }, { itemID = 2449, name = "Earthroot" } } },
    { minSkill = 50, maxSkill = 100, what = "Mageroyal, Briarthorn, Stranglekelp", note = "",
      alliance = "Westfall, Loch Modan, Darkshore", horde = "The Barrens, Silverpine Forest", items = { { itemID = 785, name = "Mageroyal" }, { itemID = 2450, name = "Briarthorn" }, { itemID = 3820, name = "Stranglekelp" } } },
    { minSkill = 100, maxSkill = 150, what = "Bruiseweed, Wild Steelbloom, Grave Moss, Kingsblood", note = "",
      alliance = "Wetlands, Redridge Mountains, Duskwood", horde = "Stonetalon Mountains, Hillsbrad Foothills, Ashenvale", items = { { itemID = 2453, name = "Bruiseweed" }, { itemID = 3355, name = "Wild Steelbloom" }, { itemID = 3369, name = "Grave Moss" }, { itemID = 3356, name = "Kingsblood" } } },
    { minSkill = 150, maxSkill = 205, what = "Liferoot, Fadeleaf, Goldthorn, Khadgar’s Whisker, Wintersbite", note = "",
      alliance = "Arathi Highlands, Stranglethorn Vale, Alterac Mountains", horde = "Arathi Highlands, Stranglethorn Vale, Dustwallow Marsh", items = { { itemID = 3357, name = "Liferoot" }, { itemID = 3818, name = "Fadeleaf" }, { itemID = 3821, name = "Goldthorn" }, { itemID = 3358, name = "Khadgar's Whisker" }, { itemID = 3819, name = "Wintersbite" } } },
    { minSkill = 205, maxSkill = 230, what = "Firebloom, Purple Lotus, Arthas’ Tears", note = "",
      alliance = "Badlands, Searing Gorge, The Hinterlands", horde = "Tanaris, Feralas, Azshara", items = { { itemID = 4625, name = "Firebloom" }, { itemID = 8831, name = "Purple Lotus" }, { itemID = 8836, name = "Arthas' Tears" } } },
    { minSkill = 230, maxSkill = 270, what = "Sungrass, Blindweed, Ghost Mushroom, Gromsblood, Golden Sansam", note = "",
      alliance = "The Hinterlands, Swamp of Sorrows, Blasted Lands", horde = "Feralas, Felwood, Un’Goro Crater", items = { { itemID = 8838, name = "Sungrass" }, { itemID = 8839, name = "Blindweed" }, { itemID = 8845, name = "Ghost Mushroom" }, { itemID = 8846, name = "Gromsblood" }, { itemID = 13464, name = "Golden Sansam" } } },
    { minSkill = 270, maxSkill = 300, what = "Dreamfoil, Mountain Silversage, Plaguebloom, Icecap", note = "",
      alliance = "Un’Goro Crater, Western Plaguelands, Eastern Plaguelands", horde = "Un’Goro Crater, Felwood, Winterspring", items = { { itemID = 13463, name = "Dreamfoil" }, { itemID = 13465, name = "Mountain Silversage" }, { itemID = 13466, name = "Plaguebloom" }, { itemID = 13467, name = "Icecap" } } },
  },
}
RGXProf.ForeverNotes[186] = { -- Mining
  tagline = "Node skills unchanged. Smelting barely helps now.",
  summary = "Mining nodes need the same skill they did in Classic, so the route is the old zone ladder. What changed is smelting: Copper is learned at 25 instead of 1, Tin goes grey at 75, and Mithril and Thorium are grey the moment you learn them. Plan on getting nearly every point from nodes.",
  changes = {
    { text = "Node skill requirements match Classic: Copper 1, Tin 65, Silver 75, Iron 125, Gold 155, Mithril 175, Truesilver 230, Small Thorium 245, Rich Thorium 275.", source = "Beta data" },
    { text = "Smelt Copper is learned at 25. Smelt Tin is grey at 75, Smelt Iron at 140, and Smelt Mithril and Smelt Thorium give no skill at all.", source = "Beta data" },
    { text = "Made of Metal: 5% increased total health while Mining is trained.", source = "Reported" },
    { text = "Arcanite Lodes that take more effort to mine, and some creatures can be mined after death.", source = "Reported" },
    { text = "New ores and bars at the top end: Pitchblende smelts into Azerothium Bars at 275, and Heavy Thorium Ore smelts at 300.", source = "Beta data" },
    { text = "A level 3 to 4 gathering manual quest teaches the profession and reportedly adds 2 skill, up to 15.", source = "Reported" },
  },
  tips = {
    "Smelt Copper, Bronze, Silver and Gold while they are still yellow or green for a few free points. Iron barely helps and everything from Steel up gives none, so smelt those for the bars only.",
    "Carry a Mining Pick in your bags. Nodes do not wait while you run back to a vendor.",
    "Gold at 155 and Truesilver at 230 are rare spawns on Iron and Mithril routes. Take them when you see them.",
  },
  ranks = {
    "Journeyman unlocks at skill 50, Expert at 125 and Artisan at 200, each raising the cap by 75.",
    "Character level gates of 5, 10, 20 and 35 for the four ranks carry over from Classic. Beta players report Cooking reaching 150 before level 10, and a forum moderator called that a bug.",
    "Hitting 150, 225 and 300 in a profession each award a Legacy point the first time you do it on the account.",
  },
  tools = {
    { itemID = 2901, name = "Mining Pick", note = "Mining Pick, from any trade supplier" },
  },
  brackets = {
    { minSkill = 1, maxSkill = 65, what = "Copper", note = "",
      alliance = "Elwynn Forest, Dun Morogh, Darkshore", horde = "Durotar, Mulgore, Tirisfal Glades", items = { { itemID = 2770, name = "Copper Ore" } } },
    { minSkill = 65, maxSkill = 125, what = "Tin and Silver", note = "Keep mining Copper until Tin turns orange at 65.",
      alliance = "Loch Modan, Westfall, Redridge Mountains", horde = "The Barrens, Silverpine Forest, Stonetalon Mountains", items = { { itemID = 2771, name = "Tin Ore" }, { itemID = 2775, name = "Silver Ore" } } },
    { minSkill = 125, maxSkill = 175, what = "Iron and Gold", note = "",
      alliance = "Arathi Highlands, Wetlands, Stranglethorn Vale", horde = "Arathi Highlands, Thousand Needles, Desolace", items = { { itemID = 2772, name = "Iron Ore" }, { itemID = 2776, name = "Gold Ore" } } },
    { minSkill = 175, maxSkill = 245, what = "Mithril and Truesilver", note = "",
      alliance = "Badlands, The Hinterlands, Searing Gorge", horde = "Badlands, Tanaris, Feralas", items = { { itemID = 3858, name = "Mithril Ore" }, { itemID = 7911, name = "Truesilver Ore" } } },
    { minSkill = 245, maxSkill = 275, what = "Small Thorium", note = "",
      alliance = "Un’Goro Crater, Burning Steppes, Western Plaguelands", horde = "Un’Goro Crater, Felwood, Silithus", items = { { itemID = 10620, name = "Thorium Ore" } } },
    { minSkill = 275, maxSkill = 300, what = "Rich Thorium", note = "",
      alliance = "Un’Goro Crater, Eastern Plaguelands, Winterspring", horde = "Un’Goro Crater, Winterspring, Silithus", items = { { itemID = 10620, name = "Thorium Ore" } } },
  },
}
RGXProf.ForeverNotes[393] = { -- Skinning
  tagline = "Skin what you kill. It levels itself.",
  summary = "Skinning is the one profession you do not need a route for: if you skin every beast you kill while questing, you arrive at 60 with 300 skill. The rule from Classic is that you can skin a mob of level L once your skill reaches L × 5 (above level 20), so 150 skill covers level 30 beasts and 300 covers everything. The table below is the zone order if you want to catch up.",
  changes = {
    { text = "Beasts of the Wild: 5% increased damage to Beasts and Dragonkin while Skinning is trained.", source = "Reported" },
    { text = "Rare hides with new recipes that use previously worthless skins.", source = "Reported" },
    { text = "Skill needed is mob level × 5 above level 20, and (level − 10) × 10 below it. Nobody has shown this changed.", source = "Classic" },
  },
  tips = {
    "Buy a Skinning Knife from a trade supplier and keep it in your bags.",
    "Skin other players’ kills too. Nobody minds and it is free skill.",
    "Behind on skill? Farm one zone of beasts that are orange to you rather than questing ahead.",
  },
  ranks = {
    "Journeyman unlocks at skill 50, Expert at 125 and Artisan at 200, each raising the cap by 75.",
    "Character level gates of 5, 10, 20 and 35 for the four ranks carry over from Classic. Beta players report Cooking reaching 150 before level 10, and a forum moderator called that a bug.",
    "Hitting 150, 225 and 300 in a profession each award a Legacy point the first time you do it on the account.",
  },
  tools = {
    { itemID = 7005, name = "Skinning Knife", note = "Skinning Knife, from any trade supplier" },
  },
  brackets = {
    { minSkill = 1, maxSkill = 75, what = "Light Leather, Ruined Leather Scraps", note = "",
      alliance = "Elwynn Forest, Dun Morogh, Westfall, Loch Modan", horde = "Durotar, Mulgore, The Barrens", items = { { itemID = 2318, name = "Light Leather" }, { itemID = 2934, name = "Ruined Leather Scraps" } } },
    { minSkill = 75, maxSkill = 150, what = "Light and Medium Leather", note = "Level 15 to 30 beasts.",
      alliance = "Wetlands, Redridge Mountains, Duskwood", horde = "The Barrens, Stonetalon Mountains, Hillsbrad Foothills", items = { { itemID = 2318, name = "Light Leather" }, { itemID = 2319, name = "Medium Leather" } } },
    { minSkill = 150, maxSkill = 225, what = "Medium and Heavy Leather", note = "Level 30 to 45 beasts. Stranglethorn raptors and tigers are the best farm.",
      alliance = "Arathi Highlands, Stranglethorn Vale, Desolace", horde = "Arathi Highlands, Stranglethorn Vale, Dustwallow Marsh", items = { { itemID = 2319, name = "Medium Leather" }, { itemID = 4234, name = "Heavy Leather" } } },
    { minSkill = 225, maxSkill = 300, what = "Thick and Rugged Leather", note = "Level 45 to 60 beasts. Un’Goro devilsaurs and Winterspring bears finish it.",
      alliance = "Feralas, Tanaris, Un’Goro Crater, Winterspring", horde = "Feralas, Tanaris, Un’Goro Crater, Winterspring", items = { { itemID = 4304, name = "Thick Leather" }, { itemID = 8170, name = "Rugged Leather" } } },
  },
}
