RGXProf.Layouts = RGXProf.Layouts or {}
RGXProf.Layouts.MiniWindow = RGXProf.Layouts.MiniWindow or {}

local w = RGXProf.Layouts.Defaults.main.width
local h = RGXProf.Layouts.Defaults.main.height
RGXProf.Layouts.MiniWindow.BackFrame = {
    name = "RGXProf_MV_BackFrame",
    layout = "vertical",
    width = 300,
    height = 200,
    template = "PortraitFrameTemplate",
    positionFunc = function(frame)
        RGXProf.LayoutManager.PositionOrBottom(frame, "RGXProf_MV_BackFrame_Position", 200)
    end,
    frameStrata = "DIALOG",
    draggable = true,
    titleText = RGXProf.L.ADDON_TITLE,
    textureSettings = {
        layer = "BACKGROUND",
        texture = "Interface\\QuestFrame\\QuestBG",
        width = 500,
        height = 200,
        offsetX = 0,
        offsetY = -60
    },
    fillParentWidth = true,
    margins = { left = 1, right = 2, top = 60, bottom = 2 },
    spacing = 6,
    children = {
        { kind = "Section", name = "InternalFrame",
          fillParentWidth = true, fillParentHeight = true,
        }
    }
}
RGXProf.Layouts.MiniWindow.InternalFrame = {
    name = "MV_InternalFrame",
    layout = "vertical",
    margins = { left = 5, right = 5, top = 5, bottom = -8 },
    spacing = 4,
    children = {
        { kind = "Section", name = "Header",
          fillParentWidth = true
        }
    }
}
RGXProf.Layouts.MiniWindow.Header = {
    name = "MV_Header",
    layout = "vertical",
    margins = { left = 4, right = 4, top = 1, bottom = 2 },
    backdrop = RGXProf.Layouts.Defaults.innerPanelBackdrop,
    spacing = 2,
    padding = 2,
    children = {
        { kind = "FontString", name = "MV_Title",
          font = RGXProf.Layouts.Defaults.fonts.medium,
          color = RGXProf.Constants.Colors.RGB["BRN"],
          text = RGXProf.L.PREVIEW_TITLE_SKILL,
          fillParentWidth = true,
          padding = 8,
          height = 20,
          spacing = 2
        },
        { kind = "ScrollFrame", name = "Steps",
            fillParentWidth = true
        }
    }
}

RGXProf.Layouts.MiniWindow.Steps = {
    name = "MV_Steps",
    height = 90,
    layout = "vertical",
    backdrop = RGXProf.Layouts.Defaults.innerPanelBackdrop,
    scrollContent = {
        kind = "FontString",
        name = "StepLine",
        font = RGXProf.Layouts.Defaults.fonts.small,
        color = RGXProf.Constants.Colors.RGB.BLK,
        justifyH = "LEFT",
        justifyV = "TOP",
        tooltipIntent = "SimpleTooltip",
        height = 16,
        spacing = 2,
        padding = 8
    }
}
