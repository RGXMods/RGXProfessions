-- The detail pane geometry must come from sizes and text, not from frame positions: cards are
-- placed with one anchor plus an explicit size, the Materials/Where cards are level, and nothing
-- overlaps at any window width. Runs the real LayoutDetail from UI/BookWindow.lua.
local f = assert(io.open("UI/BookWindow.lua", "r")); local source = f:read("*a"); f:close()
local a = assert(source:find("LayoutDetail = function(self)", 1, true), "LayoutDetail not found")
local b = assert(source:find("-- Landing page", a, true), "end marker not found")
local chunk = assert(loadstring("local LayoutDetail\n" .. source:sub(a, b - 1) .. "\nreturn LayoutDetail"))

local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end

local function widget(text, lineH, charW)
  local w = { text = text or "", width = 0, points = {} }
  function w:GetText() return self.text end
  function w:SetText(t) self.text = t end
  function w:ClearAllPoints() self.points = {} end
  function w:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function w:SetWidth(v) self.width = v end
  function w:SetHeight(v) self.height = v end
  function w:SetSize(wd, h) self.width, self.height = wd, h end
  function w:GetHeight() return self.height end
  function w:GetWidth() return self.width end
  function w:IsShown() return self.shown ~= false end
  function w:GetStringHeight()   -- word-wrapped height from the width that was set
    local perLine = math.max(1, math.floor(self.width / charW))
    local lines = 0
    for line in (self.text .. "\n"):gmatch("(.-)\n") do lines = lines + math.max(1, math.ceil(#line / perLine)) end
    return lines * lineH
  end
  return w
end
local function card(shown)
  local c = widget("", 12, 6); c.shown = shown; c.contentTopInset = 42; c.contentBottomInset = 12
  c.content = widget("", 12, 6)
  return c
end

local function build(canvasW, textLen)
  local long = string.rep("word ", textLen)
  local detail = {
    canvas = widget("", 12, 6), recipeCard = card(true), matsCard = card(true), locCard = card(true), notesCard = card(true),
    title = widget("Recipe name", 16, 8), meta = widget(long, 12, 6), icon = widget("", 12, 6),
    locHeader = widget(long, 12, 6), locCoords = widget("44.2, 51.0", 12, 6), locAction = widget("Closest to you", 12, 6),
    notes = widget(long, 12, 6), materials = {},
  }
  detail.canvas.width = canvasW
  detail.width, detail.height = canvasW + 16, 400
  function detail:GetWidth() return self.width end
  function detail:GetHeight() return self.height end
  for i = 1, 8 do
    local row = widget("", 12, 6); row.icon = widget("", 12, 6)
    row.name = widget(i <= 5 and long or "", 12, 6); row.shown = i <= 5
    detail.materials[i] = row
  end
  return detail
end

for _, width in ipairs({ 380, 470, 600, 900 }) do
  local detail = build(width, 12)
  local self = { frame = { detail = detail } }
  chunk()(self)
  local r, m, l, n = detail.recipeCard, detail.matsCard, detail.locCard, detail.notesCard
  local function pos(c) return c.points[1][4], -c.points[1][5], c.width, c.height end
  local rx, ry, rw, rh = pos(r); local mx, my, mw, mh = pos(m); local lx, ly, lw, lh = pos(l); local nx, ny, nw, nh = pos(n)
  check(#r.points == 1 and #m.points == 1 and #l.points == 1 and #n.points == 1, width .. ": each card has exactly one anchor (no over-constraint)")
  check(my == ly and mh == lh, width .. ": Materials and Where-to-get-it are level and the same height")
  check(my >= ry + rh, width .. ": middle row starts below the recipe card")
  check(mx + mw <= lx, width .. ": the two columns do not overlap")
  check(lx + lw <= rx + rw + 0.5, width .. ": the right column stays inside the recipe card width")
  check(ny >= my + mh, width .. ": notes start below the middle row")
  check(detail.canvas.height >= ny + nh, width .. ": the canvas is tall enough for every card")
  check(math.abs(mw / (mw + lw) - 0.46) < 0.02, width .. ": the columns split about 46/54")
  -- every wrapped text fits inside its card
  check(detail.meta.height == nil and detail.meta.width <= rw - 32, width .. ": meta text is narrower than the recipe card")
end

-- A narrower window makes wrapped text taller, and the cards grow with it (no clipping).
local narrow, wide = build(380, 20), build(900, 20)
chunk()({ frame = { detail = narrow } }); chunk()({ frame = { detail = wide } })
check(narrow.recipeCard.height > wide.recipeCard.height, "narrow window: the recipe card grows to fit wrapped text")

-- Hidden notes card is skipped.
local d = build(600, 4); d.notesCard.shown = false
chunk()({ frame = { detail = d } })
check(d.notesCard.points[1] == nil, "a hidden notes card is not positioned")
print("DetailLayout.test OK")
