RGXProf = RGXProf or {}
RGXProf.LayoutManager = {}
----------------------------------
-- Main layout dispatcher
-- Recursively travels through Layouts from backFrame through children tables
-- Each child of type Section is a parent for another recursion
-----------------------------------
--- @param context Context
--- @return table|BackdropTemplate|Frame
function RGXProf.LayoutManager:BuildLayout(context)

    local backFrame = self:CreateBackFrame(context.layoutRoot.name, context.layoutRoot)
    context.ui.backFrame = backFrame

    self:ApplyLayout(backFrame, context.layoutRoot, context)

    return context.ui
end

function RGXProf.LayoutManager:ApplyLayout(parent, layout, context)

    if layout.layout == "vertical" then
        self:ApplyVertical(parent, layout, context)
    elseif layout.layout == "horizontal" then
        self:ApplyHorizontal(parent, layout, context)
    end

end

function RGXProf.LayoutManager:CreateBackFrame(name, layout)
    local template = layout.template or "BackdropTemplate"
    local backFrame = CreateFrame("Frame", name, UIParent, template)

    --gave up and setting it manually
    if layout.width then backFrame:SetWidth(layout.width) end
    if layout.height then backFrame:SetHeight(layout.height) end
    backFrame:SetPoint("CENTER")

    if backFrame.TitleText and layout.title then
        backFrame.TitleText:SetText(layout.title)
    end

    if layout.textureSettings then
        local txtr = layout.textureSettings
        backFrame.texture = backFrame:CreateTexture(nil, txtr.layer)
        backFrame.texture:SetTexture(txtr.texture)
        backFrame.texture:SetPoint("TOPLEFT",txtr.offsetX or 0, txtr.offsetY or 0)
        if txtr.width then backFrame.texture:SetWidth(txtr.width) end
        if txtr.height then backFrame.texture:SetHeight(txtr.height) end
    end

    if layout.backdrop then
        backFrame:SetBackdrop(layout.backdrop)
        backFrame:SetBackdropBorderColor(1, 1, 1, 1)
    end

    backFrame:SetFrameStrata(layout.frameStrata or "DIALOG")

    if layout.draggable then
        RGXProf.LayoutManager:MakeDraggable(backFrame)
    end

    if layout.positionFunc then
        layout.positionFunc(backFrame)
    end

    backFrame:Hide()
    return backFrame
end

function RGXProf.LayoutManager:ApplyVertical(parentFrame, parentLayout, context)

    local margins = parentLayout.margins or { left = 0, right = 0, top = 0, bottom = 0 }
    local padding = parentLayout.padding or 0
    local spacing = parentLayout.spacing or 0

    local availableWidth = parentFrame:GetWidth() - margins.left - margins.right - (padding * 2)
    local availableHeight = parentFrame:GetHeight() - margins.top - margins.bottom

    if not parentLayout.children then
        return
    end

    local fillCount = 0
    for _, childInfo in ipairs(parentLayout.children) do
        if childInfo.fillParentHeight then
            fillCount = fillCount + 1
        elseif childInfo.height then
            availableHeight = availableHeight - childInfo.height
        end
    end

    local totalHeight = 0
    local maxWidth = 0
    local prev

    for _, childInfo in ipairs(parentLayout.children) do
        if childInfo.fillParentWidth then childInfo.availableWidth = availableWidth end
        if childInfo.fillParentHeight then childInfo.availableHeight = availableHeight / fillCount end

        local child = self:CreateByKind(parentFrame, childInfo, context)

        if prev and not childInfo.alignBottom then
            child:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -spacing)
            
        else
            if childInfo.alignBottom then
                child:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", margins.left, childInfo.margins and childInfo.margins.bottom or 5)---(margins.top))
            else
                child:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", margins.left + padding, -(margins.top + padding))
            end
        end

        if child.fontString then
            child.fontString:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -(parentLayout.padding or 4))
        end

        totalHeight = totalHeight + (child:GetHeight() or 0)
        if prev then totalHeight = totalHeight + spacing else totalHeight = totalHeight + padding + padding end
        maxWidth = math.max(maxWidth, child:GetWidth() or 0)

        context.ui[childInfo.name] = child
        prev = child

    end

    totalHeight = totalHeight + padding + margins.bottom
    -- Resize parent
    parentFrame:SetHeight(math.max(totalHeight, parentFrame:GetHeight())+ (parentLayout.heightBuffer or 0))
    if not parentLayout.fillParentWidth then
        parentFrame:SetWidth(maxWidth)
    end
