--- @class ToolTipLine
--- @field kind string which tooltip format to use (blank, title, single, tabular)
--- @field text string
--- @field leftText string
--- @field rightText string
--- @field color table
--- @field leftColor table
--- @field rightColor table
--- @field wrap boolean

RGXProf.Layouts = RGXProf.Layouts or {}
RGXProf.Layouts.Tooltips = {
    NextUp = {
        {
            kind = "title", text = "" or "Next Up", color = "BRN"
        },
        {
            kind = "children",
            children = {
                {kind = "body", leftText = "", rightText = "", leftColor = "WHT", rightColor = "GRN", leftFormat = "* %s", rightFormat = "%d |cffaaaaaa(%d x %d)|r"}
            }
        },
        { kind = "blank" },
        { kind = "footer", text = "", color = "GRY" }
    },
    VENDOR_PROF = {
        { kind = "title", text = RGXProf.L.VENDOR_BOOK },
        { kind = "normal", text = RGXProf.L.VENDOR_BOOK1, color = "WHT", wrap = true },
        { kind = "blank"},
        {
            kind = "children",
            children = {
                {kind = "body", leftText = "", rightText = "", leftColor = "GLD", rightColor = "LBL"}
            }
        }
    },
    QUEST_PROF = {
        { kind = "title", text = RGXProf.L.QUEST_PROF },
        { kind = "normal", text = RGXProf.L.QUEST_PROF1, color = "WHT", wrap = true },
        { kind = "blank"},
        { kind = "subtitle", text = "", color = RGXProf.Constants.Colors.GRN }, -- quest name
        {
            kind = "children",
            children = {
                {kind = "body", leftText = "", rightText = "", leftColor = "GLD", rightColor = "LBL"}
            }
        }
    },
    TRAINER = {
        { kind = "title", text = RGXProf.L.TRAINER },
        { kind = "single", text = RGXProf.L.TRAINER1, color = "WHT", wrap = true },
        { kind = "blank"},
        {
            kind = "children",
            children = {
                {kind = "body", leftText = "", rightText = "", leftColor = "GLD", rightColor = "LBL"}
            }
        }
    },
    VENDOR_RECIPE = {
        { kind = "title", text = RGXProf.L.VENDOR },
        { kind = "normal", text = RGXProf.L.VENDOR1, color = "WHT", wrap = true },
        { kind = "blank"},
        {
            kind = "children",
            children = {
                { kind = "body", leftText = "", rightText = "", leftColor = "GLD", rightColor = "LBL"},
                { kind = "footer", text = "", color = "WHT" }
            }
        },
        { kind = "footer", text = "", color = "WHT" }
    },
    QUEST_RECIPE = {
        { kind = "title", text = RGXProf.L.QUEST1_TITLE },
        { kind = "blank"},
        { kind = "subtitle", text = "", color = RGXProf.Constants.Colors.YEL }, -- quest name (title??)
        { kind = "normal", text = RGXProf.L.QUEST1, color = "WHT", wrap = true },
        { kind = "blank"},
        {
            kind = "children",
            children = {
                {kind = "body", leftText = "", rightText = "", leftColor = "GLD", rightColor = "LBL"}
            }
        }
    },
    TRAINER_RECIPE = {
        { kind = "title", text = RGXProf.L.TRAINER },
        { kind = "normal", text = RGXProf.L.TRAINER2, color = "WHT", wrap = true },
        { kind = "blank"},
        {
            kind = "children",
            children = {
                {kind = "body", leftText = "", rightText = "", leftColor = "GLD", rightColor = "LBL"}
            }
        }
    },
    TRAIN_MAX = {
        { kind = "title", text = RGXProf.L.TRAINER },
        { kind = "normal", text = RGXProf.L.TRAINER1, color = "WHT", wrap = true },
        { kind = "blank"},
        {
            kind = "children",
            children = {
                {kind = "body", leftText = "", rightText = "", leftColor = "GLD", rightColor = "LBL"}
            }
        }
    }
}
