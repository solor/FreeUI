local _G = _G
local unpack = unpack
local select = select
local next = next
local pairs = pairs
local mod = mod
local tinsert = tinsert
local wipe = wipe
local strsplit = strsplit
local format = format
local CreateFrame = CreateFrame
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsInInstance = IsInInstance
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local UnitName = UnitName
local IsPartyLFG = IsPartyLFG
local IsLFGComplete = IsLFGComplete
local HasLFGRestrictions = HasLFGRestrictions
local GetInstanceInfo = GetInstanceInfo
local GetNumGroupMembers = GetNumGroupMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local GetSpellCharges = GetSpellCharges
local GetSpellInfo = GetSpellInfo
local GetSpellTexture = GetSpellTexture
local UnitAura = UnitAura
local GetTime = GetTime
local SendChatMessage = SendChatMessage
local LoadAddOn = LoadAddOn
local EnableAddOn = EnableAddOn
local IsAddOnLoaded = IsAddOnLoaded
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local InCombatLockdown = InCombatLockdown
local UninviteUnit = UninviteUnit
local UnitExists = UnitExists
local DoReadyCheck = DoReadyCheck
local InitiateRolePoll = InitiateRolePoll
local GetReadyCheckStatus = GetReadyCheckStatus
local StaticPopup_Show = StaticPopup_Show
local ToggleFriendsFrame = ToggleFriendsFrame
local C_Timer_After = C_Timer.After
local LeaveParty = C_PartyInfo.LeaveParty
local ConvertToRaid = C_PartyInfo.ConvertToRaid
local ConvertToParty = C_PartyInfo.ConvertToParty
local CONVERT_TO_PARTY = CONVERT_TO_PARTY
local CONVERT_TO_RAID = CONVERT_TO_RAID
local READY_CHECK = READY_CHECK
local ERR_NOT_LEADER = ERR_NOT_LEADER
local SPELL_STAT4_NAME = SPELL_STAT4_NAME
local RAID_BUFF_2 = RAID_BUFF_2
local RAID_BUFF_3 = RAID_BUFF_3
local RUNES = RUNES
local ALL = ALL
local PLAYER = PLAYER
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local YES = YES
local NO = NO
local TEAM_DISBAND = TEAM_DISBAND
local ROLE_POLL = ROLE_POLL
local RAID_CONTROL = RAID_CONTROL

local F, C, L = unpack(select(2, ...))
local MISC = F:GetModule('General')

function MISC:RaidTool_Visibility(frame)
    if IsInGroup() then
        frame:Show()
    else
        frame:Hide()
    end
end

function MISC:RaidTool_Header()
    local frame = CreateFrame('Button', nil, _G.UIParent)
    frame:SetSize(120, 28)
    frame:SetFrameLevel(2)
    F.Reskin(frame)
    F.Mover(frame, L['Group Tool'], 'GroupTool', {'TOP', 0, -30})

    MISC:RaidTool_Visibility(frame)
    F:RegisterEvent('GROUP_ROSTER_UPDATE', function()
        MISC:RaidTool_Visibility(frame)
    end)

    frame:RegisterForClicks('AnyUp')
    frame:SetScript('OnClick', function(self, btn)
        if btn == 'LeftButton' then
            local menu = self.menu
            F:TogglePanel(menu)

            if menu:IsShown() then
                menu:ClearAllPoints()
                if MISC:IsFrameOnTop(self) then
                    menu:SetPoint('TOP', self, 'BOTTOM', 0, -3)
                else
                    menu:SetPoint('BOTTOM', self, 'TOP', 0, 3)
                end

                self.buttons[2].text:SetText(IsInRaid() and CONVERT_TO_PARTY or CONVERT_TO_RAID)
            end
        end
    end)
    frame:SetScript('OnDoubleClick', function(_, btn)
        if btn == 'RightButton' and (IsPartyLFG() and IsLFGComplete() or not IsInInstance()) then
            LeaveParty()
        end
    end)
    -- frame:SetScript('OnHide', function(self)
    -- 	self.bg:SetBackdropColor(0, 0, 0, .5)
    -- 	self.bg:SetBackdropBorderColor(0, 0, 0, 1)
    -- end)

    return frame
end

function MISC:IsFrameOnTop(frame)
    local y = select(2, frame:GetCenter())
    local screenHeight = _G.UIParent:GetTop()
    return y > screenHeight / 2
end