end

function RGXProf.LayoutManager:ApplyHorizontal(parentFrame, parentLayout, context)
    local margins = parentLayout.margins or { left = 0, right = 0, top = 0, bottom = 0 }
    local padding = parentLayout.padding or 0
    local spacing = parentLayout.spacing or 0

    local availableWidth = parentFrame:GetWidth() - margins.left - margins.right - (padding * 2)
    local availableHeight = parentFrame:GetHeight() - margins.top - margins.bottom

    availableWidth = availableWidth - (spacing * math.max(#parentLayout.children - 1, 0))

    local fillCount = 0
    for _, childInfo in ipairs(parentLayout.children) do
        if childInfo.fillParentWidth then
            fillCount = fillCount + 1
        elseif childInfo.width then
            availableWidth = availableWidth - childInfo.width
        end
    end

    local totalWidth = 0
    local maxHeight = 0
    local prev

    for _, childInfo in ipairs(parentLayout.children) do
        if childInfo.fillParentWidth then
            childInfo.availableWidth = availableWidth / fillCount
        end
        if childInfo.fillParentHeight then
            childInfo.availableHeight = availableHeight
        end

        local child = self:CreateByKind(parentFrame, childInfo, context)

        -- Anchor child
        if prev then
            if childInfo.alignRight then
                local marginRight = margins.right or 0
                local offset = 0 - marginRight - padding
                child:SetPoint("RIGHT", parentFrame, "RIGHT", offset, 0)
            else
                child:SetPoint("TOPLEFT", prev, "TOPRIGHT", spacing, 0)
            end
        else
            child:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", margins.left + padding, -margins.top - padding)
        end

        if child.fontString then
            child.fontString:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -(parentLayout.padding or 4))
        end

        if childInfo.kind == "IconSection" then
            child.texture:SetWidth(32)
            child.texture:SetPoint("TOPLEFT", child, "TOPLEFT", 0, 0)
        end

        totalWidth = totalWidth + (child:GetWidth() or 0)
        if prev then totalWidth = totalWidth + spacing else totalWidth = totalWidth + padding + padding end
        maxHeight = math.max(maxHeight, child:GetHeight() or 0)
        prev = child

        context.ui[childInfo.name] = child
    end

    totalWidth = totalWidth + padding + margins.right

    if not parentLayout.fillParentHeight then
        parentFrame:SetHeight(maxHeight)
    end
    if not parentLayout.fillParentWidth then
        parentFrame:SetWidth(totalWidth)
    end
end


---
--- Create By Kind of Section
---
function RGXProf.LayoutManager:CreateSection(parent, childInfo, context)
    local sectionName = "RGXProf_" .. childInfo.name .. "_Frame"
    local section = CreateFrame("Frame", sectionName, parent, "BackdropTemplate")

    if childInfo.height or childInfo.availableHeight then
        childInfo.finalHeight = childInfo.height or childInfo.availableHeight
        section:SetHeight(childInfo.finalHeight)
    end
    if childInfo.width or childInfo.availableWidth then
        childInfo.finalWidth = childInfo.width or childInfo.availableWidth
        section:SetWidth(childInfo.finalWidth)
    end
    local backdrop = childInfo.backdrop or (childInfo.outline and RGXProf.Layouts.Defaults.backdrop)

    if backdrop and backdrop.style.bgFile then
        section:SetBackdrop(backdrop.style)
        section:SetBackdropColor(unpack(backdrop.color))
        section:SetBackdropBorderColor(unpack(backdrop.borderColor))
    elseif backdrop then
        section.texture = section:CreateTexture(nil, backdrop.texture.layer)
        section.texture:SetAllPoints(section)
        section.texture:SetTexture(unpack(backdrop.texture.color))

        if childInfo.outline then
            section:SetBackdrop(backdrop.style)
            section:SetBackdropBorderColor(unpack(backdrop.borderColor))
        end
    end

    RGXProf.LayoutManager:HookTooltip( section, childInfo.tooltipIntent )

    local layoutTable = context.layoutGroup[childInfo.name]
    if layoutTable then
        layoutTable.fillParentHeight = childInfo.fillParentHeight
        layoutTable.fillParentWidth = childInfo.fillParentWidth
        self:ApplyLayout(section, layoutTable, context)
    end


    return section
end

function RGXProf.LayoutManager:CreateIconSection(parent, childInfo, context)
    local name = "RGXProf_"..childInfo.name.."_Frame"
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:SetSize(RGXProf.Layouts.Defaults.icon.width, RGXProf.Layouts.Defaults.icon.height)

    local tex = frame:CreateTexture(nil, "ARTWORK")
    tex:SetTexture(RGXProf.Constants.Textures.default)
    tex:SetAllPoints(frame)
    frame.texture = tex

    local layoutTable = context.layoutGroup[childInfo.name]
    if layoutTable then
        layoutTable.fillParentHeight = childInfo.fillParentHeight
        layoutTable.fillParentWidth = childInfo.fillParentWidth
        self:ApplyLayout(frame, layoutTable, context)
    end

    RGXProf.LayoutManager:HookTooltip( frame, childInfo.tooltipIntent )

    return frame
end

function RGXProf.LayoutManager:CreateScrollFrame(parent, childInfo, context)

    local container = CreateFrame("Frame", childInfo.name .. "_Border", parent, "BackdropTemplate")
    container:SetSize((childInfo.width or parent:GetWidth()-4), (childInfo.height or 90) + 12)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -20) -- slight nudge outwards

    container:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    container:SetBackdropBorderColor(1, 1, 1, 1)

    local scroll = CreateFrame("ScrollFrame", childInfo.name, container, "UIPanelScrollFrameTemplate, BackdropTemplate")
    scroll:SetSize(parent:GetWidth()-16, (childInfo.height or 90))
    scroll:SetBackdropBorderColor(1, 1, 1, 1)  -- white border

    local content = CreateFrame("Frame", childInfo.name.."_Content", scroll, "BackdropTemplate")
    content:SetSize(scroll:GetWidth(), scroll:GetHeight()-24)
    scroll:SetScrollChild(content)
    scroll:SetClipsChildren(true)

    scroll.content = content
    content:SetPoint("TOPLEFT", scroll)
    content:SetPoint("TOPRIGHT", scroll)
    local layoutTable = context.layoutGroup[childInfo.name]
    if layoutTable then
        if not layoutTable.reusable then
            -- local reusableFrame = self:CreateFontString(scroll.content, layoutTable.reusable, context)
            -- reusableFrame:Hide() 
            -- context.ui[layoutTable.reusable.name] = reusableFrame        
        -- else
            layoutTable.fillParentHeight = childInfo.fillParentHeight
            layoutTable.fillParentWidth = childInfo.fillParentWidth
            self:ApplyLayout(scroll.content, layoutTable, context)
        end
    end

    return scroll
