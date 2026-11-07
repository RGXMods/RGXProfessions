-- Materials to Max: the per-rank data is right (cumulative tiers, missing-first sort, totals), and the
-- real window renders it: one tab per rank, the final cap selected, aligned rows, live refresh.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local function read(p) local f = assert(io.open(p)); local s = f:read("*a"); f:close(); return s end

-- 1. DataManager:GetRemainingMaterialsTiers with a fake bucket computation.
local dm = read("Core/DataManager.lua")
local a = assert(dm:find("function RGXProf.DataManager:GetRemainingMaterialsTiers", 1, true))
local b = assert(dm:find("function RGXProf.DataManager:getTierLabel", a, true))
local buckets = {
  { skillCap = 150, mats = { [1] = 10, [2] = 5 } },
  { skillCap = 225, mats = { [1] = 30, [2] = 5, [3] = 8 } },
}
RGXProf = { DataManager = { getTierLabel = function(_, cap) return ({ [150] = "Journeyman", [225] = "Expert" })[cap] end } }
assert(loadstring("local ComputeRemainingBuckets = ...\n" .. dm:sub(a, b - 1)))(function() return buckets end)
local names = { [1] = "Silk Cloth", [2] = "Coarse Thread", [3] = "Bleach" }
local held = { [1] = 12, [2] = 0, [3] = 8 }
local tiers = RGXProf.DataManager:GetRemainingMaterialsTiers(100, {}, function(id) return names[id], "icon" .. id, held[id] end)
check(#tiers == 2 and tiers[1].label == "Journeyman" and tiers[2].skillCap == 225, "one tier per remaining rank")
local t1 = tiers[1]
check(t1.items[1].itemID == 2 and t1.items[2].itemID == 1, "items still to get come first")
check(t1.missing == 5 and t1.ready == 1 and t1.needed == 15 and t1.have == 10, "tier totals count only what is still short")
local t2 = tiers[2]
check(t2.items[1].name == "Coarse Thread" and t2.items[2].name == "Silk Cloth" and t2.items[3].name == "Bleach",
  "missing items by name, then ready items")
check(t2.missing == 5 + 18 and t2.ready == 1, "later tiers are cumulative")
check(#RGXProf.DataManager:GetRemainingMaterialsTiers(1, nil) == 0, "no path, no tiers")

-- 2. The real window against a recording frame stub.
local created = {}
local function frame(kind, name)
  local f = { kind = kind, shown = kind ~= "Frame-root", points = {}, w = 0, h = 0, text = nil, children = {} }
  if name then _G[name] = f end
  local mt = {}
  mt.__index = function(t, k)
    if k == "Show" then return function(s) s.shown = true end end
    if k == "Hide" then return function(s) s.shown = false end end
    if k == "IsShown" then return function(s) return s.shown end end
    if k == "SetText" then return function(s, v) s.text = v end end
    if k == "GetText" then return function(s) return s.text end end
    if k == "SetWidth" then return function(s, v) s.w = v end end
    if k == "SetHeight" then return function(s, v) s.h = v end end
    if k == "SetSize" then return function(s, x, y) s.w, s.h = x, y end end
    if k == "GetWidth" then return function(s) return s.w end end
    if k == "GetHeight" then return function(s) return s.h end end
    if k == "SetPoint" then return function(s, ...) s.points[#s.points + 1] = { ... } end end
    if k == "ClearAllPoints" then return function(s) s.points = {} end end
    if k == "SetScript" then return function(s, n, fn) s["on" .. n] = fn end end
    if k == "GetVerticalScroll" then return function() return 0 end end
    if k == "SetScale" then return function(s, v) s.scale = v end end
    if k == "GetScale" then return function(s) return s.scale or 1 end end
    if k == "CreateTexture" then return function() return frame("Texture") end end
    if k == "CreateFontString" then return function() return frame("FontString") end end
    return function(s) return s end
  end
  setmetatable(f, mt)
  created[#created + 1] = f
  return f
end
function CreateFrame(kind, name) local f = frame(kind, name); f.shown = true; return f end
UIParent, UISpecialFrames, RGXProf_Settings = frame("Frame"), {}, {}
_G.RGXDesign = {
  ApplyPanel = function(_, f) f.SetPanelColor = function(s, fill) s.fill = fill end end,
  CreateFrame = function(self, parent, opts)
    check(opts.square == false, "every panel in the window is rounded")
    local f = frame("Frame", opts.name); f.shown = true; f.w, f.h = opts.width or 0, opts.height or 0
    self:ApplyPanel(f); return f
  end,
  Unpack = function() return 0.1, 0.1, 0.12 end,
}
RGXProf.L = {}
RGXProf.WowAPI = { GetItemInfo = function() return nil end }
local liveTiers = tiers
RGXProf.DataManager.GetRemainingMaterialsTiers = function() return liveTiers end
assert(loadfile("UI/MatsWindow.lua"))()
local MW = RGXProf.MatsWindow
MW:Show({ icon = 1, name = "Tailoring", currentSkill = 100, path = { { maxSkill = 300 } } })
local f = MW.frame
check(f:IsShown(), "the window shows")
check(f.title.text == "Tailoring" and f.sub.text:find("100", 1, true) and f.sub.text:find("300", 1, true), "title bar shows the profession and skill / cap")
check(#f.tabs == 2 and f.tabs[1].text.text == "To 150" and f.tabs[2].text.text == "To 225", "one tab per rank")
check(MW.selectedCap == 225 and f.tabs[2]._on and not f.tabs[1]._on, "the final cap is selected by default")
check(f.tierHeader.text:find("Expert", 1, true), "tier header names the rank")
check(f.totals.text:find("3 items", 1, true) and f.totals.text:find("23 to get", 1, true), "totals line")
local shown = 0
for _, row in ipairs(f.rows) do if row.shown then shown = shown + 1 end end
check(shown == 3, "one row per material (" .. shown .. ")")
check(f.rows[1].have.text == "0" and f.rows[1].need.text == "5", "have / need columns")
check(f.rows[2].points[1][5] == -20 and #f.rows[2].points == 2, "rows stack at the (compact) row height and span the list")
check(f.content.h == 60, "the scroll content is exactly as tall as the rows")

f.tabs[1].onOnClick()
check(MW.selectedCap == 150 and f.tabs[1]._on, "clicking a tab selects that rank")
shown = 0
for _, row in ipairs(f.rows) do if row.shown then shown = shown + 1 end end
check(shown == 2, "the list follows the selected rank")

liveTiers = {}
MW:Refresh()
check(f.empty.shown and f.empty.text:lower():find("cap", 1, true), "at the cap the window says so instead of an empty list")
-- Minimal overlay: compact default, see-through, resizable within bounds, Ctrl+wheel scaling remembered.
check(f.w == 300 and f.h == 330, "compact default size (" .. f.w .. "x" .. f.h .. ")")
check(MW:SetSize(100, 5000) and f.w == 240 and f.h == 900, "resizing is clamped to 240x200 .. 640x900")
check(MW:SetScale(5) == 1.6 and RGXProf_Settings.matsScale == 1.6, "scale is clamped and saved")
IsControlKeyDown = function() return true end
f.onOnMouseWheel(f, -1)
check(math.abs(RGXProf_Settings.matsScale - 1.55) < 1e-9, "Ctrl + mouse wheel scales the overlay")
IsControlKeyDown = function() return false end
f.onOnMouseWheel(f, -1)
check(math.abs(RGXProf_Settings.matsScale - 1.55) < 1e-9, "the plain mouse wheel does not scale")
check(f.grip and f.grip.onOnDragStart and f.grip.onOnDragStop, "a corner grip resizes the overlay")
MW:Hide()
check(not f:IsShown(), "hides")
print("MatsWindow.test OK")
