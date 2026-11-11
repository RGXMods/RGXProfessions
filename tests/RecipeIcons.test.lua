-- Recipe icons: the Brilliant Smallfish recipe shows its product's icon (not the rune spell
-- texture), and recipe slots no longer fall back to the question-mark placeholder.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local function read(p) local f = assert(io.open(p)); local s = f:read("*a"); f:close(); return s end

RGXProf = { Constants = {} }
assert(loadfile("Constants/Constants.lua"))()
check(RGXProf.Constants.ProductItemIcons[7751] == 6290, "Brilliant Smallfish (spell 7751) uses product item 6290")

local api = read("Core/WowAPI.lua")
check(api:find("RGXProf.Constants.ProductItemIcons[step.spellID]", 1, true), "spell icons consult the product-item override")
check(api:find("self:GetItemIconInstant(productItem) or icon", 1, true), "the product icon is read without waiting for the item cache")

local layout = read("UI/LayoutDefinitions.lua")
local slot = assert(layout:find('name = base .. "_Button"', 1, true))
local block = layout:sub(slot, slot + 200)
check(not block:find("Textures.default", 1, true), "recipe slot buttons have no question-mark placeholder")

-- Execute the real resolver as well: a source-string check cannot catch a
-- missing output mapping or an icon accidentally taken from an item class ID.
RGXProf.L = { LOADING = "Loading" }
assert(loadfile("Core/WowAPI.lua"))()
local wow = RGXProf.WowAPI
check(RGXProf.Constants.ProductItemIcons[2152] == 2304, "Light Armor Kit uses product item 2304")

C_Spell = { GetSpellTexture = function() return 7 end } -- deliberately wrong spell texture
C_Item = { GetItemIconByID = function(id) return 1000000 + id end }
GetSpellInfo, GetItemIcon, GetItemInfo = nil, nil, nil
local count = 0
for spellID, itemID in pairs(RGXProf.Constants.ProductItemIcons) do
    local display = wow:GetItemLinkAndIconOrSpell({ spellID = spellID, name = "Recipe" })
    check(display.icon == 1000000 + itemID, "product icon wins over a wrong spell texture for " .. spellID)
    check(display.name == "Recipe" and display.link:find("Hspell:" .. spellID, 1, true), "product icon preserves the recipe name and spell link")
    count = count + 1
end
check(count == 92, "all 92 verified Forever recipe outputs are covered (got " .. count .. ")")
check(RGXProf.Constants.ProductItemIcons[1255039] == 252548, "Forever-only Skulker's Leather Gauntlets uses its verified product")
check(wow:GetItemLinkAndIconOrSpell({ spellID = 2152, itemID = 999, name = "Light Armor Kit" }).icon == 1002304,
    "verified product wins even when historical step data carries an incorrect item ID")

-- Every item-producing step in the shipped Forever routes is covered;
-- the seven enchants have no product and intentionally use spell textures.
local paths = { "Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering", "FirstAid", "Leatherworking", "Tailoring" }
local spellOnly = { [7420] = true, [7771] = true, [13501] = true, [13637] = true, [13815] = true, [13948] = true, [20017] = true }
for _, name in ipairs(paths) do
    assert(loadfile("Data/Forever/ProfessionPaths/" .. name .. ".lua"))()
    for _, step in ipairs(RGXProf.ForeverPaths[name]) do
        check(RGXProf.Constants.ProductItemIcons[step.spellID] or spellOnly[step.spellID],
            name .. ": product icon mapping is required for " .. step.name)
    end
end

-- Cold item cache: use the fifth return from GetItemInfoInstant, not the
-- equipment slot, class or subclass. Never wait for a localized item name.
C_Item = { GetItemInfoInstant = function(id) return id, "Armor", "Leather", "INVTYPE_CHEST", 12345, 4, 2 end }
check(wow:GetItemLinkAndIconOrSpell({ spellID = 2152, name = "Light Armor Kit" }).icon == 12345, "uncached product uses instant item icon")
C_Item.GetItemInfoInstant = function(id) return id, "Armor", "Leather", "", nil, 4, 2 end
check(wow:GetItemLinkAndIconOrSpell({ itemID = 2304, name = "Light Armor Kit" }).icon == "Interface\\Icons\\INV_Misc_QuestionMark", "a class ID is never treated as an icon")

C_Item = { GetItemIconByID = function() error("temporarily unavailable") end }
check(wow:GetItemLinkAndIconOrSpell({ spellID = 2152, name = "Light Armor Kit" }).icon == 7, "failed product lookup retains the spell fallback")
C_Item.GetItemInfoInstant = function(id) return id, "Armor", "Leather", "", 12345, 4, 2 end
check(wow:GetItemLinkAndIconOrSpell({ spellID = 2152, name = "Light Armor Kit" }).icon == 12345,
    "failed direct lookup still tries the instant-info icon")
C_Item, C_Spell = nil, nil
GetItemIcon = function(id) return id == 2304 and 54321 end
check(wow:GetItemLinkAndIconOrSpell({ spellID = 2152, name = "Light Armor Kit" }).icon == 54321, "legacy item icon fallback remains supported")
GetItemIcon = nil
check(wow:GetItemLinkAndIconOrSpell({ spellID = 2152, name = "Light Armor Kit" }).icon == "Interface\\Icons\\INV_Misc_QuestionMark", "missing APIs use the placeholder")
C_Spell = { GetSpellTexture = function() return 87654 end }
check(wow:GetItemLinkAndIconOrSpell({ spellID = 99999999, name = "New recipe" }).icon == 87654, "an unknown future product keeps its spell icon")
check(wow:GetItemLinkAndIconOrSpell({ spellID = 7420, name = "Enchant" }).icon == 87654, "an enchant keeps its spell icon")
print("RecipeIcons.test OK (" .. count .. " product mappings and resolver fallbacks)")