end

function RGXProf.LayoutManager:CreateFontString(parent, childInfo, context)

    local frame = CreateFrame("Frame", childInfo.name, parent, "BackdropTemplate")
    if childInfo.height or childInfo.availableHeight then
        childInfo.finalHeight = childInfo.height or childInfo.availableHeight
        frame:SetHeight(childInfo.finalHeight)
    end
    if childInfo.width or childInfo.availableWidth then
        childInfo.finalWidth = childInfo.width or childInfo.availableWidth
        frame:SetWidth(childInfo.finalWidth)
    end

    local fs = frame:CreateFontString(
            "RGXProf_"..childInfo.name.."_FS",
            "ARTWORK",
            childInfo.font
    )

    fs:SetNonSpaceWrap(true)
    fs:SetWordWrap(true)
    fs:SetJustifyH(childInfo.justifyH or "LEFT")
    fs:SetJustifyV(childInfo.justifyV or "TOP")

    local r, g, b = unpack(childInfo.color or RGXProf.Constants.Colors.RGB.BLK)
    fs:SetTextColor(r, g, b, 1)
    fs:SetText(childInfo.text or childInfo.name or "???")
    fs:SetShadowColor(0, 0, 0, 0.8)
    fs:SetShadowOffset(1, -1)

    fs:SetWidth(childInfo.availableWidth or frame:GetWidth())
    local effectiveHeight = fs:GetStringHeight() + (childInfo.spacing or 0)
    frame:SetHeight(math.max(effectiveHeight, childInfo.height or 0))

    frame.fontString = fs
    frame.tooltipData = childInfo.tooltipData
    RGXProf.LayoutManager:HookTooltip( frame, childInfo.tooltipIntent)

    return frame
end

