-------------------------------------------------------------------
-- Profession Leveling Guide: UI Layout
-- Author: Liramei
-------------------------------------------------------------------

--[[
        +------------------------------------------------------------------+
        | [Portrait]       Profession Leveling Guide                [X]    |
        +------------------------------------------------------------------+
        |                                                                  |
        |  INSTRUCTIONS      [Vendor]                     [Preview]        |
        |  Create 31 of the following recipe until skill level 65.         |
        |  You will need to keep these for future recipes.                 |
        |                                                                  |
        |  RECIPE                          ALTERNATE                       |
        |  +-----------------------------+ +-----------------------------+ |
        |  | [Icon] Rough Grinding Stone | | [Icon] Alt Option Name      | |
        |  | [Green Progress Bar]        | | [Skill Color Bar]           | |
        |  +-----------------------------+ +-----------------------------+ |
        |                                                                  |
        |  REAGENTS                                                        |
        |  +---------------------------+ +---------------------------+     |
        |  | [Icon] Rough Stone        | | [Icon] Reagent 2          |     |
        |  | Count: 3/62               | | Count: x/y                |     |
        |  +---------------------------+ +---------------------------+     |
        |  +---------------------------+ +---------------------------+     |
        |  | [Icon] Reagent 3          | | [Icon] Reagent 4          |     |
        |  +---------------------------+ +---------------------------+     |
        |  +---------------------------+ +---------------------------+     |
        |  | [Icon] Reagent 3          | | [Icon] Reagent 4          |     |
        |  +---------------------------+ +---------------------------+     |
        |  UP NEXT:                                      [Calc]            |
        |  Coarse Sharpening Stone                                         |
        +------------------------------------------------------------------+
]]

RGXProf.Layouts = RGXProf.Layouts or {}
RGXProf.Layouts.MainWindow = RGXProf.Layouts.MainWindow or {}

RGXProf.Layouts.Defaults = {
    main = {
      width = 375,
      height = 425,
    },
    fonts = {
      title = "DestinyFontLarge",
      medium = "GameFontNormal",
      small = "GameFontNormalSmall2"
    },
    titles = {
        font = "DestinyFontLarge",
        height = 20, -- for estimates
        width = 132, -- for estimates
        color = RGXProf.Constants.Colors.RGB["BRN"]
    },
    otherText = {
      height = 10, -- for estimates
      width = 132 -- for estimates
    },
    icon = {
        height = 32,
        width = 32
    },
    innerPanelBackdrop = {
        style = {
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        },
        color = { 0.50, 0.45, 0.35, 1 },
        borderColor = RGXProf.Constants.Colors.RGB["SUNSET"]
    },
    button = {
        height = 30,
        width = 30
    },
    backdrop = {
        style = {
            layer = "BACKGROUND",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileEdge = true,
            tileSize = 4,
            edgeSize = 4,
            -- insets = { left = 1, right = 1, top = 1, bottom = 1 },
        },
        texture = {
            color = { 0, 0, 0, 0.2 },
            layer = "BACKGROUND"
        },
        borderColor = RGXProf.Constants.Colors.RGB["SUNSET"]
    },
    colorBar = {
        height = 5
    },
    maxReagents = 8
}

local w = RGXProf.Layouts.Defaults.main.width
local h = RGXProf.Layouts.Defaults.main.height
RGXProf.Layouts.MainWindow.BackFrame = {
    name = "RGXProf_BackFrame",
    layout = "vertical",
    width = 364,
    height = h,
    template = "PortraitFrameTemplate",
    titleText = RGXProf.L.ADDON_TITLE,
    textureSettings = {
        layer = "BACKGROUND",
        texture = "Interface\\QuestFrame\\QuestBG",
        width = 600,
        height = 550,
        offsetX = 6,
        offsetY = -62
    },
    fillParentWidth = true,
    margins = { left = 1, right = 2, top = 60, bottom = 2 },
    spacing = 6,
    children = {
        { kind = "Section", name = "InternalFrame",
          fillParentWidth = true, fillParentHeight = true,
        }
    },
    draggable = true
}

RGXProf.Layouts.MainWindow.InternalFrame = {
    name = "InternalFrame",
    layout = "vertical",
    margins = { left = 5, right = 5, top = 5, bottom = 5 },
    spacing = 4,
    children = {
        { kind = "Section", name = "Instructions",
          outline = true,
          fillParentWidth = true
        },
        { kind = "Section", name = "Recipes",
          fillParentWidth = true
        },
        { kind = "Section", name = "Reagents",
          fillParentWidth = true
        },
        { kind = "Section", name = "Footer",
          fillParentWidth = true
        }
    }
}

