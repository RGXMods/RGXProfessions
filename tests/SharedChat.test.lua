-- Chat goes through the framework's shared chat when it is present: "<icon> - [Professions] message", obeying the
-- standard options (chatOutput, loginMessage, chatPrefix).
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local printed = {}
_G.print = function(...) printed[#printed + 1] = table.concat({ ... }, " ") end
local opts
_G.RGXFramework = { CreateChat = function(_, o)
  opts = o
  local chat = {}
  local function s() return o.storage() end
  function chat:Print(t) if s().chatOutput == false then return end t = t:gsub("^%[RGXProf%] ", "") print("[" .. o.label .. "] " .. t) end
  function chat:Login(t) if s().loginMessage == false then return end self:Print(t) end
  return chat
end }
RGXProf = { Constants = { Colors = { Hex = { BLUE = "" } } } }
RGXProf_Settings = {}
assert(loadfile("UI/Theme.lua"))()
assert(loadfile("Core/Utils.lua"))()
RGXProf.Utils:SendMsg("[RGXProf] hello")
check(printed[1] == "[Professions] hello", "messages use the shared chat voice: " .. tostring(printed[1]))
check(opts.label == "Professions" and opts.tagColor == "8B1538" and opts.name == "RGX Professions", "label and brand colour are passed")
RGXProf.Utils:SendLogin("loaded")
check(#printed == 2, "login message prints")
RGXProf_Settings.loginMessage = false
RGXProf.Utils:SendLogin("loaded")
check(#printed == 2, "login message off prints nothing")
RGXProf_Settings.chatOutput = false
RGXProf.Utils:SendMsg("x")
check(#printed == 2, "chat output off prints nothing")
print = nil
io.write("SharedChat OK\n")

-- Style choice: the framework's saved style is honoured while the theme switch is on.
RGXProf.Brand = RGXProf.Brand or {}
_G.RGXDesign = { ResolveStyle = function(_, n) return ({ forever = "forever", materialround = "materialround" })[n] end }
_G.RGXFrameworkDB = {}
check(RGXProf.ActiveStyle() == "materialround", "no saved style: the addon's own Material Round")
_G.RGXFrameworkDB = { style = "forever" }
check(RGXProf.ActiveStyle() == "forever", "a saved framework style is used")
_G.RGXFrameworkDB = { style = "forever", themeOverride = false }
check(RGXProf.ActiveStyle() == "materialround", "theme switched off: back to the addon's own style")
_G.RGXFrameworkDB = { style = "bogus" }
check(RGXProf.ActiveStyle() == "materialround", "an unknown saved style is ignored")
io.write("ActiveStyle OK\n")

-- The options page reads RGXProf.L as a table: it must not call it.
local src = assert(io.open("UI/OptionsWindow.lua")):read("*a")
assert(src:find("local function L(key, default) return strings[key] or default end", 1, true), "options read strings through a table lookup helper")
assert(not src:find("local L = RGXProf.L", 1, true), "RGXProf.L is a table and is not called directly")
io.write("OptionsStrings OK\n")

-- Options: a header switch per card, tick boxes inside, and the book follows the window.
local ow = assert(io.open("UI/OptionsWindow.lua")):read("*a")
assert(not ow:find("UI:CreateSwitch", 1, true), "no switches inside cards")
assert(select(2, ow:gsub("Tick%(", "")) >= 7 and ow:find('"chatOutput"', 1, true) and ow:find('"minimapIconEnabled"', 1, true) and ow:find('"followProfessionWindow"', 1, true), "three cards, header switches, tick boxes")
local ev = assert(io.open("Core/Events.lua")):read("*a")
assert(ev:find("bookAutoOpen", 1, true) and ev:find("bookAutoClose", 1, true), "the book can open and close with the profession window")
local sm = assert(io.open("Core/StateManager.lua")):read("*a")
assert(sm:find("bookOpen", 1, true) and sm:find("RefreshLegacy", 1, true), "the book refreshes on its own, without the trade-window guide built")
io.write("Options standard OK\n")
