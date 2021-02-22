local _G = _G
local wipe = wipe
local tonumber = tonumber
local pairs = pairs
local unpack = unpack
local select = select
local rad = rad
local strmatch = strmatch
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local SetCVar = SetCVar
local NamePlateDriverFrame = NamePlateDriverFrame
local UnitLevel = UnitLevel
local UnitThreatSituation = UnitThreatSituation
local UnitIsTapDenied = UnitIsTapDenied
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsUnit = UnitIsUnit
local UnitReaction = UnitReaction
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitSelectionColor = UnitSelectionColor
local GetInstanceInfo = GetInstanceInfo
local UnitClassification = UnitClassification
local UnitExists = UnitExists
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local InCombatLockdown = InCombatLockdown
local UnitGUID = UnitGUID
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local Ambiguate = Ambiguate
local issecure = issecure
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local IsInInstance = IsInInstance
local UnitName = UnitName
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSubgroupMembers = GetNumSubgroupMembers
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local C_NamePlate_SetNamePlateFriendlySize = C_NamePlate.SetNamePlateFriendlySize
local C_NamePlate_SetNamePlateEnemySize = C_NamePlate.SetNamePlateEnemySize
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local C_MythicPlus_GetCurrentAffixes = C_MythicPlus.GetCurrentAffixes
local GetSpellInfo = GetSpellInfo
local GetSpellTexture = GetSpellTexture
local UnitNameplateShowsWidgetsOnly = UnitNameplateShowsWidgetsOnly
local INTERRUPTED = INTERRUPTED

local F, C = unpack(select(2, ...))
local NAMEPLATE = F.NAMEPLATE
local UNITFRAME = F.UNITFRAME
local OUF = F.OUF

--[[ CVars ]]

function NAMEPLATE:PlateInsideView()
    if C.DB.Nameplate.InsideView then
        SetCVar('nameplateOtherTopInset', .05)
        SetCVar('nameplateOtherBottomInset', .08)
    else
        SetCVar('nameplateOtherTopInset', -1)
        SetCVar('nameplateOtherBottomInset', -1)
    end
end

function NAMEPLATE:UpdatePlateScale()
    SetCVar('namePlateMinScale', C.DB.Nameplate.MinScale)
    SetCVar('namePlateMaxScale', C.DB.Nameplate.MinScale)
end

function NAMEPLATE:UpdatePlateTargetScale()
    SetCVar('nameplateLargerScale', C.DB.Nameplate.TargetScale)
    SetCVar('nameplateSelectedScale', C.DB.Nameplate.TargetScale)
end

function NAMEPLATE:UpdatePlateAlpha()
    SetCVar('nameplateMinAlpha', C.DB.Nameplate.MinAlpha)
    SetCVar('nameplateMaxAlpha', C.DB.Nameplate.MinAlpha)
    SetCVar('nameplateSelectedAlpha', 1)
end

function NAMEPLATE:UpdatePlateOccludedAlpha()
    SetCVar('nameplateOccludedAlphaMult', C.DB.Nameplate.OccludedAlpha)
end

function NAMEPLATE:UpdatePlateVerticalSpacing()
    SetCVar('nameplateOverlapV', C.DB.Nameplate.VerticalSpacing)
end

function NAMEPLATE:UpdatePlateHorizontalSpacing()
    SetCVar('nameplateOverlapH', C.DB.Nameplate.HorizontalSpacing)
end

function NAMEPLATE:SetupCVars()
    NAMEPLATE:PlateInsideView()

    NAMEPLATE:UpdatePlateVerticalSpacing()
    NAMEPLATE:UpdatePlateHorizontalSpacing()

    NAMEPLATE:UpdatePlateAlpha()
    NAMEPLATE:UpdatePlateOccludedAlpha()

    NAMEPLATE:UpdatePlateScale()
    NAMEPLATE:UpdatePlateTargetScale()

    SetCVar('nameplateShowSelf', 0)
    SetCVar('nameplateResourceOnTarget', 0)
    F.HideOption(_G.InterfaceOptionsNamesPanelUnitNameplatesPersonalResource)
    F.HideOption(_G.InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy)
end

--[[ AddOn ]]

function NAMEPLATE:BlockAddons()
    if not _G.DBM or not _G.DBM.Nameplate then
        return
    end

    function _G.DBM.Nameplate:SupportedNPMod()
        return true
    end

    local function showAurasForDBM(_, _, _, spellID)
        if not tonumber(spellID) then
            return
        end
        if not C.AuraWhiteList[spellID] then
            C.AuraWhiteList[spellID] = true
        end
    end
    hooksecurefunc(_G.DBM.Nameplate, 'Show', showAurasForDBM)