function RGXProf.LayoutManager:CreateColorBar(parent, childInfo, context)
    local myName = "RGXProf_"..childInfo.name
    local bar = CreateFrame("Frame", myName, parent, "BackdropTemplate")
    bar:SetHeight(childInfo.height or 4)
    bar:SetBackdrop(RGXProf.Layouts.Defaults.backdrop.style)
    if childInfo.color then
        bar:SetBackdropBorderColor(unpack(childInfo.color))
    else
        bar:SetBackdropBorderColor(unpack(RGXProf.Layouts.Defaults.backdrop.borderColor))
    end
    if childInfo.width or childInfo.availableWidth then bar:SetWidth(childInfo.width or childInfo.availableWidth) end
    local cbTex = bar:CreateTexture(nil, "BACKGROUND")
    local col = RGXProf.Constants.SkillUpColors["optimal"]
    cbTex:SetColorTexture(col.r, col.g, col.b, col.a or 1)
    cbTex:SetAllPoints()

    bar.texture = cbTex
    return bar
end

function RGXProf.LayoutManager:CreateButton(parent, childInfo, context)
    local myName = "RGXProf_"..childInfo.name
    local btn = CreateFrame("BUTTON", myName, parent)

    btn:SetSize(childInfo.width or RGXProf.Layouts.Defaults.button.width, childInfo.height or RGXProf.Layouts.Defaults.button.height)
    local tex = btn:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints(btn)
    tex:SetTexture(childInfo.texture)
    btn:SetNormalTexture(tex)
    btn.texture = tex
    RGXProf.LayoutManager:HookTooltip( btn, childInfo.tooltipIntent )
    RGXProf.LayoutManager:HookClick( btn, childInfo.onClickIntent )

    return btn
end

function RGXProf.LayoutManager:CreateByKind(parent, childInfo, context)
    if childInfo.kind == "Section" then return self:CreateSection(parent, childInfo, context)
    elseif childInfo.kind == "IconSection" then return self:CreateIconSection(parent, childInfo, context)
    elseif childInfo.kind == "FontString" then return self:CreateFontString(parent, childInfo, context)
    elseif childInfo.kind == "Icon" then return self:CreateIcon(parent, childInfo, context)
    elseif childInfo.kind == "ColorBar"  then return self:CreateColorBar(parent, childInfo, context)
    elseif childInfo.kind == "Button"  then return self:CreateButton(parent, childInfo, context)
    elseif childInfo.kind == "ScrollFrame"  then return self:CreateScrollFrame(parent, childInfo, context)
    end
end

function RGXProf.LayoutManager:CloneFrameLayout(layoutDef, parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    local reusable

    frame:SetSize(templateFrame:GetWidth(), templateFrame:GetHeight())

    -- Clone font string
    local fs = frame:CreateFontString(nil, "ARTWORK")
    fs:SetFontObject(templateFrame.fontString:GetFontObject())
    fs:SetJustifyH(templateFrame.fontString:GetJustifyH())
    fs:SetJustifyV(templateFrame.fontString:GetJustifyV())

    local r, g, b, a = templateFrame.fontString:GetTextColor()
    fs:SetTextColor(r, g, b, a)

    fs:SetShadowColor(0, 0, 0, 0.8)
    fs:SetShadowOffset(1, -1)
    fs:SetNonSpaceWrap(true)
    fs:SetWordWrap(true)

    local width = templateFrame.fontString:GetWidth() or frame:GetWidth()
    fs:SetWidth(width)

    fs:SetPoint("TOPLEFT", frame)

    frame.fontString = fs

    return frame
end

function RGXProf.LayoutManager:HookTooltip(frame, tooltipIntent, tooltipData)
    if not tooltipIntent then return end
    local handler = RGXProf.TooltipHandlers[tooltipIntent]
    if not handler then
        RGXProf.Debug:warn("No tooltip handler found for", tooltipIntent)
        return
    end
    frame:SetScript("OnEnter", function(self)
        handler(self)
    end)

    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
        ResetCursor()
    end)
end

function RGXProf.LayoutManager:HookClick(frame, clickIntent)
    if not clickIntent then return end

    local handler = RGXProf.ClickHandlers[clickIntent]
    if not handler then
        RGXProf.Debug:msg("No click handler found for", clickIntent)
        return
    end

    frame:SetScript("OnClick", function(self)
        local data = RGXProf.FrameRegistry:Get(self)
        handler(self, data)
    end)

end

