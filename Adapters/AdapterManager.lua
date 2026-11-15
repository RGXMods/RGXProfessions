-------------------------------------------------------------------
-- Handles dynamic identification of frames and hooks for addons, including RGXProf
-------------------------------------------------------------------
RGXProf = RGXProf or {}

RGXProf.AdapterManager = {
    registeredAdapters = {},
    currentAdapter = nil
}

RGXProf.AdapterFactories = RGXProf.AdapterFactories or {}

function RGXProf.AdapterManager:RegisterAsLoaded(name)
    local factory = RGXProf.AdapterFactories[name]
    if factory and not self.registeredAdapters[name] then
        local adapter = factory()
        if not adapter then return end

        adapter.loaded = true
        self.registeredAdapters[name] = adapter
        if (adapter.type == "trade" or adapter.type == "craft") then 
            adapter:hook()
        end
    end
end

function RGXProf.AdapterManager:GetAdapter(name)
    return self.registeredAdapters[name]
end

function RGXProf.AdapterManager:SetCurrentAdapter(adapter)

    if adapter and (adapter.type == "trade" or adapter.type == "craft") then
        self.currentAdapter = adapter
    end
end

function RGXProf.AdapterManager:GetCurrent()
    return self.currentAdapter
end

-- Waypoints use the game's own map pin (C_Map.SetUserWaypoint), the same pin the book's Where card sets.
function RGXProf.AdapterManager:HasNavigationAddon()
    return C_Map ~= nil and type(C_Map.SetUserWaypoint) == "function"
end

function RGXProf.AdapterManager:SetWaypoint(name, zoneID, x, y)
    local pin = RGXProf.BookWindow and RGXProf.BookWindow.PinTarget
    if type(pin) == "function" then
        pin({ name = name, zoneID = zoneID, x = x, y = y })
    end
end

function RGXProf.AdapterManager:RegisterMissedAdapters()
    for addonName, _ in pairs(RGXProf.AdapterFactories) do
        if RGXProf.WowAPI:IsAddOnLoaded(addonName) then
            self:RegisterAsLoaded(addonName)
        end
    end
end
