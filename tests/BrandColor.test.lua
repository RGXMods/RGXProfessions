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
local chunk = assert(loadstring("local Design = ...\n" .. pre .. src:sub(a, b + 4) .. "\nreturn BrandSection, BRAND_TEXT"))
local BrandSection, BRAND_TEXT = chunk(Design)
local label = { color = sqpGreen }
function label:SetTextColor(r, g, bl) self.color = { r, g, bl } end
local header = { label = label, SetBackdrop = function(s, v) s.backdrop = v end, backdrop = "square" }
BrandSection({ header = header })
check(header.backdrop == nil, "the square header backdrop is removed")
check(header.fill and header.border and header.border[1] > 0.5 and header.border[2] < 0.1, "header is a rounded crimson band")
check(label.color[1] == BRAND_TEXT[1] and label.color[2] == BRAND_TEXT[2], "header title is RGXProfessions crimson, not the shared green")
check(BrandSection({}) ~= nil, "a section without a header is left alone")

-- 3. Padding/alignment rules.
check(src:find('f.stepScroll:SetPoint("TOPLEFT", INSET, -INSET)', 1, true), "step rows are inset from the list panel edge")
check(src:find('detail:SetPoint("TOPLEFT", f.detailPanel, "TOPLEFT", 0, 0)', 1, true), "detail content is anchored to its panel (scroll page adds the inset)")
check(src:find('place(detail.recipeCard, 0, 0, full, recipeH)', 1, true), "cards start at the canvas edge, no ad-hoc offsets")
check(src:find('f.backBtn:SetPoint("BOTTOMLEFT", INSET, 12)', 1, true), "footer buttons line up with the panels' left edge")
check(src:find('row.bgIsSlice = false', 1, true), "step rows use one highlight shape")
print("BrandColor.test OK")
