-- Run: lua5.1 tests/MaterialsSummary.test.lua   (from the repository root)
-- Checks the to-max materials summary: the pure totals, and which rows the Materials card shows.
local function check(cond, msg) if not cond then error("CHECK FAILED: " .. msg, 2) end end

-- SummarizeMats lives in Core/DataManager.lua; load only that function.
local dm = assert(io.open("Core/DataManager.lua", "r")):read("*a")
local a = assert(dm:find("function RGXProf.DataManager.SummarizeMats", 1, true))
local b = assert(dm:find("\n-- The \"to max\" totals", a, true))
RGXProf = { DataManager = {} }
assert(loadstring(dm:sub(a, b - 1)))()
local Summarize = RGXProf.DataManager.SummarizeMats

local have = { [1] = 10, [2] = 0, [3] = 4 }
local r = Summarize({ [1] = 6, [2] = 5, [3] = 4 }, function(id) return have[id] end)
check(r.items == 3 and r.needed == 15, "items and total needed")
check(r.missing == 5, "missing counts only the shortfall (item 2 short by 5, others covered), got " .. r.missing)
r = Summarize({ [1] = 20 }, function(id) return have[id] end)
check(r.missing == 10, "partially held item contributes its shortfall")
r = Summarize({}, function() return 0 end)
check(r.items == 0 and r.needed == 0 and r.missing == 0, "empty table")
r = Summarize({ [9] = 3 }, nil)
check(r.missing == 3, "no counter means nothing held")

-- BuildMaterialEntries lives in UI/BookWindow.lua between markers.
local bw = assert(io.open("UI/BookWindow.lua", "r")):read("*a")
local s = assert(bw:find("-- BEGIN MATERIAL ENTRIES", 1, true))
local e = assert(bw:find("-- END MATERIAL ENTRIES", s, true))
RGXProf = { BookWindow = {} }
assert(loadstring(bw:sub(s, e - 1)))()
local Build = RGXProf.BookWindow.BuildMaterialEntries

local function reagents(n) local t = {} for i = 1, n do t[i] = { itemID = i } end return t end
local e0 = Build(reagents(0), true)
check(#e0 == 2 and e0[1].kind == "empty" and e0[2].kind == "summary", "no reagent data still shows the summary")
local e3 = Build(reagents(3), true)
check(#e3 == 4 and e3[4].kind == "summary", "3 reagents then the summary")
local e7 = Build(reagents(7), true)
check(#e7 == 8 and e7[7].kind == "reagent" and e7[8].kind == "summary", "7 reagents plus summary fill all 8 rows")
local e10 = Build(reagents(10), true)
check(#e10 == 8, "never more than the card's 8 rows, got " .. #e10)
check(e10[7].kind == "more" and e10[7].hidden == 4, "overflow row counts the hidden reagents (10 - 6)")
check(e10[8].kind == "summary", "summary stays visible when there are many reagents")
local noSummary = Build(reagents(3), false)
check(#noSummary == 3, "no summary row when there is nothing to total")

print("MaterialsSummary test OK")