RGXProf.Layouts.MainWindow.Instructions = {
    name = "Instructions",
    layout = "horizontal",
    margins = { left = 4, right = 4, top = 2, bottom = 2 },
    backdrop = RGXProf.Layouts.Defaults.innerPanelBackdrop,
    spacing = 4,
    padding = 4,
    children = {
        { kind = "Section", name = "Instructions_TextBlock",
          fillParentHeight = true, fillParentWidth = true,
        },
        { kind = "Button", name = "Trainer",
          texture = RGXProf.Constants.Textures.trainer,
          height = RGXProf.Layouts.Defaults.button.height, width = RGXProf.Layouts.Defaults.button.width,
          alignRight = true,
          tooltipIntent = "TrainingTooltip",
          onClickIntent = "TrainerClick"
        },
        -- { kind = "Button", name = "Preview",
        --   texture = RGXProf.Constants.Textures.preview,
        --   height = RGXProf.Layouts.Defaults.button.height, width = RGXProf.Layouts.Defaults.button.width,
        --   alignRight = true,
        --   tooltipIntent = "PreviewTooltip",
        --   onClickIntent = "PreviewClick"
        -- }
    }
}

RGXProf.Layouts.MainWindow.Instructions_TextBlock = {
    name = "Instructions_TextBlock",
    layout = "vertical",
    fillParentHeight = true,
    children = {
        { kind = "FontString", name = "Instructions_Title",
          fillParentWidth = true,
          font = RGXProf.Layouts.Defaults.fonts.title,
          color = RGXProf.Constants.Colors.RGB["BRN"],
          text = RGXProf.L.LABEL_INSTRUCTIONS
        },
        { kind = "FontString", name = "Instructions_Body",
          fillParentWidth = true,
          height = RGXProf.Layouts.Defaults.icon.height,
          font = RGXProf.Layouts.Defaults.fonts.medium,
          color = RGXProf.Constants.Colors.RGB.BRN,
          text = "Testing body"
        }
    }
}
--[[|RECIPE                         ALTERNATE                       |
|   +-----------------------------+ +-----------------------------+ |
|   | [Icon] Rough Grinding Stone | | [Icon] Alt Option Name      | |
|   | [Skill Color Bar]           | | [Skill Color Bar]           | |
|   +-----------------------------+ +-----------------------------+ |
--]]

RGXProf.Layouts.MainWindow.Recipes = {
    name = "Recipes",
    layout = "horizontal",
    margins = { left = 4, right = 4, top = 2, bottom = 2 },
    --backdrop = RGXProf.Layouts.Defaults.innerPanelBackdrop,
    spacing = 4,
    padding = 4,
    heightBuffer = 8,
    debug = true,
    children = {
        { kind = "Section", name = "MainSlot",
          fillParentWidth = true, fillParentHeight = true, debug = true,
        },
        { kind = "Section", name = "AltSlot",
          fillParentWidth = true, fillParentHeight = true, debug = true,
        },
    }
}

local function BuildSlotLayouts(name, titleText)
    local slotLayout = {
        name = name .. "Slot",
        layout = "vertical",
        debug = true,
        spacing = 3,
        padding = 0,
        children = {
            {
                kind = "FontString",
                name = name .. "Slot_Title",
                font = RGXProf.Layouts.Defaults.fonts.title,
                color = RGXProf.Layouts.Defaults.titles.color, debug = true,
                text = titleText,
                fillParentWidth = true
            },
            {
                kind = "Section",
                name = name .. "Slot_Recipe",
                height = RGXProf.Layouts.Defaults.icon.height,debug = true,
                outline = true,
                fillParentWidth = true
            }
        }
    }
    local base = name .. "Slot_Recipe"
    local recipeLayout = {
        name = base,
        layout = "horizontal",
        debug = true,
        children = {
            {
                kind = "Button",
                name = base .. "_Button", debug = true,
                texture = RGXProf.Constants.Textures.default,
                width = RGXProf.Layouts.Defaults.icon.width,
                height = RGXProf.Layouts.Defaults.icon.height,
                tooltipIntent = "RecipeTooltip",
                onClickIntent = "RecipeClick"
            },
            {
                kind = "Section",
                name = base .. "_Details", debug = true,
                fillParentWidth = true,
                fillParentHeight = true
            }
        }
    }

    local recipeDetailLayout = {
        name = name.."Slot_Recipe_Details",
        layout = "vertical",
        debug = true,
        children = {
            {
                kind = "FontString", name = base .. "_SpellName", debug = true,
                font = RGXProf.Layouts.Defaults.fonts.medium, text="Test Spell Name",
                fillParentWidth = true, fillParentHeight = true
            },
            {
                kind = "ColorBar", name = base .. "_ColorBar",
                height = RGXProf.Layouts.Defaults.colorBar.height,
                margins = { bottom = 0 },
                alignBottom = true,
                fillParentWidth = true
            }
        }
    }

    return slotLayout, recipeLayout, recipeDetailLayout
end

RGXProf.Layouts.MainWindow.MainSlot,
RGXProf.Layouts.MainWindow.MainSlot_Recipe,
RGXProf.Layouts.MainWindow.MainSlot_Recipe_Details = BuildSlotLayouts("Main", RGXProf.L.LABEL_RECIPE)
RGXProf.Layouts.MainWindow.AltSlot,
RGXProf.Layouts.MainWindow.AltSlot_Recipe,
RGXProf.Layouts.MainWindow.AltSlot_Recipe_Details = BuildSlotLayouts("Alt", RGXProf.L.LABEL_ALTERNATE)