function MISC:GetRaidMaxGroup()
    local _, instType, difficulty = GetInstanceInfo()
    if (instType == 'party' or instType == 'scenario') and not IsInRaid() then
        return 1
    elseif instType ~= 'raid' then
        return 8
    elseif difficulty == 8 or difficulty == 1 or difficulty == 2 or difficulty == 24 then
        return 1
    elseif difficulty == 14 or difficulty == 15 then
        return 6
    elseif difficulty == 16 then
        return 4
    elseif difficulty == 3 or difficulty == 5 then
        return 2
    elseif difficulty == 9 then
        return 8
    else
        return 5
    end
end

function MISC:RaidTool_RoleCount(parent)
    local roleIcons = {
        C.AssetsPath .. 'textures\\roles_tank',
        C.AssetsPath .. 'textures\\roles_healer',
        C.AssetsPath .. 'textures\\roles_dps',
    }

    local frame = CreateFrame('Frame', nil, parent)
    frame:SetAllPoints()
    local role = {}
    for i = 1, 3 do
        role[i] = frame:CreateTexture(nil, 'OVERLAY')
        role[i]:SetPoint('LEFT', 36 * i - 30, 0)
        role[i]:SetSize(12, 12)
        role[i]:SetTexture(roleIcons[i])
        role[i].text = F.CreateFS(frame, C.Assets.Fonts.Regular, 12, 'OUTLINE', '0', 'YELLOW', true)
        role[i].text:ClearAllPoints()
        role[i].text:SetPoint('CENTER', role[i], 'RIGHT', 10, 0)
    end

    local raidCounts = {totalTANK = 0, totalHEALER = 0, totalDAMAGER = 0}

    local function updateRoleCount()
        for k in pairs(raidCounts) do
            raidCounts[k] = 0
        end

        local maxgroup = MISC:GetRaidMaxGroup()
        for i = 1, GetNumGroupMembers() do
            local name, _, subgroup, _, _, _, _, online, isDead, _, _, assignedRole = GetRaidRosterInfo(i)
            if name and online and subgroup <= maxgroup and not isDead and assignedRole ~= 'NONE' then
                raidCounts['total' .. assignedRole] = raidCounts['total' .. assignedRole] + 1
            end
        end

        role[1].text:SetText(raidCounts.totalTANK)
        role[2].text:SetText(raidCounts.totalHEALER)
        role[3].text:SetText(raidCounts.totalDAMAGER)
    end

    local eventList = {
        'GROUP_ROSTER_UPDATE',
        'UPDATE_ACTIVE_BATTLEFIELD',
        'UNIT_FLAGS',
        'PLAYER_FLAGS_CHANGED',
        'PLAYER_ENTERING_WORLD',
    }
    for _, event in next, eventList do
        F:RegisterEvent(event, updateRoleCount)
    end

    parent.roleFrame = frame
end

