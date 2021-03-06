local _G = _G
local unpack = unpack
local select = select
local wipe = wipe
local format = format
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local IsEveryoneAssistant = IsEveryoneAssistant
local bit_band = bit.band
local GetSpellLink = GetSpellLink
local UnitGUID = UnitGUID
local IsInGroup = IsInGroup
local SendChatMessage = SendChatMessage
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local IsInInstance = IsInInstance
local InCombatLockdown = InCombatLockdown
local GetNumGroupMembers = GetNumGroupMembers
local GetSpellInfo = GetSpellInfo
local UnitIsFeignDeath = UnitIsFeignDeath

local F, C, L = unpack(select(2, ...))
local ANNOUNCEMENT = F:RegisterModule('Announcement')

function ANNOUNCEMENT:IsInMyGroup(flag)
    local inParty = IsInGroup() and bit_band(flag, _G.COMBATLOG_OBJECT_AFFILIATION_PARTY) ~= 0
    local inRaid = IsInRaid() and bit_band(flag, _G.COMBATLOG_OBJECT_AFFILIATION_RAID) ~= 0

    return inRaid or inParty
end

function ANNOUNCEMENT:GetChannel(warning)
    if C.DB.Announcement.Channel == 1 then
        if IsInGroup(_G.LE_PARTY_CATEGORY_INSTANCE) then
            return 'INSTANCE_CHAT'
        elseif IsInRaid(_G.LE_PARTY_CATEGORY_HOME) then
            if warning and (UnitIsGroupLeader('player') or UnitIsGroupAssistant('player') or IsEveryoneAssistant()) then
                return 'RAID_WARNING'
            else
                return 'RAID'
            end
        elseif IsInGroup(_G.LE_PARTY_CATEGORY_HOME) then
            return 'PARTY'
        end
    elseif C.DB.Announcement.Channel == 2 then
        return 'YELL'
    elseif C.DB.Announcement.Channel == 3 then
        return 'EMOTE'
    elseif C.DB.Announcement.Channel == 4 then
        return 'SAY'
    end
end

ANNOUNCEMENT.AnnounceableSpellsList = {}
function ANNOUNCEMENT:RefreshSpells()
    wipe(ANNOUNCEMENT.AnnounceableSpellsList)

    for spellID in pairs(C.AnnounceableSpellsList) do
        local name = GetSpellInfo(spellID)
        if name then
            local modValue = _G.FREE_ADB['AnnounceableSpellsList'][spellID]
            if modValue == nil then
                ANNOUNCEMENT.AnnounceableSpellsList[spellID] = true
            end
        end
    end

    for spellID, value in pairs(_G.FREE_ADB['AnnounceableSpellsList']) do
        if value then
            ANNOUNCEMENT.AnnounceableSpellsList[spellID] = true
        end
    end
end

