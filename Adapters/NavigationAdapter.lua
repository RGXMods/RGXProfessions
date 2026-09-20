RGXProf.AdapterFactories = RGXProf.AdapterFactories or {}

---@class NavigationAdapter
---@field loaded boolean
---@field waypoint fun(name: string, mapID: number, x: number, y: number)
RGXProf.NavigationAdapter = {}
RGXProf.NavigationAdapter.__index = RGXProf.NavigationAdapter

function RGXProf.NavigationAdapter:new(name, waypointFunc)
    local obj = {
        name = name,
        type = "navigation",
        loaded = RGXProf.WowAPI:IsAddOnLoaded(name),
        waypoint = waypointFunc,
    }
    setmetatable(obj, self)
    return obj
end

-- function RGXProf.NavigationAdapter:isActive()
--     return self.loaded
-- end

RGXProf.AdapterFactories["TomTom"] = function()
    local adapter =  RGXProf.NavigationAdapter:new("TomTom", function(name, zoneID, x, y)
        if not TomTom or not TomTom.AddWaypoint then return end

        TomTom:AddWaypoint(zoneID, x / 100, y / 100, {
            title = name,
            from = "RGXProf"
        })
    end)

    return adapter
end

RGXProf.AdapterFactories["Carbonite"] = function()
    local adapter =  RGXProf.NavigationAdapter:new("Carbonite", function(name, mapID, x, y)
        if not Nx or not Nx.slashCommand then return end

        Nx.slashCommand("goto " .. RGXProf.WowAPI:GetMapName(mapID) .. " " .. x .. " " .. y .. " " .. name)
    end)
        
    return adapter
end
