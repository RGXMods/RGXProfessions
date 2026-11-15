-- Waypoints from the profession-window guide use the game's own map pin, the same one the book sets; no
-- waypoint addon is involved.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
RGXProf = { AdapterManager = { registeredAdapters = {} }, BookWindow = {}, Utils = { SendMsg = function() end } }
assert(loadfile("Adapters/AdapterManager.lua"))()
local pinned
RGXProf.BookWindow.PinTarget = function(t) pinned = t return true end
C_Map = nil
check(RGXProf.AdapterManager:HasNavigationAddon() == false, "no map pin API: no waypoint offered")
C_Map = { SetUserWaypoint = function() end }
check(RGXProf.AdapterManager:HasNavigationAddon() == true, "the game's map pin is always offered when the client has it")
RGXProf.AdapterManager:SetWaypoint("Bowen", 1420, 52.6, 55.5)
check(pinned and pinned.name == "Bowen" and pinned.zoneID == 1420 and pinned.x == 52.6 and pinned.y == 55.5, "the guide's waypoint goes through the book's map pin")
local toc = assert(io.open("RGXProfessions.toc")):read("*a")
check(not toc:find("NavigationAdapter", 1, true), "no waypoint-addon adapter is loaded")
for adapterFile in toc:gmatch("Adapters[/\\](%w+)%.lua") do
  check(({ AddonAdapter = true, TradeskillAdapter = true, CraftAdapter = true, AdapterManager = true })[adapterFile],
    "only the game's own profession windows have adapters (" .. adapterFile .. ")")
end
io.write("MapPin OK\n")
