-- tests/ResizeBoundsFixture.lua
-- Capability fixture: BookWindow init-path resize bounds (issue #15 / #11).
--
-- Dev-time harness only; intentionally NOT referenced by RGXProfessions.toc.
-- Mirrors the operator's repro approach (repro-professions-resize.mjs): stub
-- the frame API surface and exercise the REAL RGXProf.BookWindow:EnsureFrame
-- code path, asserting the init-path resize-bounds contract in BOTH
-- capability modes:
--   modern: the client exposes Frame:SetResizeBounds(minW, minH, maxW, maxH)
--   legacy : the whole native resize-bound family is absent (the Forever
--            beta shape, where the issue #11 crash happened)
--
-- Run from the repository root:
--   lua5.1 tests/ResizeBoundsFixture.lua modern
--   lua5.1 tests/ResizeBoundsFixture.lua legacy
-- or drive both modes with the Node runner:  node tests/resize-bounds.test.mjs
-- Requires no WoW installation.

-- Lua 5.2+/LuaJIT tolerance so the same file runs under any 5.1-era toolchain.
local loadstring = loadstring or load
local unpack = unpack or table.unpack

local function main(mode, addonSrc)

if mode ~= "modern" and mode ~= "legacy" then
    error("ResizeBoundsFixture: expected mode 'modern' or 'legacy', got " .. tostring(mode))
end

--------------------------------------------------------------------------------
-- Minimal WoW API stub surface (enough for the real EnsureFrame to complete)
--------------------------------------------------------------------------------

local function makeFrame()
    local frame = { width = 0, height = 0, scripts = {}, shown = false }
    frame.SetSize = function(_, w, h) frame.width = w frame.height = h end
    frame.SetWidth = function(_, w) frame.width = w end
    frame.SetHeight = function(_, h) frame.height = h end
    frame.GetWidth = function() return frame.width end
    frame.GetHeight = function() return frame.height end
    frame.SetPoint = function() end
    frame.ClearAllPoints = function() end
    frame.GetPoint = function() return "CENTER", "UIParent", "CENTER", 0, 0 end
    frame.SetMovable = function() end
    frame.EnableMouse = function() end
    frame.EnableMouseWheel = function() end
    frame.SetClampedToScreen = function() end
    frame.SetFrameStrata = function() end
    frame.SetToplevel = function() end
    frame.RegisterForDrag = function() end
    frame.SetScript = function(_, name, fn) frame.scripts[name] = fn end
    frame.HookScript = function(_, name, fn)
        local prev = frame.scripts[name]
        frame.scripts[name] = function(...) if prev then prev(...) end fn(...) end
    end
    frame.Show = function() frame.shown = true end
    frame.Hide = function() frame.shown = false end
    frame.IsShown = function() return frame.shown end
    frame.SetID = function() end
    frame.SetHitRectInsets = function() end
    frame.SetAlpha = function() end
    frame.GetEffectiveScale = function() return 1 end
    frame.GetLeft = function() return 0 end
    frame.GetTop = function() return 0 end
    frame.GetRight = function() return frame.width end
    frame.GetBottom = function() return 0 end
    frame.GetMinMaxValues = function() return 0, 1 end
    frame.SetMinMaxValues = function() end
    frame.SetValue = function() end
    frame.SetOrientation = function() end
    frame.SetStatusBarTexture = function() end
    frame.SetStatusBarColor = function() end
    frame.SetColorTexture = function() end
    frame.SetNormalTexture = function() end
    frame.SetPushedTexture = function() end
    frame.SetHighlightTexture = function() end
    frame.SetPanelColor = function() end
    frame.SetScrollChild = function() end
    frame.GetVerticalScroll = function() return 0 end
    frame.SetVerticalScroll = function() end
    frame.EnableKeyboard = function() end
    frame.SetPropagateKeyboardInput = function() end
    frame.SetAttribute = function() end
    frame.SetAllPoints = function() end
    frame.CreateTexture = function()
        local t = {}
        t.SetTexture = function() end
        t.SetTexCoord = function() end
        t.SetVertexColor = function() end
        t.SetSize = function() end
        t.SetWidth = function() end
        t.SetHeight = function() end
        t.SetPoint = function() end
        t.SetAllPoints = function() end
        t.Show = function() end
        t.Hide = function() end
        t.SetAlpha = function() end
        t.SetDrawLayer = function() end
        t.SetDesaturated = function() end
        return t
    end
    frame.CreateFontString = function()
        local fs = {}
        fs.SetText = function() end
        fs.SetFontObject = function() end
        fs.SetFont = function() end
        fs.SetPoint = function() end
        fs.SetJustifyH = function() end
        fs.SetJustifyV = function() end
        fs.SetSize = function() end
        fs.SetWidth = function() end
        fs.SetHeight = function() end
        fs.SetTextColor = function() end
        fs.Show = function() end
        fs.Hide = function() end
        fs.SetAllPoints = function() end
        fs.SetWordWrap = function() end
        fs.SetNonSpaceWrap = function() end
        fs.SetSpacing = function() end
        fs.SetMaxLines = function() end
        fs.GetText = function() return "" end
        return fs
    end
    return frame
end

-- Capability-mode window factory ----------------------------------------------
-- modern: the native resize-bound API family is present.
-- legacy : the entire native resize-bound family is nil, the exact surface
--          the operator's crash reproduced on (SetMinResize is nil).
local function makeWindowFrame()
    local frame = makeFrame()
    if mode == "modern" then
        frame.resizeBounds = nil
        frame.SetResizeBounds = function(_, minW, minH, maxW, maxH)
            frame.resizeBounds = { minW, minH, maxW, maxH }
        end
        frame.GetResizeBounds = function() return frame.resizeBounds end
    else
        frame.SetResizeBounds = nil
        frame.SetMinResize = nil
        frame.SetMaxResize = nil
        frame.GetResizeBounds = nil
    end
    return frame
end

local window = makeWindowFrame()

-- Capability call log: which native bound APIs the real init path invoked.
local calls = {}
local nativeSetResizeBounds = window.SetResizeBounds
if nativeSetResizeBounds then
    window.SetResizeBounds = function(...)
        calls[#calls + 1] = "SetResizeBounds"
        return nativeSetResizeBounds(...)
    end
end
-- Sentinels for the crash API family from issue #11. These must NEVER be
-- called in either mode: unguarded SetMinResize calls are what crashed the
-- book open on the Forever beta, and even the guarded pair stays retired.
local crashedAPI = nil
window.SetMinResize = function()
    crashedAPI = "SetMinResize"
    error("SetMinResize called in " .. mode .. " mode")
end
window.SetMaxResize = function()
    crashedAPI = "SetMaxResize"
    error("SetMaxResize called in " .. mode .. " mode")
end

--------------------------------------------------------------------------------
-- Global environment the addon expects at EnsureFrame time
--------------------------------------------------------------------------------

local function freshRGXProf()
    return {
        BookWindow = {},
        L = setmetatable({}, { __index = function() return "" end }),
        Constants = {
            Professions = {},
            ProfessionOrder = {},
            SkillUpColors = {},
            TierLabels = {},
        },
        currentExpansion = { maxSkill = 300, paths = {} },
        WowAPI = { GetProfessionSkill = function() return nil, nil end },
    }
end

RGXProf = freshRGXProf()
RGXProf_Settings = {}

local Design = {
    CreateFrame = function() return makeFrame() end,
    CreateButton = function()
        local b = makeFrame()
        b.SetTooltip = function() end
        b.SetText = function() end
        return b
    end,
    Unpack = function() return 1, 1, 1 end,
}
_G.RGXDesign = Design

local UIStub = {
    CreateScrollPage = function() return makeFrame() end,
    CreateSection = function()
        local sec = makeFrame()
        sec.content = makeFrame()
        sec.FitContent = function() end
        return sec
    end,
}
_G.RGXUI = UIStub

_G.UIParent = makeFrame()
_G.CreateFrame = function() return makeFrame() end
_G.GetTime = function() return 0 end
_G.GetCursorPosition = function() return 0, 0 end
_G.GameTooltip = makeFrame()
_G.GameTooltip.SetOwner = function() end
_G.GameTooltip.SetText = function() end
_G.CreateColor = nil

--------------------------------------------------------------------------------
-- Exercise the REAL EnsureFrame path and assert the init contract
--------------------------------------------------------------------------------

-- The bounds contract from the parent: 640x420 .. 1400x1000, all four.
local MIN_W, MAX_W, MIN_H, MAX_H = 640, 1400, 420, 1000

local failures = 0
local function check(cond, msg)
    if cond then
        print("  PASS: " .. msg)
    else
        failures = failures + 1
        print("  FAIL: " .. msg)
    end
end

-- EnsureFrame builds once and caches self.frame, and the addon chunk merges
-- into whatever RGXProf.BookWindow table exists at load time
-- (RGXProf.BookWindow = RGXProf.BookWindow or {}). Each case therefore gets
-- a fresh RGXProf table and re-executes the REAL addon chunk, so the real
-- constructor re-runs from scratch against the capability-mode window. The
-- first Design:CreateFrame call in each run is the book window itself; route
-- it to the capability-mode window under test.
local realCreateFrame = Design.CreateFrame
local function runCase(savedSize, label)
    RGXProf = freshRGXProf()
    RGXProf_Settings = {}
    if savedSize then RGXProf_Settings.bookSize = savedSize end
    window.width, window.height = 0, 0
    window.sizer = nil
    window.resizeBounds = nil
    calls = {}

    local freshAddon = assert(loadstring(addonSrc, "UI/BookWindow.lua"))

    Design.CreateFrame = function(parent, opts)
        if opts and opts.width and window.sizer == nil then
            -- The real Design factory applies the requested opts as the
            -- frame's initial size; mirror that on the window stub.
            window.width, window.height = opts.width, opts.height
            return window
        end
        return realCreateFrame(parent, opts)
    end

    local ok, err = pcall(function()
        freshAddon()
        RGXProf.BookWindow:EnsureFrame()
    end)
    Design.CreateFrame = realCreateFrame
    if not ok then
        check(false, label .. ": real EnsureFrame completed without error (" .. tostring(err) .. ")")
        return nil
    end
    check(window.width >= MIN_W and window.width <= MAX_W
        and window.height >= MIN_H and window.height <= MAX_H,
        label .. ": size inside 640x420..1400x1000 after init (got "
        .. tostring(window.width) .. "x" .. tostring(window.height) .. ")")
    return {
        w = window.width, h = window.height,
        resizeBounds = window.resizeBounds,
        calls = calls,
    }
end

print("ResizeBoundsFixture[" .. mode .. "]: exercising the real EnsureFrame init path")

-- 1. Out-of-bounds saved size (below minimum) is clamped up at init.
local c1 = runCase({ 100, 50 }, "saved-below-min")
if c1 then
    check(c1.w == MIN_W and c1.h == MIN_H,
        "saved-below-min: clamped exactly to the minimum " .. MIN_W .. "x" .. MIN_H)
    if mode == "modern" then
        check(#c1.calls >= 1 and c1.calls[1] == "SetResizeBounds",
            "modern: init published all four bounds through SetResizeBounds")
        check(c1.resizeBounds ~= nil
            and c1.resizeBounds[1] == MIN_W and c1.resizeBounds[2] == MIN_H
            and c1.resizeBounds[3] == MAX_W and c1.resizeBounds[4] == MAX_H,
            "modern: SetResizeBounds received (minW, minH, maxW, maxH) = (640, 420, 1400, 1000)")
    else
        check(#c1.calls == 0, "legacy: no call to the absent SetResizeBounds")
    end
end

-- 2. Out-of-bounds saved size (above maximum) is clamped down at init.
local c2 = runCase({ 5000, 4000 }, "saved-above-max")
if c2 then
    check(c2.w == MAX_W and c2.h == MAX_H,
        "saved-above-max: clamped exactly to the maximum " .. MAX_W .. "x" .. MAX_H)
    if mode == "modern" then
        check(c2.resizeBounds ~= nil
            and c2.resizeBounds[1] == MIN_W and c2.resizeBounds[2] == MIN_H
            and c2.resizeBounds[3] == MAX_W and c2.resizeBounds[4] == MAX_H,
            "modern: native bounds recorded for the above-max case")
    else
        check(#c2.calls == 0, "legacy: no call to the absent SetResizeBounds")
    end
end

-- 3. In-range saved size passes through unchanged.
local c3 = runCase({ 900, 600 }, "saved-in-range")
if c3 then
    check(c3.w == 900 and c3.h == 600,
        "saved-in-range: size unchanged (got " .. c3.w .. "x" .. c3.h .. ")")
end

-- 4. No saved size: the fixed defaults (720x470) pass the bounds check.
local c4 = runCase(nil, "default-size")
if c4 then
    check(c4.w == 720 and c4.h == 470,
        "default-size: in-range default passes through unchanged")
end

-- 5. Mixed saved size: one axis below min, one above max.
local c5 = runCase({ 100, 4000 }, "saved-mixed")
if c5 then
    check(c5.w == MIN_W and c5.h == MAX_H,
        "saved-mixed: each axis clamped independently (got "
        .. c5.w .. "x" .. c5.h .. ")")
end

-- 6. Sizer wiring: after the bounded init the grip is present and drag-wired,
--    the drag-time clamp still bounds the window, and releasing the grip
--    persists bookSize (no sizer or persistence regression).
local c6 = runCase({ 800, 500 }, "sizer-wired")
if c6 then
    check(window.sizer ~= nil, "sizer-wired: grip exists after bounded init")
    if window.sizer then
        check(window.sizer.scripts["OnDragStart"] ~= nil,
            "sizer-wired: grip registered OnDragStart after bounded init")
        local drag = window.sizer.scripts["OnDragStart"]
        local okDrag = pcall(function() drag(window.sizer) end)
        local upd = window.sizer.scripts["OnUpdate"]
        if okDrag and upd then
            local okUpd = pcall(function() upd(window.sizer) end)
            check(okUpd and window.width >= MIN_W and window.width <= MAX_W
                and window.height >= MIN_H and window.height <= MAX_H,
                "sizer-wired: drag-time clamp still bounds the window (got "
                .. tostring(window.width) .. "x" .. tostring(window.height) .. ")")
            local stop = window.sizer.scripts["OnDragStop"]
            local okStop = pcall(function() stop(window.sizer) end)
            local saved = RGXProf_Settings.bookSize
            check(okStop and type(saved) == "table"
                and saved[1] == window.width and saved[2] == window.height,
                "sizer-wired: drag release persists bookSize ("
                .. tostring(saved and saved[1]) .. "x" .. tostring(saved and saved[2]) .. ")")
        else
            check(false, "sizer-wired: drag scripts runnable")
        end
    end
end

-- 7. ESC-close path intact after the bounded init.
local c7 = runCase(nil, "esc-close")
if c7 then
    window:Show()
    local key = window.scripts["OnKeyDown"]
    check(key ~= nil, "esc-close: OnKeyDown handler wired")
    if key then
        local okKey = pcall(function() key(window, "ESCAPE") end)
        check(okKey and not window:IsShown(),
            "esc-close: ESC hides the window")
    end
end

-- 8. BOTH modes: the issue #11 crash API family is never invoked.
check(crashedAPI == nil,
    mode .. ": SetMinResize/SetMaxResize never called (issue #11 crash family)")

if failures > 0 then
    print("ResizeBoundsFixture[" .. mode .. "]: " .. failures .. " FAILURE(S)")
    error(failures .. " fixture assertion(s) failed in " .. mode .. " mode")
else
    print("ResizeBoundsFixture[" .. mode .. "]: all assertions passed")
end

end

-- Direct-run entry point. Executed from the repository root:
--   lua5.1 tests/ResizeBoundsFixture.lua <mode>
-- reads the real addon source and runs the same assertions the Node runner
-- drives in both modes.
local argMode = ...
local fh = io.open("UI/BookWindow.lua", "rb")
if fh then
    local src = fh:read("*a")
    fh:close()
    main(argMode or "modern", src)
else
    error("ResizeBoundsFixture: UI/BookWindow.lua not found - run from the repository root")
end
