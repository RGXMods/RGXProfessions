-- Title, icons, tooltips, click-to-pin, settings window, minimap switch, popup lock, removed
-- "source" labels. Each runs the real code from the addon files against small stubs.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local function read(p) local f = assert(io.open(p)); local s = f:read("*a"); f:close(); return s end
local book = read("UI/BookWindow.lua")

-- 1. Title: RGX (red) | (white pipe) Professions (white). A literal pipe in a WoW string is "||": a single
-- "|" starts an escape, so "||r" renders a pipe followed by the letter r (the bug this guards against).
RGXProf = {}
assert(loadfile("UI/Theme.lua"))()
local BrandTitle = RGXProf.BrandTitle
local function render(str)   -- what the client shows: colour codes and |r removed, "||" -> "|"
  local out = str:gsub("||", "\0"):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("%z", "|")
  return out
end
local t = BrandTitle("Professions")
check(t == "|cff8B1538RGX|r |cffffffff|||r |cffffffffProfessions|r", "title string: " .. t)
check(render(t) == "RGX | Professions", "the title renders as 'RGX | Professions' (got '" .. render(t) .. "')")
check(render(BrandTitle("Alchemy")) == "RGX | Alchemy", "profession pages use the same title")
for _, f in ipairs({ "UI/BookWindow.lua", "UI/OptionsWindow.lua", "Core/Core.lua" }) do
  local src = read(f)
  check(not src:find("||r", 1, true), f .. " contains '||r' (a pipe followed by the letter r)")
end
local toc = read("RGXProfessions.toc")
local tocTitle = toc:match("## Title: ([^\r\n]+)")
check(render(tocTitle) == "RGX | Professions", "the TOC title renders as 'RGX | Professions' (got '" .. render(tocTitle) .. "')")
check(RGXProf.Brand.accent[1] > 0.7 and math.abs(RGXProf.Brand.accent[1] - RGXProf.Brand.accent[3]) < 0.1, "the accent is a light grey, not pink")

-- 2. Icons: Forever has no global GetSpellInfo, only C_Spell
RGXProf = { WowAPI = {} }
local api = read("Core/WowAPI.lua")
local i1 = assert(api:find("function RGXProf.WowAPI:GetSpellIcon", 1, true))
local i2 = assert(api:find("function RGXProf.WowAPI:GetReagentInfoByItemID", 1, true))
assert(loadstring(api:sub(i1, i2 - 1)))()
GetSpellInfo = nil
C_Spell = { GetSpellTexture = function(id) return id == 7183 and 134830 or nil end }
check(RGXProf.WowAPI:GetSpellIcon(7183) == 134830, "spell icon comes from C_Spell.GetSpellTexture when the global is gone")
C_Spell = { GetSpellInfo = function() return { iconID = 99 } end }
check(RGXProf.WowAPI:GetSpellIcon(1) == 99, "falls back to C_Spell.GetSpellInfo().iconID")
C_Spell = nil; GetSpellInfo = function() return "n", nil, 77 end
check(RGXProf.WowAPI:GetSpellIcon(1) == 77, "Classic Era's global still works")
C_Item = { GetItemIconByID = function(id) return id == 2589 and 132889 or nil end }
check(RGXProf.WowAPI:GetItemIconInstant(2589) == 132889, "item icon does not wait for the item cache")
check(api:find("icon = icon or self:GetItemIconInstant(itemID)", 1, true), "reagent icons fall back to the instant lookup")
check(not api:find("if GetSpellInfo then\n\t\t\tlocal _, _, spellIcon", 1, true), "recipe icons no longer depend on the removed global")

-- 3. Hover tooltips and click to pin are wired
check(book:find('row:SetScript("OnEnter"', 1, true) and book:find("SetItemByID", 1, true), "material rows show the item tooltip")
check(book:find("detail.locHit", 1, true) and book:find("RGXProf.BookWindow.PinTarget(detail._pinTarget)", 1, true), "the Where card is a click-to-pin button")
check(book:find('btn:HookScript("OnEnter"', 1, true), "profession tiles show a tooltip")
check(book:find("detail.titleHover:SetPoint", 1, true), "icon and name show the recipe tooltip")

-- 4. PinTarget on a client without UiMapPoint (Forever)
local p1 = assert(book:find("function RGXProf.BookWindow.PinTarget", 1, true))
local p2 = assert(book:find("\nend\n", p1, true))
RGXProf = { BookWindow = {}, L = { PIN_SET = "Pinned %s.", PIN_FALLBACK = "%s %.1f %.1f" }, Utils = { SendMsg = function(_, m) RGXProf.said = m end } }
assert(loadstring(book:sub(p1, p2 + 4)))()
local set, tracked
CreateVector2D = function(x, y) return { x = x, y = y } end
C_Map = { CanSetUserWaypointOnMap = function() return true end, SetUserWaypoint = function(pt) set = pt end }
C_SuperTrack = { SetSuperTrackedUserWaypoint = function(v) tracked = v end }
UiMapPoint = nil
check(RGXProf.BookWindow.PinTarget({ name = "Bowen", zoneID = 1420, x = 52.6, y = 55.5 }), "pin succeeds")
check(set and set.uiMapID == 1420 and math.abs(set.position.x - 0.526) < 1e-9 and math.abs(set.position.y - 0.555) < 1e-9, "waypoint uses 0-1 coordinates on the right map")
check(tracked == true and RGXProf.said == "Pinned Bowen.", "the waypoint is tracked and the player is told")
C_Map = nil
local tt
TomTom = { AddWaypoint = function(_, m, x, y, o) tt = { m, x, y, o.title } end }
check(RGXProf.BookWindow.PinTarget({ name = "Bowen", zoneID = 1420, x = 52.6, y = 55.5 }) and tt[1] == 1420, "TomTom is used when the map API is missing")
TomTom = nil
check(RGXProf.BookWindow.PinTarget({ name = "Bowen", zoneID = 1420, x = 52.6, y = 55.5 }) == false and RGXProf.said:find("52.6", 1, true), "last resort: print the coordinates")
check(RGXProf.BookWindow.PinTarget({ name = "x" }) == false, "a target without coordinates is ignored")