end

--[[ Elements ]]

local customUnits = {}
function NAMEPLATE:CreateUnitTable()
    wipe(customUnits)
    if not C.DB.Nameplate.CustomUnitColor then
        return
    end
    F.CopyTable(C.NPSpecialUnitsList, customUnits)
    F.SplitList(customUnits, C.DB.Nameplate.CustomUnitList)
end

local showPowerList = {}
function NAMEPLATE:CreatePowerUnitTable()
    wipe(showPowerList)
    F.CopyTable(C.NPShowPowerUnitsList, showPowerList)
    F.SplitList(showPowerList, C.DB.Nameplate.ShowPowerList)
end

function NAMEPLATE:UpdateUnitPower()
    local unitName = self.unitName
    local npcID = self.npcID
    local shouldShowPower = showPowerList[unitName] or showPowerList[npcID]
    if shouldShowPower then
        self.powerText:Show()
    else
        self.powerText:Hide()
    end
end

-- Off-tank threat color
local groupRoles, isInGroup = {}
local function refreshGroupRoles()
    local isInRaid = IsInRaid()
    isInGroup = isInRaid or IsInGroup()
    wipe(groupRoles)

    if isInGroup then
        local numPlayers = (isInRaid and GetNumGroupMembers()) or GetNumSubgroupMembers()
        local unit = (isInRaid and 'raid') or 'party'
        for i = 1, numPlayers do
            local index = unit .. i
            if UnitExists(index) then
                groupRoles[UnitName(index)] = UnitGroupRolesAssigned(index)
            end
        end
    end
end

local function resetGroupRoles()
    isInGroup = IsInRaid() or IsInGroup()
    wipe(groupRoles)
end

function NAMEPLATE:UpdateGroupRoles()
    refreshGroupRoles()
    F:RegisterEvent('GROUP_ROSTER_UPDATE', refreshGroupRoles)
    F:RegisterEvent('GROUP_LEFT', resetGroupRoles)
end

function NAMEPLATE:CheckThreatStatus(unit)
    if not UnitExists(unit) then
        return
    end

    local unitTarget = unit .. 'target'
    local unitRole = isInGroup and UnitExists(unitTarget) and not UnitIsUnit(unitTarget, 'player') and
                         groupRoles[UnitName(unitTarget)] or 'NONE'

    if C.Role == 'Tank' and unitRole == 'TANK' then
        return true, UnitThreatSituation(unitTarget, unit)
    else
        return false, UnitThreatSituation('player', unit)
    end
end

