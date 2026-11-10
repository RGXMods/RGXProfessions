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

print("RecipeIcons.test OK")
