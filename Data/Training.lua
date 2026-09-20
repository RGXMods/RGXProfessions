----------------------------------------------------------------------------------------------
--- TRAINING data from stored Training database
----------------------------------------------------------------------------------------------
---@class TrainingChoice
---@field questName string
---@field name string
---@field location number The internal map ID or zone ID of the npc
---@field x number x coordinate of npc
---@field y number y coordinate of npc
---@field note string extra instructions

--- @class Training
--- @field icon string
--- @field layout ToolTipLine[]
--- @field instructions string
--- @field list table[]


RGXProf = RGXProf or {}
RGXProf.Training = {
    trainingList = {},
    currentTraining = {},
    SKILLED_KEEP = {
        icon = RGXProf.Constants.Textures.vendorRecipe,
        instructions = RGXProf.L.CREATE.." "..RGXProf.L.KEEP
    },
    SKILLED = {
        icon = RGXProf.Constants.Textures.vendorRecipe,
        instructions = RGXProf.L.CREATE
    },
    NONE = {
        icon = RGXProf.Constants.Textures.vendorRecipe,
        instructions = RGXProf.L.CREATE
    },
    VENDOR_PROF ={
        icon = RGXProf.Constants.Textures.vendorRecipe,
        layout = RGXProf.Layouts.Tooltips.VENDOR_PROF,
        instructions = RGXProf.L.LEARN_MAX_VENDOR
    },
    QUEST_PROF     ={
        icon = RGXProf.Constants.Textures.questRecipe,
        layout = RGXProf.Layouts.Tooltips.QUEST_PROF,
        instructions = RGXProf.L.LEARN_MAX_QUEST
    },
    TRAINER        ={
        icon = RGXProf.Constants.Textures.questRecipe,
        layout = RGXProf.Layouts.Tooltips.TRAINER
    },
    VENDOR_RECIPE   ={
        icon = RGXProf.Constants.Textures.vendorRecipe,
        layout = RGXProf.Layouts.Tooltips.VENDOR_RECIPE,
        instructions = RGXProf.L.LEARN_VENDOR
    },
    QUEST_RECIPE    = {
        icon = RGXProf.Constants.Textures.trainer,
        layout = RGXProf.Layouts.Tooltips.QUEST_RECIPE,
        instructions = RGXProf.L.LEARN_QUEST
    },
    TRAINER_RECIPE  = {
        icon = RGXProf.Constants.Textures.trainer,
        layout = RGXProf.Layouts.Tooltips.TRAINER_RECIPE,
        instructions = RGXProf.L.LEARN
    },
    TRAIN_MAX       = {
        icon = RGXProf.Constants.Textures.trainer,
        layout = RGXProf.Layouts.Tooltips.TRAIN_MAX,
        instructions =  RGXProf.L.LEARN_MAX_TRAINER
    }
}