-- 5. No "derived/source" labels
local cmd = read("Core/Commands.lua")
check(not cmd:find("change.source", 1, true), "/prof tips no longer prints [Beta data]/[Blizzard] source tags")
for _, bad in ipairs({ "Pattern comes from a vendor", "New recipe in Forever", "Learned from a quest", "Derived from" }) do
  check(not book:find(bad, 1, true), "the page no longer says '" .. bad .. "'")
end

-- 6. Settings window + minimap switch persist and take effect
local ow = read("UI/OptionsWindow.lua")
local o1 = assert(ow:find("-- Show or hide the minimap button now", 1, true))
local o2 = assert(ow:find("-- Show or hide the Blizzard Addons menu entry", o1, true))
RGXProf = { OptionsWindow = {}, L = {} }
RGXProf_Settings = {}
function RGXProf.OptionsWindow:SetSetting(k, v) RGXProf_Settings[k] = v end
local created = 0
RGXProf.CreateMinimapButton = function() created = created + 1; RGXProf.minimapButton = { shown = nil, SetVisible = function(s, v) s.shown = v end } end
assert(loadstring(ow:sub(o1, o2 - 1)))()
RGXProf.OptionsWindow:SetMinimapIcon(false)
check(RGXProf_Settings.minimapIconEnabled == false and created == 0, "turning the icon off is saved and does not build a button")
RGXProf.OptionsWindow:SetMinimapIcon(true)
check(RGXProf_Settings.minimapIconEnabled == true and created == 1 and RGXProf.minimapButton.shown == true, "turning it on saves, builds the button if needed and shows it")
RGXProf.OptionsWindow:SetMinimapIcon(false)
check(RGXProf.minimapButton.shown == false, "turning it off hides the existing button")
check(book:find('f.gear = CreateFrame("Button"', 1, true) and book:find("RGXProf.OptionsWindow:Toggle()", 1, true), "the guide header has a gear that opens the settings window")
for _, key in ipairs({ "OPT_MINIMAP", "OPT_ADDON_MENU", "OPT_FOLLOW", "OPT_AUTOOPEN", "OPT_SELECT", "OPT_CHAT", "OPT_LOGIN" }) do check(ow:find("\"" .. key .. "\"", 1, true), "the settings page offers " .. key) end
check(cmd:find('command == "settings"', 1, true), "/prof settings opens it")

-- 7. Materials popup lock: Escape closes it only while unlocked
local mats = read("UI/MatsWindow.lua")
local m1 = assert(mats:find("function W:SetLocked", 1, true))
local m2 = assert(mats:find("function W:Place()", m1, true))
RGXProf = { MatsWindow = {}, Brand = { accent = { 0.741, 0.765, 0.780 } } }
local W = RGXProf.MatsWindow
RGXProf_Settings = {}
UISpecialFrames = { "OtherFrame" }
local tint
W.frame = { lock = { SetNormalTexture = function(_, tex) W._lockTex = tex end,
  SetVertexColor = function(_, r) tint = r end, SetAlpha = function() end } }
assert(loadstring("local W = RGXProf.MatsWindow\n" .. mats:sub(m1, m2 - 1)))()
W:SetLocked(false)
local function has(n) for _, v in ipairs(UISpecialFrames) do if v == n then return true end end return false end
check(has("RGXProf_MatsWindow") and not W:IsLocked(), "unlocked: Escape closes the popup")
W:SetLocked(true)
check(not has("RGXProf_MatsWindow") and W:IsLocked() and RGXProf_Settings.matsLocked == true, "locked: Escape no longer closes it, and the lock is remembered")
check(W._lockTex:find("Locked-Up", 1, true) and not W._lockTex:find("Unlocked", 1, true), "the lock icon shows the locked state")
check(tint == 0.741, "the locked icon is tinted with the light-grey accent")
W:SetLocked(true)
W:SetLocked(false)
local _, registered = table.concat(UISpecialFrames, ","):gsub("RGXProf_MatsWindow", "")
check(registered == 1, "toggling never registers it twice")
check(mats:find('f.lock = CreateFrame("Button"', 1, true) and mats:find('f.lock:SetPoint("RIGHT", f.close', 1, true), "the lock sits next to the close button")
print("PolishFeatures.test OK")
