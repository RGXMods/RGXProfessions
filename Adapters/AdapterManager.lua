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

function RGXProf.AdapterManager:HasNavigationAddon()
    for _, addon in pairs(self.registeredAdapters) do
        if addon.type == "navigation" and addon.loaded and addon.waypoint then
            return true
        end
    end
    return false
end

function RGXProf.AdapterManager:SetWaypoint(name, zoneID, x, y)
    for _, addon in pairs(RGXProf.AdapterManager.registeredAdapters) do
        if addon.type == "navigation" and addon.loaded and addon.waypoint then
            addon.waypoint(name, zoneID, x, y)
            return
        end
    end
    RGXProf.Utils:SendMsg(RGXProf.L.NO_WAYPOINT_ADDON)
end

function RGXProf.AdapterManager:RegisterMissedAdapters()
    for addonName, _ in pairs(RGXProf.AdapterFactories) do
        if RGXProf.WowAPI:IsAddOnLoaded(addonName) then
            self:RegisterAsLoaded(addonName)
        end
    end
end
