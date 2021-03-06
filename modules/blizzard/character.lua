local _G = _G
local unpack = unpack
local select = select
local format = format
local max = max
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded
local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetMeleeHaste = GetMeleeHaste
local UnitAttackSpeed = UnitAttackSpeed
local GetAverageItemLevel = GetAverageItemLevel
local C_PaperDollInfo_GetMinItemLevel = C_PaperDollInfo.GetMinItemLevel
local PaperDollFrame_SetLabelAndText = PaperDollFrame_SetLabelAndText
local C_PaperDollInfo_OffhandHasShield = C_PaperDollInfo.OffhandHasShield
local PaperDollFrame_SetEnergyRegen = PaperDollFrame_SetEnergyRegen
local PaperDollFrame_SetRuneRegen = PaperDollFrame_SetRuneRegen
local PaperDollFrame_SetFocusRegen = PaperDollFrame_SetFocusRegen
local EquipmentManager_RunAction = EquipmentManager_RunAction
local EquipmentManager_UnequipItemInSlot = EquipmentManager_UnequipItemInSlot
local GetInventoryItemTexture = GetInventoryItemTexture
local STAT_ATTACK_SPEED_BASE_TOOLTIP = STAT_ATTACK_SPEED_BASE_TOOLTIP
local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT
local STAT_AVERAGE_ITEM_LEVEL = STAT_AVERAGE_ITEM_LEVEL
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local WEAPON_SPEED = WEAPON_SPEED
local ATTACK_SPEED = ATTACK_SPEED

local F, C, L = unpack(select(2, ...))
local BLIZZARD = F:GetModule('Blizzard')

function BLIZZARD:MissingStats()
    if not C.DB.General.MissingStats then
        return
    end
    if IsAddOnLoaded('DejaCharacterStats') then
        return
    end

    local statPanel = CreateFrame('Frame', nil, _G.CharacterFrameInsetRight)
    statPanel:SetSize(200, 350)
    statPanel:SetPoint('TOP', 0, -5)
    local scrollFrame = CreateFrame('ScrollFrame', nil, statPanel, 'UIPanelScrollFrameTemplate')
    scrollFrame:SetAllPoints()
    scrollFrame.ScrollBar:Hide()
    scrollFrame.ScrollBar.Show = F.Dummy
    local stat = CreateFrame('Frame', nil, scrollFrame)
    stat:SetSize(200, 1)
    scrollFrame:SetScrollChild(stat)
    _G.CharacterStatsPane:ClearAllPoints()
    _G.CharacterStatsPane:SetParent(stat)
    _G.CharacterStatsPane:SetAllPoints(stat)
    hooksecurefunc('PaperDollFrame_UpdateSidebarTabs', function()
        if (not _G[PAPERDOLL_SIDEBARS[1].frame]:IsShown()) then
            statPanel:Hide()
        else
            statPanel:Show()
        end
    end)

    -- Change default data
    _G.PAPERDOLL_STATCATEGORIES = {
        [1] = {
            categoryFrame = 'AttributesCategory',
            stats = {
                [1] = {stat = 'STRENGTH', primary = _G.LE_UNIT_STAT_STRENGTH},
                [2] = {stat = 'AGILITY', primary = _G.LE_UNIT_STAT_AGILITY},
                [3] = {stat = 'INTELLECT', primary = _G.LE_UNIT_STAT_INTELLECT},
                [4] = {stat = 'STAMINA'},
                [5] = {stat = 'ARMOR'},
                [6] = {stat = 'STAGGER', hideAt = 0, roles = {'TANK'}},
                [7] = {stat = 'ATTACK_DAMAGE', primary = _G.LE_UNIT_STAT_STRENGTH, roles = {'TANK', 'DAMAGER'}},
                [8] = {stat = 'ATTACK_AP', hideAt = 0, primary = _G.LE_UNIT_STAT_STRENGTH, roles = {'TANK', 'DAMAGER'}},
                [9] = {stat = 'ATTACK_ATTACKSPEED', primary = _G.LE_UNIT_STAT_STRENGTH, roles = {'TANK', 'DAMAGER'}},
                [10] = {stat = 'ATTACK_DAMAGE', primary = _G.LE_UNIT_STAT_AGILITY, roles = {'TANK', 'DAMAGER'}},
                [11] = {stat = 'ATTACK_AP', hideAt = 0, primary = _G.LE_UNIT_STAT_AGILITY, roles = {'TANK', 'DAMAGER'}},
                [12] = {stat = 'ATTACK_ATTACKSPEED', primary = _G.LE_UNIT_STAT_AGILITY, roles = {'TANK', 'DAMAGER'}},
                [13] = {stat = 'SPELLPOWER', hideAt = 0, primary = _G.LE_UNIT_STAT_INTELLECT},
                [14] = {stat = 'MANAREGEN', hideAt = 0, primary = _G.LE_UNIT_STAT_INTELLECT},
                [15] = {stat = 'ENERGY_REGEN', hideAt = 0, primary = _G.LE_UNIT_STAT_AGILITY},
                [16] = {stat = 'RUNE_REGEN', hideAt = 0, primary = _G.LE_UNIT_STAT_STRENGTH},
                [17] = {stat = 'FOCUS_REGEN', hideAt = 0, primary = _G.LE_UNIT_STAT_AGILITY},
                [18] = {stat = 'MOVESPEED'},
            },
        },
        [2] = {
            categoryFrame = 'EnhancementsCategory',
            stats = {
                {stat = 'CRITCHANCE', hideAt = 0},
                {stat = 'HASTE', hideAt = 0},
                {stat = 'MASTERY', hideAt = 0},
                {stat = 'VERSATILITY', hideAt = 0},
                {stat = 'LIFESTEAL', hideAt = 0},
                {stat = 'AVOIDANCE', hideAt = 0},
                {stat = 'SPEED', hideAt = 0},
                {stat = 'DODGE', roles = {'TANK'}},
                {stat = 'PARRY', hideAt = 0, roles = {'TANK'}},
                {stat = 'BLOCK', hideAt = 0, showFunc = C_PaperDollInfo_OffhandHasShield},
            },
        },
    }

    _G.PAPERDOLL_STATINFO['ENERGY_REGEN'].updateFunc = function(statFrame, unit)
        statFrame.numericValue = 0
        PaperDollFrame_SetEnergyRegen(statFrame, unit)
    end

    _G.PAPERDOLL_STATINFO['RUNE_REGEN'].updateFunc = function(statFrame, unit)
        statFrame.numericValue = 0
        PaperDollFrame_SetRuneRegen(statFrame, unit)
    end

    _G.PAPERDOLL_STATINFO['FOCUS_REGEN'].updateFunc = function(statFrame, unit)
        statFrame.numericValue = 0
        PaperDollFrame_SetFocusRegen(statFrame, unit)
    end

    function PaperDollFrame_SetAttackSpeed(statFrame, unit)
        local meleeHaste = GetMeleeHaste()
        local speed, offhandSpeed = UnitAttackSpeed(unit)
        local displaySpeed = format('%.2f', speed)
        if offhandSpeed then
            offhandSpeed = format('%.2f', offhandSpeed)
        end
        if offhandSpeed then
            displaySpeed = BreakUpLargeNumbers(displaySpeed) .. ' / ' .. offhandSpeed
        else
            displaySpeed = BreakUpLargeNumbers(displaySpeed)
        end
        PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, displaySpeed, false, speed)
        statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED) .. ' ' .. displaySpeed .. FONT_COLOR_CODE_CLOSE
        statFrame.tooltip2 = format(STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHaste))
        statFrame:Show()
    end

    _G.MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY = 1
    hooksecurefunc('PaperDollFrame_SetItemLevel', function(statFrame, unit)
        if unit ~= 'player' then
            return
        end

        local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
        local minItemLevel = C_PaperDollInfo_GetMinItemLevel()
        local displayItemLevel = max(minItemLevel or 0, avgItemLevelEquipped)
        displayItemLevel = format('%.1f', displayItemLevel)
        avgItemLevel = format('%.1f', avgItemLevel)

        if displayItemLevel ~= avgItemLevel then
            displayItemLevel = displayItemLevel .. ' / ' .. avgItemLevel
        end
        PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, displayItemLevel, false, displayItemLevel)

        _G.CharacterStatsPane.ItemLevelFrame.Value:SetFont(C.Assets.Fonts.Header, 18)
        _G.CharacterStatsPane.ItemLevelFrame.Value:SetShadowColor(0, 0, 0, 1)
        _G.CharacterStatsPane.ItemLevelFrame.Value:SetShadowOffset(1, -1)
    end)
