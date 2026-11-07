--=====================================================================================
-- RGXProfessions - UI/RoundedButton.lua
-- Rounded RGX buttons: the framework's Design:CreateButton is a square backdrop button, so the
-- addon draws its own on the same rounded panel the windows and cards use. Same hover feel
-- (surface -> hover fill, border -> brand crimson) and the same SetTooltip(title, body) call.
--=====================================================================================

RGXProf = RGXProf or {}

local BRAND = { 0.545, 0.082, 0.220 } -- RGX crimson

local function Tex()
    local D = _G.RGXDesign
    return (D and D.PANEL_TEX) or "Interface\\AddOns\\RGX-Framework\\libraries\\design\\panel_rounded.tga"
end
RGXProf.PanelTexture = Tex

local function Shade(key, fallback)
    local D = _G.RGXDesign
    if D and D.Unpack then
        local ok, r, g, b = pcall(D.Unpack, D, key)
        if ok and r then return { r, g, b } end
    end
    return fallback
end

--- width/height in pixels; text may be nil (icon tiles add their own children).
function RGXProf.CreateRoundedButton(parent, text, width, height, tooltipTitle, tooltipBody)
    local D = _G.RGXDesign
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(width or 120, height or 24)

    btn._fill = Shade("surface", { 0.086, 0.086, 0.110 })
    btn._hoverFill = Shade("hover", { 0.102, 0.102, 0.129 })
    btn._border = Shade("border", { 0.137, 0.137, 0.173 })

    if D and D.ApplyPanel then
        D:ApplyPanel(btn, { color = "surface", radius = math.min(10, math.floor((height or 24) / 2)) })
        btn:SetPanelColor(btn._fill, btn._border, 1)
        btn._rounded = true
    else
        btn.bg = btn:CreateTexture(nil, "BACKGROUND")
        btn.bg:SetAllPoints()
        btn.bg:SetColorTexture(btn._fill[1], btn._fill[2], btn._fill[3], 1)
    end

    btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.label:SetPoint("LEFT", 8, 0)
    btn.label:SetPoint("RIGHT", -8, 0)
    btn.label:SetJustifyH("CENTER")
    btn.label:SetWordWrap(false)
    btn.label:SetText(text or "")
    local sr, sg, sb = 0.545, 0.545, 0.596
    if D and D.Unpack then sr, sg, sb = D:Unpack("subtext") end
    btn.label:SetTextColor(sr, sg, sb)

    local function paint(self, hover)
        local fill = hover and self._hoverFill or self._fill
        local border = hover and BRAND or self._border
        if self._rounded then
            self:SetPanelColor(fill, border, 1)
        elseif self.bg then
            self.bg:SetColorTexture(fill[1], fill[2], fill[3], 1)
        end
        if hover then self.label:SetTextColor(1, 1, 1) else self.label:SetTextColor(sr, sg, sb) end
    end

    btn:SetScript("OnEnter", function(self)
        paint(self, true)
        if self._ttTitle and GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self._ttTitle, 1, 1, 1)
            if self._ttBody then GameTooltip:AddLine(self._ttBody, sr, sg, sb, true) end
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function(self)
        paint(self, false)
        if GameTooltip then GameTooltip:Hide() end
    end)
    btn:SetScript("OnMouseDown", function(self) self.label:SetPoint("LEFT", 8, -1) self.label:SetPoint("RIGHT", -8, -1) end)
    btn:SetScript("OnMouseUp", function(self) self.label:SetPoint("LEFT", 8, 0) self.label:SetPoint("RIGHT", -8, 0) end)

    function btn:SetTooltip(title, body) self._ttTitle, self._ttBody = title, body end
    function btn:SetLabel(t) self.label:SetText(t or "") end
    if tooltipTitle then btn:SetTooltip(tooltipTitle, tooltipBody) end
    return btn
end
