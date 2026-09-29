RGXProf = RGXProf or {}
RGXProf.Expansions = RGXProf.Expansions or {
    Classic = {},
    Cata = {},
    Mists = {}
}

local function Classic() 

    return {
        majorVersion = 1,
        fullName = "Classic Era",
        tag = "Classic",
        maxSkill = 300,
        vendors = RGXProf.Classic.Vendors,
        quests = RGXProf.Classic.Quests,
        trainers = RGXProf.Classic.Trainers,
        racialBonuses = {
            [202] = {20593, 15}, -- Engineering +15 (Gnome)
            [185] = {107073, 15}, -- Cooking +15
        },
        paths = {
            [164] = RGXProf.ClassicPaths.Blacksmithing,
            [165] = RGXProf.ClassicPaths.Leatherworking,
            [171] = RGXProf.ClassicPaths.Alchemy,
            [185] = RGXProf.ClassicPaths.Cooking,
            [333] = RGXProf.ClassicPaths.Enchanting,
            [202] = RGXProf.ClassicPaths.Engineering,
            [129] = RGXProf.ClassicPaths.FirstAid,
            [356] = RGXProf.ClassicPaths.Fishing,
            [182] = RGXProf.ClassicPaths.Herbalism,
            [186] = RGXProf.ClassicPaths.Mining,
            [393] = RGXProf.ClassicPaths.Skinning,
            [197] = RGXProf.ClassicPaths.Tailoring
        },
        tiers = { 50, 75, 100, 150, 225, 300 },
    }
end

local function Cata()
    return {
        majorVersion = 4,
        fullName = "Cataclysm Classic",
        tag = "Cata",
        maxSkill = 525,
        vendors = RGXProf.Cata.Vendors,
        quests = RGXProf.Cata.Quests,
        trainers = RGXProf.Cata.Trainers,
        racialBonuses = {
            [202] = {20593, 15}, -- Engineering +15 (Gnome)
            [171] = {69045, 15}, -- Alchemy +15 (Goblin, Cata only)
            [185] = {107073, 15}, -- Cooking +15
            [333] = {28877, 10}, -- Enchanting +10
            [755] = {28875, 10}, -- Jewelcrafting +10
        },
        paths = {
            [164] = RGXProf.CataPaths.Blacksmithing,
            [165] = RGXProf.CataPaths.Leatherworking,
            [171] = RGXProf.CataPaths.Alchemy,
            [185] = RGXProf.CataPaths.Cooking,
            [333] = RGXProf.CataPaths.Enchanting,
            [202] = RGXProf.CataPaths.Engineering,
            [129] = RGXProf.CataPaths.FirstAid,
            [356] = RGXProf.CataPaths.Fishing,
            [182] = RGXProf.CataPaths.Herbalism,
            [773] = RGXProf.CataPaths.Inscription,
            [755] = RGXProf.CataPaths.Jewelcrafting,
            [186] = RGXProf.CataPaths.Mining,
            [393] = RGXProf.CataPaths.Skinning,
            [197] = RGXProf.CataPaths.Tailoring
        },
        tiers = { 50, 75, 100, 150, 225, 300, 375, 450, 525 }

    }
end

local function Mists()
    return {
        majorVersion = 5,
        fullName = "Mists of Pandaria Classic",
        tag = "Mists",
        maxSkill = 600,
        vendors = RGXProf.Mists.Vendors,
        quests = RGXProf.Mists.Quests,
        trainers = RGXProf.Mists.Trainers,
        racialBonuses = {
            [202] = {20593, 15}, -- Engineering +15 (Gnome)
            [171] = {69045, 15}, -- Alchemy +15 (Goblin, Cata only)
            [185] = {107073, 15}, -- Cooking +15
            [333] = {28877, 10}, -- Enchanting +10
            [755] = {28875, 10}, -- Jewelcrafting +10
        },
        paths = {
            [164] = RGXProf.MistsPaths.Blacksmithing,
            [165] = RGXProf.MistsPaths.Leatherworking,
            
            [171] = RGXProf.MistsPaths.Alchemy,
            [185] = RGXProf.MistsPaths.Cooking,
            [333] = RGXProf.MistsPaths.Enchanting,
            [202] = RGXProf.MistsPaths.Engineering,
            [129] = RGXProf.MistsPaths.FirstAid,
            [356] = RGXProf.MistsPaths.Fishing,
            [182] = RGXProf.MistsPaths.Herbalism,
            [773] = RGXProf.MistsPaths.Inscription,
            [755] = RGXProf.MistsPaths.Jewelcrafting,
            [186] = RGXProf.MistsPaths.Mining,
            [393] = RGXProf.MistsPaths.Skinning,
            [197] = RGXProf.MistsPaths.Tailoring
        },
        tiers = { 50, 75, 100, 150, 225, 300, 375, 450, 525, 600 }

    }
end

RGXProf.Expansions.All = {
    [1] = Classic,
    [4] = Cata,
    [5] = Mists
}

RGXProf.currentExpansion = RGXProf.currentExpansion or {}

function RGXProf.Expansions:GetVersion()
    local buildVersion = RGXProf.WowAPI:GetBuildInfo()
    return tonumber(string.match(buildVersion, "^%d+"))
end

function RGXProf.Expansions:IsSupported()
    local version = self:GetVersion()
    if not version then
        print(RGXProf.L.UNABLE_DETECT_VERSION)
        return false
    end

    if self.All[version] then return true end

    print(RGXProf.L.UNSUPPORTED_WOW_VERSION)
    return false
end

function RGXProf.Expansions:SetExpansionData(majorVersion)
    local expansionConstructor = self.All[majorVersion]
    if not expansionConstructor then
        print(RGXProf.L.UNKNOWN_EXPANSION, majorVersion)
        return
    end
    
    -- Set global active expansion
    RGXProf.currentExpansion = expansionConstructor()

    -- Wire up expansion-specific data tables
    RGXProf.VendorData = RGXProf.currentExpansion.vendors
    RGXProf.QuestData  = RGXProf.currentExpansion.quests
    RGXProf.TrainerData = RGXProf.currentExpansion.trainers
end
