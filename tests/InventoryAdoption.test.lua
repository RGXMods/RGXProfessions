local function check(value, message)
    if not value then error("CHECK FAILED: " .. message, 2) end
end
local held = { [10] = 60, [20] = 250 }
local calls = {}
C_Item = {
    GetItemCount = function(id, bank, uses, reagent)
        check(bank == false and uses == false and reagent == false, "guide queries bags only through correct native positions")
        calls[id] = (calls[id] or 0) + 1
        return held[id]
    end,
    GetItemInfo = function(id)
        return "Material " .. id, "|Hitem:" .. id .. "|h[Material]|h", nil, nil, nil, nil, nil, nil, nil, 1000 + id
    end,
}
local framework = assert(loadfile("tests/InventoryFixture.lua"))()
RGXProf = {
    Data = { Recipes = { [1] = { [10] = 2 }, [2] = { [10] = 1, [20] = 1 } } },
    Constants = { TierLabels = { [75] = "Apprentice", [150] = "Journeyman", [225] = "Expert", [300] = "Artisan" } },
    currentExpansion = { tiers = { 75, 150, 225, 300 } },
    L = { LOADING = "Loading", SKILL_TIER_FALLBACK = "Skill %d", ITEM_ID_FALLBACK = "ItemID:" },
}
assert(loadfile("Core/WowAPI.lua"))()
assert(loadfile("Core/DataManager.lua"))()
local dm = RGXProf.DataManager
local path = {
    { minSkill = 1, maxSkill = 100, spellID = 1, crafts = 198 },
    { minSkill = 100, maxSkill = 300, spellID = 2, crafts = 200 },
}
local summary = dm:GetRemainingMaterialsSummary(50, path)
check(summary.items == 2 and summary.needed == 600 and summary.missing == 340 and summary.countsKnown,
    "shared aggregation preserves cumulative route estimates and live shortages")
local tiers = dm:GetRemainingMaterialsTiers(50, path)
check(#tiers == 4 and tiers[1].needed == 100 and tiers[1].missing == 40, "first remaining rank")
check(tiers[4].needed == 600 and tiers[4].missing == 340, "last rank matches the in-book summary")
check(tiers[4].items[1].itemID == 10 and tiers[4].items[2].itemID == 20, "missing-first display order is retained")
check(tiers[4].items[1].name == "Material 10" and tiers[4].items[1].icon == 1010, "shared metadata reaches the UI model")
check(#dm:GetRemainingMaterialsTiers(300, path) == 0, "no tiers remain at the cap")
local rows = dm:GetReagentListWithDetails(2, 5)
check(#rows == 2, "per-step material rows come from the shared material plan")
for _, row in ipairs(rows) do
    check(row.requiredCount == 5 and row.countKnown == true, "required counts and known state")
    check(row.link:find("|Hitem:", 1, true), "shared metadata preserves clickable item links")
end
held[10] = nil
summary = dm:GetRemainingMaterialsSummary(50, path)
check(summary.countsKnown == false and summary.missing == nil, "unknown inventory is not advertised as a definite shortage")
rows = dm:GetReagentListWithDetails(1, 2)
check(rows[1].countKnown == false, "unknown per-step counts are explicitly marked for question-mark rendering")
tiers = dm:GetRemainingMaterialsTiers(50, path)
check(tiers[4].countsKnown == false and tiers[4].missing == nil, "unknown totals remain unknown in Materials to Max")

-- Exercise the real recipe hover renderer with denied count data.
local file = assert(io.open("UI/BookWindow.lua"))
local source = file:read("*a"); file:close()
local a = assert(source:find("local function ShowStepMaterials", 1, true))
local b = assert(source:find("local function SelectedPage", a, true))
local hover = assert(loadstring("local StepDifficulty, LiveSkill, C, Text, Dim = ...\n"
    .. source:sub(a, b - 1) .. "\nreturn ShowStepMaterials"))(
    function() end, function() return 1 end, function() return "" end,
    function() return "" end, function() return "" end)
local tooltipLines = {}
GameTooltip = {
    SetOwner = function() end, SetText = function() end, Show = function() end,
    AddLine = function(_, text) tooltipLines[#tooltipLines + 1] = text end,
}
hover({}, { spellID = 1, name = "Recipe", minSkill = 1, maxSkill = 3, crafts = 2 })
check(tooltipLines[#tooltipLines]:find("(?/4)", 1, true), "recipe hover shows unknown ownership, never a fabricated zero")

local requests, materials, overlay = 0, 0, 0
RGXProf.AdapterManager = { registeredAdapters = {} }
RGXProf.StateManager = { RequestRefresh = function() requests = requests + 1 end }
RGXProf.BookWindow = { RefreshMaterials = function() materials = materials + 1 end }
RGXProf.MatsWindow = { Refresh = function() overlay = overlay + 1 end }
assert(loadfile("Core/Events.lua"))()
RGXProf:RegisterEvents()
RGXProf:RegisterEvents()
local bags, itemInfo = 0, 0
for _ in pairs(framework.events.BAG_UPDATE_DELAYED) do bags = bags + 1 end
for _ in pairs(framework.events.GET_ITEM_INFO_RECEIVED) do itemInfo = itemInfo + 1 end
check(bags == 1 and itemInfo == 1, "only the shared owner subscribes to native inventory events")
framework:FireEvent("BAG_UPDATE_DELAYED")
check(requests == 1 and materials == 1 and overlay == 1, "one shared bag notification refreshes all consumer surfaces once")
framework:FireEvent("GET_ITEM_INFO_RECEIVED", 10, false)
check(requests == 1, "failed metadata responses do not start refresh/request loops")
framework:FireEvent("GET_ITEM_INFO_RECEIVED", 10, true)
check(requests == 2 and overlay == 2, "successful item metadata flows through the shared subscription")
RGXProf._inventoryUnsubscribe()
framework:FireEvent("BAG_UPDATE_DELAYED")
check(requests == 2, "unsubscribe detaches the consumer without replacing shared plumbing")
print("InventoryAdoption.test OK")
