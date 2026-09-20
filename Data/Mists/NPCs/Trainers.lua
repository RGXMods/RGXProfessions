RGXProf.Mists = RGXProf.Mists or {}

-- Trainers.lua
RGXProf.Mists.Trainers = {

  -- Alliance General Profession Trainers
  { name = "Valn", faction = "Alliance", zoneID = 97, x = 48.6, y = 52.2, minSkill = 0, maxSkill = 75, professionID = nil }, -- Azuremyst Isle
  { name = "Wembil Taskwidget", faction = "Alliance", zoneID = 27, x = 53.8, y = 52.0, minSkill = 0, maxSkill = 75, professionID = nil }, -- Dun Morogh
  { name = "Jack 'All-Trades' Derrington", faction = "Alliance", zoneID = 179, x = 37.2, y = 63.2, minSkill = 0, maxSkill = 75, professionID = nil }, -- Gilneas (Duskhaven)
  { name = "Jack 'All-Trades' Derrington", faction = "Alliance", zoneID = 179, x = 41.6, y = 37.6, minSkill = 0, maxSkill = 75, professionID = nil }, -- Gilneas (Keel Harbor)
  { name = "Lien Farner", faction = "Alliance", zoneID = 37, x = 42.0, y = 67.0, minSkill = 0, maxSkill = 75, professionID = nil }, -- Elwynn Forest
  { name = "Iranis Shadebloom", faction = "Alliance", zoneID = 57, x = 56.0, y = 52.2, minSkill = 0, maxSkill = 75, professionID = nil }, -- Teldrassil

  -- Horde General Profession Trainers
  { name = "Runda", faction = "Horde", zoneID = 1, x = 52.8, y = 42.0, minSkill = 0, maxSkill = 75, professionID = nil }, -- Durotar
  { name = "Saren", faction = "Horde", zoneID = 94, x = 48.8, y = 46.8, minSkill = 0, maxSkill = 75, professionID = nil }, -- Eversong Woods
  { name = "Lalum Darkmane", faction = "Horde", zoneID = 7, x = 46.4, y = 57.6, minSkill = 0, maxSkill = 75, professionID = nil }, -- Mulgore
  { name = "KTC Train-a-Tron Deluxe", faction = "Horde", zoneID = 174, x = 45.6, y = 65.6, minSkill = 0, maxSkill = 75, professionID = nil }, -- The Lost Isles
  { name = "Therisa Sallow", faction = "Horde", zoneID = 18, x = 44.6, y = 53.0, minSkill = 0, maxSkill = 75, professionID = nil }, -- Tirisfal Glades


-- Alchemy Trainers
    -- Horde Trainers
    {name = "Yelmak",                  faction = "Horde",    zoneID = 85,  x = 56.6,  y = 33.2, professionID = 197, minSkill = 1}, -- Orgrimmar
    {name = "Doctor Herbert Halsey",  faction = "Horde",    zoneID = 998, x = 47.6,  y = 73.0, professionID = 197, minSkill = 1}, -- Undercity
    {name = "Bena Winterhoof",        faction = "Horde",    zoneID = 88,  x = 46.8,  y = 33.6, professionID = 197, minSkill = 1}, -- Thunder Bluff
    {name = "Camberon",               faction = "Horde",    zoneID = 110, x = 66.4,  y = 16.4, professionID = 197, minSkill = 1}, -- Silvermoon City

    -- Alliance Trainers
    {name = "Tally Berryfizz",        faction = "Alliance", zoneID = 87,  x = 67.2,  y = 54.2, professionID = 197, minSkill = 1}, -- Ironforge
    {name = "Lilyssia Nightbreeze",   faction = "Alliance", zoneID = 84,  x = 46.4,  y = 79.6, professionID = 197, minSkill = 1}, -- Stormwind City
    {name = "Ainethil",               faction = "Alliance", zoneID = 89,  x = 55.0,  y = 23.8, professionID = 197, minSkill = 1}, -- Darnassus
    {name = "Lucc",                   faction = "Alliance", zoneID = 103, x = 27.8,  y = 60.2, professionID = 197, minSkill = 1}, -- The Exodar

  -- Blacksmithing
  -- Horde Trainers
    {name = "Saru Steelfury",         faction = "Horde",    zoneID = 85,  x = 76.4, y = 34.4, professionID = 164, minSkill = 1}, -- Orgrimmar
    {name = "James Van Brunt",        faction = "Horde",    zoneID = 998, x = 61.6, y = 30.2, professionID = 164, minSkill = 1}, -- Undercity
    {name = "Karn Stonehoof",         faction = "Horde",    zoneID = 88,  x = 40.0, y = 54.2,  professionID = 164, minSkill = 1}, -- Thunder Bluff
    {name = "Bemarrin",               faction = "Horde",    zoneID = 110, x = 79.6, y = 39.6,  professionID = 164, minSkill = 1}, -- Silvermoon City

    -- Alliance Trainers
    {name = "Bengus Deepforge",       faction = "Alliance", zoneID = 87,  x = 53.2, y = 40.0,  professionID = 164, minSkill = 1}, -- Ironforge
    {name = "Therum Deepforge",       faction = "Alliance", zoneID = 84,  x = 57.0, y = 16.6,  professionID = 164, minSkill = 1}, -- Stormwind City
    {name = "Miall",                  faction = "Alliance", zoneID = 103, x = 60.6, y = 89.6,  professionID = 164, minSkill = 1}, -- The Exodar


    -- Enchanting
    -- Horde Trainers
    {name = "Godan",                  faction = "Horde",    zoneID = 85,  x = 53.8, y = 38.4,  professionID = 333, minSkill = 1}, -- Orgrimmar
    {name = "Lavinia Crowe",       faction = "Horde",    zoneID = 998, x = 62.4, y = 61.4,  professionID = 333, minSkill = 1}, -- Undercity
    {name = "Teg Dawnstrider",        faction = "Horde",    zoneID = 88,  x = 45.2, y = 38.6,  professionID = 333, minSkill = 1}, -- Thunder Bluff
    {name = "Vance Undergloom",   faction = "Horde",    zoneID = 18,  x =  61.6, y = 51.6, professionID = 333, minSkill = 1}, -- Tirisfal Glades (Brill)
    {name = "Sedana",             faction = "Horde",    zoneID = 110, x = 69.8, y = 24.0, professionID = 333, minSkill = 1}, -- Silvermoon City

       -- Alliance Trainers
    {name = "Lucan Cordell",      faction = "Alliance", zoneID = 84,  x = 43.0, y = 64.4, professionID = 333, minSkill = 1}, -- Stormwind City
    {name = "Gimble Thistlefuzz", faction = "Alliance", zoneID = 87,  x = 60.0, y = 45.4, professionID = 333, minSkill = 1}, -- Ironforge
    {name = "Taladan",            faction = "Alliance", zoneID = 89,  x = 58.6, y = 13.6, professionID = 333, minSkill = 1}, -- Darnassus
    {name = "Alanna Raveneye",    faction = "Alliance", zoneID = 57,  x =36.8, y = 34.2, professionID = 333, minSkill = 1}, -- Teldrassil
    {name = "Nahogg",             faction = "Alliance", zoneID = 103, x = 41.6, y = 38.6, professionID = 333, minSkill = 1}, -- The Exodar

    -- Engineering
     -- Horde Trainers
-- Horde Trainers
    {name = "Roxxik",                   faction = "Horde",    zoneID = 85,  x = 56.8, y = 56.4,  professionID = 202, minSkill = 1}, -- Orgrimmar
    {name = "Graham Van Talen",        faction = "Horde",    zoneID = 998, x = 75.2, y = 72.4,  professionID = 202, minSkill = 1}, -- Undercity
    {name = "Twizwick Sprocketgrind",  faction = "Horde",    zoneID = 7,   x = 61.8, y =  31.6,  professionID = 202, minSkill = 1}, -- Mulgore
    {name = "Mukdrak",                 faction = "Horde",    zoneID = 1,   x = 52.2, y =  40.8,  professionID = 202, minSkill = 1}, -- Durotar
    {name = "Danwe",                   faction = "Horde",    zoneID = 110, x = 76.2, y =  40.8,  professionID = 202, minSkill = 1}, -- Silvermoon City

    -- Alliance Trainers
    {name = "Springspindle Fizzlegear",faction = "Alliance", zoneID = 87,  x = 68.6, y =  44.2,  professionID = 202, minSkill = 1}, -- Ironforge
    {name = "Lilliam Sparkspindle",    faction = "Alliance", zoneID = 84,  x = 55.0, y =  8.6,  professionID = 202, minSkill = 1}, -- Stormwind City
    {name = "Jenna Lemkenilli",        faction = "Alliance", zoneID = 62,  x = 38.2, y =  41.0,  professionID = 202, minSkill = 1}, -- Darkshore
    {name = "Ockil",                   faction = "Alliance", zoneID = 103, x = 54.0, y =  91.4,  professionID = 202, minSkill = 1}, -- The Exodar


    -- Inscription
    -- Horde Trainers
    {name = "Jo'mah",                 faction = "Horde",    zoneID = 85,  x = 35.6, y =  69.2,  professionID = 773, minSkill = 1}, -- Orgrimmar
    {name = "Margaux Parchley",      faction = "Horde",    zoneID = 998, x = 61.6, y =  58.6,  professionID = 773, minSkill = 1}, -- Undercity
    {name = "Poshken Hardbinder",    faction = "Horde",    zoneID = 88,  x = 29.2, y =  21.8,  professionID = 773, minSkill = 1}, -- Thunder Bluff
    {name = "Zantasia",              faction = "Horde",    zoneID = 110, x = 69.6, y =  23.6,  professionID = 773, minSkill = 1}, -- Silvermoon City

    -- Alliance Trainers
    {name = "Catarina Stanford",     faction = "Alliance", zoneID = 84,  x = 49.8, y =  74.0,  professionID = 773, minSkill = 1}, -- Stormwind City
    {name = "Elise Brightletter",    faction = "Alliance", zoneID = 87,  x = 61.6, y =  44.8,  professionID = 773, minSkill = 1}, -- Ironforge
    {name = "Feyden Darkin",         faction = "Alliance", zoneID = 89,  x = 56.6, y =  31.60,  professionID = 773, minSkill = 1}, -- Darnassus
    {name = "Thoth",                 faction = "Alliance", zoneID = 103, x = 40.6, y =  39.0,  professionID = 773, minSkill = 1}, -- The Exodar

    -- Jewelcrafting
-- Horde Trainers
    {name = "Lugrah",                faction = "Horde",    zoneID = 85,  x = 72.4, y =  34.6,  professionID = 755, minSkill = 1}, -- Orgrimmar
    {name = "Nahari Cloudchaser",   faction = "Horde",    zoneID = 88,  x = 35.6, y =  53.8,  professionID = 755, minSkill = 1}, -- Thunder Bluff
    {name = "Neller Fayne",         faction = "Horde",    zoneID = 998, x = 56.2, y =  36.6,  professionID = 755, minSkill = 1}, -- Undercity
    {name = "Kalinda",              faction = "Horde",    zoneID = 110, x = 90.6, y =  73.8,  professionID = 755, minSkill = 1}, -- Silvermoon City

    -- Alliance Trainers
    {name = "Theresa Denman",       faction = "Alliance", zoneID = 84,  x = 63.6, y =  61.6,  professionID = 755, minSkill = 1}, -- Stormwind City
    {name = "Hanner Gembold",       faction = "Alliance", zoneID = 87,  x = 50.6, y =  26.0,  professionID = 755, minSkill = 1}, -- Ironforge
    {name = "Aessa Silverdew",      faction = "Alliance", zoneID = 89,  x = 54.2, y =  30.4,  professionID = 755, minSkill = 1}, -- Darnassus
    {name = "Farii",                faction = "Alliance", zoneID = 103, x = 44.8, y =  24.6,  professionID = 755, minSkill = 1}, -- The Exodar

    -- Leatherworking
-- Horde Trainers
    {name = "Karolek",        faction = "Horde", zoneID = 85,  x = 62.8, y =  44.6,  professionID = 165, minSkill = 1}, -- Orgrimmar
    {name = "Arthur Moore",   faction = "Horde", zoneID = 998, x =70.6, y =  58.6,  professionID = 165, minSkill = 1}, -- Undercity
    {name = "Una",            faction = "Horde", zoneID = 88,  x = 41.8, y =  42.6,  professionID = 165, minSkill = 1}, -- Thunder Bluff
    {name = "Lynalis",        faction = "Horde", zoneID = 110, x = 84.8, y =  80.6,  professionID = 165, minSkill = 1}, -- Silvermoon City

    -- Alliance Trainers
    {name = "Simon Tanner",       faction = "Alliance", zoneID = 84,  x = 71.8, y =  62.,  professionID = 165, minSkill = 1}, -- Stormwind City
    {name = "Fimble Finespindle", faction = "Alliance", zoneID = 87,  x = 40.4, y =  32.4,  professionID = 165, minSkill = 1}, -- Ironforge
    {name = "Telonis",            faction = "Alliance", zoneID = 89,  x = 64.6, y =  21.6,  professionID = 165, minSkill = 1}, -- Darnassus
    {name = "Akham",              faction = "Alliance", zoneID = 103, x = 67.2, y =  74.6,  professionID = 165, minSkill = 1}, -- The Exodar

     -- Tailoring
    -- Horde Trainers
    {name = "Magar",              faction = "Horde",    zoneID = 85,  x = 63.6, y =  50.0,  professionID = 197, minSkill = 1}, -- Orgrimmar
    {name = "Victor Ward",        faction = "Horde",    zoneID = 998, x = 70.6, y =  29.6,  professionID = 197, minSkill = 1}, -- Undercity
    {name = "Vhan",               faction = "Horde",    zoneID = 88,  x = 44.0, y =  44.4,  professionID = 197, minSkill = 1}, -- Thunder Bluff
    {name = "Kil'hala",           faction = "Horde",    zoneID = 10,  x = 52.2, y =  31.6,  professionID = 197, minSkill = 1}, -- The Barrens
    {name = "Bowen Brisboise",    faction = "Horde",    zoneID = 18,  x = 52.6, y = 55.6,  professionID = 197, minSkill = 1}, -- Tirisfal Glades
    {name = "Keelen Sheets",      faction = "Horde",    zoneID = 110, x = 57.2, y =  50.4,  professionID = 197, minSkill = 1}, -- Silvermoon City

    -- Alliance Trainers
    {name = "Uthrar Threx",       faction = "Alliance", zoneID = 87,  x = 43.6, y =  28.2 ,  professionID = 197, minSkill = 1}, -- Ironforge
    {name = "Grondal Moonbreeze", faction = "Alliance", zoneID = 62,  x = 38.2, y =  40.6,  professionID = 197, minSkill = 1}, -- Darkshore
    {name = "Lawrence Schneider", faction = "Alliance", zoneID = 84,  x = 43.6, y =  73.8,  professionID = 197, minSkill = 1}, -- Stormwind City
    {name = "Trianna",            faction = "Alliance", zoneID = 89,  x = 63.6, y =  21.6,  professionID = 197, minSkill = 1}, -- Darnassus
    {name = "Eldrin",             faction = "Alliance", zoneID = 37,  x = 79.2, y =  69.0,  professionID = 197, minSkill = 1}, -- Elwynn Forest
    {name = "Refik",              faction = "Alliance", zoneID = 103, x = 64.6, y =  68.6,  professionID = 197, minSkill = 1}, -- The Exodar

    -- First Aid
    -- Alliance Trainers
    {name = "Angela Leifeld",    faction = "Alliance", zoneID = 84,  x = 52.2, y =  45.4,  professionID = 129, minSkill = 1}, -- Stormwind City
    {name = "Dannelor",          faction = "Alliance", zoneID = 89,  x = 51.6, y =  30.6,  professionID = 129, minSkill = 1}, -- Darnassus
    {name = "Nissa Firestone",   faction = "Alliance", zoneID = 87,  x = 55.6, y =  59.6,  professionID = 129, minSkill = 1}, -- Ironforge
    {name = "Nus",               faction = "Alliance", zoneID = 103, x = 39.6, y =  22.6,  professionID = 129, minSkill = 1}, -- The Exodar
    {name = "Michelle Belle",    faction = "Alliance", zoneID = 37,  x = 43.4, y =  65.6,  professionID = 129, minSkill = 1}, -- Elwynn Forest
    {name = "Byancie",           faction = "Alliance", zoneID = 57,  x = 55.0, y =  49.6,  professionID = 129, minSkill = 1}, -- Teldrassil
    {name = "Thamner Pol",       faction = "Alliance", zoneID = 27,  x = 54.2, y =  50.8,  professionID = 129, minSkill = 1}, -- Dun Morogh

    -- Horde Trainers
    {name = "Krenk Choplimb",    faction = "Horde",    zoneID = 85,  x = 37.6, y =  87.2,  professionID = 129, minSkill = 1}, -- Orgrimmar
    {name = "Pand Stonebinder",  faction = "Horde",    zoneID = 88,  x = 29.6, y =  21.6,  professionID = 129, minSkill = 1}, -- Thunder Bluff
    {name = "Mary Edras",        faction = "Horde",    zoneID = 998, x = 73.6, y =  55.6,  professionID = 129, minSkill = 1}, -- Undercity
    {name = "Alestus",           faction = "Horde",    zoneID = 110, x = 77.8, y =  70.4,  professionID = 129, minSkill = 1}, -- Silvermoon City
    {name = "Nurse Neela",       faction = "Horde",    zoneID = 18,  x = 59.8, y =  52.0,  professionID = 129, minSkill = 1}, -- Tirisfal Glades
    {name = "Rawrk",             faction = "Horde",    zoneID = 1,   x = 54.0, y =  42.0,  professionID = 129, minSkill = 1}, -- Durotar
    {name = "Vira Younghoof",    faction = "Horde",    zoneID = 7,   x = 46.8, y =  60.2,  professionID = 129, minSkill = 1}, -- Mulgore
}