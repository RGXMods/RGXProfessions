-- Every RGXProfessions frame uses the rounded RGX theme: the guide's four cards ask for rounded
-- sections, and the LayoutManager windows (materials, mini, main) get a rounded shell, rounded cards
-- and readable text instead of PortraitFrameTemplate + gold dialog borders + parchment.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local function read(p) local f = assert(io.open(p)); local s = f:read("*a"); f:close(); return s end

-- 1. Guide cards
local book = read("UI/BookWindow.lua")
local n = 0
for line in book:gmatch("[^\n]*UI:CreateSection%([^\n]*") do
  n = n + 1
  check(line:find("square = false", 1, true), "guide card is rounded: " .. line:match("title = [^,}]*"))
end
check(n == 4, "all four guide cards checked (" .. n .. ")")

-- 2. LayoutManager windows, with a recording frame stub
local backdrops, panels, globals = 0, 0, {}
local function frame(name)
  local f = { scripts = {}, shown = true, name = name }
  if name then _G[name] = f end
  return setmetatable(f, { __index = function(t, k)
    if k == "SetBackdrop" then return function() backdrops = backdrops + 1 end end
    if k == "CreateTexture" then return function(_, tn) local tx = frame(tn); if tn then globals[tn] = tx end return tx end end
    if k == "CreateFontString" then return function() local fs = frame(); fs.SetTextColor = function(s, r, g, b) s.color = { r, g, b } end
      fs.SetText = function(s, v) s.text = v end; fs.GetStringHeight = function() return 12 end; return fs end end
    if k == "GetWidth" or k == "GetHeight" then return function() return 300 end end
    if k == "GetName" then return function(s) return s.name end end
    return function(s) return s end
  end })
end
function CreateFrame(_, name) return frame(name) end
UIParent, UISpecialFrames = frame(), {}
_G.RGXDesign = {
  Unpack = function() return 0.5, 0.1, 0.2 end,
  ApplyPanel = function(_, f) panels = panels + 1; f._panelFill = {}; f.SetPanelColor = function() end end,
  CreateFrame = function(self, parent, opts)
    check(opts.square == false, "window shell is a rounded panel")
    local f = frame(opts.name); self:ApplyPanel(f); return f
  end,
}
RGXProf = { Constants = { Textures = { default = "x" }, Colors = { RGB = { BLK = { 0, 0, 0 }, BRN = { .24, .16, .11 }, WHT = { 1, 1, 1 } } } },
  Layouts = { Defaults = { backdrop = { style = {}, color = { 0, 0, 0, 1 }, borderColor = { 1, 1, 1, 1 } } } } }
assert(loadfile("UI/LayoutManager.lua"))()
local LM = RGXProf.LayoutManager
LM.HookTooltip = function() end
LM.MakeDraggable = function() end

local win = LM:CreateBackFrame("RGXProf_Test_BackFrame", { template = "PortraitFrameTemplate", width = 300, height = 200,
  titleText = "RGX Professions", draggable = true, textureSettings = { layer = "BACKGROUND", texture = "Interface\\QuestFrame\\QuestBG" } })
check(globals["RGXProf_Test_BackFramePortrait"], "the window keeps a global <name>Portrait texture for SetPortrait")
check(rawget(win, "TitleText") and win.TitleText.text == "RGX Professions", "the window title comes from titleText")
check(rawget(win, "CloseButton") ~= nil, "the window has a close button")
check(rawget(win, "texture") == nil, "no parchment background on the themed window")

local before = panels
local section = LM:CreateSection(win, { name = "S", backdrop = { style = { bgFile = "x" }, color = { 1, 1, 1, 1 }, borderColor = { 1, 1, 1, 1 } } }, { layoutGroup = {} })
check(panels == before + 1 and rawget(section, "_rgxCard"), "a backdrop section becomes a rounded card")
LM:CreateSection(win, { name = "O", outline = true }, { layoutGroup = {} })
LM:CreateScrollFrame(win, { name = "Sc", height = 90 }, { layoutGroup = {} })
check(backdrops == 0, "no Blizzard backdrop (gold dialog / tooltip edge) is applied anywhere (" .. backdrops .. ")")

local body = LM:CreateFontString(win, { name = "b", color = RGXProf.Constants.Colors.RGB.BLK }, {})
local title = LM:CreateFontString(win, { name = "t", color = RGXProf.Constants.Colors.RGB.BRN }, {})
local white = LM:CreateFontString(win, { name = "w", color = RGXProf.Constants.Colors.RGB.WHT }, {})
check(body.fontString.color[1] > 0.8, "black body text becomes light on the dark panel")
check(title.fontString.color[1] == 1 and title.fontString.color[2] > 0.7, "brown titles become gold")
check(white.fontString.color[1] == 1 and white.fontString.color[3] == 1, "already-light text is untouched")
print("RoundedTheme.test OK")

-- 3. Buttons are rounded and every texture path resolves.
local bookSrc = read("UI/BookWindow.lua")
check(bookSrc:find("local NewButton = RGXProf.NewButton", 1, true), "the guide builds its buttons through the framework-backed helper")
check(not bookSrc:find("Design:CreateButton", 1, true), "no direct square framework button left in the guide")
check(not bookSrc:find("media\\\\panel_rounded", 1, true), "no texture path points at the missing media\\panel_rounded.tga")
for _, f in ipairs({ "UI/BookWindow.lua", "UI/LayoutManager.lua", "UI/Theme.lua", "UI/MatsWindow.lua", "UI/MainWindow.lua" }) do
  for path in read(f):gmatch('"Interface\\\\AddOns\\\\([%w_%-]+\\\\[^"]-%.tga)"') do
    local rel = path:gsub("\\\\", "/")
    local addon = rel:match("^([^/]+)/")
    -- the framework is only checked where a sibling checkout exists (not in CI)
    if addon == "RGXProfessions" or io.open("../" .. addon .. "/" .. addon .. ".toc", "rb") then
      local ok = io.open(addon == "RGXProfessions" and rel:gsub("^RGXProfessions/", "") or ("../" .. rel), "rb")
      check(ok, f .. ": texture exists: " .. path)
      if ok then ok:close() end
    end
  end
end
local th = read("UI/Theme.lua")
check(th:find("_G.RGXDesign:CreateButton", 1, true) and th:find("PANEL_TEX", 1, true), "buttons come from the framework and the panel texture path from its Design")
local toc = read("RGXProfessions.toc")
check(toc:find("UI/Theme.lua", 1, true) and not toc:find("RoundedButton", 1, true), "Theme.lua is in the TOC and the local rounded-button copy is gone")
check(toc:find("X-RGX-Framework-MinVersion: 2.16.0", 1, true), "the addon requires the framework with RGX Material Round and the Addons-menu toggle")
print("RoundedTheme (buttons/textures) OK")
