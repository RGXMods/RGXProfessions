-- Regression: after Enchanting, a Tailoring SHOW can briefly expose stale data. The following
-- trade-skill update must re-resolve the open window and switch the book to Tailoring.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local function read(p) local f = assert(io.open(p)); local s = f:read("*a"); f:close(); return s end
local book = read("UI/BookWindow.lua")
local a = assert(book:find("local function GuideID(name)", 1, true))
local b = assert(book:find("function RGXProf.BookWindow:Show()", a, true))
RGXProf = {
    BookWindow = {},
    Constants = { ProfessionNameToID = { Enchanting = 333, Tailoring = 197 } },
    currentExpansion = { paths = { [333] = { { minSkill = 1 } }, [197] = { { minSkill = 1 } } } },
}
RGXProf_Settings = { bookProfessionID = 333, followProfessionWindow = true }
assert(loadstring("local FindCurrentIndex, LiveSkill = ...\n" .. book:sub(a, b - 1)))(
    function() return 4 end, function() return 100 end)
local B = RGXProf.BookWindow
B.frame = { IsShown = function() return true end }
function B:GetCurrentProfession() return RGXProf_Settings.bookProfessionID end
local shown = 0
function B:Show() shown = shown + 1 end

RGXProf._lastProfessionEvent = "TRADE_SKILL_SHOW"
local function StubTradeSkillLine(name)
    rawset(_G, "GetTradeSkillLine", function()
        if not name then return nil end
        return name, 76, 150
    end)
end
StubTradeSkillLine("Enchanting")
B:OnProfessionWindowOpened()
check(RGXProf_Settings.bookProfessionID == 333, "the fixture starts on the stale Enchanting result")
StubTradeSkillLine("Tailoring")
B:OnProfessionWindowOpened()
check(RGXProf_Settings.bookProfessionID == 197 and RGXProf_Settings.bookPage == 4 and shown == 2,
    "fresh open-window data switches Enchanting to Tailoring")

-- A closed craft adapter must not put Enchanting back while Tailoring's direct API is unavailable.
StubTradeSkillLine(nil)
RGXProf.AdapterManager = { GetCurrent = function() return {
    isShown = function() return false end,
    getProfessionInfo = function() return "Enchanting", 82, 150 end,
} end }
check(B:GetOpenProfessionID() == nil, "a hidden stale adapter cannot restore the previous profession")
RGXProf.AdapterManager = { GetCurrent = function() return {
    isShown = function() return true end,
    getProfessionInfo = function() return "Tailoring", 76, 150 end,
} end }
check(B:GetOpenProfessionID() == 197, "the visible current adapter remains a valid fallback")

-- The real event table must call that follow path on later data updates, not just refresh stale content.
local follows, refreshes = 0, 0
RGXProf.BookWindow = { OnProfessionWindowOpened = function() follows = follows + 1 end }
RGXProf.StateManager = { RequestRefresh = function() refreshes = refreshes + 1 end }
assert(loadfile("Core/Events.lua"))()
for _, event in ipairs({ "TRADE_SKILL_UPDATE", "CRAFT_UPDATE", "TRADE_SKILL_LIST_UPDATE" }) do
    local before = follows
    RGXProf.Events[event](RGXProf, event)
    check(follows == before + 1, event .. " re-resolves the open profession")
end
check(refreshes == 3, "all three update paths still request the existing display refresh")
io.write("ProfessionWindowSwitch OK\n")
