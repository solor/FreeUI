local F, C, L = unpack(select(2, ...))

if not C.unitframe.enable then return end

local module = F:GetModule('Unitframe')
local cfg, oUF = C.unitframe, FreeUI.oUF

local format, tostring = string.format, tostring

local Mover_Width, Mover_Height,
	Player_Pos, Player_Height, Player_Width,
	Pet_Pos, Pet_Height, Pet_Width,
	Target_Pos, Target_Height, Target_Width,
	TargetTarget_Pos, TargetTarget_Height, TargetTarget_Width,
	Focus_Pos, Focus_Height, Focus_Width,
	FocusTarget_Pos, FocusTarget_Height, FocusTarget_Width,
	Party_Pos, Party_Height, Party_Width,
	Raid_Pos, Raid_Height, Raid_Width,
	Boss_Pos, Boss_Height, Boss_Width,
	Arena_Pos, Arena_Height, Arena_Width
	

if cfg.healer_layout then
	Focus_Width = cfg.focus_width_healer
	FocusTarget_Width = cfg.focustarget_width_healer
	TargetTarget_Width = cfg.targettarget_width_healer
	Party_Width = cfg.party_width_healer
	Party_Height = cfg.party_height_healer

	Player_Pos = cfg.player_pos_healer
	Pet_Pos = cfg.pet_pos_healer
	Target_Pos = cfg.target_pos_healer
	TargetTarget_Pos = cfg.targettarget_pos_healer
	Focus_Pos = cfg.focus_pos_healer
	FocusTarget_Pos = cfg.focustarget_pos_healer
	Boss_Pos = cfg.boss_pos_healer
	Arena_Pos = cfg.arena_pos_healer
	Party_Pos = cfg.party_pos_healer
	Raid_Pos = cfg.raid_pos_healer
else
	Focus_Width = cfg.focus_width
	FocusTarget_Width = cfg.focustarget_width
	TargetTarget_Width = cfg.targettarget_width
	Party_Width = cfg.party_width
	Party_Height = cfg.party_height

	Player_Pos = cfg.player_pos
	Pet_Pos = cfg.pet_pos
	Target_Pos = cfg.target_pos
	TargetTarget_Pos = cfg.targettarget_pos
	Focus_Pos = cfg.focus_pos
	FocusTarget_Pos = cfg.focustarget_pos
	Boss_Pos = cfg.boss_pos
	Arena_Pos = cfg.arena_pos
	Party_Pos = cfg.party_pos
	Raid_Pos = cfg.raid_pos
end



local function CreatePlayerStyle(self)
	self.unitStyle = 'player'
	self:SetSize(cfg.player_width, cfg.player_height)

	module:AddBackDrop(self)
	module:AddHealthBar(self)
	module:AddHealthPrediction(self)
	module:AddPowerBar(self)
	module:AddAlternativePower(self)
	module:AddHealthValue(self)
	module:AddPowerValue(self)
	module:AddPortrait(self)
	module:AddDispel(self)
	module:AddCastBar(self)
	module:AddRaidTargetIndicator(self)
	module:AddStatusIndicator(self)
	module:AddPvPIndicator(self)
	module:AddPlayerBuffTimer(self)
	--module:ReskinMirrorBars()
	--module:ReskinTimerTrakcer(self)

	if C.Class == 'DEATHKNIGHT' then module:AddRunes(self) end

	if C.Class == 'MONK' then module:AddStagger(self) end

	if C.Class == 'SHAMAN' then module:AddTotems(self) end

	if cfg.classPower then module:AddClassPower(self) end

	if cfg.quakeTimer then module:AddQuakeTimer(self) end

	if C.actionbar.enable then
		FreeUI_LeaveVehicleButton:SetPoint('LEFT', self, 'RIGHT', 6, 0)
	end
end

local function CreatePetStyle(self)
	self.unitStyle = 'pet'
	self:SetSize(cfg.pet_width, cfg.pet_height)

	module:AddBackDrop(self)
	module:AddHealthBar(self)
	module:AddHealthPrediction(self)
	module:AddPowerBar(self)
	module:AddPortrait(self)
	module:AddCastBar(self)
	module:AddAuras(self)
	module:AddRangeCheck(self)
	module:AddRaidTargetIndicator(self)
end

