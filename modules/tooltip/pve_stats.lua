--[[
    Show PvE stats
    Credit: Elv_WindTools by fang2hou
]]

local _G = _G
local unpack = unpack
local select = select
local GetTime = GetTime
local format = string.format
local gsub = string.gsub
local strfind = string.find
local UnitExists = UnitExists
local UnitRace = UnitRace
local UnitLevel = UnitLevel
local UnitIsPlayer = UnitIsPlayer
local UnitGUID = UnitGUID
local CanInspect = CanInspect
local GetAchievementInfo = GetAchievementInfo
local GetAchievementComparisonInfo = GetAchievementComparisonInfo
local ClearAchievementComparisonUnit = ClearAchievementComparisonUnit
local C_PlayerInfo_GetPlayerMythicPlusRatingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary
local C_ChallengeMode_GetDungeonScoreRarityColor = C_ChallengeMode.GetDungeonScoreRarityColor
local C_ChallengeMode_GetSpecificDungeonOverallScoreRarityColor = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor
local C_CreatureInfo_GetFactionInfo = C_CreatureInfo.GetFactionInfo
local C_ChallengeMode_GetMapUIInfo = C_ChallengeMode.GetMapUIInfo
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsAddOnLoaded = IsAddOnLoaded
local AchievementFrame_LoadUI = AchievementFrame_LoadUI
local SetAchievementComparisonUnit = SetAchievementComparisonUnit
local HideUIPanel = HideUIPanel

local F, C, L = unpack(select(2, ...))
local TOOLTIP = F:GetModule('Tooltip')

local loadedComparison
local compareGUID
local cache = {}

local tiers = {
    'Castle Nathria',
    'Sanctum of Domination'
}

local levels = {
    'Mythic',
    'Heroic',
    'Normal',
    'Raid Finder'
}

local locales = {
    ['Shadowlands Keystone Master: Season One'] = {
        short = L['Keystone Master: Season One']
    },
    ['Shadowlands Keystone Master: Season Two'] = {
        short = L['Keystone Master: Season Two']
    },
    ['Raid Finder'] = {
        short = L['Raid Finder']
    },
    ['Normal'] = {
        short = L['Normal']
    },
    ['Heroic'] = {
        short = L['Heroic']
    },
    ['Mythic'] = {
        short = L['Mythic']
    },
    ['Castle Nathria'] = {
        short = L['Castle Nathria']
    },
    ['Sanctum of Domination'] = {
        short = L['Sanctum of Domination']
    },
    ['The Necrotic Wake'] = {
        short = L['The Necrotic Wake']
    },
    ['Plaguefall'] = {
        short = L['Plaguefall']
    },
    ['Mists of Tirna Scithe'] = {
        short = L['Mists of Tirna Scithe']
    },
    ['Halls of Atonement'] = {
        short = L['Halls of Atonement']
    },
    ['Theater of Pain'] = {
        short = L['Theater of Pain']
    },
    ['De Other Side'] = {
        short = L['De Other Side']
    },
    ['Spires of Ascension'] = {
        short = L['Spires of Ascension']
    },
    ['Sanguine Depths'] = {
        short = L['Sanguine Depths']
    }
}

local raidAchievements = {
    ['Castle Nathria'] = {
        ['Mythic'] = {
            14421,
            14425,
            14429,
            14433,
            14437,
            14441,
            14445,
            14449,
            14453,
            14457
        },
        ['Heroic'] = {
            14420,
            14424,
            14428,
            14432,
            14436,
            14440,
            14444,
            14448,
            14452,
            14456
        },
        ['Normal'] = {
            14419,
            14423,
            14427,
            14431,
            14435,
            14439,
            14443,
            14447,
            14451,
            14455
        },
        ['Raid Finder'] = {
            14422,
            14426,
            14430,
            14434,
            14438,
            14442,
            14446,
            14450,
            14454,
            14458
        }
    },
    ['Sanctum of Domination'] = {
        ['Mythic'] = {
            15139,
            15143,
            15147,
            15155,
            15151,
            15159,
            15163,
            15167,
            15172,
            15176
        },
        ['Heroic'] = {
            15138,
            15142,
            15146,
            15154,
            15150,
            15158,
            15162,
            15166,
            15171,
            15175
        },
        ['Normal'] = {
            15137,
            15141,
            15145,
            15153,
            15149,
            15157,
            15161,
            15165,
            15170,
            15174
        },
        ['Raid Finder'] = {
            15136,
            15140,
            15144,
            15152,
            15148,
            15156,
            15160,
            15164,
            15169,
            15173
        }
    }
}

