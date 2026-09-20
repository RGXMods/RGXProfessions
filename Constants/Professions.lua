RGXProf = RGXProf or {}
RGXProf.Constants = RGXProf.Constants or {}

RGXProf.Constants.Professions = {
    [164] = { name = "Blacksmithing", icon = 136241 },
    [165] = { name = "Leatherworking", icon = 133611 },
    [171] = { name = "Alchemy", icon = 136240 },
    [185] = { name = "Cooking", icon = 133971 },
    [333] = { name = "Enchanting", icon = 136244 },
    [202] = { name = "Engineering", icon = 136243 },
    [129] = { name = "First Aid", icon = 135966 },
    [356] = { name = "Fishing", icon = 136245 },
    [182] = { name = "Herbalism", icon = 136065 },
    [773] = { name = "Inscription", icon = 237171 },
    [755] = { name = "Jewelcrafting", icon = 134071 },
    [186] = { name = "Mining", icon = 136248 },
    [393] = { name = "Skinning", icon = 134366 },
    [197] = { name = "Tailoring", icon = 136249 },
    Default = { name = "Default", icon = 133741 }
}

RGXProf.Constants.ProfessionOrder = {
    164, -- Blacksmithing
    165, -- Leatherworking
    171, -- Alchemy
    185, -- Cooking
    333, -- Enchanting
    202, -- Engineering
    129, -- First Aid
    197, -- Tailoring
    356, -- Fishing
    182, -- Herbalism
    186, -- Mining
    393, -- Skinning
    755, -- Jewelcrafting
    773, -- Inscription
}

RGXProf.Constants.ProfessionNameToID = {}
for professionID, profession in pairs(RGXProf.Constants.Professions) do
    if type(professionID) == "number" then
        -- Keep the built-in English name as a fallback if the spell-name API
        -- is unavailable or its data has not been cached during early login.
        RGXProf.Constants.ProfessionNameToID[profession.name] = professionID
    end
end

local professionSpellMap = {
    [164] = 2018,   -- Blacksmithing
    [165] = 2108,   -- Leatherworking
    [171] = 2259,   -- Alchemy
    [185] = 2550,   -- Cooking
    [333] = 7411,   -- Enchanting
    [202] = 4036,   -- Engineering
    [129] = 3273,   -- First Aid
    [356] = 7620,   -- Fishing
    [182] = 2366,   -- Herbalism
    [773] = 45357,  -- Inscription
    [755] = 25229,  -- Jewelcrafting
    [186] = 2575,   -- Mining
    [393] = 8613,   -- Skinning
    [197] = 3908,   -- Tailoring
}
function RGXProf.Constants:InitializeLocalizedProfessionNames()
    for professionID, spellID in pairs(professionSpellMap) do
        local localizedName = RGXProf.WowAPI:GetSpellInfo(spellID)
        if localizedName then
            RGXProf.Constants.Professions[professionID].name = localizedName
            RGXProf.Constants.ProfessionNameToID[localizedName] = professionID
        -- else
        --     print("|cffff0000[RGXProf]|r Failed to localize profession ID:", professionID)
        end
    end
end