-- Update unit color
function NAMEPLATE:UpdateColor(_, unit)
    if not unit or self.unit ~= unit then
        return
    end

    local element = self.Health
    local name = self.unitName
    local npcID = self.npcID
    local isCustomUnit = customUnits[name] or customUnits[npcID]
    local isPlayer = self.isPlayer
    local isFriendly = self.isFriendly
    local isOffTank, status = NAMEPLATE:CheckThreatStatus(unit)

    local customColor = C.DB.Nameplate.CustomColor
    local secureColor = C.DB.Nameplate.SecureColor
    local transColor = C.DB.Nameplate.TransColor
    local insecureColor = C.DB.Nameplate.InsecureColor
    local revertThreat = C.DB.Nameplate.RevertThreat
    local offTankColor = C.DB.Nameplate.OffTankColor
    local targetColor = C.DB.Nameplate.TargetColor
    local coloredTarget = C.DB.Nameplate.ColoredTarget
    local hostileClassColor = C.DB.Nameplate.HostileClassColor
    local friendlyClassColor = C.DB.Nameplate.FriendlyClassColor
    local tankMode = C.DB.Nameplate.TankMode
    local executeIndicator = C.DB.Nameplate.ExecuteIndicator
    local executeRatio = C.DB.Nameplate.ExecuteRatio
    local healthPerc = UnitHealth(unit) / (UnitHealthMax(unit) + .0001) * 100
    local r, g, b

    if not UnitIsConnected(unit) then
        r, g, b = unpack(OUF.colors.disconnected)
    else
        if coloredTarget and UnitIsUnit(unit, 'target') then
            r, g, b = targetColor.r, targetColor.g, targetColor.b
        elseif isCustomUnit then
            r, g, b = customColor.r, customColor.g, customColor.b
        elseif isPlayer and isFriendly then
            if friendlyClassColor then
                r, g, b = F.UnitColor(unit)
            else
                r, g, b = .3, .3, 1
            end
        elseif isPlayer and (not isFriendly) and hostileClassColor then
            r, g, b = F.UnitColor(unit)
        elseif UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) then
            r, g, b = unpack(OUF.colors.tapped)
        else
            -- r, g, b = unpack(OUF.colors.reaction[UnitReaction(unit, 'player') or 5])
            r, g, b = UnitSelectionColor(unit, true)
            if status and (tankMode or C.Role == 'Tank') then
                if status == 3 then
                    if C.Role ~= 'Tank' and revertThreat then
                        r, g, b = insecureColor.r, insecureColor.g, insecureColor.b
                    else
                        if isOffTank then
                            r, g, b = offTankColor.r, offTankColor.g, offTankColor.b
                        else
                            r, g, b = secureColor.r, secureColor.g, secureColor.b
                        end
                    end
                elseif status == 2 or status == 1 then
                    r, g, b = transColor.r, transColor.g, transColor.b
                elseif status == 0 then
                    if C.Role ~= 'Tank' and revertThreat then
                        r, g, b = secureColor.r, secureColor.g, secureColor.b
                    else
                        r, g, b = insecureColor.r, insecureColor.g, insecureColor.b
                    end
                end
            end
        end
    end

    if r or g or b then
        element:SetStatusBarColor(r, g, b)
    end

    self.ThreatIndicator:Hide()
    if status and (isCustomUnit or (not tankMode and C.Role ~= 'Tank')) then
        if status == 3 then
            self.ThreatIndicator:SetVertexColor(1, 0, 0)
            self.ThreatIndicator:Show()
        elseif status == 2 or status == 1 then
            self.ThreatIndicator:SetVertexColor(1, 1, 0)
            self.ThreatIndicator:Show()
        end
    end

    if executeIndicator and executeRatio > 0 and healthPerc <= executeRatio then
        self.Name:SetTextColor(1, 0, 0)
    else
        self.Name:SetTextColor(1, 1, 1)
    end
end

function NAMEPLATE:UpdateThreatColor(_, unit)
    if unit ~= self.unit then
        return
    end

    NAMEPLATE.UpdateColor(self, _, unit)
end

function NAMEPLATE:AddThreatIndicator(self)
    if not C.DB.Nameplate.ThreatIndicator then
        return
    end

    local frame = CreateFrame('Frame', nil, self)
    frame:SetAllPoints()
    frame:SetFrameLevel(self:GetFrameLevel() - 1)

    local threat = frame:CreateTexture(nil, 'OVERLAY')
    threat:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT', 0, 0)
    threat:SetPoint('BOTTOMRIGHT', frame, 'TOPRIGHT', 0, 0)
    threat:SetHeight(8)
    threat:SetTexture(C.Assets.glow_tex)
    threat:Hide()

    self.ThreatIndicator = threat
    self.ThreatIndicator.Override = NAMEPLATE.UpdateThreatColor
end

-- Target indicator
function NAMEPLATE:UpdateTargetChange()
    local element = self.TargetIndicator
    local unit = self.unit

    if UnitIsUnit(self.unit, 'target') and not UnitIsUnit(self.unit, 'player') then
        element:Show()
    else
        element:Hide()
    end

    if C.DB.Nameplate.ColoredTarget then
        NAMEPLATE.UpdateThreatColor(self, _, unit)
    end
end

function NAMEPLATE:UpdateTargetIndicator()
    local element = self.TargetIndicator
    local isNameOnly = self.isNameOnly

    if C.DB.Nameplate.TargetIndicator then
        if isNameOnly then
            element.Glow:Hide()
            element.nameGlow:Show()
        else
            element.Glow:Show()
            element.nameGlow:Hide()
        end
        element:Show()
    else
        element:Hide()
    end
end

function NAMEPLATE:AddTargetIndicator(self)
    if not C.DB.Nameplate.TargetIndicator then
        return
    end

    local color = C.DB.Nameplate.TargetIndicatorColor
    local r, g, b = color.r, color.g, color.b

    local frame = CreateFrame('Frame', nil, self)
    frame:SetAllPoints()
    frame:SetFrameLevel(self:GetFrameLevel() - 1)
    frame:Hide()

    frame.Glow = frame:CreateTexture(nil, 'OVERLAY')
    frame.Glow:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', 0, 0)
    frame.Glow:SetPoint('TOPRIGHT', frame, 'BOTTOMRIGHT', 0, 0)
    frame.Glow:SetHeight(8)
    frame.Glow:SetTexture(C.Assets.glow_tex)
    frame.Glow:SetRotation(rad(180))
    frame.Glow:SetVertexColor(r, g, b)

    frame.nameGlow = frame:CreateTexture(nil, 'BACKGROUND', nil, -5)
    frame.nameGlow:SetSize(150, 80)
    frame.nameGlow:SetTexture('Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64')
    frame.nameGlow:SetVertexColor(0, .6, 1)
    frame.nameGlow:SetBlendMode('ADD')
    frame.nameGlow:SetPoint('CENTER', self, 'BOTTOM')

    self.TargetIndicator = frame
    self:RegisterEvent('PLAYER_TARGET_CHANGED', NAMEPLATE.UpdateTargetChange, true)
    NAMEPLATE.UpdateTargetIndicator(self)
