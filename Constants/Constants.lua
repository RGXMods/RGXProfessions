RGXProf = RGXProf or {}
RGXProf.Constants = RGXProf.Constants or {}

RGXProf.Constants.Textures = {
    background = "Interface\\FrameGeneral\\UI-Background-Rock",
    questRecipe = "Interface\\ICONS\\INV_Scroll_04",
    vendorRecipe = "Interface\\ICONS\\INV_Scroll_06",
    trainer = "Interface\\MINIMAP\\TRACKING\\Profession",
    backdrop = "Interface\\Tooltips\\UI-Tooltip-Border",
    calculate = "Interface\\ICONS\\inv_egg_01",
    default = "Interface\\Icons\\INV_Misc_QuestionMark",
    preview =  "Interface\\Minimap\\UI-Minimap-ZoomInButton"
}
-- Recipes whose spell texture is wrong on a client: the icon comes from the
-- product item instead (spellID -> item ID of the crafted product).
-- Spell 7751 (Brilliant Smallfish) resolves to a rune texture on WoW Forever.
RGXProf.Constants.ProductItemIcons = {
    [7751] = 6290,
}
RGXProf.Constants.MAIN = 1
RGXProf.Constants.ALTERNATE = 2

RGXProf.Constants.Train_Threshold = 25

RGXProf.Constants.TierLabels = {
    [75]  = "Apprentice",
    [150] = "Journeyman",
    [225] = "Expert",
    [300] = "Artisan",
    [375] = "Master",
    [450] = "Grandmaster",
    [525] = "Illustrious Grand Master"
}