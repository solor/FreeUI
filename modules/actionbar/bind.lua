local _G = _G
local unpack = unpack
local select = select
local pairs = pairs
local format = format
local tonumber = tonumber
local strfind = strfind
local strupper = strupper
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local GetSpellBookItemName = GetSpellBookItemName
local GetMacroInfo = GetMacroInfo
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local GetBindingKey = GetBindingKey
local GetBindingName = GetBindingName
local SetBinding = SetBinding
local SaveBindings = SaveBindings
local LoadBindings = LoadBindings
local MAX_ACCOUNT_MACROS = MAX_ACCOUNT_MACROS
local NOT_BOUND = NOT_BOUND
local PRESS_KEY_TO_BIND = PRESS_KEY_TO_BIND
local QUICK_KEYBIND_DESCRIPTION = QUICK_KEYBIND_DESCRIPTION
local SpellBook_GetSpellBookSlot = SpellBook_GetSpellBookSlot
local MacroFrameTab1Text = MacroFrameTab1Text
local SlashCmdList = SlashCmdList
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local QUICK_KEYBIND_MODE = QUICK_KEYBIND_MODE
local CHARACTER_SPECIFIC_KEYBINDINGS = CHARACTER_SPECIFIC_KEYBINDINGS
local APPLY = APPLY
local CANCEL = CANCEL

local F, C, L = unpack(select(2, ...))
local ACTIONBAR = F:GetModule('Actionbar')

-- Button types
local function hookActionButton(self)
    local pet = self.commandName and strfind(self.commandName, '^BONUSACTION') and 'PET'
    local stance = self.commandName and strfind(self.commandName, '^SHAPESHIFT') and 'STANCE'
    ACTIONBAR:Bind_Update(self, pet or stance or nil)
end

local function hookMacroButton(self)
    ACTIONBAR:Bind_Update(self, 'MACRO')
end

local function hookSpellButton(self)
    ACTIONBAR:Bind_Update(self, 'SPELL')
end

function ACTIONBAR:Bind_RegisterButton(button)
    if button.IsProtected and button.IsObjectType and button:IsObjectType('CheckButton') and button:IsProtected() then
        button:HookScript('OnEnter', hookActionButton)
    end
end

function ACTIONBAR:Bind_RegisterMacro()
    if self ~= 'Blizzard_MacroUI' then return end

    for i = 1, MAX_ACCOUNT_MACROS do
        local button = _G['MacroButton' .. i]
        button:HookScript('OnEnter', hookMacroButton)
    end
end

function ACTIONBAR:Bind_Create()
    if ACTIONBAR.keybindFrame then return end

    local frame = CreateFrame('Frame', nil, _G.UIParent, 'BackdropTemplate')
    frame:SetFrameStrata('DIALOG')
    frame:EnableMouse(true)
    frame:EnableKeyboard(true)
    frame:EnableMouseWheel(true)
    F.CreateBD(frame, 1)
    frame:SetBackdropColor(1, .8, 0, .25)
    frame:SetBackdropBorderColor(1, .8, 0)
    frame:Hide()

    frame:SetScript('OnEnter', function()
        _G.GameTooltip:SetOwner(frame, 'ANCHOR_NONE')
        _G.GameTooltip:SetPoint('BOTTOM', frame, 'TOP', 0, 2)
        _G.GameTooltip:AddLine(frame.tipName or frame.name, .6, .8, 1)

        if #frame.bindings == 0 then
            _G.GameTooltip:AddLine(NOT_BOUND, 1, 0, 0)
            _G.GameTooltip:AddLine(PRESS_KEY_TO_BIND)
        else
            _G.GameTooltip:AddDoubleLine(L['Index'], L['Key'], .6, .6, .6, .6, .6, .6)
            for i = 1, #frame.bindings do
                _G.GameTooltip:AddDoubleLine(i, frame.bindings[i], 1, 1, 1, 0, 1, 0)
            end
            _G.GameTooltip:AddLine(L['Press the escape key or right click to unbind this action.'], 1, .8, 0, 1)
        end
        _G.GameTooltip:Show()
    end)

    frame:SetScript('OnLeave', ACTIONBAR.Bind_HideFrame)

    frame:SetScript('OnKeyUp', function(_, key)
        ACTIONBAR:Bind_Listener(key)
    end)

    frame:SetScript('OnMouseUp', function(_, key)
        ACTIONBAR:Bind_Listener(key)
    end)

    frame:SetScript('OnMouseWheel', function(_, delta)
        if delta > 0 then
            ACTIONBAR:Bind_Listener('MOUSEWHEELUP')
        else
            ACTIONBAR:Bind_Listener('MOUSEWHEELDOWN')
        end
    end)

    for _, button in pairs(ACTIONBAR.buttons) do ACTIONBAR:Bind_RegisterButton(button) end

    for i = 1, 12 do
        local button = _G['SpellButton' .. i]
        button:HookScript('OnEnter', hookSpellButton)
    end

    if not IsAddOnLoaded('Blizzard_MacroUI') then
        hooksecurefunc('LoadAddOn', ACTIONBAR.Bind_RegisterMacro)
    else
        ACTIONBAR.Bind_RegisterMacro('Blizzard_MacroUI')
    end

    ACTIONBAR.keybindFrame = frame
