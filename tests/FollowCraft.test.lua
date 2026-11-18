-- Opening Enchanting (a craft window) with the book set to follow opens the book on Enchanting, even before the
-- craft frame has switched the current adapter.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local f = assert(io.open("UI/BookWindow.lua")); local src = f:read("*a"); f:close()
local a = assert(src:find("local function GuideID(name)", 1, true))
local b = assert(src:find("--- \"Open to the current profession window\"", a, true))
RGXProf = { BookWindow = {}, Constants = { ProfessionNameToID = { Enchanting = 333, Cooking = 185 } },
  currentExpansion = { paths = { [333] = {}, [185] = {} } } }
assert(loadstring(src:sub(a, b - 1)))()
local B = RGXProf.BookWindow
-- The current adapter still points at the trade skill window (Cooking).
RGXProf.AdapterManager = { GetCurrent = function() return { getProfessionInfo = function() return "Cooking" end } end }
_G.GetCraftDisplaySkillLine = function() return "Enchanting", 82, 150 end
_G.GetTradeSkillLine = function() return "Cooking", 76, 150 end
RGXProf._lastProfessionEvent = "CRAFT_SHOW"
check(B:GetOpenProfessionID() == 333, "a craft window opening is Enchanting, whatever the current adapter says")
RGXProf._lastProfessionEvent = "TRADE_SKILL_SHOW"
check(B:GetOpenProfessionID() == 185, "a trade skill window opening asks the trade skill API")
RGXProf._lastProfessionEvent = nil
check(B:GetOpenProfessionID() == 185, "with no event seen, the current adapter answers")
_G.GetCraftDisplaySkillLine = function() return "Beast Training" end
RGXProf._lastProfessionEvent = "CRAFT_SHOW"
check(B:GetOpenProfessionID() == 185, "a craft line with no guide falls back to the adapter")
local ev = assert(io.open("Core/Events.lua")):read("*a")
check(ev:find('RGXProf._lastProfessionEvent = event', 1, true), "the window event is remembered when a profession window opens")
io.write("FollowCraft OK\n")
