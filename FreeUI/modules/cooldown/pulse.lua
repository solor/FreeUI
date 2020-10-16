local F, C, L = unpack(select(2, ...))
local COOLDOWN = F:GetModule('COOLDOWN')


local GetTime = GetTime
local fadeInTime, fadeOutTime, maxAlpha, elapsed, runtimer = 0.3, 0.7, 1, 0, 0
local animScale, iconSize, holdTime, threshold = 1.5, 50, 0, 3
local cooldowns, animating, watching = {}, {}, {}
local bg


local anchor = CreateFrame('Frame', 'FreeUI_CooldownPulse', UIParent)
anchor:SetSize(iconSize, iconSize)

local frame = CreateFrame('Frame', 'CDPulseFrame', anchor)
frame:SetPoint('CENTER', anchor, 'CENTER')

local icon = frame:CreateTexture(nil, 'ARTWORK')
icon:SetAllPoints()

local function tcount(tab)
	local n = 0
	for _ in pairs(tab) do
		n = n + 1
	end
	return n
end

local function memoize(f)
    local cache = nil

    local memoized = {}

    local function get()
        if (cache == nil) then
            cache = f()
        end

        return cache
    end

    memoized.resetCache = function()
        cache = nil
    end

    setmetatable(memoized, {__call = get})

    return memoized
end

local function GetPetActionIndexByName(name)
	for i = 1, _G.NUM_PET_ACTION_SLOTS, 1 do
		if GetPetActionInfo(i) == name then
			return i
		end
	end
	return nil
end

local function OnUpdate(_, update)
	elapsed = elapsed + update
	if elapsed > 0.05 then
		for i, v in pairs(watching) do
			if GetTime() >= v[1] + 0.5 then
				local getCooldownDetails
				if v[2] == 'spell' then
					getCooldownDetails = memoize(function()
                        local start, duration, enabled = GetSpellCooldown(v[3])
                        return {
                            name = GetSpellInfo(v[3]),
                            texture = GetSpellTexture(v[3]),
                            start = start,
                            duration = duration,
                            enabled = enabled
                        }
                    end)
				elseif v[2] == 'item' then
					getCooldownDetails = memoize(function()
                        local start, duration, enabled = GetItemCooldown(i)
                        return {
                            name = GetItemInfo(i),
                            texture = v[3],
                            start = start,
                            duration = duration,
                            enabled = enabled
                        }
                    end)
				elseif v[2] == 'pet' then
					getCooldownDetails = memoize(function()
                        local name, texture = GetPetActionInfo(v[3])
                        local start, duration, enabled = GetPetActionCooldown(v[3])
                        return {
                            name = name,
                            texture = texture,
                            isPet = true,
                            start = start,
                            duration = duration,
                            enabled = enabled
                        }
                    end)
				end
				local cooldown = getCooldownDetails()
				if FreeDB.cooldown.ignored_spells[cooldown.name] then
					watching[i] = nil
				else
					if cooldown.enabled ~= 0 then
                        if cooldown.duration and cooldown.duration > threshold and cooldown.texture then
                            cooldowns[i] = getCooldownDetails
                        end
                    end
                    if not (cooldown.enabled == 0 and v[2] == 'spell') then
                        watching[i] = nil
                    end
				end
			end
		end
		for i, getCooldownDetails in pairs(cooldowns) do
            local cooldown = getCooldownDetails()
            local remaining = cooldown.duration - (GetTime() - cooldown.start)
            if remaining <= 0 then
                tinsert(animating, {cooldown.texture, cooldown.isPet, cooldown.name})
                cooldowns[i] = nil
            end
        end

		elapsed = 0
		if #animating == 0 and tcount(watching) == 0 and tcount(cooldowns) == 0 then
			frame:SetScript('OnUpdate', nil)
			return
		end
	end

	if #animating > 0 then
		runtimer = runtimer + update
		if runtimer > (fadeInTime + holdTime + fadeOutTime) then
			tremove(animating, 1)
			runtimer = 0
			icon:SetTexture(nil)
			bg:Hide()
		else
			if not icon:GetTexture() then
				icon:SetTexture(animating[1][1])

				if FreeDB.cooldown.sound then
					PlaySoundFile(FreeDB.cooldown.sound_file, 'Master')
				end
			end
			local alpha = maxAlpha
			if runtimer < fadeInTime then
				alpha = maxAlpha * (runtimer / fadeInTime)
			elseif runtimer >= fadeInTime + holdTime then
				alpha = maxAlpha - (maxAlpha * ((runtimer - holdTime - fadeInTime) / fadeOutTime))
			end
			frame:SetAlpha(alpha)
			local scale = FreeDB.cooldown.icon_size + (FreeDB.cooldown.icon_size * ((animScale - 1) * (runtimer / (fadeInTime + holdTime + fadeOutTime))))
			frame:SetWidth(scale)
			frame:SetHeight(scale)
			bg:Show()
		end
	end