function RGXProf.LayoutManager:GetChildFrame(parentFrame, suffix)
    local parentName = parentFrame:GetName()--:gsub("_Frame$", "")
    if parentName and parentName:sub(-#suffix) == suffix then
        return parentFrame
    end

    -- Loop through all regions/children
    local numRegions = parentFrame:GetNumChildren()

    for i = 1, numRegions do
        local child = select(i, parentFrame:GetChildren())
        if child then
            local found = self:GetChildFrame(child, suffix)
            if found then return found end
        end
    end

    return nil
end

function RGXProf.LayoutManager:AutoResizeTextFrames(container, titleFontString, bodyFontString)
    local newBodyHeight = bodyFontString:GetStringHeight()
    bodyFontString:SetHeight(newBodyHeight)

    local titleHeight = titleFontString:GetStringHeight()
    local totalHeight = titleHeight + newBodyHeight + 12

    container:SetHeight(totalHeight)
end

--- Creates frames to fill a scrollable content area
--- @param layoutTemplate {} the template for each line in the scrollable content
--- @param parent Frame the parent frame to attach the scroll content to
--- @param contentLines {}[] array of objects with text and link properties
--- @param context {} context for the window and layout calling this function
function RGXProf.LayoutManager:FillScrollContent(layoutTemplate, parent, contentLines, context)
    self:ClearChildren(parent)

    local virtualLayout = {
        name = layoutTemplate.name .. "_DynamicList",
        layout = "vertical",
        fillParentWidth = true,
        padding = layoutTemplate.padding or 0,
        spacing = layoutTemplate.spacing or 0,
        margins = layoutTemplate.margins or { top = 0, bottom = 0, left = 0, right = 0 },
        children = {}
    }

    for i, line in ipairs(contentLines) do
        local childInfo = CopyTable(layoutTemplate)
        childInfo.name = layoutTemplate.name .. i
        childInfo.text = line.text or line
        childInfo.tooltipIntent = line.tooltipIntent or layoutTemplate.tooltipIntent
        childInfo.tooltipData = line.link
        childInfo.fillParentWidth = true
        table.insert(virtualLayout.children, childInfo)
    end
    
    self:ApplyVertical(parent, virtualLayout, context)
end


-----------Positioning Functions-----------------

--- Clears all children of a frame
--- @param frame Frame the frame to clear children from
function RGXProf.LayoutManager:ClearChildren(frame)
    for i = 1, select("#", frame:GetChildren()) do
        local child = select(i, frame:GetChildren())
        child:Hide()
    end
end

function RGXProf.LayoutManager:MakeDraggable(frame)

    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")

    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)

    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        RGXProf.LayoutManager:SaveFramePosition(self)
    end)

end

function RGXProf.LayoutManager:SaveFramePosition(frame)
    local dbKey = frame:GetName() .. "_Position"

    if not RGXProf_Settings then RGXProf_Settings = {} end
    if not RGXProf_Settings.positions then RGXProf_Settings.positions = {} end

    local point, relativeTo, relativePoint, x, y = frame:GetPoint()

    RGXProf_Settings.positions[dbKey] = {
        point = point,
        relativePoint = relativePoint,
        x = x,
        y = y,
    }
end

function RGXProf.LayoutManager:RestoreOrAlignToAnchor(frame, anchorFrame, offsetX, offsetY, anchorPoints)
    local dbKey = frame:GetName() .. "_Position"
    local pos = RGXProf_Settings and RGXProf_Settings.positions and RGXProf_Settings.positions[dbKey]
    if pos then
        frame:ClearAllPoints()
        frame:SetPoint(pos.point or "CENTER", UIParent, pos.relativePoint or "CENTER", pos.x or 0, pos.y or 0)
    elseif anchorFrame and anchorFrame:IsShown() then
        local point = (anchorPoints and anchorPoints.first) or "TOPLEFT"
        local relativePoint = (anchorPoints and anchorPoints.second) or "TOPRIGHT"
        local x = offsetX or 25
        local y = offsetY or -10

        frame:ClearAllPoints()
        frame:SetPoint(point, anchorFrame, relativePoint, x, y)
    end
end

function RGXProf.LayoutManager.PositionOrBottom(frame, dbKey, defaultYOffset)
    RGXProf_Settings = RGXProf_Settings or {}
    RGXProf_Settings.positions = RGXProf_Settings.positions or {}

    local saved = RGXProf_Settings.positions[dbKey]
    frame:SetParent(UIParent)
    frame:ClearAllPoints()
    if saved then
        frame:SetPoint(saved.point or "CENTER", UIParent, saved.relativePoint or "CENTER", saved.x or 0, saved.y or 0)
    else
        frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, defaultYOffset or 200)
    end
end
