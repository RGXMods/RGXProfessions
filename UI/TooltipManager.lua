RGXProf.TooltipManager = {}
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    if RGXProf.TooltipManager and RGXProf.TooltipManager.AttachWhereNeededTooltips then
        RGXProf.TooltipManager:AttachWhereNeededTooltips()
    end
end)
--------------------------------------------------------------------
-- Attach tooltip hooks to add the Where Needed lines
--------------------------------------------------------------------
function RGXProf.TooltipManager:AttachWhereNeededTooltips()
    local f = function(tooltip)
        RGXProf.TooltipManager:AttachTooltip(tooltip)
    end
    local tooltips = { GameTooltip, ItemRefTooltip, ItemRefShoppingTooltip1, ItemRefShoppingTooltip2 }
    for _, tooltip in ipairs(tooltips) do
        if tooltip and tooltip.HasScript and tooltip:HasScript("OnTooltipSetItem") then
            tooltip:HookScript("OnTooltipSetItem", f)
        end
    end
end


function RGXProf.TooltipManager:Usage(itemID)
    local usage = RGXProf.DataManager.ReagentUsage and RGXProf.DataManager.ReagentUsage[itemID]
    local tooltips = {}
    if usage then
        table.insert(tooltips," ")
        table.insert(tooltips,"|cff00ccffUsed in RGXProf:|r")
        for _, entry in pairs(usage) do
            local name = entry.name
            local rangeText
            if entry.minSkill == entry.maxSkill then
                rangeText = string.format(" (%d)", entry.minSkill)
            else
                rangeText = string.format(" (%d–%d)", entry.minSkill, entry.maxSkill)
            end

            table.insert(tooltips, "• " .. name .. rangeText)
        end
    end
    return tooltips
end

function RGXProf.TooltipManager:AttachTooltip(tooltip)
    local _, link = tooltip:GetItem()
    if not link then return end

    local itemID = RGXProf.Utils:GetItemID(link)
    if not itemID then return end

    for _,text in ipairs(self:Usage(itemID)) do
        tooltip:AddLine(text)
    end
end

function RGXProf.TooltipManager:RenderTooltipFromLayout(tooltip, layout)
    function resolveColor(clr)
        if clr then
            return unpack(RGXProf.Constants.Colors.RGB[clr])
        else
            return nil, nil, nil
        end
    end
    if not layout then
        return
    end
    tooltip:ClearLines()
    tooltip:ClearAllPoints()

    for i, entry in ipairs(layout) do
        local kind = entry.kind
        if kind == "blank" then
            tooltip:AddLine(" ")
        elseif kind == "title" then
            tooltip:SetText(
                    entry.text or "",
                    (entry.color and entry.color.r) or 1,
                    (entry.color and entry.color.g) or 1,
                    (entry.color and entry.color.b) or 1
            )
        elseif kind == "single" then
            tooltip:AddLine(
                    entry.text or "",
                    (entry.color and entry.color.r) or 1,
                    (entry.color and entry.color.g) or 1,
                    (entry.color and entry.color.b) or 1
            )
        elseif kind == "double" then
            local lr, lg, lb = resolveColor(entry.leftColor)
            local rr, rg, rb = resolveColor(entry.rightColor)
            tooltip:AddDoubleLine(
                    entry.leftText or "", entry.rightText or "",
                    lr or 1, lg or 1, lb or 1,
                    rr or 1, rg or 1, rb or 1,
                    (entry.rightColor and entry.rightColor.r) or 1,
                    (entry.rightColor and entry.rightColor.g) or 1,
                    (entry.rightColor and entry.rightColor.b) or 1
            )
        elseif kind == "children" then
            if entry.children then
                self:RenderTooltipFromLayout(tooltip, entry.children)
            end
        end
    end
end

--- Takes the content that has the data for the current step and the UI layout for the tooltip and merges them together
--- @param layout ToolTipLine[]
--- @param content table
--- @return table
function RGXProf.TooltipManager:CreateFinalTooltipContent(layout, content)
    local injected = {}
    for _, line in ipairs(layout) do
        local result = TitleLine(line, content.title) or NormalLine(line) or FooterLine(line, content) or BodyLine(line, content) or BlankLine(line) or ChildrenLines(line, content) or SubtitleLine(line, content)
        if result and line.kind == "children" then
            for _, childLine in ipairs(result) do
                table.insert(injected, childLine)
            end
        elseif result then
            table.insert(injected, result)
        else
            table.insert(injected, DefaultLine(line))
        end
    end
    return injected
end

--- children should be a table of the kinds of lines.
--- if the kind is body, there can be multiple content lines inside a body property on content
--- if the kind is anything else, there would only be one added before or after the body of lines as positioned in the layout

function ChildrenLines(line, content)
    if line.kind ~= "children" or not content.children then return nil end
    local resultLines = {}
    local bodyLayout = {}
    local footerLayout = {}

    for _, layout in ipairs(line.children) do
        if layout.kind == "body" then bodyLayout = layout end
        if layout.kind == "footer" then footerLayout = layout end
    end

    for _, childContent in ipairs(content.children) do
        local result = BodyLine(bodyLayout, childContent) or FooterLine(footerLayout, childContent)
        if result then table.insert(resultLines, result) end
    end

    return resultLines
end

function TitleLine(line, title)
    if line.kind ~= "title" then return nil end
    return {
        kind = "title",
        text = title or line.text,
        color = line.color
    }
end

function SubtitleLine(line, content)
    if line.kind ~= "subtitle" or not content.subtitle then return nil end
    return {
        kind = "single",
        text = content.subtitle,
        color = line.color
    }
end

function NormalLine(line)
    if line.kind ~= "normal"  then return nil end
    return {
        kind = "single",
        text = line.text,
        color = line.color
    }
end

function FooterLine(line, content)
    if line.kind ~= "footer" or not content.footer then return nil end
    return {
        kind = "single",
        text = content.footer,
        color = line.color
    }
end

function BodyLine(line, content)
    if line.kind ~= "body" then return nil end

    local leftText = content.leftText
    local rightText = content.rightText

    if line.leftFormat and type(leftText) == "string" then
        leftText = string.format(line.leftFormat, leftText)
    end

    if line.rightFormat and type(rightText) == "table" then
        rightText = string.format(line.rightFormat, unpack(rightText))
    elseif rightText == nil then
        rightText = ""
    elseif type(rightText) ~= "string" then
        rightText = tostring(rightText)
    end

    return {
        kind = "double",
        leftText = leftText,
        rightText = rightText,
        leftColor = line.leftColor,
        rightColor = line.rightColor
    }
end

function BlankLine(line)
   if line.kind ~= "blank" then return nil end
   return { kind = "blank" }
end

function DefaultLine(line)
    return { kind = "single", line}
end