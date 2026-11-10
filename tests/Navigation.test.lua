-- Navigation and sizing: right click is back, the guide follows the open profession window, the window
-- fits its content without jumping, chat output obeys the settings, and the step list is coloured by state.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local function read(p) local f = assert(io.open(p)); local s = f:read("*a"); f:close(); return s end
local book = read("UI/BookWindow.lua")

-- 1. Right click = back (AttachBack on every clickable surface).
local a = assert(book:find("local function AttachBack", 1, true))
local b = assert(book:find("\nend\n", a, true))
RGXProf = { BookWindow = {} }
local goBack = 0
function RGXProf.BookWindow:GoBack() goBack = goBack + 1 end
local AttachBack = assert(loadstring(book:sub(a, b + 4) .. "\nreturn AttachBack"))()
local hooked
local frame = { HookScript = function(_, name, fn) if name == "OnMouseUp" then hooked = fn end end }
check(AttachBack(frame) == frame and hooked, "AttachBack hooks OnMouseUp and returns the frame")
hooked(frame, "LeftButton"); check(goBack == 0, "left click does not go back")
hooked(frame, "RightButton"); check(goBack == 1, "right click goes back")
check(AttachBack(nil) == nil and AttachBack({}) ~= nil, "frames without HookScript are skipped safely")
local _, uses = book:gsub("AttachBack%(", "")
check(uses - 1 >= 6, "right click is wired on the window, rows, hover areas, materials and location card (" .. (uses - 1) .. ")")

-- 2. GoBack / follow the open profession window.
local g1 = assert(book:find("--- Right click: back from a profession page", 1, true))
local g2 = assert(book:find("function RGXProf.BookWindow:Show()", g1, true))
RGXProf = { BookWindow = {}, Constants = { ProfessionNameToID = { Cooking = 185, Alchemy = 171 } },
  currentExpansion = { paths = { [185] = { { minSkill = 1 } }, [171] = { { minSkill = 1 } } } } }
local settings = {}
RGXProf_Settings = settings
local B = RGXProf.BookWindow
B.frame = { IsShown = function() return true end }
local shown = 0
function B:Show() shown = shown + 1 end
function B:GetCurrentProfession() return settings.bookProfessionID end
assert(loadstring("local FindCurrentIndex, LiveSkill = ...\n" .. book:sub(g1, g2 - 1)))(
  function() return 3 end, function() return 100 end)

settings.bookProfessionID = 185
check(B:GoBack() == true and settings.bookProfessionID == nil and shown == 1, "GoBack leaves the profession page for the list")
check(B:GoBack() == false and shown == 1, "on the profession list there is nothing to go back to")
B.frame = { IsShown = function() return false end }
settings.bookProfessionID = 185
check(B:GoBack() == false and settings.bookProfessionID == 185, "a hidden window does not navigate")
B.frame = { IsShown = function() return true end }

local adapter = { getProfessionInfo = function() return "Alchemy", 80, 150 end }
RGXProf.AdapterManager = { GetCurrent = function() return adapter end }
check(B:GetOpenProfessionID() == 171, "the open profession window is found")
adapter.getProfessionInfo = function() return "Riding", 1, 1 end
check(B:GetOpenProfessionID() == nil, "a profession with no guide is ignored (and nothing is printed)")
adapter.getProfessionInfo = function() error("boom") end
check(B:GetOpenProfessionID() == nil, "an adapter error is contained")
adapter.getProfessionInfo = function() return "Alchemy", 80, 150 end

settings.bookProfessionID, settings.bookPage = nil, nil
check(B:FollowProfessionWindow() == true and settings.bookProfessionID == 171 and settings.bookPage == 3, "the book opens to the open window's profession at the live step")
settings.followProfessionWindow = false
settings.bookProfessionID = nil
check(B:FollowProfessionWindow() == false and settings.bookProfessionID == nil, "the setting turns following off")
settings.followProfessionWindow = nil   -- default: on
settings.bookProfessionID = 185
shown = 0
B:OnProfessionWindowOpened()
check(settings.bookProfessionID == 171 and shown == 1, "a profession window opening while the book is up switches it")
check(read("Core/Events.lua"):find("followProfessionWindow == nil", 1, true), "following defaults to on")
local s0 = book:find("function RGXProf.BookWindow:Show()", 1, true)
local showSrc = book:sub(s0, book:find("local professionID = self:GetCurrentProfession()", s0, true))
check(showSrc:find("if not self.frame:IsShown() then", 1, true) and showSrc:find("FollowProfessionWindow", 1, true), "following applies only when the window opens, so Back is not undone")