local dungeons = {
    [375] = 'Mists of Tirna Scithe',
    [376] = 'The Necrotic Wake',
    [377] = 'De Other Side',
    [378] = 'Halls of Atonement',
    [379] = 'Plaguefall',
    [380] = 'Sanguine Depths',
    [381] = 'Spires of Ascension',
    [382] = 'Theater of Pain'
}

local specialAchievements = {
    [1] = {
        id = 14532,
        name = 'Shadowlands Keystone Master: Season One'
    },
    [2] = {
        id = 15078,
        name = 'Shadowlands Keystone Master: Season Two'
    }
}

local function GetLevelColoredString(level)
    local color = 'ff8000'

    if level == 'Mythic' then
        color = 'a335ee'
    elseif level == 'Heroic' then
        color = '0070dd'
    elseif level == 'Normal' then
        color = '1eff00'
    end

    return '|cff' .. color .. locales[level].short .. '|r'
end

local function GetBossKillTimes(guid, achievementID)
    local func = guid == C.MyGUID and GetStatistic or GetComparisonStatistic
    return tonumber(func(achievementID), 10) or 0
end

local function GetAchievementInfoByID(guid, achievementID)
    local completed, month, day, year
    if guid == C.MyGUID then
        completed, month, day, year = select(4, GetAchievementInfo(achievementID))
    else
        completed, month, day, year = GetAchievementComparisonInfo(achievementID)
    end
    return completed, month, day, year
end

