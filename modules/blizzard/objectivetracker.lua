local _G = _G
local unpack = unpack
local select = select
local min = min
local abs = abs
local strmatch = strmatch
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo
local StaticPopup_Show = StaticPopup_Show
local UIDropDownMenu_AddButton = UIDropDownMenu_AddButton
local ObjectiveTracker_Update = ObjectiveTracker_Update
local UIDROPDOWN_MENU_LEVEL = UIDROPDOWN_MENU_LEVEL
local OKAY = OKAY

local F, C, L = unpack(select(2, ...))
local BLIZZARD = F:GetModule('Blizzard')

function BLIZZARD:ObjectiveTrackerMover()
    local frame = CreateFrame('Frame', 'ObjectiveTrackerMover', _G.UIParent)
    frame:SetSize(240, 50)
    F.Mover(frame, L['Objective Tracker'], 'QuestTracker', {'TOPRIGHT', _G.UIParent, 'TOPRIGHT', -C.UIGap, -60})

    local tracker = _G.ObjectiveTrackerFrame
    tracker:ClearAllPoints()
    tracker:SetPoint('TOPRIGHT', frame)
    tracker:SetHeight(C.ScreenHeight / 1.5 * C.Mult)
    tracker:SetScale(1)
    tracker:SetClampedToScreen(false)
    tracker:SetMovable(true)
    if tracker:IsMovable() then
        tracker:SetUserPlaced(true)
    end
end





--[[ Restyle objective tracker text ]]

local color = {start = {r = 1.000, g = 0.647, b = 0.008}, complete = {r = 0.180, g = 0.835, b = 0.451}}

local function SetTextColorHook(text)
    if not text.Hooked then
        local SetTextColorOld = text.SetTextColor
        text.SetTextColor = function(self, r, g, b, a)
            if r == _G.OBJECTIVE_TRACKER_COLOR['Header'].r and g == _G.OBJECTIVE_TRACKER_COLOR['Header'].g and b ==
                _G.OBJECTIVE_TRACKER_COLOR['Header'].b then
                r = 216 / 255
                g = 197 / 255
                b = 136 / 255
            elseif r == _G.OBJECTIVE_TRACKER_COLOR['HeaderHighlight'].r and g ==
                _G.OBJECTIVE_TRACKER_COLOR['HeaderHighlight'].g and b == _G.OBJECTIVE_TRACKER_COLOR['HeaderHighlight'].b then
                r = 216 / 255
                g = 181 / 255
                b = 136 / 255
            end
            SetTextColorOld(self, r, g, b, a)
        end
        text:SetTextColor(_G.OBJECTIVE_TRACKER_COLOR['Header'].r, _G.OBJECTIVE_TRACKER_COLOR['Header'].g,
                          _G.OBJECTIVE_TRACKER_COLOR['Header'].b, 1)
        text.Hooked = true
    end
end

local function GetProgressColor(progress)
    local r = (color.complete.r - color.start.r) * progress + color.start.r
    local g = (color.complete.g - color.start.g) * progress + color.start.g
    local b = (color.complete.r - color.start.b) * progress + color.start.b

    local addition = 0.35
    r = min(r + abs(0.5 - progress) * addition, r)
    g = min(g + abs(0.5 - progress) * addition, g)
    b = min(b + abs(0.5 - progress) * addition, b)

    return {r = r, g = g, b = b}
end

function BLIZZARD:HandleHeaderText()
    local frame = _G.ObjectiveTrackerFrame.MODULES
    if not frame then
        return
    end

    for i = 1, #frame do
        local modules = frame[i]
        if modules and modules.Header and modules.Header.Text then
            F:SetFS(modules.Header.Text, C.Assets.Fonts.Header, 15, nil, nil, nil, 'THICK')
        end
    end
end

function BLIZZARD:HandleTitleText(text)
    local font = C.Assets.Fonts.Bold
    local outline = _G.FREE_ADB.FontOutline
    F:SetFS(text, font, 14, outline, nil, nil, outline or 'THICK')

    local height = text:GetStringHeight() + 2
    if height ~= text:GetHeight() then
        text:SetHeight(height)
    end

    SetTextColorHook(text)
end

function BLIZZARD:HandleInfoText(text)
    self:ColorfulProgression(text)

    local font = C.Assets.Fonts.Regular
    local outline = _G.FREE_ADB.FontOutline
    F:SetFS(text, font, 13, outline, nil, nil, outline or 'THICK')
    text:SetHeight(text:GetStringHeight())

    local line = text:GetParent()
    local dash = line.Dash or line.Icon

    dash:Hide()
    text:ClearAllPoints()
    text:SetPoint('TOPLEFT', dash, 'TOPLEFT', 0, 0)
end