function ANNOUNCEMENT:OnEvent()
    if not (IsInInstance() and IsInGroup() and GetNumGroupMembers() > 1) then
        return true
    end

    local _, eventType, _, srcGUID, srcName, srcFlags, _, destGUID, destName, _, _, spellID, _, _, extraSpellID = CombatLogGetCurrentEventInfo()
    --    1  2          3  4        5        6         7  8         9         10 11 12       13 14 15

    if srcName then
        srcName = srcName:gsub('%-[^|]+', '')
    end

    if destName then
        destName = destName:gsub('%-[^|]+', '')
    end

    if eventType == 'SPELL_INTERRUPT' and C.DB.Announcement.Interrupt then
        if srcGUID == UnitGUID('player') or srcGUID == UnitGUID('pet') then
            SendChatMessage(format(L['Interrupted %s -> %s'], GetSpellLink(extraSpellID), destName), 'SAY')
        end
    elseif eventType == 'SPELL_DISPEL' and C.DB.Announcement.Dispel then
        if srcGUID == UnitGUID('player') or srcGUID == UnitGUID('pet') then
            SendChatMessage(format(L['Dispelled %s -> %s'], GetSpellLink(extraSpellID), destName), 'SAY')
        end
    elseif eventType == 'SPELL_STOLEN' and C.DB.Announcement.Stolen then
        if srcGUID == UnitGUID('player') then
            SendChatMessage(format(L['Stolen %s -> %s'], GetSpellLink(extraSpellID), destName), 'SAY')
        end
    elseif eventType == 'SPELL_MISSED' and C.DB.Announcement.Reflect then
        local missType, _, _ = select(15, CombatLogGetCurrentEventInfo())
        if missType == 'REFLECT' and destGUID == UnitGUID('player') then
            SendChatMessage(format(L['Reflected %s -> %s'], GetSpellLink(spellID), srcName), 'SAY')
        end
    end

    if eventType == 'SPELL_CAST_SUCCESS' then
        if not (srcGUID == UnitGUID('player') and srcName == C.MyName) then
            if not srcName then
                return
            end

            if C.DB.Announcement.BattleRez and C.BattleRezList[spellID] then
                if destName == nil then
                    SendChatMessage(format(L['%s used %s'], srcName, GetSpellLink(spellID)), ANNOUNCEMENT:GetChannel())
                else
                    SendChatMessage(format(L['%s used %s -> %s'], srcName, GetSpellLink(spellID), destName), ANNOUNCEMENT:GetChannel())
                end
            end
        else
            if not (srcGUID == UnitGUID('player') and srcName == C.MyName) then
                return
            end

            if C.BattleRezList[spellID] and C.DB.Announcement.BattleRez then
                if destName == nil then
                    SendChatMessage(format(L['I have cast %s'], GetSpellLink(spellID)), ANNOUNCEMENT:GetChannel())
                else
                    SendChatMessage(format(L['I have cast %s -> %s'], GetSpellLink(spellID), destName), ANNOUNCEMENT:GetChannel())
                end
            end

            if ANNOUNCEMENT.AnnounceableSpellsList[spellID] and C.DB.Announcement.PersonalMajorSpell then
                if destName == nil then
                    SendChatMessage(format(L['I have cast %s'], GetSpellLink(spellID)), ANNOUNCEMENT:GetChannel())
                else
                    SendChatMessage(format(L['I have cast %s -> %s'], GetSpellLink(spellID), destName), ANNOUNCEMENT:GetChannel())
                end
            end
        end
    elseif eventType == 'UNIT_DIED' then
        if not ANNOUNCEMENT:IsInMyGroup(srcFlags) then
            return
        end

        if C.DB.Announcement.Death and not UnitIsFeignDeath(destName) then
            SendChatMessage(format('%s died', destName), ANNOUNCEMENT:GetChannel(true))
        end
    end

    if InCombatLockdown() then
        return
    end

    if not eventType or not spellID or not srcName then
        return
    end

    if not ANNOUNCEMENT:IsInMyGroup(srcFlags) then
        return
    end

    if eventType == 'SPELL_CAST_SUCCESS' then
        -- Feasts and Cauldron
        if (C.DB.Announcement.Feast and C.FeastsList[spellID]) or (C.DB.Announcement.Cauldron and C.CauldronList[spellID]) then
            SendChatMessage(format(L['%s has put down %s'], srcName, GetSpellLink(spellID)), ANNOUNCEMENT:GetChannel(true))

        -- Refreshment Table
        elseif C.DB.Announcement.RefreshmentTable and spellID == 43987 then
            SendChatMessage(format(L['%s has put down %s'], srcName, GetSpellLink(spellID)), ANNOUNCEMENT:GetChannel(true))

        -- Ritual of Summoning
        elseif C.DB.Announcement.RitualofSummoning and spellID == 698 then
            SendChatMessage(format(L['%s is casting %s'], srcName, GetSpellLink(spellID)), ANNOUNCEMENT:GetChannel(true))

        -- Piccolo of the Flaming Fire
        elseif C.DB.Announcement.Toy and spellID == 182346 then
            SendChatMessage(format(L['%s is casting %s'], srcName, GetSpellLink(spellID)), ANNOUNCEMENT:GetChannel(true))
        end

    elseif eventType == 'SPELL_SUMMON' then
        -- Repair Bots and Codex
        if (C.DB.Announcement.Bot and C.BotsList[spellID]) or (C.DB.Announcement.Codex and C.CodexList[spellID]) then
            SendChatMessage(format(L['%s has put down %s'], srcName, GetSpellLink(spellID)), ANNOUNCEMENT:GetChannel(true))
        end

    elseif eventType == 'SPELL_CREATE' then
        -- 29893 Soulwell 54710 MOLL-E 261602 Katy's Stampwhistle
        if C.DB.Announcement.Mailbox and (spellID == 29893 or spellID == 54710 or spellID == 261602) then
            SendChatMessage(format(L['%s has put down %s'], srcName, GetSpellLink(spellID)), ANNOUNCEMENT:GetChannel(true))

        elseif C.DB.Announcement.Toy and C.ToysList[spellID] then -- Toys
            SendChatMessage(format(L['%s has put down %s'], srcName, GetSpellLink(spellID)), ANNOUNCEMENT:GetChannel(true))

        elseif C.DB.Announcement.Portal and C.PortalsList[spellID] then -- Portals
            SendChatMessage(format(L['%s has opened %s'], srcName, GetSpellLink(spellID)), ANNOUNCEMENT:GetChannel(true))
        end

    elseif eventType == 'SPELL_AURA_APPLIED' then
        -- Turkey Feathers and Party G.R.E.N.A.D.E.
        if C.DB.Announcement.Toy and (spellID == 61781 or ((spellID == 51508 or spellID == 51510) and destName == C.MyName)) then
            SendChatMessage(format(L['%s used %s.'], srcName, GetSpellLink(spellID)), ANNOUNCEMENT:GetChannel(true))
        end
    end
end

function ANNOUNCEMENT:AnnounceSpells()
    F:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', ANNOUNCEMENT.OnEvent)
end

function ANNOUNCEMENT:OnLogin()
    if not C.DB.Announcement.Enable then
        return
    end

    ANNOUNCEMENT:RefreshSpells()

    ANNOUNCEMENT:AnnounceSpells()
    ANNOUNCEMENT:AnnounceReset()
    ANNOUNCEMENT:AnnounceQuest()
end
