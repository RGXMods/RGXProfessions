local function check(value, message)
    if not value then error("CHECK FAILED: " .. message, 2) end
end
RGXProf = {
    L = { LOADING = "Loading" }, Constants = { SkillUpColors = { none = {} } },
    Data = { Recipes = { [7183] = { [765] = 2 } } },
}
assert(loadfile("Core/WowAPI.lua"))()
assert(loadfile("Core/DataManager.lua"))()
local requests, ready = 0, false
C_Item = {
    GetItemInfo = function()
        if ready then return "Silverleaf", "|Hitem:765|h[Silverleaf]|h", nil, nil, nil, nil, nil, nil, nil, 123 end
    end,
    RequestLoadItemDataByID = function(id)
        check(id == 765, "the exact reagent is requested")
        requests = requests + 1
    end,
    GetItemIconByID = function() return 123 end,
    GetItemCount = function() return nil end,
}
GetItemInfo = nil
assert(loadfile("tests/InventoryFixture.lua"))()
local api, dm = RGXProf.WowAPI, RGXProf.DataManager
local rows = dm:GetReagentListWithDetails(7183, 3)
check(requests == 1, "a cold lookup requests data once, not twice")
check(rows[1].name == "Loading (#765)" and rows[1].icon == 123, "uncached names stay identifiable with their instant icon")
check(rows[1].onHandCount == 0 and rows[1].displayText == "0/6", "unavailable counts cannot break rendering")
ready = true
rows = dm:GetReagentListWithDetails(7183, 3)
check(rows[1].name == "Silverleaf" and rows[1].link:find("|Hitem:765", 1, true), "fresh metadata replaces the loading label")
check(requests == 1, "ready items need no load request")
ready = false
C_Item.RequestLoadItemDataByID = nil
check(pcall(api.GetReagentInfoByItemID, api, 765), "missing loading API is safe")
C_Item.RequestLoadItemDataByID = function() error("request unavailable") end
check(pcall(api.GetReagentInfoByItemID, api, 765), "a failed load request does not abort the guide")
C_Item.GetItemInfo = nil
GetItemInfo = function() return "Legacy Silverleaf" end
local name = api:GetItemInfo(765)
check(name == "Legacy Silverleaf", "legacy cached names remain usable without a modern lookup")
rows = dm:GetReagentListWithDetails(7183, -3)
check(rows[1].requiredCount == 0, "completed steps never show negative requirements")

dm.GetRecipeDetails = function() return {} end
local step = { spellID = 7183, minSkill = 1, maxSkill = 11, crafts = 20 }
local recipe = dm:GetRecipeWithReagents(6, step)
check(recipe.craftCount == 10 and recipe.reagents[1].requiredCount == 20,
    "current-step materials use the guide's expected crafts, not skill-point difference")
check(dm:GetRecipeWithReagents(20, step).craftCount == 0, "completed recipes require zero crafts")
check(dm:GetRecipeWithReagents(0, step).craftCount == 20, "future steps start at their own minimum skill")

local refreshed, bookRefresh = 0, 0
RGXProf.AdapterManager = { registeredAdapters = {} }
RGXProf.StateManager = { RequestRefresh = function() bookRefresh = bookRefresh + 1 end }
RGXProf.MatsWindow = { Refresh = function() refreshed = refreshed + 1 end }
assert(loadfile("Core/Events.lua"))()
RGXProf.Events.GET_ITEM_INFO_RECEIVED(RGXProf, "GET_ITEM_INFO_RECEIVED", 765, true)
check(refreshed == 1 and bookRefresh == 1, "item metadata refreshes Materials and schedules the book/guide refresh")
print("ReagentLoading.test OK")
