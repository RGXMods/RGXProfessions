RGXProf.Layouts = RGXProf.Layouts or {}
RGXProf.Layouts.MatsWindow = RGXProf.Layouts.MatsWindow or {}

local w = RGXProf.Layouts.Defaults.main.width
local h = RGXProf.Layouts.Defaults.main.height
RGXProf.Layouts.MatsWindow.BackFrame = {
    name = "RGXProf_MatsV_BackFrame",
    layout = "vertical",
    width = 300,
    height = 200,
    template = "PortraitFrameTemplate",
    titleText = RGXProf.L.ADDON_TITLE,    
    positionFunc = function(frame)
        local anchor = RGXProf.MainWindow and RGXProf.MainWindow.UIElements and RGXProf.MainWindow.UIElements.backFrame
        if anchor and anchor:IsShown() then
            RGXProf.LayoutManager:RestoreOrAlignToAnchor(frame, anchor, 20, 0, {
                first = "TOPLEFT",
                second = "TOPRIGHT"
            })
        else
            RGXProf.LayoutManager.PositionOrBottom(frame, "RGXProf_MatsV_BackFrame_Position", 200)
        end
    end,
    draggable = true,
    -- Keep the auxiliary window wholly above the main DIALOG guide when a
    -- user intentionally overlaps them; equal strata can interleave children.
    frameStrata = "FULLSCREEN_DIALOG",
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
RGXProf.Layouts.MatsWindow.InternalFrame = {
    name = "MatsV_InternalFrame",
    layout = "vertical",
    margins = { left = 5, right = 5, top = 5, bottom = -8 },
    spacing = 4,
    children = {
        { kind = "Section", name = "Header",
          fillParentWidth = true
        }
    }
}
RGXProf.Layouts.MatsWindow.Header = {
    name = "MatsV_Header",
    layout = "vertical",
    margins = { left = 4, right = 4, top = 1, bottom = 2 },
    backdrop = RGXProf.Layouts.Defaults.innerPanelBackdrop,
    spacing = 2,
    padding = 2,
    children = {
        { kind = "FontString", name = "MatsV_Title",
          font = RGXProf.Layouts.Defaults.fonts.medium,
          color = RGXProf.Constants.Colors.RGB["BRN"],
          text = "Remaining Materials",
          fillParentWidth = true,
          padding = 8,
          height = 20,
          spacing = 2

        },
        { kind = "ScrollFrame", name = "Mats",
            fillParentWidth = true
        }
    }
}

RGXProf.Layouts.MatsWindow.Mats = {
    name = "MatsV_Mats",
    height = 90,
    layout = "vertical",
    backdrop = RGXProf.Layouts.Defaults.innerPanelBackdrop,
    scrollContent = {
        kind = "FontString",
        name = "MatsLine",
        font = RGXProf.Layouts.Defaults.fonts.small,
        color = RGXProf.Constants.Colors.RGB.BLK,
        justifyH = "LEFT",
        justifyV = "TOP",
        tooltipIntent = "SimpleTooltip",
        spacing = 2,
        height = 16,
        padding = 8
    }
}