end

-- Mouseover indicator
function NAMEPLATE:IsMouseoverUnit()
    if not self or not self.unit then
        return
    end

    if self:IsVisible() and UnitExists('mouseover') then
        return UnitIsUnit('mouseover', self.unit)
    end
    return false
end

function NAMEPLATE:UpdateMouseoverShown()
    if not self or not self.unit then
        return
    end

    if self:IsShown() and UnitIsUnit('mouseover', self.unit) then
        self.HighlightIndicator:Show()
        self.HighlightUpdater:Show()
    else
        self.HighlightUpdater:Hide()
    end
end

function NAMEPLATE:AddHighlight(self)
    local highlight = CreateFrame('Frame', nil, self.Health)
    highlight:SetAllPoints(self)
    highlight:Hide()
    local texture = highlight:CreateTexture(nil, 'ARTWORK')
    texture:SetAllPoints()
    texture:SetColorTexture(1, 1, 1, .25)

    self:RegisterEvent('UPDATE_MOUSEOVER_UNIT', NAMEPLATE.UpdateMouseoverShown, true)

    local f = CreateFrame('Frame', nil, self)
    f:SetScript('OnUpdate', function(_, elapsed)
        f.elapsed = (f.elapsed or 0) + elapsed
        if f.elapsed > .1 then
            if not NAMEPLATE.IsMouseoverUnit(self) then
                f:Hide()
            end
            f.elapsed = 0
        end
    end)
    f:HookScript('OnHide', function()
        highlight:Hide()
    end)

    self.HighlightIndicator = highlight
    self.HighlightUpdater = f
end

-- Unit classification
local classify = {
    elite = {'VignetteKill'},
    rare = {'VignetteKill', true},
    rareelite = {'VignetteKill', true},
    worldboss = {'VignetteKillElite'},
}

function NAMEPLATE:AddClassifyIndicator(self)
    if not C.DB.Nameplate.ClassifyIndicator then
        return
    end

    local icon = self:CreateTexture(nil, 'ARTWORK')
    icon:SetPoint('LEFT', self, 'RIGHT')
    icon:SetSize(16, 16)
    icon:SetAtlas('')
    icon:Hide()

    self.ClassifyIndicator = icon
end

function NAMEPLATE:UpdateUnitClassify(unit)
    local isBoss = UnitLevel(unit) == -1
    local class = UnitClassification(unit)
    local isNameOnly = self.isNameOnly

    if self.ClassifyIndicator then
        if not isNameOnly and isBoss then
            self.ClassifyIndicator:SetAtlas('VignetteKillElite')
            self.ClassifyIndicator:Show()
        elseif not isNameOnly and class and classify[class] then
            local atlas, desature = unpack(classify[class])
            self.ClassifyIndicator:SetAtlas(atlas)
            self.ClassifyIndicator:SetDesaturated(desature)
            self.ClassifyIndicator:Show()
        else
            self.ClassifyIndicator:SetAtlas('')
            self.ClassifyIndicator:Hide()
        end
    end
end

-- Quest progress
local isInInstance
local function CheckInstanceStatus()
    isInInstance = IsInInstance()
end

function NAMEPLATE:QuestIconCheck()
    if not C.DB.Nameplate.QuestIndicator then
        return
    end

    CheckInstanceStatus()
    F:RegisterEvent('PLAYER_ENTERING_WORLD', CheckInstanceStatus)
end

