local _G = _G
local unpack = unpack
local select = select
local tinsert = tinsert
local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local SHOW_MULTIBAR2_TEXT = SHOW_MULTIBAR2_TEXT
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
local MultiBarBottomRight = MultiBarBottomRight

local F, C = unpack(select(2, ...))
local ACTIONBAR = F:GetModule('Actionbar')

local margin, padding = 3, 3

local function SetFrameSize(frame, size, num)
    size = size or frame.buttonSize
    num = num or frame.numButtons

    local layout = C.DB.Actionbar.Layout

    if layout == 4 then
        frame:SetWidth(18 * size + 17 * margin + 2 * padding)
        frame:SetHeight(2 * size + margin + 2 * padding)

        local button = _G['MultiBarBottomRightButton7']
        button:SetPoint('TOPRIGHT', frame, -2 * (size + margin) - padding, -padding)
    else
        frame:SetWidth(num * size + (num - 1) * margin + 2 * padding)
        frame:SetHeight(size + 2 * padding)
    end

    if not frame.mover then
        if layout == 3 or layout == 4 then
            frame.mover = F.Mover(frame, SHOW_MULTIBAR2_TEXT, 'Bar3', frame.Pos)
        end
    else
        frame.mover:SetSize(frame:GetSize())
    end

    if not frame.SetFrameSize then
        frame.buttonSize = size
        frame.numButtons = num
        frame.SetFrameSize = SetFrameSize
    end
end

function ACTIONBAR:CreateBar3()
    local num = NUM_ACTIONBAR_BUTTONS
    local size = C.DB.Actionbar.ButtonSize
    local layout = C.DB.Actionbar.Layout
    local buttonList = {}

    local frame = CreateFrame('Frame', 'FreeUI_ActionBar3', _G.UIParent, 'SecureHandlerStateTemplate')

    if layout == 4 then
        frame.Pos = {'BOTTOM', _G.UIParent, 'BOTTOM', 0, C.UIGap}
    else
        frame.Pos = {'BOTTOM', _G.FreeUI_ActionBar2, 'TOP', 0, -margin}
    end

    MultiBarBottomRight:SetParent(frame)
    MultiBarBottomRight:EnableMouse(false)
    MultiBarBottomRight.QuickKeybindGlow:SetTexture('')

    for i = 1, num do
        local button = _G['MultiBarBottomRightButton' .. i]
        tinsert(buttonList, button)
        tinsert(ACTIONBAR.buttons, button)
        button:ClearAllPoints()

        if i == 1 then
            button:SetPoint('TOPLEFT', frame, padding, -padding)
        elseif (i == 4 and layout == 4) then
            local previous = _G['MultiBarBottomRightButton1']
            button:SetPoint('TOP', previous, 'BOTTOM', 0, -padding)
        elseif (i == 7 and layout == 4) then
            button:SetPoint('TOPRIGHT', frame, -2 * (size + margin) - padding, -padding)
        elseif (i == 10 and layout == 4) then
            local previous = _G['MultiBarBottomRightButton7']
            button:SetPoint('TOP', previous, 'BOTTOM', 0, -padding)
        else
            local previous = _G['MultiBarBottomRightButton' .. i - 1]
            button:SetPoint('LEFT', previous, 'RIGHT', margin, 0)
        end
    end

    frame.buttonList = buttonList
    SetFrameSize(frame, size, num)

    if layout == 3 or layout == 4 then
        frame.frameVisibility = '[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show'
    else
        frame.frameVisibility = 'hide'
    end
    RegisterStateDriver(frame, 'visibility', frame.frameVisibility)
end
