-- A theme change announced by the framework redraws RGXProfessions' open windows without a reload: the brand
-- colours are re-resolved in place and the book and Materials overlay rebuild.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local GOLD = { 1, 0.843, 0 }
local override = false
local listener, built
RGXProf = {}
_G.RGXDesign = {
  ResolveStyle = function(_, n) return n end,
  RegisterBrand = function(_, id, own, style)
    return { id = id, own = own, style = style,
      OnChange = function(_, fn) listener = fn end,
      Build = function(self, fn) built = self; return fn() end,
      Resolve = function(self)
        if override then return { primary = GOLD, accent = GOLD }, "forever" end
        return { primary = self.own.primary, accent = self.own.accent }, self.style
      end }
  end,
}
assert(loadfile("UI/Theme.lua"))()
local rebuilt = { book = 0, mats = 0 }
RGXProf.BookWindow = { Rebuild = function() rebuilt.book = rebuilt.book + 1 end }
RGXProf.MatsWindow = { Rebuild = function() rebuilt.mats = rebuilt.mats + 1 end }
RGXProf.MainWindow = { Rebuild = function() rebuilt.main = (rebuilt.main or 0) + 1 end }

local ring = RGXProf.Brand.primary
check(RGXProf.Themed(function() return "ok" end) == "ok" and built and built.id == "RGXProfessions", "windows are built through the registered brand")
check(type(listener) == "function", "the addon listens for theme changes")
override = true
listener()
check(ring[1] == GOLD[1] and RGXProf.BrandHex.primary == "|cffFFD700", "a change re-resolves the live brand colours in place")
check(rebuilt.book == 1 and rebuilt.mats == 1 and rebuilt.main == 1, "the book, the Materials overlay and the profession-window guide are rebuilt")
local src = assert(io.open("UI/OptionsWindow.lua")):read("*a")
check(src:find("addonBrand = RGXProf.GetBrand(),", 1, true), "the settings page is built with the brand, so it redraws itself")
check(src:find("title = function()", 1, true), "the settings page title is re-coloured on a change")
io.write("LiveTheme OK\n")