function NAMEPLATE:UpdateQuestUnit(_, unit)
    if not C.DB.Nameplate.QuestIndicator then
        return
    end
    if isInInstance then
        self.questIcon:Hide()
        self.questCount:SetText('')
        return
    end

    unit = unit or self.unit

    local isLootQuest, questProgress
    F.ScanTip:SetOwner(_G.UIParent, 'ANCHOR_NONE')
    F.ScanTip:SetUnit(unit)

    for i = 2, F.ScanTip:NumLines() do
        local textLine = _G['FreeUI_ScanTooltipTextLeft' .. i]
        local text = textLine:GetText()
        if textLine and text then
            local r, g, b = textLine:GetTextColor()
            if r > .99 and g > .82 and b == 0 then
                if isInGroup and text == C.MyName or not isInGroup then
                    isLootQuest = true

                    local questLine = _G['FreeUI_ScanTooltipTextLeft' .. (i + 1)]
                    local questText = questLine:GetText()
                    if questLine and questText then
                        local current, goal = strmatch(questText, '(%d+)/(%d+)')
                        local progress = strmatch(questText, '(%d+)%%')
                        if current and goal then
                            current = tonumber(current)
                            goal = tonumber(goal)
                            if current == goal then
                                isLootQuest = nil
                            elseif current < goal then
                                questProgress = goal - current
                                break
                            end
                        elseif progress then
                            progress = tonumber(progress)
                            if progress == 100 then
                                isLootQuest = nil
                            elseif progress < 100 then
                                questProgress = progress .. '%'
                                -- break -- lower priority on progress
                            end
                        end
                    end
                end
            end
        end
    end

    if questProgress then
        self.questCount:SetText(questProgress)
        self.questIcon:SetAtlas('Warfronts-BaseMapIcons-Horde-Barracks-Minimap')
        self.questIcon:Show()
    else
        self.questCount:SetText('')
        if isLootQuest then
            self.questIcon:SetAtlas('adventureguide-microbutton-alert')
            self.questIcon:Show()
        else
            self.questIcon:Hide()
        end
    end
end

function NAMEPLATE:AddQuestIndicator(self)
    if not C.DB.Nameplate.QuestIndicator then
        return
    end

    local qicon = self:CreateTexture(nil, 'OVERLAY', nil, 2)
    qicon:SetPoint('TOP', self, 'BOTTOM', 0, -3)
    qicon:SetSize(20, 20)
    qicon:SetAtlas('adventureguide-microbutton-alert')
    qicon:Hide()
    local count = F.CreateFS(self, C.Assets.Fonts.Condensed, 12, nil, '', nil, true)
    count:SetPoint('LEFT', qicon, 'RIGHT', -3, 0)
    count:SetTextColor(.6, .8, 1)

    self.questIcon = qicon
    self.questCount = count
    self:RegisterEvent('QUEST_LOG_UPDATE', NAMEPLATE.UpdateQuestUnit, true)
end

-- Scale plates for explosives
local hasExplosives
local id = 120651
function NAMEPLATE:UpdateExplosives(event, unit)
    if not hasExplosives or unit ~= self.unit then
        return
    end

    local npcID = self.npcID
    if event == 'NAME_PLATE_UNIT_ADDED' and npcID == id then
        self:SetScale(_G.FREE_ADB.ui_scale * C.DB.Nameplate.ExplosiveScale)
    elseif event == 'NAME_PLATE_UNIT_REMOVED' then
        self:SetScale(_G.FREE_ADB.ui_scale)
    end
end

local function checkInstance()
    local name, _, instID = GetInstanceInfo()
    if name and instID == 8 then
        hasExplosives = true
    else
        hasExplosives = false
    end
end

local function checkAffixes(event)
    local affixes = C_MythicPlus_GetCurrentAffixes()
    if not affixes then
        return
    end
    if affixes[3] and affixes[3].id == 13 then
        checkInstance()
        F:RegisterEvent(event, checkInstance)
        F:RegisterEvent('CHALLENGE_MODE_START', checkInstance)
    end
    F:UnregisterEvent(event, checkAffixes)
end

function NAMEPLATE:CheckExplosives()
    if not C.DB.Nameplate.ExplosiveEnlarge then
        return
    end

    F:RegisterEvent('PLAYER_ENTERING_WORLD', checkAffixes)
end

-- Interrupt info on castbars
local guidToPlate = {}
function NAMEPLATE:UpdateCastbarInterrupt(...)
    local _, eventType, _, sourceGUID, sourceName, _, _, destGUID = ...
    if eventType == 'SPELL_INTERRUPT' and destGUID and sourceName and sourceName ~= '' then
        local nameplate = guidToPlate[destGUID]
        if nameplate and nameplate.Castbar then
            local _, class = GetPlayerInfoByGUID(sourceGUID)
            local r, g, b = F.ClassColor(class)
            local color = F.RGBToHex(r, g, b)
            sourceName = Ambiguate(sourceName, 'short')
            nameplate.Castbar.Text:Show()
            nameplate.Castbar.Text:SetText(color .. sourceName .. '|r ' .. INTERRUPTED)
        end
    end