local function CreateTargetStyle(self)
	self.unitStyle = 'target'
	self:SetSize(cfg.target_width, cfg.target_height)

	module:AddBackDrop(self)
	module:AddHealthBar(self)
	module:AddHealthPrediction(self)
	module:AddPowerBar(self)
	module:AddPortrait(self)
	module:AddNameText(self)
	module:AddHealthValue(self)
	module:AddPowerValue(self)
	module:AddClassificationText(self)
	module:AddCastBar(self)
	module:AddAuras(self)
	module:AddRaidTargetIndicator(self)
	--module:AddQuestIndicator(self)
	module:AddRangeCheck(self)
end

local function CreateTargetTargetStyle(self)
	self.unitStyle = 'targettarget'
	self:SetSize(TargetTarget_Width, cfg.targettarget_height)

	module:AddBackDrop(self)
	module:AddHealthBar(self)
	module:AddPowerBar(self)
	module:AddNameText(self)
	module:AddRaidTargetIndicator(self)
	module:AddRangeCheck(self)
end

local function CreateFocusStyle(self)
	self.unitStyle = 'focus'
	self:SetSize(Focus_Width, cfg.focus_height)

	module:AddBackDrop(self)
	module:AddHealthBar(self)
	module:AddHealthPrediction(self)
	module:AddPowerBar(self)
	module:AddNameText(self)
	module:AddCastBar(self)
	module:AddAuras(self)
	module:AddRaidTargetIndicator(self)
	module:AddRangeCheck(self)
end

local function CreateFocusTargetStyle(self)
	self.unitStyle = 'focustarget'
	self:SetSize(FocusTarget_Width, cfg.focustarget_height)

	module:AddBackDrop(self)
	module:AddHealthBar(self)
	module:AddPowerBar(self)
	module:AddNameText(self)
	module:AddRaidTargetIndicator(self)
	module:AddRangeCheck(self)
end

local function CreatePartyStyle(self)
	self.unitStyle = 'party'

	module:AddBackDrop(self)
	module:AddHealthBar(self)
	module:AddHealthPrediction(self)
	module:AddPowerBar(self)
	module:AddPortrait(self)
	module:AddDispel(self)
	module:AddNameText(self)
	module:AddBuffs(self)
	module:AddDebuffs(self)
	module:AddRangeCheck(self)
	module:AddRaidTargetIndicator(self)
	module:AddLeaderIndicator(self)
	module:AddResurrectIndicator(self)
	module:AddReadyCheckIndicator(self)
	module:AddGroupRoleIndicator(self)
	module:AddPhaseIndicator(self)
	module:AddSummonIndicator(self)
	module:AddThreatIndicator(self)
	module:AddSelectedBorder(self)
end

local function CreateRaidStyle(self)
	self.unitStyle = 'raid'

	module:AddBackDrop(self)
	module:AddHealthBar(self)
	module:AddHealthPrediction(self)
	module:AddPowerBar(self)
	module:AddDispel(self)
	module:AddNameText(self)
	module:AddBuffs(self)
	module:AddDebuffs(self)
	module:AddRangeCheck(self)
	module:AddRaidTargetIndicator(self)
	module:AddLeaderIndicator(self)
	module:AddResurrectIndicator(self)
	module:AddReadyCheckIndicator(self)
	module:AddGroupRoleIndicator(self)
	module:AddPhaseIndicator(self)
	module:AddSummonIndicator(self)
	module:AddSelectedBorder(self)
end

local function CreateBossStyle(self)
	self.unitStyle = 'boss'
	self:SetSize(cfg.boss_width, cfg.boss_height)

	module:AddBackDrop(self)
	module:AddHealthBar(self)
	module:AddHealthValue(self)
	module:AddHealthPercentage(self)
	module:AddPowerBar(self)
	module:AddAlternativePower(self)
	module:AddPowerValue(self)
	module:AddPortrait(self)
	module:AddNameText(self)
	module:AddCastBar(self)
	module:AddAuras(self)
	module:AddRangeCheck(self)
	module:AddRaidTargetIndicator(self)
	module:AddSelectedBorder(self)
end

local function CreateArenaStyle(self)
	self.unitStyle = 'arena'
	self:SetSize(cfg.arena_width, cfg.arena_height)

	module:AddBackDrop(self)
	module:AddHealthBar(self)
	module:AddPowerBar(self)
	module:AddNameText(self)
	module:AddHealthValue(self)
	module:AddArenaSpec(self)
	module:AddCastBar(self)
	module:AddAuras(self)
	module:AddRangeCheck(self)
	module:AddSelectedBorder(self)
