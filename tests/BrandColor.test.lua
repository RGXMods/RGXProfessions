-- RGXProfessions is branded by its own primary/accent pair, defined once in UI/Theme.lua, and the
-- framework's RGX Material Round style draws everything from it. It never reads the framework's SHARED
-- theme colour (SimpleQuestPlates sets that to green) and draws no panels or buttons of its own. Also
-- checks the padding rules: list and detail content sit inside their panels, cards start at the canvas edge.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local function read(p) local f = assert(io.open(p)); local s = f:read("*a"); f:close(); return s end

-- 1. No UI file reads the shared highlight/accent colour or hard-codes the brand pair.
local BRAND_LITERAL = "0.545, 0.082, 0.220"
for _, f in ipairs({ "UI/BookWindow.lua", "UI/MatsWindow.lua", "UI/Theme.lua", "UI/LayoutManager.lua", "UI/OptionsWindow.lua" }) do
  local s = read(f)
  for _, key in ipairs({ '"primary"', '"accent"', '"mainBorder"', '"mainSurface"', '"highlight"' }) do
    check(not s:find(key, 1, true), f .. " reads the shared theme colour " .. key)
  end
  check(not s:find("0.1, 1, 0.1", 1, true), f .. " has no hard-coded bright green")
  if f ~= "UI/Theme.lua" then
    check(not s:find(BRAND_LITERAL, 1, true), f .. " hard-codes the brand colour instead of using RGXProf.Brand")
  end
end
local theme = read("UI/Theme.lua")
check(theme:find(BRAND_LITERAL, 1, true) and theme:find("RGXProf.Brand", 1, true), "the brand pair is defined once, in UI/Theme.lua")

-- 2. Card headers: the framework style draws them; the addon only lines the title up with the content.
local src = read("UI/BookWindow.lua")
local a = assert(src:find("local function AlignSection", 1, true))
local b = assert(src:find("\nend\n", a, true))
local AlignSection = assert(loadstring(src:sub(a, b + 4) .. "\nreturn AlignSection"))()
local label = { ClearAllPoints = function(s) s.pt = nil end, SetPoint = function(s, ...) s.pt = { ... } end }
AlignSection({ header = { label = label } })
check(label.pt and label.pt[1] == "LEFT" and label.pt[2] == 6, "card titles line up with the content below them")
check(AlignSection({}) ~= nil, "a section without a header is left alone")
check(not src:find("BrandSection", 1, true) and not src:find("PANEL_BORDER", 1, true), "the guide no longer repaints framework headers or rings by hand")

-- 3. Padding/alignment rules.
check(src:find('f.stepScroll:SetPoint("TOPLEFT", INSET, -INSET)', 1, true), "step rows are inset from the list panel edge")
check(src:find('detail:SetPoint("TOPLEFT", f.detailPanel, "TOPLEFT", 0, 0)', 1, true), "detail content is anchored to its panel (scroll page adds the inset)")
check(src:find('place(detail.recipeCard, 0, 0, full, recipeH)', 1, true), "cards start at the canvas edge, no ad-hoc offsets")
check(src:find('f.backBtn:SetPoint("TOPLEFT", f.stepPanel, "BOTTOMLEFT", 0, -INSET)', 1, true), "Back sits under the step list, left edges aligned")
check(src:find('f.matsBtn:SetPoint("TOPRIGHT", f.stepPanel, "BOTTOMRIGHT", 0, -INSET)', 1, true), "Materials to Max sits under the step list, right edges aligned")
check(src:find("math.floor((LIST_WIDTH - FOOTER_GAP) / 2)", 1, true), "the two buttons split the list width exactly (no overflow)")
check(src:find('row.bgIsSlice = false', 1, true), "step rows use one highlight shape")
-- 4. The "Craft N more" / "Gather until" instruction lines are gold, not the dark crimson.
local render = src:sub(assert(src:find("RenderDetail = function(self)", 1, true)), assert(src:find("LayoutDetail = function(self)", 1, true)))
check(render:find('Instruct() .. "Craft "', 1, true) and render:find('Instruct() .. "Gather until skill "', 1, true), "instruction lines use the gold instruction colour")
check(not render:find('Accent() .. "Craft "', 1, true) and not render:find('Accent() .. "Gather', 1, true), "instruction lines no longer use the crimson accent")
check(src:find('local function Instruct() return "|cffffd100" end', 1, true), "instruction colour is WoW gold")
-- 5. Everything is built through the framework style, in the addon's theme.
check(src:find("RGXProf.Themed(function() BuildFrame(self) end)", 1, true), "the guide is built inside RGXProf.Themed")
check(read("UI/MatsWindow.lua"):find("RGXProf.Themed(function() BuildWindow(self) end)", 1, true), "the Materials overlay is built inside RGXProf.Themed")
check(read("UI/OptionsWindow.lua"):find("RGXProf.Themed(function() return BuildSettings(self) end)", 1, true), "the settings window is built inside RGXProf.Themed")
check(read("UI/LayoutManager.lua"):find("return RGXProf.Themed(function()", 1, true), "the old layout windows are built inside RGXProf.Themed")
check(not src:find("SetPanelColor", 1, true), "no hand-painted panel colours in the guide")
print("BrandColor.test OK")