end

function frame:ADDON_LOADED(addon)
	for _, v in pairs(FreeDB.cooldown.ignored_spells) do
		FreeDB.cooldown.ignored_spells[v] = true
	end

	self:UnregisterEvent('ADDON_LOADED')
end
frame:RegisterEvent('ADDON_LOADED')

function frame:SPELL_UPDATE_COOLDOWN()
    for _, getCooldownDetails in pairs(cooldowns) do
        getCooldownDetails.resetCache()
    end
end

function frame:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
	if unit == 'player' then
		watching[spellID] = {GetTime(), 'spell', spellID}
		self:SetScript('OnUpdate', OnUpdate)
	end
end

function frame:COMBAT_LOG_EVENT_UNFILTERED()
	local _, eventType, _, _, _, sourceFlags, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
	if eventType == 'SPELL_CAST_SUCCESS' then
		if (bit.band(sourceFlags, _G.COMBATLOG_OBJECT_TYPE_PET) == _G.COMBATLOG_OBJECT_TYPE_PET and bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE) then
			local name = GetSpellInfo(spellID)
			local index = GetPetActionIndexByName(name)
			if index and not select(7, GetPetActionInfo(index)) then
				watching[spellID] = {GetTime(), 'pet', index}
			elseif not index and spellID then
				watching[spellID] = {GetTime(), 'spell', spellID}
			else
				return
			end
			self:SetScript('OnUpdate', OnUpdate)
		end
	end
end

function frame:PLAYER_ENTERING_WORLD()
	local _, instanceType = IsInInstance()
	if instanceType == 'arena' then
		self:SetScript('OnUpdate', nil)
		wipe(cooldowns)
		wipe(watching)
	end
end


function COOLDOWN:CooldownPulse()
	if not FreeDB.cooldown.pulse then return end

	bg = F.CreateBDFrame(frame, nil, true)
	icon:SetTexCoord(unpack(C.TexCoord))
	F.Mover(anchor, L['ACTIONBAR_MOVER_COOLDOWN'], 'CooldownPulse', {'CENTER', UIParent, 0, 100}, FreeDB.cooldown.icon_size, FreeDB.cooldown.icon_size)

	frame:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)
	frame:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
	frame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	frame:RegisterEvent('SPELL_UPDATE_COOLDOWN')
	frame:RegisterEvent('PLAYER_ENTERING_WORLD')

	hooksecurefunc('UseAction', function(slot)
		local actionType, itemID = GetActionInfo(slot)
		if actionType == 'item' then
			local texture = GetActionTexture(slot)
			watching[itemID] = {GetTime(), 'item', texture}
		end
	end)

	hooksecurefunc('UseInventoryItem', function(slot)
		local itemID = GetInventoryItemID('player', slot)
		if itemID then
			local texture = GetInventoryItemTexture('player', slot)
			watching[itemID] = {GetTime(), 'item', texture}
		end
	end)

	hooksecurefunc('UseContainerItem', function(bag, slot)
		local itemID = GetContainerItemID(bag, slot)
		if itemID then
			local texture = select(10, GetItemInfo(itemID))
			watching[itemID] = {GetTime(), 'item', texture}
		end
	end)
end

_G.SlashCmdList.PULSECD = function()
	tinsert(animating, {GetSpellTexture(87214)})
	if FreeDB.cooldown.sound == true then
		PlaySoundFile(FreeDB.cooldown.sound_file, 'Master')
	end
	frame:SetScript('OnUpdate', OnUpdate)
end
SLASH_PULSECD1 = '/pulse'