function MISC:RaidTool_UpdateRes(elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed > .1 then
        local charges, _, started, duration = GetSpellCharges(20484)
        if charges then
            local timer = duration - (GetTime() - started)
            if timer < 0 then
                self.Timer:SetText('--:--')
            else
                self.Timer:SetFormattedText('%d:%.2d', timer / 60, timer % 60)
            end
            self.Count:SetText(charges)
            if charges == 0 then
                self.Count:SetTextColor(1, 0, 0)
            else
                self.Count:SetTextColor(0, 1, 0)
            end
            self.__owner.resFrame:SetAlpha(1)
            self.__owner.roleFrame:SetAlpha(0)
        else
            self.__owner.resFrame:SetAlpha(0)
            self.__owner.roleFrame:SetAlpha(1)
        end

        self.elapsed = 0
    end
end

function MISC:RaidTool_CombatRes(parent)
    local frame = CreateFrame('Frame', nil, parent)
    frame:SetAllPoints()
    frame:SetAlpha(0)
    local res = CreateFrame('Frame', nil, frame)
    res:SetSize(22, 22)
    res:SetPoint('LEFT', 5, 0)
    F.PixelIcon(res, GetSpellTexture(20484))
    res.__owner = parent

    res.Count = F.CreateFS(res, C.Assets.Fonts.Regular, 14, 'OUTLINE', '0', nil, true)
    res.Count:ClearAllPoints()
    res.Count:SetPoint('LEFT', res, 'RIGHT', 10, 0)
    res.Timer = F.CreateFS(frame, C.Assets.Fonts.Regular, 14, 'OUTLINE', '00:00', nil, true, 'RIGHT', -5, 0)
    res:SetScript('OnUpdate', MISC.RaidTool_UpdateRes)

    parent.resFrame = frame
end

function MISC:RaidTool_ReadyCheck(parent)
    local frame = CreateFrame('Frame', nil, parent)
    frame:SetPoint('TOP', parent, 'BOTTOM', 0, -3)
    frame:SetSize(120, 50)
    frame:Hide()
    frame:SetScript('OnMouseUp', function(self)
        self:Hide()
    end)
    F.SetBD(frame)
    F.CreateFS(frame, C.Assets.Fonts.Regular, 14, 'OUTLINE', READY_CHECK, nil, true, 'TOP', 0, -8)
    local rc = F.CreateFS(frame, C.Assets.Fonts.Regular, 14, 'OUTLINE', '', nil, true, 'TOP', 0, -28)

    local count, total
    local function hideRCFrame()
        frame:Hide()
        rc:SetText('')
        count, total = 0, 0
    end

    local function updateReadyCheck(event)
        if event == 'READY_CHECK_FINISHED' then
            if count == total then
                rc:SetTextColor(0, 1, 0)
            else
                rc:SetTextColor(1, 0, 0)
            end
            C_Timer_After(5, hideRCFrame)
        else
            count, total = 0, 0

            frame:ClearAllPoints()
            if MISC:IsFrameOnTop(parent) then
                frame:SetPoint('TOP', parent, 'BOTTOM', 0, -3)
            else
                frame:SetPoint('BOTTOM', parent, 'TOP', 0, 3)
            end
            frame:Show()

            local maxgroup = MISC:GetRaidMaxGroup()
            for i = 1, GetNumGroupMembers() do
                local name, _, subgroup, _, _, _, _, online = GetRaidRosterInfo(i)
                if name and online and subgroup <= maxgroup then
                    total = total + 1
                    local status = GetReadyCheckStatus(name)
                    if status and status == 'ready' then
                        count = count + 1
                    end
                end
            end
            rc:SetText(count .. ' / ' .. total)
            if count == total then
                rc:SetTextColor(0, 1, 0)
            else
                rc:SetTextColor(1, 1, 0)
            end
        end
    end
    F:RegisterEvent('READY_CHECK', updateReadyCheck)
    F:RegisterEvent('READY_CHECK_CONFIRM', updateReadyCheck)
    F:RegisterEvent('READY_CHECK_FINISHED', updateReadyCheck)
end

function MISC:RaidTool_Marker(parent)
    local markerButton = _G.CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
    if not markerButton then
        for _, addon in next, {'Blizzard_CUFProfiles', 'Blizzard_CompactRaidFrames'} do
            EnableAddOn(addon)
            LoadAddOn(addon)
        end
    end
    if markerButton then
        markerButton:ClearAllPoints()
        markerButton:SetPoint('RIGHT', parent, 'LEFT', -4, 0)
        markerButton:SetParent(parent)
        markerButton:SetSize(28, 28)

        for i = 1, 9 do
            select(i, markerButton:GetRegions()):SetAlpha(0)
        end

        F.Reskin(markerButton)
        markerButton:SetNormalTexture('Interface\\RaidFrame\\Raid-WorldPing')
        markerButton:GetNormalTexture():SetVertexColor(.2, 1, .2)
        markerButton:HookScript('OnMouseUp', function()
            if (IsInGroup() and not IsInRaid()) or UnitIsGroupLeader('player') or UnitIsGroupAssistant('player') then
                return
            end
            _G.UIErrorsFrame:AddMessage(C.RedColor .. ERR_NOT_LEADER)
        end)
    end
end

function MISC:RaidTool_BuffChecker(parent)
    local frame = CreateFrame('Button', nil, parent)
    frame:SetPoint('LEFT', parent, 'RIGHT', 4, 0)
    frame:SetSize(28, 28)
    -- F.CreateFS(frame, C.Assets.Fonts.Regular, 16, 'OUTLINE', '!', nil, true)
    frame.tex = frame:CreateTexture(nil, 'ARTWORK')
    frame.tex:SetSize(16, 16)
    frame.tex:SetPoint('CENTER')
    frame.tex:SetTexture(C.Assets.classify_tex)
    frame.tex:SetTexCoord(.5, 1, 0, .5)
    F.Reskin(frame)

    local BuffName = {L['Flask'], _G.POWER_TYPE_FOOD, SPELL_STAT4_NAME, RAID_BUFF_2, RAID_BUFF_3, RUNES}
    local NoBuff, numGroups, numPlayer = {}, 6, 0
    for i = 1, numGroups do
        NoBuff[i] = {}
    end

    local debugMode = false
    local function sendMsg(text)
        if debugMode then
            print(text)
        else
            SendChatMessage(text, IsPartyLFG() and 'INSTANCE_CHAT' or IsInRaid() and 'RAID' or 'PARTY')
        end
    end

    local function sendResult(i)
        local count = #NoBuff[i]
        if count > 0 then
            if count >= numPlayer then
                sendMsg(L['Lack of'] .. BuffName[i] .. ': ' .. ALL .. PLAYER)
            elseif count >= 5 and i > 2 then
                sendMsg(L['Lack of'] .. BuffName[i] .. ': ' .. format(L['%s players'], count))
            else
                local str = L['Lack of'] .. BuffName[i] .. ': '
                for j = 1, count do
                    str = str .. NoBuff[i][j] .. (j < #NoBuff[i] and ', ' or '')
                    if #str > 230 then
                        sendMsg(str)
                        str = ''
                    end
                end
                sendMsg(str)
            end
        end
    end

    local function scanBuff()
        for i = 1, numGroups do
            wipe(NoBuff[i])
        end
        numPlayer = 0

        local maxgroup = MISC:GetRaidMaxGroup()
        for i = 1, GetNumGroupMembers() do
            local name, _, subgroup, _, _, _, _, online, isDead = GetRaidRosterInfo(i)
            if name and online and subgroup <= maxgroup and not isDead then
                numPlayer = numPlayer + 1
                for j = 1, numGroups do
                    local HasBuff
                    local buffTable = C.GroupBuffsCheckList[j]
                    for k = 1, #buffTable do
                        local buffName = GetSpellInfo(buffTable[k])
                        for index = 1, 32 do
                            local currentBuff = UnitAura(name, index)
                            if currentBuff and currentBuff == buffName then
                                HasBuff = true
                                break
                            end
                        end
                    end
                    if not HasBuff then
                        name = strsplit('-', name) -- remove realm name
                        tinsert(NoBuff[j], name)
                    end
                end
            end
        end
        if not C.DB.General.RuneCheck then
            NoBuff[numGroups] = {}
        end

        if #NoBuff[1] == 0 and #NoBuff[2] == 0 and #NoBuff[3] == 0 and #NoBuff[4] == 0 and #NoBuff[5] == 0 and
            #NoBuff[6] == 0 then
            sendMsg(L['All Buffs Ready!'])
        else
            sendMsg(L['Raid Buff Checker:'])
            for i = 1, 5 do
                sendResult(i)
            end
            if C.DB.General.RuneCheck then
                sendResult(numGroups)
            end
        end
    end

    local potionCheck = IsAddOnLoaded('ExRT')

    frame:HookScript('OnEnter', function(self)
        _G.GameTooltip:SetOwner(self, 'ANCHOR_BOTTOM', 0, -3)
        _G.GameTooltip:ClearLines()
        _G.GameTooltip:AddLine(L['Group Tool'])
        _G.GameTooltip:AddLine(' ')
        _G.GameTooltip:AddLine(C.Assets.mouse_left .. READY_CHECK, 0, .6, 1)
        _G.GameTooltip:AddLine(C.Assets.mouse_middle .. L['Start/Cancel count down'], 0, .6, 1)
        _G.GameTooltip:AddLine(C.Assets.mouse_right .. C.RedColor .. '(Ctrl)|r ' .. L['Check Flask & Food'], 0, .6, 1)
        if potionCheck then
            _G.GameTooltip:AddLine(C.Assets.mouse_right .. C.RedColor .. '(Alt)|r ' .. L['ExRT Potion Check'], 0,
                                   .6, 1)
        end
        _G.GameTooltip:Show()
    end)
    frame:HookScript('OnLeave', F.HideTooltip)

    local reset = true
    F:RegisterEvent('PLAYER_REGEN_ENABLED', function()
        reset = true
    end)

    frame:HookScript('OnMouseDown', function(_, btn)
        if btn == 'RightButton' then
            if IsAltKeyDown() and potionCheck then
                _G.SlashCmdList['exrtSlash']('potionchat')
            elseif IsControlKeyDown() then
                scanBuff()
            end
        elseif btn == 'LeftButton' then
            if InCombatLockdown() then
                _G.UIErrorsFrame:AddMessage(C.RedColor .. ERR_NOT_IN_COMBAT)
                return
            end
            if IsInGroup() and (UnitIsGroupLeader('player') or (UnitIsGroupAssistant('player') and IsInRaid())) then
                DoReadyCheck()
            else
                _G.UIErrorsFrame:AddMessage(C.RedColor .. ERR_NOT_LEADER)
            end
        else
            if IsInGroup() and (UnitIsGroupLeader('player') or (UnitIsGroupAssistant('player') and IsInRaid())) then
                if IsAddOnLoaded('DBM-Core') then
                    if reset then
                        _G.SlashCmdList['DEADLYBOSSMODS']('pull ' .. C.DB.General.Countdown)
                    else
                        _G.SlashCmdList['DEADLYBOSSMODS']('pull 0')
                    end
                    reset = not reset
                elseif IsAddOnLoaded('BigWigs') then
                    if not _G.SlashCmdList['BIGWIGSPULL'] then
                        LoadAddOn('BigWigs_Plugins')
                    end
                    if reset then
                        _G.SlashCmdList['BIGWIGSPULL'](C.DB.General.Countdown)
                    else
                        _G.SlashCmdList['BIGWIGSPULL']('0')
                    end
                    reset = not reset
                else
                    _G.UIErrorsFrame:AddMessage(C.RedColor .. L['You can not do it without DBM or BigWigs!'])
                end
            else
                _G.UIErrorsFrame:AddMessage(C.RedColor .. ERR_NOT_LEADER)
            end
        end
    end)
end

function MISC:RaidTool_CreateMenu(parent)
    local frame = CreateFrame('Frame', nil, parent)
    frame:SetPoint('TOP', parent, 'BOTTOM', 0, -3)
    frame:SetSize(182, 70)
    F.SetBD(frame)
    frame:Hide()

    local function updateDelay(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed > .1 then
            if not frame:IsMouseOver() then
                self:Hide()
                self:SetScript('OnUpdate', nil)
            end

            self.elapsed = 0
        end
    end

    frame:SetScript('OnLeave', function(self)
        self:SetScript('OnUpdate', updateDelay)
    end)

    local buttons = {
        {
            TEAM_DISBAND,
            function()
                if UnitIsGroupLeader('player') then
                    StaticPopup_Show('FREEUI_DISBAND_GROUP')
                else
                    _G.UIErrorsFrame:AddMessage(C.RedColor .. ERR_NOT_LEADER)
                end
            end,
        },
        {
            CONVERT_TO_RAID,
            function()
                if UnitIsGroupLeader('player') and not HasLFGRestrictions() and GetNumGroupMembers() <= 5 then
                    if IsInRaid() then
                        ConvertToParty()
                    else
                        ConvertToRaid()
                    end
                    frame:Hide()
                    frame:SetScript('OnUpdate', nil)
                else
                    _G.UIErrorsFrame:AddMessage(C.RedColor .. ERR_NOT_LEADER)
                end
            end,
        },
        {
            ROLE_POLL,
            function()
                if IsInGroup() and not HasLFGRestrictions() and
                    (UnitIsGroupLeader('player') or (UnitIsGroupAssistant('player') and IsInRaid())) then
                    InitiateRolePoll()
                else
                    _G.UIErrorsFrame:AddMessage(C.RedColor .. ERR_NOT_LEADER)
                end
            end,
        },
        {
            RAID_CONTROL,
            function()
                ToggleFriendsFrame(3)
            end,
        },
    }

    local bu = {}
    for i, j in pairs(buttons) do
        bu[i] = F.CreateButton(frame, 84, 28, j[1], 12)
        bu[i]:SetPoint(mod(i, 2) == 0 and 'TOPRIGHT' or 'TOPLEFT', mod(i, 2) == 0 and -5 or 5, i > 2 and -37 or -5)
        bu[i]:SetScript('OnClick', j[2])
    end

    parent.menu = frame
    parent.buttons = bu
end

function MISC:RaidTool_Misc()
    -- UIWidget reanchor
    if not _G.UIWidgetTopCenterContainerFrame:IsMovable() then -- can be movable for some addons, eg BattleInfo
        _G.UIWidgetTopCenterContainerFrame:ClearAllPoints()
        _G.UIWidgetTopCenterContainerFrame:SetPoint('TOP', 0, -35)
    end
end

function MISC:RaidTool_Init()
    if not C.DB.General.GroupTool then
        return
    end

    local frame = MISC:RaidTool_Header()
    MISC:RaidTool_RoleCount(frame)
    MISC:RaidTool_CombatRes(frame)
    MISC:RaidTool_ReadyCheck(frame)
    MISC:RaidTool_Marker(frame)
    MISC:RaidTool_BuffChecker(frame)
    MISC:RaidTool_CreateMenu(frame)
    MISC:RaidTool_Misc()
end
MISC:RegisterMisc('RaidTool', MISC.RaidTool_Init)