end

function ACTIONBAR:Bind_Update(button, spellmacro)
    local frame = ACTIONBAR.keybindFrame
    if not frame.enabled or InCombatLockdown() then return end

    frame.button = button
    frame.spellmacro = spellmacro
    frame:ClearAllPoints()
    frame:SetAllPoints(button)
    frame:Show()

    if spellmacro == 'SPELL' then
        frame.id = SpellBook_GetSpellBookSlot(frame.button)
        frame.name = GetSpellBookItemName(frame.id, _G.SpellBookFrame.bookType)
        frame.bindings = {GetBindingKey(spellmacro .. ' ' .. frame.name)}
    elseif spellmacro == 'MACRO' then
        frame.id = frame.button:GetID()
        local colorIndex = F:Round(select(2, MacroFrameTab1Text:GetTextColor()), 1)
        if colorIndex == .8 then frame.id = frame.id + MAX_ACCOUNT_MACROS end
        frame.name = GetMacroInfo(frame.id)
        frame.bindings = {GetBindingKey(spellmacro .. ' ' .. frame.name)}
    elseif spellmacro == 'STANCE' or spellmacro == 'PET' then
        frame.name = button:GetName()
        if not frame.name then return end
        frame.tipName = button.commandName and GetBindingName(button.commandName)

        frame.id = tonumber(button:GetID())
        if not frame.id or frame.id < 1 or frame.id > (spellmacro == 'STANCE' and 10 or 12) then
            frame.bindstring = 'CLICK ' .. frame.name .. ':LeftButton'
        else
            frame.bindstring = (spellmacro == 'STANCE' and 'SHAPESHIFTBUTTON' or 'BONUSACTIONBUTTON') .. frame.id
        end
        frame.bindings = {GetBindingKey(frame.bindstring)}
    else
        frame.name = button:GetName()
        if not frame.name then return end
        frame.tipName = button.commandName and GetBindingName(button.commandName)

        frame.action = tonumber(button.action)
        if button.isCustomButton or not frame.action or frame.action < 1 or frame.action > 168 then
            frame.bindstring = 'CLICK ' .. frame.name .. ':LeftButton'
        else
            local modact = 1 + (frame.action - 1) % 12
            if frame.name == 'ExtraActionButton1' then
                frame.bindstring = 'EXTRAACTIONBUTTON1'
            elseif frame.action < 25 or frame.action > 72 then
                frame.bindstring = 'ACTIONBUTTON' .. modact
            elseif frame.action < 73 and frame.action > 60 then
                frame.bindstring = 'MULTIACTIONBAR1BUTTON' .. modact
            elseif frame.action < 61 and frame.action > 48 then
                frame.bindstring = 'MULTIACTIONBAR2BUTTON' .. modact
            elseif frame.action < 49 and frame.action > 36 then
                frame.bindstring = 'MULTIACTIONBAR4BUTTON' .. modact
            elseif frame.action < 37 and frame.action > 24 then
                frame.bindstring = 'MULTIACTIONBAR3BUTTON' .. modact
            end
        end
        frame.bindings = {GetBindingKey(frame.bindstring)}
    end

    -- Refresh tooltip
    frame:GetScript('OnEnter')(self)
end

local ignoreKeys = {
    ['LALT'] = true,
    ['RALT'] = true,
    ['LCTRL'] = true,
    ['RCTRL'] = true,
    ['LSHIFT'] = true,
    ['RSHIFT'] = true,
    ['UNKNOWN'] = true,
    ['LeftButton'] = true,
}