function TOOLTIP:UpdatePvEStats(guid, faction)
    cache[guid] = cache[guid] or {}
    cache[guid].info = cache[guid].info or {}
    cache[guid].timer = GetTime()

    cache[guid].info.special = {}

    for _, achievement in ipairs(specialAchievements) do
        local completed, month, day, year = GetAchievementInfoByID(guid, achievement.id)
        local completedString = '|cff888888' .. L['Not Completed'] .. '|r'
        if completed then
            completedString = gsub(L['%month%-%day%-%year%'], '%%month%%', month)
            completedString = gsub(completedString, '%%day%%', day)
            completedString = gsub(completedString, '%%year%%', 2000 + year)
        end

        cache[guid].info.special[achievement.name] = completedString
    end

    cache[guid].info.raids = {}
    for _, tier in ipairs(tiers) do
        cache[guid].info.raids[tier] = {}
        local bosses = raidAchievements[tier]
        if bosses.separated then
            bosses = bosses[faction]
        end

        for _, level in ipairs(levels) do
            local alreadyKilled = 0
            for _, achievementID in pairs(bosses[level]) do
                if GetBossKillTimes(guid, achievementID) > 0 then
                    alreadyKilled = alreadyKilled + 1
                end
            end

            if alreadyKilled > 0 then
                cache[guid].info.raids[tier][level] = format('%d/%d', alreadyKilled, #bosses[level])
                if alreadyKilled == #bosses[level] then
                    break
                end
            end
        end
    end
end

function TOOLTIP:SetPvEStats(unit, guid)
    if not cache[guid] then
        return
    end

    local updated = false

    for i = 2, _G.GameTooltip:NumLines() do
        local leftTip = _G['GameTooltipTextLeft' .. i]
        local leftTipText = leftTip:GetText()
        local found = false

        if leftTipText then

            for _, achievement in ipairs(specialAchievements) do
                local name = achievement.name
                local nameStr = locales[name] and locales[name].short or name
                if strfind(leftTipText, nameStr) then
                    local rightTip = _G['GameTooltipTextRight' .. i]
                    leftTip:SetText(nameStr .. ':')
                    rightTip:SetText(cache[guid].info.special[name])
                    updated = true
                    found = true
                    break
                end
                if found then
                    break
                end
            end

            found = false

            for _, tier in ipairs(tiers) do
                for _, level in ipairs(levels) do
                    if strfind(leftTipText, locales[tier].short) then
                        local rightTip = _G['GameTooltipTextRight' .. i]
                        leftTip:SetText(format('%s:', locales[tier].short))
                        rightTip:SetText(GetLevelColoredString(level) .. ' ' .. cache[guid].info.raids[tier][level])
                        updated = true
                        found = true
                        break
                    end
                end

                if found then
                    break
                end
            end

        end
    end

    if updated then
        return
    end

    if cache[guid].info.special then
        _G.GameTooltip:AddLine(' ')
        _G.GameTooltip:AddLine(L['Special Achievements'])
        for _, achievement in ipairs(specialAchievements) do
            local name = achievement.name
            local nameStr = locales[name] and locales[name].short or name
            local left = format('%s:', nameStr)
            local right = cache[guid].info.special[name]
            _G.GameTooltip:AddDoubleLine(left, right, .6, .8, 1, 1, 1, 1)
        end
    end

    if next(cache[guid].info.raids) then
        local title = false

        for _, tier in ipairs(tiers) do
            for _, level in ipairs(levels) do
                if (cache[guid].info.raids[tier][level]) then
                    if not title then
                        _G.GameTooltip:AddLine(' ')
                        _G.GameTooltip:AddLine(L['Raids'])
                        title = true
                    end

                    local left = format('%s:', locales[tier].short)
                    local right = GetLevelColoredString(level) .. ' ' .. cache[guid].info.raids[tier][level]
                    _G.GameTooltip:AddDoubleLine(left, right, .6, .8, 1, 1, 1, 1)
                end
            end
        end
    end

    local summary = C_PlayerInfo_GetPlayerMythicPlusRatingSummary(unit)
    local score = summary and summary.currentSeasonScore
    local runs = summary and summary.runs

    if runs and next(runs) then
        _G.GameTooltip:AddLine(' ')
        local color = C_ChallengeMode_GetDungeonScoreRarityColor(score) or _G.HIGHLIGHT_FONT_COLOR
        _G.GameTooltip:AddLine(format(L['Mythic Plus: %s'], color:WrapTextInColorCode(score)))
        --_G.GameTooltip:AddDoubleLine(L['MythicDungeons'], L['Score (Level)'])

        for _, info in ipairs(runs) do
            local name = dungeons[info.challengeModeID] and locales[dungeons[info.challengeModeID]].short or C_ChallengeMode_GetMapUIInfo(info.challengeModeID)
            local left = format('%s:', name)
            local color = C_ChallengeMode_GetSpecificDungeonOverallScoreRarityColor(info.mapScore) or _G.HIGHLIGHT_FONT_COLOR
            local right = format('%s (%d)', color:WrapTextInColorCode(info.mapScore), info.bestRunLevel)
            _G.GameTooltip:AddDoubleLine(left, right, .6, .8, 1, 1, 1, 1)
        end
    end
end

function TOOLTIP:GetAchievementInfo(GUID)
    if (compareGUID ~= GUID) then
        return
    end

    local unit = 'mouseover'

    if UnitExists(unit) then
        local race = select(3, UnitRace(unit))
        local faction = race and C_CreatureInfo_GetFactionInfo(race).groupTag
        if faction then
            TOOLTIP:UpdatePvEStats(GUID, faction)
            _G.GameTooltip:SetUnit(unit)
        end
    end

    ClearAchievementComparisonUnit()

    F:UnregisterEvent(self, TOOLTIP.GetAchievementInfo)
end

function TOOLTIP:AddPvEStats()
    if not C.DB.Tooltip.PvEStats then return end

    if InCombatLockdown() then
        return
    end

    if not IsAltKeyDown() then return end

    local unit = TOOLTIP.GetUnit(self)
    if not unit or not CanInspect(unit) or not UnitIsPlayer(unit) then
        return
    end

    local level = UnitLevel(unit)
    if not (level and level == _G.MAX_PLAYER_LEVEL) then
        return
    end

    if not IsAddOnLoaded('Blizzard_AchievementUI') then
        AchievementFrame_LoadUI()
    end

    local guid = UnitGUID(unit)
    if not cache[guid] or (GetTime() - cache[guid].timer) > 600 then
        if guid == C.MyGUID then
            TOOLTIP:UpdatePvEStats(guid, C.MyFaction)
        else
            ClearAchievementComparisonUnit()

            if not loadedComparison and select(2, IsAddOnLoaded('Blizzard_AchievementUI')) then
                _G.AchievementFrame_DisplayComparison(unit)
                HideUIPanel(_G.AchievementFrame)
                ClearAchievementComparisonUnit()
                loadedComparison = true
            end

            compareGUID = guid

            if SetAchievementComparisonUnit(unit) then
                F:RegisterEvent('INSPECT_ACHIEVEMENT_READY', TOOLTIP.GetAchievementInfo)
            end

            return
        end
    end

    TOOLTIP:SetPvEStats(unit, guid)
end

local function loadFunc(event, addon)
    if addon == 'Blizzard_AchievementUI' then
        local method = 'AchievementFrameComparison_UpdateStatusBars'
        if _G[method] then
            F:RawHook(
                method,
                function(id)
                    if id and id ~= 'summary' then
                        F.hooks[method](id)
                    end
                end
            )
        end
        F:UnregisterEvent(event, loadFunc)
    end
end
F:RegisterEvent('ADDON_LOADED', loadFunc)