function BLIZZARD:ScenarioObjectiveBlock_UpdateCriteria()
    if _G.ScenarioObjectiveBlock then
        local childs = {_G.ScenarioObjectiveBlock:GetChildren()}
        for _, child in pairs(childs) do
            if child.Text then
                BLIZZARD:HandleInfoText(child.Text)
            end
        end
    end
end

function BLIZZARD:ColorfulProgression(text)
    if not text then
        return
    end

    local info = text:GetText()
    if not info then
        return
    end

    local current, required, details = strmatch(info, '^(%d-)/(%d-) (.+)')

    if not (current and required and details) then
        details, current, required = strmatch(info, '(.+): (%d-)/(%d-)$')
    end

    if not (current and required and details) then
        return
    end

    local progress = tonumber(current) / tonumber(required)

    info = F:CreateColorString(current .. '/' .. required, GetProgressColor(progress))
    info = info .. ' ' .. details

    text:SetText(info)
end

do
    local dash = _G.OBJECTIVE_TRACKER_DASH_WIDTH
    function BLIZZARD:UpdateTextWidth()
        _G.OBJECTIVE_TRACKER_DASH_WIDTH = dash
    end
end

function BLIZZARD:RestyleObjectiveTrackerText()
    self:UpdateTextWidth()

    local trackerModules = {
        _G.UI_WIDGET_TRACKER_MODULE,
        _G.BONUS_OBJECTIVE_TRACKER_MODULE,
        _G.WORLD_QUEST_TRACKER_MODULE,
        _G.CAMPAIGN_QUEST_TRACKER_MODULE,
        _G.QUEST_TRACKER_MODULE,
        _G.ACHIEVEMENT_TRACKER_MODULE,
    }

    for _, module in pairs(trackerModules) do
        hooksecurefunc(module, 'AddObjective', function(_, block)
            if not block then
                return
            end

            if block.HeaderText then
                BLIZZARD:HandleTitleText(block.HeaderText)
            end

            if block.currentLine then
                if block.currentLine.objectiveKey == 0 then -- 世界任务标题
                    BLIZZARD:HandleTitleText(block.currentLine.Text)
                else
                    BLIZZARD:HandleInfoText(block.currentLine.Text)
                end
            end
        end)

    end

    hooksecurefunc('ObjectiveTracker_Update', BLIZZARD.HandleHeaderText)
    hooksecurefunc(_G.SCENARIO_CONTENT_TRACKER_MODULE, 'UpdateCriteria', BLIZZARD.ScenarioObjectiveBlock_UpdateCriteria)

    F.Delay(1, function()
        for _, child in pairs {_G.ObjectiveTrackerBlocksFrame:GetChildren()} do
            if child and child.HeaderText then
                SetTextColorHook(child.HeaderText)
            end
        end
    end)

    ObjectiveTracker_Update()
end

local headers = {
    _G.SCENARIO_CONTENT_TRACKER_MODULE,
    _G.BONUS_OBJECTIVE_TRACKER_MODULE,
    _G.UI_WIDGET_TRACKER_MODULE,
    _G.CAMPAIGN_QUEST_TRACKER_MODULE,
    _G.QUEST_TRACKER_MODULE,
    _G.ACHIEVEMENT_TRACKER_MODULE,
    _G.WORLD_QUEST_TRACKER_MODULE,
}

local function OnEvent()
    local inInstance, instanceType = IsInInstance()
    if inInstance then
        if instanceType == 'party' or instanceType == 'scenario' then
            for i = 3, #headers do
                local button = headers[i].Header.MinimizeButton
                if button and not headers[i].collapsed then
                    button:Click()
                end
            end
        else
            ObjectiveTracker_Collapse()
        end
    else
        if not InCombatLockdown() then
            for i = 3, #headers do
                local button = headers[i].Header.MinimizeButton
                if button and headers[i].collapsed then
                    button:Click()
                end
            end
            if ObjectiveTrackerFrame.collapsed then
                ObjectiveTracker_Expand()
            end
        end
    end
end

function BLIZZARD:EnhancedObjectiveTracker()
    BLIZZARD:ObjectiveTrackerMover()

    BLIZZARD:RestyleObjectiveTrackerText()

    -- Kill reward animation when finished dungeon or bonus objectives
    ObjectiveTrackerScenarioRewardsFrame.Show = F.Dummy

    hooksecurefunc('BonusObjectiveTracker_AnimateReward', function()
        ObjectiveTrackerBonusRewardsFrame:ClearAllPoints()
        ObjectiveTrackerBonusRewardsFrame:SetPoint('BOTTOM', UIParent, 'TOP', 0, 90)
    end)

    -- Auto collapse Objective Tracker
    F:RegisterEvent('PLAYER_ENTERING_WORLD', OnEvent)
end
BLIZZARD:RegisterBlizz('EnhancedObjectiveTracker', BLIZZARD.EnhancedObjectiveTracker)