function ACTIONBAR:Bind_Listener(key)
    local frame = ACTIONBAR.keybindFrame
    if key == 'ESCAPE' or key == 'RightButton' then
        if frame.bindings then for i = 1, #frame.bindings do SetBinding(frame.bindings[i]) end end
        F:Print(format(L['All keybinds cleared for %s.'], C.GreenColor .. (frame.tipName or frame.name) .. '|r'))

        ACTIONBAR:Bind_Update(frame.button, frame.spellmacro)

        return
    end

    local isKeyIgnore = ignoreKeys[key]
    if isKeyIgnore then return end

    if key == 'MiddleButton' then key = 'BUTTON3' end
    if strfind(key, 'Button%d') then key = strupper(key) end

    local alt = IsAltKeyDown() and 'ALT-' or ''
    local ctrl = IsControlKeyDown() and 'CTRL-' or ''
    local shift = IsShiftKeyDown() and 'SHIFT-' or ''

    if not frame.spellmacro or frame.spellmacro == 'PET' or frame.spellmacro == 'STANCE' then
        SetBinding(alt .. ctrl .. shift .. key, frame.bindstring)
    else
        SetBinding(alt .. ctrl .. shift .. key, frame.spellmacro .. ' ' .. frame.name)
    end
    F:Print(C.GreenColor .. (frame.tipName or frame.name) .. ' |r' .. L['bound to'] .. ' ' .. C.RedColor .. alt .. ctrl .. shift .. key)

    ACTIONBAR:Bind_Update(frame.button, frame.spellmacro)
end

function ACTIONBAR:Bind_HideFrame()
    local frame = ACTIONBAR.keybindFrame
    frame:ClearAllPoints()
    frame:Hide()
    if not _G.GameTooltip:IsForbidden() then _G.GameTooltip:Hide() end
end

function ACTIONBAR:Bind_Activate()
    ACTIONBAR.keybindFrame.enabled = true
    F:RegisterEvent('PLAYER_REGEN_DISABLED', ACTIONBAR.Bind_Deactivate)
end

function ACTIONBAR:Bind_Deactivate(save)
    if save == true then
        SaveBindings(C.DB.Actionbar.BindType)
        F:Print(C.BlueColor .. L['Keybinds saved.'])
    else
        LoadBindings(C.DB.Actionbar.BindType)
        F:Print(C.BlueColor .. L['Keybinds discarded.'])
    end

    ACTIONBAR:Bind_HideFrame()
    ACTIONBAR.keybindFrame.enabled = false
    F:UnregisterEvent('PLAYER_REGEN_DISABLED', ACTIONBAR.Bind_Deactivate)
    ACTIONBAR.keybindDialog:Hide()
end

function ACTIONBAR:Bind_CreateDialog()
    local dialog = ACTIONBAR.keybindDialog
    if dialog then
        dialog:Show()
        return
    end

    local frame = CreateFrame('Frame', nil, _G.UIParent)
    frame:SetSize(320, 100)
    frame:SetPoint('TOP', 0, -135)
    F.SetBD(frame)

    local font = C.Assets.Fonts.Bold
    F.CreateFS(frame, font, 14, nil, QUICK_KEYBIND_MODE, false, true, 'TOP', 0, -10)

    local helpInfo = F.CreateHelpInfo(frame, '|n' .. QUICK_KEYBIND_DESCRIPTION)
    helpInfo:SetPoint('TOPRIGHT', 2, -2)

    local text = F.CreateFS(frame, font, 12, nil, CHARACTER_SPECIFIC_KEYBINDINGS, 'YELLOW', true, 'TOP', 0, -40)
    local box = F.CreateCheckbox(frame)
    box:SetChecked(C.DB.Actionbar.BindType == 2)
    box:SetPoint('RIGHT', text, 'LEFT', -5, -0)
    box:SetScript('OnClick', function(self)
        C.DB.Actionbar.BindType = self:GetChecked() and 2 or 1
    end)

    local button1 = F.CreateButton(frame, 120, 26, APPLY, 12)
    button1:SetPoint('BOTTOMLEFT', 25, 10)
    button1:SetScript('OnClick', function()
        ACTIONBAR:Bind_Deactivate(true)
    end)

    local button2 = F.CreateButton(frame, 120, 26, CANCEL, 12)
    button2:SetPoint('BOTTOMRIGHT', -25, 10)
    button2:SetScript('OnClick', function()
        ACTIONBAR:Bind_Deactivate()
    end)

    ACTIONBAR.keybindDialog = frame
end

SlashCmdList['FREEUI_KEYBIND'] = function(msg)
    if msg ~= '' then return end -- don't mess up with this
    if InCombatLockdown() then
        _G.UIErrorsFrame:AddMessage(C.RedColor .. ERR_NOT_IN_COMBAT)
        return
    end

    ACTIONBAR:Bind_Create()
    ACTIONBAR:Bind_Activate()
    ACTIONBAR:Bind_CreateDialog()
end
_G.SLASH_FREEUI_KEYBIND1 = '/bind'
