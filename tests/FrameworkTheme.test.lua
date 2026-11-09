-- RGXProfessions draws nothing itself: it builds through the framework's RGX Material Round style in its
-- own primary/accent. This runs the REAL framework design.lua (when a sibling RGX-Framework checkout is
-- present; CI without it skips) and proves the result: panels ringed in the addon's primary, card titles in
-- its accent, rounded buttons, and the shared theme and style left exactly as they were.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local function exists(p) local f = io.open(p, "rb"); if f then f:close() return true end end
local path
local override = os.getenv("RGXFW_PATH")
local candidates = { "../RGX-Framework/libraries/design/design.lua", "../../RGX-Framework/libraries/design/design.lua" }
if override then table.insert(candidates, 1, override .. "/libraries/design/design.lua") end
for _, p in ipairs(candidates) do
  if exists(p) then path = p break end
end
if not path then print("FrameworkTheme.test SKIPPED (no RGX-Framework checkout next to this addon)") return end

local function widget(kind, parent)
  local w = { kind = kind, parent = parent, scripts = {} }
  return setmetatable(w, { __index = function(t, k)
    if type(k) == "string" and k:sub(1, 1) == "_" then return nil end   -- private fields exist only when set
    if k == "SetVertexColor" then return function(s, r, g, b, a) s.vertex = { r, g, b, a } end end
    if k == "SetTextColor" then return function(s, r, g, b) s.textColor = { r, g, b } end end
    if k == "SetText" then return function(s, v) s.text = v end end
    if k == "SetScript" then return function(s, n, fn) s.scripts[n] = fn end end
    if k == "CreateTexture" then return function(s) return widget("Texture", s) end end
    if k == "CreateFontString" then return function(s) return widget("FontString", s) end end
    if k == "GetFont" then return function() return "f", 12, "" end end
    return function(s) return s end
  end })
end
function CreateFrame(kind, _, parent) return widget(kind, parent) end
UIParent = widget("Frame")
GameTooltip = widget("Tooltip")
local modules = {}
RGXFramework = { RegisterModule = function(_, name, m) modules[name] = m end }
assert(loadfile(path))("RGX-Framework", RGXFramework)
local D = _G.RGXDesign
if not (D and D.WithStyle and D.ResolveStyle and D:ResolveStyle("materialround")) then
  print("FrameworkTheme.test SKIPPED (the framework checkout next to this addon predates RGX Material Round, v2.15)")
  return
end

assert(loadfile("UI/Theme.lua"))()
local B = RGXProf.Brand
local function near(c, t) return math.abs(c[1] - t[1]) < 1e-6 and math.abs(c[2] - t[2]) < 1e-6 and math.abs(c[3] - t[3]) < 1e-6 end

-- another addon owns the shared theme
D:SetThemePreset("green")
local sharedPrimary = { D:Unpack("primary") }
local style, corner = D:GetStyle(), D.cornerStyle

local card, header, button, hoverRing
RGXProf.Themed(function()
  card = D:CreateFrame(UIParent, {})
  local section = D:CreateSection(UIParent, "Materials", nil, {})
  header = section.header
  button = RGXProf.NewButton(UIParent, "Back", 100, 26)
end)

check(card._panelBorder and near(card._panelBorder[1].vertex, B.primary), "panels are ringed in the addon's primary colour, not the shared green")
check(header._panelBorder and near(header._panelBorder[1].vertex, B.primary), "card header bands use the addon ring too")
check(near(header.label.textColor, B.accent), "card titles use the addon's accent colour")
check(button._panelBorder, "buttons are rounded (framework Material Round button)")
button.scripts.OnEnter(button)
check(button.label.textColor and near(button.label.textColor, B.accent), "button hover label is the addon accent")

-- nothing leaks to the rest of the suite
check(near({ D:Unpack("primary") }, sharedPrimary), "the shared primary colour is untouched")
check(D:GetStyle() == style and D.cornerStyle == corner, "the shared style is untouched")
local plainButton = D:CreateButton(UIParent, "x", 80, 22)
check(plainButton._panelBorder == nil, "other addons still get the default square button")

-- an older framework without styles: the builder simply runs
local withStyle = D.WithStyle
D.WithStyle = nil
local ran = false
check(RGXProf.Themed(function() ran = true return "built" end) == "built" and ran, "without WithStyle the builder still runs and returns its result")
D.WithStyle = withStyle
print("FrameworkTheme.test OK")
