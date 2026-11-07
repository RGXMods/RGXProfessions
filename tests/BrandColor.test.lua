-- RGXProfessions uses its own crimson, never the framework's SHARED theme colour (SimpleQuestPlates
-- sets that to green, which used to paint RGXProfessions' card headers and accents). Also checks the
-- padding rules: list and detail content sit inside their panels, cards start at the canvas edge.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local function read(p) local f = assert(io.open(p)); local s = f:read("*a"); f:close(); return s end

-- 1. No UI file reads the shared highlight/accent colour.
for _, f in ipairs({ "UI/BookWindow.lua", "UI/MatsWindow.lua", "UI/RoundedButton.lua", "UI/LayoutManager.lua", "UI/OptionsWindow.lua" }) do
  local s = read(f)
  for _, key in ipairs({ '"primary"', '"accent"', '"mainBorder"', '"mainSurface"', '"highlight"' }) do
    check(not s:find(key, 1, true), f .. " reads the shared theme colour " .. key)
  end
  check(not s:find("0.1, 1, 0.1", 1, true), f .. " has no hard-coded bright green")
end

-- 2. BrandSection repaints a framework card header even when the shared colour is SQP green.
local src = read("UI/BookWindow.lua")
local a = assert(src:find("local function BrandSection", 1, true))
local b = assert(src:find("\nend\n", a, true))
local pre = src:match("(local BRAND_BORDER = .-local INSET = %d+[^\n]*\n)")
assert(pre, "brand constants block")
local sqpGreen = { 0.345, 0.745, 0.506 }
local Design = { ApplyPanel = function(_, f) f.SetPanelColor = function(s, fill, border) s.fill, s.border = fill, border end end }
local chunk = assert(loadstring("local Design = ...\n" .. pre .. src:sub(a, b + 4) .. "\nreturn BrandSection, HEADER_TEXT, PANEL_BORDER"))
local BrandSection, HEADER_TEXT, PANEL_BORDER = chunk(Design)
local label = { color = sqpGreen }
function label:SetTextColor(r, g, bl) self.color = { r, g, bl } end
local header = { label = label, SetBackdrop = function(s, v) s.backdrop = v end, backdrop = "square" }
BrandSection({ header = header })
check(header.backdrop == nil, "the square header backdrop is removed")
check(header.fill and header.border == PANEL_BORDER and header.fill[1] == header.fill[2], "header is a rounded neutral grey band (RGX look, not red)")
check(label.color[1] == HEADER_TEXT[1] and label.color[2] == HEADER_TEXT[2] and label.color[2] ~= sqpGreen[2], "header title uses RGXProfessions' own text colour, not the shared green")
check(BrandSection({}) ~= nil, "a section without a header is left alone")

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
-- 5. Panels use the neutral grey ring; crimson is not used as a panel border.
check(not src:find("SetPanelColor(nil, BRAND_BORDER)", 1, true), "no panel is ringed in crimson")
check(select(2, src:gsub("SetPanelColor%(nil, PANEL_BORDER%)", "")) == 3, "window, step list and detail panels use the neutral ring")
print("BrandColor.test OK")