-- 3. Window size: default, fit, no jumping.
local f1 = assert(book:find("function RGXProf.BookWindow.FitHeight", 1, true))
local f2 = assert(book:find("\nend\n", f1, true))
RGXProf = { BookWindow = {} }
assert(loadstring(book:sub(f1, f2 + 4)))()
local Fit = RGXProf.BookWindow.FitHeight
check(Fit(300, 130, 470, 900) == 470, "short pages keep the default height")
check(Fit(600, 130, 470, 900) == 730, "a taller page grows the window to fit")
check(Fit(2000, 130, 470, 900) == 900, "the height is capped")
check(Fit(nil, nil, 470, 900) == 470, "missing numbers fall back to the minimum")
check(book:find("local WINDOW_WIDTH = 820", 1, true) and book:find("local WINDOW_HEIGHT = 470", 1, true), "default window is 820x470 (the reference screenshot)")
check(book:find("if f._sizing or RGXProf_Settings.bookSize then return end", 1, true), "a window the player resized by hand is left alone")
check(book:find("if want <= cur + 1 then return end", 1, true), "the window only grows, so paging does not make it jump")
check(book:find('f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)', 1, true), "growing keeps the top edge in place")
check(book:find("        self:FitWindow()\n    else\n        ResetAutoHeight(self)", 1, true), "the list page returns to the default height")

-- 4. Chat output obeys the settings and the prefix is added once.
local printed = {}
_G.print = function(...) printed[#printed + 1] = table.concat({ ... }, " ") end
RGXProf = { Constants = { Colors = { Hex = { BLUE = "|cff0000ff" } } } }
assert(loadfile("UI/Theme.lua"))()
assert(loadfile("Core/Utils.lua"))()
RGXProf_Settings = {}
RGXProf.Utils:SendMsg("[RGXProf] Minimap icon shown")
check(#printed == 1 and printed[1]:find("^|cff8B1538RGX|r") and not printed[1]:find("%[RGXProf%]"), "default messages use the branded prefix and drop the old [RGXProf] tag: " .. tostring(printed[1]))
RGXProf_Settings.chatPrefix = "Profs"
RGXProf.Utils:SendMsg("hi")
check(printed[2] == "|cff0000ffProfs:|r hi", "a prefix the player typed is used as written")
RGXProf_Settings.chatOutput = false
RGXProf.Utils:SendMsg("silent")
check(#printed == 2, "chat output off prints nothing")
local ev = read("Core/Events.lua")
check(ev:find("PLAYER_LOGIN = function", 1, true) and ev:find("settings.loginMessage ~= false", 1, true), "the loaded message at login is gated by its setting")

-- 5. Step list colours by state; the location card says "Recipe location".
check(book:find("nameHex = Dim()", 1, true) and book:find('nameHex = "|cffffffff"', 1, true), "finished steps recede and the current step is bright")
check(read("Constants/Localization.lua"):find('WHERE_TO_GET = "Recipe location"', 1, true), "the card is called Recipe location")
local loc = read("Constants/Localization.lua")
local _, localised = loc:gsub('WHERE_TO_GET = "', "")
check(localised == 12, "every locale defines the card title (" .. localised .. " of 12)")
for _, old in ipairs({ "Wo zu bekommen", "Dónde conseguirlo", "Où l'obtenir", "Dove ottenerlo", "획득 방법", "Onde conseguir", "Где получить", "获取途径", "取得途徑" }) do
  check(not loc:find('WHERE_TO_GET = "' .. old .. '"', 1, true), "'" .. old .. "' is renamed to the recipe-location wording in every locale")
end

-- 6. Addons-menu setting calls the framework and tells the player when a reload is needed.
local ow = read("UI/OptionsWindow.lua")
local s1 = assert(ow:find("function RGXProf.OptionsWindow:SetAddonMenu", 1, true))
local s2 = assert(ow:find("-- The gear in the guide header", s1, true))
local said
RGXProf = { OptionsWindow = {}, L = { OPT_ADDON_MENU_RELOAD = "reload" }, Utils = { SendMsg = function(_, m) said = m end } }
RGXProf_Settings = {}
function RGXProf.OptionsWindow:SetSetting(k, v) RGXProf_Settings[k] = v end
assert(loadstring(ow:sub(s1, s2 - 1)))()
local result, last = true, nil
RGXProf.minimapButton = { SetCompartmentVisible = function(_, v) last = v return result end }
RGXProf.OptionsWindow:SetAddonMenu(false)
check(RGXProf_Settings.addonMenu == false and last == false and said == nil, "turning the Addons-menu entry off is saved and applied")
result = false
RGXProf.OptionsWindow:SetAddonMenu(true)
check(RGXProf_Settings.addonMenu == true and said == "reload", "a client that cannot remove the entry gets a reload hint")
RGXProf.minimapButton = {}
RGXProf.OptionsWindow:SetAddonMenu(false)
check(RGXProf_Settings.addonMenu == false, "an older framework without SetCompartmentVisible is tolerated")
check(read("Core/Core.lua"):find("compartment = RGXProf_Settings.addonMenu ~= false", 1, true), "the button is created with the saved Addons-menu choice")
-- 7. Shipped code uses only the framework's timers (RGX-Framework is a required dependency).
for _, f in ipairs({ "Core/StateManager.lua", "UI/MainWindow.lua", "UI/MatsWindow.lua", "UI/BookWindow.lua", "Core/Events.lua", "Core/Core.lua" }) do
  check(not read(f):find("C_Timer", 1, true), f .. " uses a raw C_Timer instead of RGX:After")
end
print("Navigation.test OK")