end

function NAMEPLATE:AddInterruptInfo()
    if not C.DB.Nameplate.InterruptIndicator then
        return
    end

    F:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', self.UpdateCastbarInterrupt)
end

-- Major spells glow
NAMEPLATE.MajorSpellsList = {}
function NAMEPLATE:RefreshMajorSpells()
    wipe(NAMEPLATE.MajorSpellsList)

    for spellID in pairs(C.NPMajorSpellsList) do
        local name = GetSpellInfo(spellID)
        if name then
            local modValue = _G.FREE_ADB['NPMajorSpells'][spellID]
            if modValue == nil then
                NAMEPLATE.MajorSpellsList[spellID] = true
            end
        end
    end

    for spellID, value in pairs(_G.FREE_ADB['NPMajorSpells']) do
        if value then
            NAMEPLATE.MajorSpellsList[spellID] = true
        end
    end
end

-- Spiteful indicator
function NAMEPLATE:AddSpitefulIndicator(self)
    local tarName
    if _G.FREE_ADB.font_outline then
        tarName = F.CreateFS(self, C.Assets.Fonts.Condensed, 11, true, nil, nil, true)
    else
        tarName = F.CreateFS(self, C.Assets.Fonts.Condensed, 11, nil, nil, nil, 'THICK')
    end
    tarName:ClearAllPoints()
    tarName:SetPoint('TOP', self, 'BOTTOM', 0, -10)
    tarName:Hide()
    self:Tag(tarName, '[free:tarname]')
    self.tarName = tarName
end

function NAMEPLATE:UpdateSpitefulIndicator()
    if not C.DB.Nameplate.SpitefulIndicator then
        return
    end

    self.tarName:SetShown(self.npcID == 174773)
end

-- Totem icon
local totemsList = {
    -- npcID spellID duration
    [2630] = {2484, 20}, -- Earthbind
    [3527] = {5394, 15}, -- Healing Stream
    [6112] = {8512, 120}, -- Windfury
    [97369] = {192222, 15}, -- Liquid Magma
    [5913] = {8143, 10}, -- Tremor
    [5925] = {204336, 3}, -- Grounding
    [78001] = {157153, 15}, -- Cloudburst
    [53006] = {98008, 6}, -- Spirit Link
    [59764] = {108280, 12}, -- Healing Tide
    [61245] = {192058, 2}, -- Static Charge
    [100943] = {198838, 15}, -- Earthen Wall
    [97285] = {192077, 15}, -- Wind Rush
    [105451] = {204331, 15}, -- Counterstrike
    [104818] = {207399, 30}, -- Ancestral
    [105427] = {204330, 15}, -- Skyfury
    [119052] = {236320, 15}, -- Warrior War Banner
}

local function CreateTotemIcon(self)
    local icon = CreateFrame('Frame', nil, self)
    icon:SetSize(36, 36)
    icon:SetPoint('BOTTOM', self, 'TOP', 0, self.isNameOnly and 12 or 6)

    icon.texure = icon:CreateTexture(nil, 'ARTWORK')
    icon.texure:SetTexCoord(unpack(C.TexCoord))
    icon.texure:SetAllPoints()

    F.SetBD(icon)

    return icon
end

--[[ Create plate ]]

local platesList = {}
function NAMEPLATE:CreateNameplateStyle()
    self.unitStyle = 'nameplate'
    self:SetSize(C.DB.Nameplate.Width, C.DB.Nameplate.Height)
    self:SetPoint('CENTER', 0, -10)
    self:SetScale(_G.UIParent:GetScale())

    local health = CreateFrame('StatusBar', nil, self)
    health:SetAllPoints()
    health:SetStatusBarTexture(C.Assets.statusbar_tex)
    health.backdrop = F.SetBD(health)
    F:SmoothBar(health)

    self.Health = health
    self.Health.UpdateColor = NAMEPLATE.UpdateColor

    local name = F.CreateFS(self, C.Assets.Fonts.Header, 16, true, nil, nil, true)
    name:SetJustifyH('CENTER')
    name:ClearAllPoints()
    name:SetPoint('CENTER')
    name:Hide()
    self:Tag(name, '[free:color][name]')
    self.nameOnlyName = name

    local title = F.CreateFS(self, C.Assets.Fonts.Bold, 12, true, nil, nil, true)
    title:SetJustifyH('CENTER')
    title:ClearAllPoints()
    title:SetPoint('TOP', self, 'BOTTOM', 0, -10)
    title:Hide()
    self:Tag(title, '[free:title]')
    self.npcTitle = title

    UNITFRAME:AddNameText(self)
    UNITFRAME:AddHealthPrediction(self)
    NAMEPLATE:AddTargetIndicator(self)
    NAMEPLATE:AddHighlight(self)
    NAMEPLATE:AddClassifyIndicator(self)
    NAMEPLATE:AddThreatIndicator(self)
    NAMEPLATE:AddQuestIndicator(self)
    UNITFRAME:AddCastBar(self)
    UNITFRAME:AddRaidTargetIndicator(self)
    UNITFRAME:AddAuras(self)
    NAMEPLATE:AddSpitefulIndicator(self)

    platesList[self] = self:GetName()
