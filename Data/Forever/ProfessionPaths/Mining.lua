RGXProf.ForeverPaths = RGXProf.ForeverPaths or {}

-- WoW Forever leveling data.
RGXProf.ForeverPaths.Mining = {
  { minSkill = 1, maxSkill = 65, name = "Copper", itemID = 2770, source = "gather", zones = { alliance = "Elwynn Forest, Dun Morogh, Darkshore", horde = "Durotar, Mulgore, Tirisfal Glades" } },
  { minSkill = 65, maxSkill = 125, name = "Tin and Silver", itemID = 2771, source = "gather", note = "Keep mining Copper until Tin turns orange at 65.", zones = { alliance = "Loch Modan, Westfall, Redridge Mountains", horde = "The Barrens, Silverpine Forest, Stonetalon Mountains" } },
  { minSkill = 125, maxSkill = 175, name = "Iron and Gold", itemID = 2772, source = "gather", zones = { alliance = "Arathi Highlands, Wetlands, Stranglethorn Vale", horde = "Arathi Highlands, Thousand Needles, Desolace" } },
  { minSkill = 175, maxSkill = 245, name = "Mithril and Truesilver", itemID = 3858, source = "gather", zones = { alliance = "Badlands, The Hinterlands, Searing Gorge", horde = "Badlands, Tanaris, Feralas" } },
  { minSkill = 245, maxSkill = 275, name = "Small Thorium", itemID = 10620, source = "gather", zones = { alliance = "Un’Goro Crater, Burning Steppes, Western Plaguelands", horde = "Un’Goro Crater, Felwood, Silithus" } },
  { minSkill = 275, maxSkill = 300, name = "Rich Thorium", itemID = 10620, source = "gather", zones = { alliance = "Un’Goro Crater, Eastern Plaguelands, Winterspring", horde = "Un’Goro Crater, Winterspring, Silithus" } },
}