end

function BLIZZARD:NakedButton()
    if not C.DB.General.NakedButton then
        return
    end

    local bu = CreateFrame('Button', nil, _G.CharacterFrameInsetRight)
    bu:SetSize(31, 33)
    bu:SetPoint('RIGHT', _G.PaperDollSidebarTab1, 'LEFT', -4, -3)
    F.PixelIcon(bu, 'Interface\\ICONS\\UI_Calendar_FreeTShirtDay', true)
    F.AddTooltip(bu, 'ANCHOR_RIGHT', L['Double click to unequip all gears'])

    local function UnequipItemInSlot(i)
        local action = EquipmentManager_UnequipItemInSlot(i)
        EquipmentManager_RunAction(action)
    end

    bu:SetScript('OnDoubleClick', function()
        for i = 1, 17 do
            local texture = GetInventoryItemTexture('player', i)
            if texture then
                UnequipItemInSlot(i)
            end
        end
    end)
end

function BLIZZARD:TitleFontSize()
    hooksecurefunc('PaperDollTitlesPane_UpdateScrollFrame', function()
        local bu = _G.PaperDollTitlesPane.buttons
        for i = 1, #bu do
            if not bu[i].fontStyled then
                bu[i].text:SetFont(C.Assets.Fonts.Regular, 13)
                bu[i].text:SetShadowColor(0, 0, 0, 1)
                bu[i].text:SetShadowOffset(1, -1)
                bu[i].fontStyled = true
            end
        end
    end)
end

BLIZZARD:RegisterBlizz('MissingStats', BLIZZARD.MissingStats)
BLIZZARD:RegisterBlizz('NakedButton', BLIZZARD.NakedButton)
BLIZZARD:RegisterBlizz('TitleFontSize', BLIZZARD.TitleFontSize)
