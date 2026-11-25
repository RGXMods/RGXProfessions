-- Load the actual framework dependency; no copied count/aggregation implementation.
local root = assert(os.getenv("RGXFW_PATH"), "set RGXFW_PATH to the framework checkout")
function canaccessvalue() return true end
function canaccesstable(value) return type(value) == "table" end
C_EventUtils = { IsEventValid = function() return true end }
function CreateFrame()
    local f = { scripts = {}, registered = {} }
    function f:SetScript(name, fn) self.scripts[name] = fn end
    function f:Show() end
    function f:Hide() end
    function f:RegisterEvent(name) self.registered[name] = true end
    function f:UnregisterEvent(name) self.registered[name] = nil end
    function f:IsEventRegistered(name) return self.registered[name] == true end
    return f
end
local framework = {}
for _, file in ipairs({ "core/compat.lua", "core/core.lua", "core/systems/events.lua",
    "modules/inventory/inventory.lua" }) do
    assert(loadfile(root .. "/" .. file))("RGX-Framework", framework)
end
return framework
