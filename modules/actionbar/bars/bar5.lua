local _G = _G
local unpack = unpack
local select = select
local tinsert = tinsert
local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local SHOW_MULTIBAR4_TEXT = SHOW_MULTIBAR4_TEXT
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
local MultiBarLeft = MultiBarLeft

local F, C = unpack(select(2, ...))
local ACTIONBAR = F:GetModule('Actionbar')

local margin, padding = 3, 3

local function SetFrameSize(frame, size, num)
    size = size or frame.buttonSize
    num = num or frame.numButtons

    frame:SetWidth(size + 2 * padding)
    frame:SetHeight(num * size + (num - 1) * margin + 2 * padding)

    if not frame.mover then
        if C.DB.Actionbar.Bar5 then
            frame.mover = F.Mover(frame, SHOW_MULTIBAR4_TEXT, 'Bar5', frame.Pos)
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

function ACTIONBAR:CreateBar5()
    local num = NUM_ACTIONBAR_BUTTONS
    local buttonList = {}
    local size = C.DB.Actionbar.ButtonSize

    local frame = CreateFrame('Frame', 'FreeUI_ActionBar5', _G.UIParent, 'SecureHandlerStateTemplate')
    frame.Pos = {'RIGHT', _G.FreeUI_ActionBar4, 'LEFT', margin, 0}

    MultiBarLeft:SetParent(frame)
    MultiBarLeft:EnableMouse(false)
    MultiBarLeft.QuickKeybindGlow:SetTexture('')

    for i = 1, num do
        local button = _G['MultiBarLeftButton' .. i]
        tinsert(buttonList, button)
        tinsert(ACTIONBAR.buttons, button)
        button:ClearAllPoints()
        if i == 1 then
            button:SetPoint('TOPRIGHT', frame, -padding, -padding)
        else
            local previous = _G['MultiBarLeftButton' .. i - 1]
            button:SetPoint('TOP', previous, 'BOTTOM', 0, -margin)
        end
    end

    frame.buttonList = buttonList
    SetFrameSize(frame, size, num)

    if C.DB.Actionbar.Bar5 then
        frame.frameVisibility = '[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show'
    else
        frame.frameVisibility = 'hide'
    end
    RegisterStateDriver(frame, 'visibility', frame.frameVisibility)
end