RGXProf.Layouts.MainWindow.Reagents = {
    name = "Reagents",
    layout = "vertical",
    margins = { left = 4, right = 4, top = 2, bottom = 2 },
    spacing = 4,
    padding = 4,
    children = {
        {
            kind = "FontString", name = "Reagents_Title",
            font = RGXProf.Layouts.Defaults.fonts.title, color = RGXProf.Layouts.Defaults.titles.color, text=RGXProf.L.LABEL_REAGENTS,
            fillParentWidth=true
        },
        { kind = "Section", name = "Reagent1_Row",
          height = RGXProf.Layouts.Defaults.icon.height,
          fillParentWidth=true },
        { kind = "Section", name = "Reagent2_Row",
          height = RGXProf.Layouts.Defaults.icon.height,
          fillParentWidth=true },
        { kind = "Section", name = "Reagent3_Row",
          height = RGXProf.Layouts.Defaults.icon.height,
          fillParentWidth=true },
        { kind = "Section", name = "Reagent4_Row",
          height = RGXProf.Layouts.Defaults.icon.height,
          fillParentWidth=true },
    }
}

local function Reagent_Row_Layout(name, leftID, rightID)
    return {
        name = name.."_Row",
        layout = "horizontal",
        children = {
            { kind = "Section", name = "Reagent" .. leftID,
              outline = true,
              fillParentWidth = true, fillParentHeight = true},
            { kind = "Section", name = "Reagent" .. rightID,
              outline = true,
              fillParentWidth = true, fillParentHeight = true}
        }
    }
end

local function Reagent_Slot_Layout(id)
    return {
        name = "Reagent"..id,
        layout = "horizontal",
        children = {
            { kind = "IconSection", name = "Reagent"..id.."_Icon", tooltipIntent = "ReagentTooltip"},
            { kind = "FontString", name = "Reagent"..id.."_ItemName",
              font = RGXProf.Layouts.Defaults.fonts.medium,
              color = RGXProf.Constants.Colors.RGB.WHT,
              text="Test Reagent Name",
              fillParentWidth = true, fillParentHeight = true
            },
        }
    }
end

local function Reagent_Slot_Icon(id)
    return {
        name = "Reagent" .. id .. "_Icon",
        layout = "vertical",
        height = RGXProf.Layouts.Defaults.icon.height,
        width = RGXProf.Layouts.Defaults.icon.width,
        children = {
            {
                kind = "FontString", name = "Reagent" .. id .. "_Count",
                font = "NumberFontNormalSmall", color = RGXProf.Constants.Colors.RGB.WHT, text = "0/0",
                fillParentWidth = true, alignBottom = true,
                justifyH = "RIGHT", justifyV = "BOTTOM",
            }
        }
    }
end

for i = 1, 4 do
    local rowBase = "Reagent" .. i
    local leftID = i * 2 - 1
    local rightID = i * 2

    RGXProf.Layouts.MainWindow[rowBase .. "_Row"]    = Reagent_Row_Layout(rowBase, leftID, rightID)

    -- Left slot layout (icon + name), icon, count
    RGXProf.Layouts.MainWindow["Reagent" .. leftID]             = Reagent_Slot_Layout(leftID)
    RGXProf.Layouts.MainWindow["Reagent" .. leftID .. "_Icon"]  = Reagent_Slot_Icon(leftID)

    -- Right slot layout (icon + name), icon, count
    RGXProf.Layouts.MainWindow["Reagent" .. rightID]             = Reagent_Slot_Layout(rightID)
    RGXProf.Layouts.MainWindow["Reagent" .. rightID .. "_Icon"]  = Reagent_Slot_Icon(rightID)
end


RGXProf.Layouts.MainWindow.Footer= {
    name = "Footer",
    layout = "horizontal",
    margins = { left = 5, right = 5, top = 0, bottom = 0 },
    children = {
        { kind = "Section", name = "NextUp",
          fillParentWidth = true,
          fillParentHeight = true
        },
        { kind = "Button", name = "Calculate",
          texture = RGXProf.Constants.Textures.calculate,
          height = RGXProf.Layouts.Defaults.button.height, width = RGXProf.Layouts.Defaults.button.width,
          alignRight = true,
          xOffset = -6,
          tooltipIntent = "CalculateTooltip",
          onClickIntent = "CalculateClick"
        }
    }
}
RGXProf.Layouts.MainWindow.NextUp = {
    name = "NextUp",
    layout = "vertical",
    children = {
        { kind = "FontString", name = "NextUp_Title",
          font = RGXProf.Layouts.Defaults.fonts.title, color = RGXProf.Layouts.Defaults.titles.color, text = RGXProf.L.LABEL_UP_NEXT,
          fillParentWidth = true
        },
        { kind = "FontString", name = "NextUp_Spell",
          font = RGXProf.Layouts.Defaults.fonts.small, color = RGXProf.Constants.Colors.RGB["BRN"], text = "Next up recipe",
          fillParentWidth = true,
          tooltipIntent = "NextUpTooltip"
        }
    }
}