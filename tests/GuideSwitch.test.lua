-- The Guide card's header switch gates every option inside the card: with it off, the book does not open or
-- close with the profession window, the guide does not open with it, and guide clicks do not select recipes.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local function read(p) local f = assert(io.open(p)); local s = f:read("*a"); f:close(); return s end

RGXProf = {}
RGXProf_Settings = {}
assert(loadfile("Core/Utils.lua"))()

check(RGXProf.GuideEnabled() == true, "unset: the guide follows the profession window (default on)")
RGXProf_Settings.followProfessionWindow = true
check(RGXProf.GuideEnabled() == true, "switch on")
RGXProf_Settings.followProfessionWindow = false
check(RGXProf.GuideEnabled() == false, "switch off")

-- Every option inside the card consults the switch.
local events = read("Core/Events.lua")
check(events:find("RGXProf.GuideEnabled() and RGXProf_Settings.bookAutoOpen == true", 1, true), "book auto-open is gated")
check(events:find("RGXProf.GuideEnabled() and RGXProf_Settings.bookAutoClose == true", 1, true), "book auto-close is gated")
check(events:find("RGXProf.GuideEnabled() and self.Settings.autoOpen", 1, true), "guide auto-open is gated")
local state = read("Core/StateManager.lua")
check(state:find("RGXProf.GuideEnabled() and RGXProf.Settings.autoOpen", 1, true), "the refresh path honours the gate")
local _, selects = state:gsub("RGXProf.GuideEnabled%(%) and %(not RGXProf.Settings", "")
check(selects == 1, "recipe selection in the refresh path is gated")
check(read("UI/TooltipHandlers.lua"):find("RGXProf.GuideEnabled() and (not RGXProf.Settings", 1, true), "the select hint is gated")
io.write("GuideSwitch OK\n")