end

function NAMEPLATE:UpdateClickableSize()
    if InCombatLockdown() then
        return
    end

    local width = C.DB.Nameplate.Width
    local height = C.DB.Nameplate.Height
    local scale = _G.FREE_ADB.ui_scale
    C_NamePlate_SetNamePlateEnemySize(width * scale, height * scale + 10)
    C_NamePlate_SetNamePlateFriendlySize(width * scale, height * scale + 10)
end

function NAMEPLATE:UpdateNameplateAuras()
    local element = self.Auras
    element:SetPoint('BOTTOM', self, 'TOP', 0, 8)
    element.numTotal = C.DB.Nameplate.AuraNumTotal
    element.size = C.DB.Nameplate.AuraSize
    element:SetWidth(self:GetWidth())
    element:SetHeight((element.size + element.spacing) * 2)
    element:ForceUpdate()
end

function NAMEPLATE:RefreshNameplats()
    for nameplate in pairs(platesList) do
        nameplate:SetSize(C.DB.Nameplate.Width, C.DB.Nameplate.Height)
        NAMEPLATE.UpdateNameplateAuras(nameplate)
        NAMEPLATE.UpdateTargetIndicator(nameplate)
        NAMEPLATE.UpdateTargetChange(nameplate)
    end
    NAMEPLATE:UpdateClickableSize()
end

function NAMEPLATE:RefreshAllPlates()
    NAMEPLATE:RefreshNameplats()
end

local disabledElements = {
    'Health',
    'Castbar',
    'HealPredictionAndAbsorb',
    'PvPClassificationIndicator',
    'ThreatIndicator',
}

function NAMEPLATE:UpdatePlateByType()
    local nameOnlyName = self.nameOnlyName
    local normalName = self.Name
    local title = self.npcTitle
    local raidTarget = self.RaidTargetIndicator
    local raidTargetSize = C.DB.Nameplate.RaidTargetSize
    local raidTargetAlpha = C.DB.Nameplate.RaidTargetAlpha
    local classify = self.ClassifyIndicator
    local isNameOnly = self.isNameOnly
    local questIcon = self.questIcon

    normalName:SetShown(not self.widgetsOnly)

    if isNameOnly then
        for _, element in pairs(disabledElements) do
            if self:IsElementEnabled(element) then
                self:DisableElement(element)
            end
        end

        nameOnlyName:Show()
        normalName:Hide()
        title:Show()
        classify:Hide()

        raidTarget:ClearAllPoints()
        -- if title then
        raidTarget:SetPoint('TOP', title or nameOnlyName, 'BOTTOM')
        -- else
        --     raidTarget:SetPoint('TOP', nameOnlyName, 'BOTTOM')
        -- end
        raidTarget:SetSize(24, 24)
        raidTarget:SetAlpha(1)
        raidTarget:SetParent(self)

        if questIcon then
            questIcon:ClearAllPoints()
            questIcon:SetPoint('LEFT', nameOnlyName, 'RIGHT', 0, 0)
        end

        if self.widgetContainer then
            self.widgetContainer:ClearAllPoints()
            self.widgetContainer:SetPoint('TOP', title, 'BOTTOM', 0, -5)
        end
    else
        for _, element in pairs(disabledElements) do
            if not self:IsElementEnabled(element) then
                self:EnableElement(element)
            end
        end

        nameOnlyName:Hide()
        normalName:Show()
        title:Hide()
        classify:Show()

        raidTarget:ClearAllPoints()
        raidTarget:SetPoint('CENTER')
        raidTarget:SetSize(raidTargetSize, raidTargetSize)
        raidTarget:SetAlpha(raidTargetAlpha)
        raidTarget:SetParent(self.Health)

        if questIcon then
            questIcon:ClearAllPoints()
            questIcon:SetPoint('TOP', self, 'BOTTOM', 0, -3)
        end

        if self.widgetContainer then
            self.widgetContainer:ClearAllPoints()
            self.widgetContainer:SetPoint('TOP', self.Castbar, 'BOTTOM', 0, -5)
        end
    end

    NAMEPLATE.UpdateTargetIndicator(self)