end




function module:OnLogin()
	oUF:RegisterStyle('Player', CreatePlayerStyle)
	oUF:RegisterStyle('Pet', CreatePetStyle)
	oUF:RegisterStyle('Target', CreateTargetStyle)
	oUF:RegisterStyle('TargetTarget', CreateTargetTargetStyle)
	oUF:RegisterStyle('Focus', CreateFocusStyle)
	oUF:RegisterStyle('FocusTarget', CreateFocusTargetStyle)


	oUF:SetActiveStyle('Player')
	local player = oUF:Spawn('player', 'oUF_Player')
	if cfg.frameVisibility then
		player:Disable()
		player.frameVisibility = cfg.frameVisibility
		RegisterStateDriver(player, "visibility", cfg.player_frameVisibility)
	end
	Mover_Width, Mover_Height = player:GetWidth(), player:GetHeight()
	F.Mover(player, L['MOVER_UNITFRAME_PLAYER'], 'PlayerFrame', Player_Pos, Mover_Width, Mover_Height)

	oUF:SetActiveStyle('Pet')
	local pet = oUF:Spawn('pet', 'oUF_Pet')
	if cfg.frameVisibility then
		pet:Disable()
		pet.frameVisibility = cfg.frameVisibility
		RegisterStateDriver(pet, "visibility", cfg.pet_frameVisibility)
	end
	Mover_Width, Mover_Height = pet:GetWidth(), pet:GetHeight()
	F.Mover(pet, L['MOVER_UNITFRAME_PET'], 'PetFrame', Pet_Pos, Mover_Width, Mover_Height)

	oUF:SetActiveStyle('Target')
	local target = oUF:Spawn('target', 'oUF_Target')
	Mover_Width, Mover_Height = target:GetWidth(), target:GetHeight()
	F.Mover(target, L['MOVER_UNITFRAME_TARGET'], 'TargetFrame', Target_Pos, Mover_Width, Mover_Height)

	oUF:SetActiveStyle('TargetTarget')
	local targettarget = oUF:Spawn('targettarget', 'oUF_TargetTarget')
	Mover_Width, Mover_Height = targettarget:GetWidth(), targettarget:GetHeight()
	F.Mover(targettarget, L['MOVER_UNITFRAME_TARGETTARGET'], 'TargetTargetFrame', TargetTarget_Pos, Mover_Width, Mover_Height)

	oUF:SetActiveStyle('Focus')
	local focus = oUF:Spawn('focus', 'oUF_Focus')
	Mover_Width, Mover_Height = focus:GetWidth(), focus:GetHeight()
	F.Mover(focus, L['MOVER_UNITFRAME_FOCUS'], 'FocusFrame', Focus_Pos, Mover_Width, Mover_Height)

	oUF:SetActiveStyle('FocusTarget')
	local focustarget = oUF:Spawn('focustarget', 'oUF_FocusTarget')
	Mover_Width, Mover_Height = focustarget:GetWidth(), focustarget:GetHeight()
	F.Mover(focustarget, L['MOVER_UNITFRAME_FOCUSTARGET'], 'FocusTargetFrame', FocusTarget_Pos, Mover_Width, Mover_Height)

	
	if cfg.enableBoss then
		oUF:RegisterStyle('Boss', CreateBossStyle)
		oUF:SetActiveStyle('Boss')
		local boss = {}
		for i = 1, MAX_BOSS_FRAMES do
			boss[i] = oUF:Spawn('boss'..i, 'oUF_Boss'..i)
			if i == 1 then
				boss[i].mover = F.Mover(boss[i], L['MOVER_UNITFRAME_BOSS'], 'BossFrame', Boss_Pos, cfg.boss_width, cfg.boss_height)
			else
				boss[i]:SetPoint('BOTTOM', boss[i-1], 'TOP', 0, cfg.boss_padding)
			end
		end
	end


	if cfg.enableArena then
		oUF:RegisterStyle('Arena', CreateArenaStyle)
		oUF:SetActiveStyle('Arena')
		local arena = {}
		for i = 1, 5 do
			arena[i] = oUF:Spawn('arena'..i, 'oUF_Arena'..i)
			if i == 1 then
				arena[i].mover = F.Mover(arena[i], L['MOVER_UNITFRAME_ARENA'], 'ArenaFrame', Arena_Pos, cfg.arena_width, cfg.arena_height)
			else
				arena[i]:SetPoint('BOTTOM', arena[i-1], 'TOP', 0, cfg.arena_padding)
			end
		end
	end


	if cfg.enableGroup then
		if IsAddOnLoaded('Blizzard_CompactRaidFrames') then
			CompactRaidFrameManager:SetParent(FreeUIHider)
			CompactUnitFrameProfiles:UnregisterAllEvents()
		end


		oUF:RegisterStyle('Party', CreatePartyStyle)
		oUF:SetActiveStyle('Party')

		local partyMover
		local party = oUF:SpawnHeader(nil, nil, 'solo,party',
			'showParty', true,
			'showPlayer', true,
			'showSolo', false,
			'xoffset', cfg.party_padding,
			'yoffset', cfg.party_padding,
			'maxColumns', 1,
			'unitsperColumn', 5,
			'columnSpacing', 0,
			'point', cfg.healer_layout and 'LEFT' or 'BOTTOM',
			'columnAnchorPoint', 'LEFT',
			'groupBy', 'ASSIGNEDROLE',
			'groupingOrder', 'TANK,HEALER,DAMAGER',
			'oUF-initialConfigFunction', ([[
				self:SetHeight(%d)
				self:SetWidth(%d)
			]]):format(Party_Height, Party_Width)
		)

		if cfg.healer_layout then
			partyMover = F.Mover(party, L['MOVER_UNITFRAME_PARTY'], 'PartyFrame', Party_Pos, (cfg.party_width*5+cfg.party_padding*4), cfg.party_height)
			party:ClearAllPoints()
			party:SetPoint('TOP', partyMover)
		else
			partyMover = F.Mover(party, L['MOVER_UNITFRAME_PARTY'], 'PartyFrame', Party_Pos, cfg.party_width, (cfg.party_height*5+cfg.party_padding*4))
			party:ClearAllPoints()
			party:SetPoint('BOTTOM', partyMover)
		end


		oUF:RegisterStyle('Raid', CreateRaidStyle)
		oUF:SetActiveStyle('Raid')

		local raidMover
		local function CreateRaid(name, i)
			local raid = oUF:SpawnHeader(name, nil, 'raid',
			'showParty', false,
			'showRaid', true,
			'xoffset', cfg.raid_padding,
			'yOffset', -cfg.raid_padding,
			'groupFilter', tostring(i),
			'groupingOrder', '1,2,3,4,5,6,7,8',
			'groupBy', 'GROUP',
			'sortMethod', 'INDEX',
			'maxColumns', 1,
			'unitsPerColumn', 5,
			'columnSpacing', 0,
			'point', cfg.healer_layout and 'LEFT' or 'TOP',
			'columnAnchorPoint', cfg.healer_layout and 'LEFT' or 'RIGHT',
			'oUF-initialConfigFunction', ([[
			self:SetHeight(%d)
			self:SetWidth(%d)
			]]):format(cfg.raid_height, cfg.raid_width))
			return raid
		end

		local groups = {}
		for i = 1, cfg.raid_numGroups do
			groups[i] = CreateRaid('oUF_Raid'..i, i)
			if i == 1 then
				if cfg.healer_layout then
					raidMover = F.Mover(groups[i], L['MOVER_UNITFRAME_RAID'], 'RaidFrame', Raid_Pos, (cfg.raid_width*5+cfg.raid_padding*4), (cfg.raid_height*cfg.raid_numGroups+(cfg.raid_padding*(cfg.raid_numGroups-1))))
					groups[i]:ClearAllPoints()
					groups[i]:SetPoint('TOPLEFT', raidMover)
				else
					raidMover = F.Mover(groups[i], L['MOVER_UNITFRAME_RAID'], 'RaidFrame', Raid_Pos, (cfg.raid_width*cfg.raid_numGroups+(cfg.raid_padding*(cfg.raid_numGroups-1))), (cfg.raid_height*5+cfg.raid_padding*4))
					groups[i]:ClearAllPoints()
					groups[i]:SetPoint('TOPRIGHT', raidMover)
				end
			else
				if cfg.healer_layout then
					groups[i]:SetPoint('TOPLEFT', groups[i-1], 'BOTTOMLEFT', 0, -cfg.raid_padding)
				else
					groups[i]:SetPoint('TOPRIGHT', groups[i-1], 'TOPLEFT', -cfg.raid_padding, 0)
				end
			end
		end
	end
end