end

function NAMEPLATE:RefreshPlateType(unit)
    self.reaction = UnitReaction(unit, 'player')
    self.isFriendly = self.reaction and self.reaction >= 5
    self.isNameOnly = C.DB.Nameplate.NameOnly and self.isFriendly or self.widgetsOnly or false

    if self.previousType == nil or self.previousType ~= self.isNameOnly then
        NAMEPLATE.UpdatePlateByType(self)
        self.previousType = self.isNameOnly
    end
end

function NAMEPLATE:OnUnitFactionChanged(unit)
    local nameplate = C_NamePlate_GetNamePlateForUnit(unit, issecure())
    local unitFrame = nameplate and nameplate.unitFrame
    if unitFrame and unitFrame.unitName then
        NAMEPLATE.RefreshPlateType(unitFrame, unit)
    end
end

function NAMEPLATE:RefreshPlateOnFactionChanged()
    F:RegisterEvent('UNIT_FACTION', NAMEPLATE.OnUnitFactionChanged)
end

function NAMEPLATE:PostUpdatePlates(event, unit)
    if not self then
        return
    end

    if event == 'NAME_PLATE_UNIT_ADDED' then
        self.unitName = UnitName(unit)
        self.unitGUID = UnitGUID(unit)
        if self.unitGUID then
            guidToPlate[self.unitGUID] = self
        end
        self.isPlayer = UnitIsPlayer(unit)
        self.npcID = F.GetNPCID(self.unitGUID)
        self.widgetsOnly = UnitNameplateShowsWidgetsOnly(unit)

        local blizzPlate = self:GetParent().UnitFrame
        self.widgetContainer = blizzPlate and blizzPlate.WidgetContainer
        if self.widgetContainer then
            self.widgetContainer:SetParent(self)
            self.widgetContainer:SetScale(1 / _G.FREE_ADB.ui_scale)
        end

        NAMEPLATE.RefreshPlateType(self, unit)

        if C.DB.Nameplate.TotemIcon and self.npcID and totemsList[self.npcID] then
            if not self.TotemIcon then
                self.TotemIcon = CreateTotemIcon(self)
            end

            self.TotemIcon:Show()

            local totemData = totemsList[self.npcID]
            local spellID, duration = unpack(totemData)
            local texure = GetSpellTexture(spellID)

            self.TotemIcon.texure:SetTexture(texure)

            if self.Name then
                self.Name:Hide()
            end
        end

    elseif event == 'NAME_PLATE_UNIT_REMOVED' then
        if self.unitGUID then
            guidToPlate[self.unitGUID] = nil
        end
        self.npcID = nil

        if self.TotemIcon then
            self.TotemIcon:Hide()
        end
    end

    if event ~= 'NAME_PLATE_UNIT_REMOVED' then
        NAMEPLATE.UpdateTargetChange(self)
        NAMEPLATE.UpdateUnitClassify(self, unit)
        NAMEPLATE.UpdateQuestUnit(self, event, unit)
        NAMEPLATE.UpdateSpitefulIndicator(self)
    end

    NAMEPLATE.UpdateExplosives(self, event, unit)
end

function NAMEPLATE:OnLogin()
    if not C.DB.Nameplate.Enable then
        return
    end

    NAMEPLATE:UpdateClickableSize()
    hooksecurefunc(NamePlateDriverFrame, 'UpdateNamePlateOptions', NAMEPLATE.UpdateClickableSize)

    NAMEPLATE:SetupCVars()
    NAMEPLATE:BlockAddons()
    NAMEPLATE:CreateUnitTable()
    NAMEPLATE:CreatePowerUnitTable()
    NAMEPLATE:CheckExplosives()
    NAMEPLATE:AddInterruptInfo()
    NAMEPLATE:UpdateGroupRoles()
    NAMEPLATE:RefreshPlateOnFactionChanged()
    NAMEPLATE:RefreshMajorSpells()

    OUF:RegisterStyle('Nameplate', NAMEPLATE.CreateNameplateStyle)
    OUF:SetActiveStyle('Nameplate')
    OUF:SpawnNamePlates('oUF_Nameplate', NAMEPLATE.PostUpdatePlates)
end
