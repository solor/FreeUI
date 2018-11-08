local F, C, L = unpack(select(2, ...))

-- All exceptions and special rules for these options are in profiles.lua!

-- [[ Constants ]]

C.media = {
	['arrowUp']    = 'Interface\\AddOns\\FreeUI\\assets\\arrow-up-active',
	['arrowDown']  = 'Interface\\AddOns\\FreeUI\\assets\\arrow-down-active',
	['arrowLeft']  = 'Interface\\AddOns\\FreeUI\\assets\\arrow-left-active',
	['arrowRight'] = 'Interface\\AddOns\\FreeUI\\assets\\arrow-right-active',
	['backdrop']   = 'Interface\\AddOns\\FreeUI\\assets\\blank',
	['checked']    = 'Interface\\AddOns\\FreeUI\\assets\\CheckButtonHilight',
	['glowtex']    = 'Interface\\AddOns\\FreeUI\\assets\\glowTex',
	['gradient']   = 'Interface\\AddOns\\FreeUI\\assets\\gradient',
	['roleIcons']  = 'Interface\\Addons\\FreeUI\\assets\\UI-LFG-ICON-ROLES',
	['texture']    = 'Interface\\AddOns\\FreeUI\\assets\\statusbar',
	['bgtex']	   = 'Interface\\AddOns\\FreeUI\\assets\\bgTex',
	['sparktex']   = 'Interface\\AddOns\\FreeUI\\assets\\spark',
	['pixel']      = 'Interface\\AddOns\\FreeUI\\assets\\font\\pixel.ttf',
}

if GetLocale() == 'zhCN' then
	C.font = {
		['normal'] 		= 'Fonts\\ARKai_T.ttf',
		['damage'] 		= 'Fonts\\ARKai_C.ttf',
		['header']		= 'Fonts\\ARKai_T.ttf',
		['chat']		= 'Fonts\\ARKai_T.ttf',
		['pixel']		= {'Fonts\\pixfontCN.ttf', 10, 'OUTLINEMONOCHROME'}, -- pixel font for Chinese client, personal use
	}
elseif GetLocale() == 'zhTW' then
	C.font = {
		['normal'] 		= 'Fonts\\blei00d.ttf',
		['damage'] 		= 'Fonts\\bKAI00M.ttf',
		['header']		= 'Fonts\\blei00d.ttf',
		['chat']		= 'Fonts\\blei00d.ttf',
	}
elseif GetLocale() == 'koKR' then
	C.font = {
		['normal'] 		= 'Fonts\\2002.ttf',
		['damage'] 		= 'Fonts\\K_Damage.ttf',
		['header']		= 'Fonts\\2002.ttf',
		['chat']		= 'Fonts\\2002.ttf',
	}
elseif GetLocale() == 'ruRU' then
	C.font = {
		['normal'] 		= 'Fonts\\FRIZQT___CYR.ttf',
		['damage'] 		= 'Fonts\\FRIZQT___CYR.ttf',
		['header']		= 'Fonts\\FRIZQT___CYR.ttf',
		['chat']		= 'Fonts\\FRIZQT___CYR.ttf',
	}
else
	C.font = {
		['normal'] 		= 'Interface\\AddOns\\FreeUI\\assets\\font\\expresswaysb.ttf',
		['damage'] 		= 'Interface\\AddOns\\FreeUI\\assets\\font\\PEPSI_pl.ttf',
		['header']		= 'Interface\\AddOns\\FreeUI\\assets\\font\\ExocetBlizzardMedium.ttf',
		['chat']		= 'Interface\\AddOns\\FreeUI\\assets\\font\\expresswaysb.ttf',
	}
end



-- [[ Global config ]]

C['appearance'] = {
	['backdropcolor'] = {.05, .05, .05},
	['alpha'] = .6,
	['shadow'] = true,
	['buttonGradientColour'] = {.3, .3, .3, .3},
	['buttonSolidColour'] = {.2, .2, .2, .6},
	['useButtonGradientColour'] = true,

	['useCustomColour'] = false,
		['customColour'] = {r = 1, g = 1, b = 1},

	['vignette'] = true,
		['vignetteAlpha'] = .5,

	['fontStyle'] = true,

	['usePixelFont'] = false, -- Chinese pixel font for personal use
}

C['actionbars'] = {
	['buttonSizeNormal'] = 30,
	['buttonSizeSmall'] = 24,
	['buttonSizeBig'] = 34,
	['buttonSizeHuge'] = 40,
	['padding'] = 2,
	['margin'] = 4,

	['bar3Fade'] = false,

	['sideBarEnable'] = true,
		['sideBarFade'] = false,

	['petBarFade'] = false,
	['stanceBarEnable'] = true,

	['extraButtonPos'] = {'CENTER', UIParent, 'CENTER', 0, 200},
	['zoneAbilityPos'] = {'CENTER', UIParent, 'CENTER', 0, 300},

	['fader'] = {
		fadeInAlpha = 1,
		fadeInDuration = 0.3,
		fadeInSmooth = 'OUT',
		fadeOutAlpha = 0,
		fadeOutDuration = 0.9,
		fadeOutSmooth = 'OUT',
		fadeOutDelay = 0,
	},
	['faderOnShow'] = {
		fadeInAlpha = 1,
		fadeInDuration = 0.3,
		fadeInSmooth = 'OUT',
		fadeOutAlpha = 0,
		fadeOutDuration = 0.9,
		fadeOutSmooth = 'OUT',
		fadeOutDelay = 0,
		trigger = 'OnShow',
	},

	['hotKey'] = true, 					-- show hot keys on buttons
	['macroName'] = true,				-- show macro name on buttons
	['count'] = false,					-- show itme count on buttons		
	['classColor'] = false,				-- button border colored by class color

	['layoutSimple'] = false,			-- only show bar1/bar2 when shift key is down
}


C['auras'] = {
	['position'] = {'TOPRIGHT', UIParent, 'TOPRIGHT', -290, -36},
	['buffSize'] = 42,
	['debuffSize'] = 50,
	['paddingX'] = 5,
	['paddingY'] = 8,
	['buffPerRow'] = 10,
}


C['maps'] = {
	['worldMapScale'] = 1,
	['miniMapScale'] = 1,
	['miniMapPosition'] = { 'TOPRIGHT', UIParent, 'TOPRIGHT', -22, 0 },
	['miniMapSize'] = 256,
	['whoPings'] = true,
	['mapReveal'] = true,
}


C['blizzard'] = {
	['hideBossBanner'] = true,
	['hideTalkingHead'] = true,
}


C['misc'] = {
	['uiScale'] = 1,
	['uiScaleAuto'] = true,

	['flashCursor'] = true,

	
	['mailButton'] = true, 
	['undressButton'] = true, 
	['alreadyKnown'] = true,

	['autoScreenShot'] = true,			-- auto screenshot when achieved
	['autoActionCam'] = true,

	['cooldownpulse'] = true,
	['cooldownCount'] = true,
		['decimalCD'] = false,
		['CDFont'] = {'Interface\\AddOns\\FreeUI\\assets\\font\\supereffective.ttf', 16, 'OUTLINEMONOCHROME'},

	['rareAlert'] = true,
		['rareAlertNotify'] = true,
	['interruptAlert'] = true,
		['interruptSound'] = true,
		['interruptNotify'] = true,
		['dispelSound'] = true,
		['dispelNotify'] = true,
	['usefulSpellAlert'] = true,		-- feast/bot/portal/summon/refreshmenttable/soulwell/toy
	['resAlert'] = true,				-- combat res
	['sappedAlert'] = true,

	['autoSetRole'] = true,				-- automatically set role and hide dialog where possible
		['autoSetRole_useSpec'] = true,		-- attempt to set role based on your current spec
		['autoSetRole_verbose'] = true, 	-- tells you what happens when setting role

	['autoRepair'] = true,				-- automatically repair items
		['autoRepair_guild'] = true, 		-- use guild funds for auto repairs

	['autoAccept'] = false, 			-- auto accept invites from friends and guildies

	['missingStats'] = true,
	['PVPSound'] = true,

	['clickCast'] = true,
	['fasterLooting'] = true,

	['objectiveTracker_height'] = 800,
	['objectiveTracker_width'] = 250,
}


C['camera'] = {
	['speed'] = 50,
	['increment'] = 3,
	['distance'] = 50,
}


C['bags'] = {
	['itemSlotSize'] = 38,
	['sizes'] = {
		bags = {
			columnsSmall = 8,
			columnsLarge = 10,
			largeItemCount = 64,
		},
		bank = {
			columnsSmall = 10,
			columnsLarge = 12,
			largeItemCount = 96,
		},
	},
}

C['infoBar'] = {
	['enable'] = true,
	['height'] = 16,
	['enableButtons'] = true,			-- show buttons for quick access on the menu bar
		['buttons_mouseover'] = true,			-- only on mouseover
}


C['tooltip'] = {
	['enable'] = true,		-- enable tooltip and modules
	['anchorCursor'] = false,		-- tooltip at mouse
	['tipPosition'] = {'BOTTOMRIGHT', -30, 30},	-- tooltip position
	
	['hidePVP'] = false,
	['hideFaction'] = true,
	['hideTitle'] = true,
	['hideRealm'] = true,
	['hideGuildRank'] = true,

	['fadeOnUnit'] = false,
	['combatHide'] = false,

	['ilvlspec'] = true,
	['extraInfo'] = true,
	['azeriteTrait'] = true,
	['borderColor'] = true,		-- item tooltip border colored by item quality

	['clearTip'] = true,
}


C['chat'] = {
	['position'] = {'BOTTOMLEFT', UIParent, 'BOTTOMLEFT', 50, 50},
	['lockPosition'] = true,
	['sticky'] = true,
	['itemLinkLevel'] = true,
	['spamageMeters'] = true,
	['whisperAlert'] = true,
	['minimize'] = true,
	['outline'] = false,
	['timeStamp'] = true,

	['enableFilter'] = true,
	['keyWordMatch'] = 1,
	['blockAddonAlert'] = true,
	['symbols'] = {'`', '～', '＠', '＃', '^', '＊', '！', '？', '。', '|', ' ', '—', '——', '￥', '’', '‘', '“', '”', '【', '】', '『', '』', '《', '》', '〈', '〉', '（', '）', '〔', '〕', '、', '，', '：', ',', '_', '/', '~', '-'},
	['filterList'] = '',	-- blacklist keywords
	['addonBlockList'] = {
		'任务进度提示%s?[:：]', '%[接受任务%]', '%(任务完成%)', '<大脚组队提示>', '<大脚团队提示>', '【爱不易】', 'EUI:', 'EUI_RaidCD', '打断:.+|Hspell', 'PS 死亡: .+>', '%*%*.+%*%*',
		'<iLvl>', ('%-'):rep(30), '<小队物品等级:.+>', '<LFG>', '进度:', '属性通报', 'blizzard%.cn.+%.vip'
		},
}


C['unitframes'] = {
	['enable'] = true, 						-- enable the unit frames and their included modules

	['transMode'] = true,
		['transModeAlpha'] = .1,
		['healthClassColor'] = true,
		['powerTypeColor'] = true,

	['gradient'] = true,					-- gradient mode

	['portrait'] = true,					-- enable portrait on player/target frame
		['portraitAlpha'] = .1,

	['spellRange'] = true,					-- spell range support for target/focus/boss
		['spellRangeAlpha'] = .4,

	['classPower'] = true,					-- player's class resources (like Chi Orbs or Holy Power) and combo points
		['classPower_height'] = 2,

	['classMod_havoc'] = true,	 			-- set power bar to red if power below 40(chaos strike)

	['threat'] = true,						-- threat indicator for party/raid frames
	['healthPrediction'] = false, 			-- incoming heals and heal/damage absorbs
	['dispellable'] = true,					-- Highlights debuffs that are dispelable by the player
	
	['castbar'] = true,						-- enable cast bar
		['cbSeparate'] = false,				-- true for a separate player cast bar
		['cbCastingColor'] = {77/255, 183/255, 219/255},
		['cbChannelingColor'] = {77/255, 183/255, 219/255},
		['cbnotInterruptibleColor'] = {160/255, 159/255, 161/255},
		['cbCompleteColor'] = {63/255, 161/255, 124/255},
		['cbFailColor'] = {187/255, 99/255, 110/255},
		['cbHeight'] = 14,
		['cbName'] = false,
		['cbTimer'] = false,

	['enableGroup'] = true,					-- enable party/raid frames
		['showRaidFrames'] = true, 				-- show the raid frames
		['limitRaidSize'] = false, 				-- show a maximum of 25 players in a raid
		['partyNameAlways'] = false,			-- show name on party/raid frames
		['partyMissingHealth'] = false,			-- show missing health on party/raid frames
	['enableBoss'] = true,					-- enable boss frames
	['enableArena'] = true,					-- enable arena/flag carrier frames

	['debuffbyPlayer'] = true,				-- only show target debuffs casted by player

	['focuser'] = true,						-- shift + left click on unitframes/models/nameplates to set focus

	['player_pos'] = {'CENTER', UIParent, 'CENTER', 0, -380},						-- player unitframe position
	['player_pos_healer'] = {'CENTER', UIParent, 'CENTER', 0, -380},				-- player unitframe position for healer layout(WIP)
	['player_width'] = 200,
	['player_height'] = 14,

	['pet_pos'] = {'RIGHT', 'oUF_FreePlayer', 'LEFT', -5, 0},						-- pet unitframe position
	['pet_width'] = 68,
	['pet_height'] = 14,

	['useFrameVisibility'] = false,													-- hide palyer/pet unitframes for defualt

	['target_pos'] = {'LEFT', 'oUF_FreePlayer', 'RIGHT', 100, 60},					-- target unitframe position
	['target_width'] = 220,
	['target_height'] = 16,

	['targettarget_pos'] = {'LEFT', 'oUF_FreeTarget', 'RIGHT', 6, 0},					-- target target unitframe position
	['targettarget_width'] = 80,
	['targettarget_height'] = 16,

	['focus_pos'] = {'LEFT', 'oUF_FreePlayer', 'RIGHT', 100, -60},					-- focus unitframe position
	['focus_width'] = 106,
	['focus_height'] = 16,

	['focustarget_pos'] = {'LEFT', 'oUF_FreeFocus', 'RIGHT', 6, 0},					-- focus target unitframe position
	['focustarget_width'] = 106,
	['focustarget_height'] = 16,

	['party_pos'] = {'BOTTOMRIGHT', 'oUF_FreePlayer', 'BOTTOMLEFT', -100, 60},		-- party unitframe position
	['party_width'] = 90,
	['party_height'] = 38,

	['raid_pos'] = {'TOPRIGHT', 'oUF_FreePlayer', 'TOPLEFT', -100, 140},			-- raid unitframe position
	['raid_width'] = 58,
	['raid_height'] = 32,

	['boss_pos'] = {'LEFT', 'oUF_FreeTarget', 'RIGHT', 120, 160},					-- boss unitframe position
	['boss_width'] = 166,
	['boss_height'] = 20,

	['arena_pos'] = {'RIGHT', 'oUF_FreePlayer', 'LEFT', -400, 249},					-- arena unitframe position
	['arena_width'] = 166,
	['arena_height'] = 16,
	
	['power_height'] = 2,
	['altpower_height'] = 2,
}



-- [[ Aura Filters ]]

-- ignored debuffs on party/raid frames
C['ignoredDebuffs'] = {
	[57724] = true, 	-- Sated
	[57723] = true,  	-- Exhaustion
	[80354] = true,  	-- Temporal Displacement
	[41425] = true,  	-- Hypothermia
	[95809] = true,  	-- Insanity
	[36032] = true,  	-- Arcane Blast
	[26013] = true,  	-- Deserter
	[95223] = true,  	-- Recently Mass Resurrected
	[97821] = true,  	-- Void-Touched (death knight resurrect)
	[36893] = true,  	-- Transporter Malfunction
	[36895] = true,  	-- Transporter Malfunction
	[36897] = true,  	-- Transporter Malfunction
	[36899] = true,  	-- Transporter Malfunction
	[36900] = true,  	-- Soul Split: Evil!
	[36901] = true,  	-- Soul Split: Good
	[25163] = true,  	-- Disgusting Oozeling Aura
	[85178] = true,  	-- Shrink (Deviate Fish)
	[8064] = true,   	-- Sleepy (Deviate Fish)
	[8067] = true,   	-- Party Time! (Deviate Fish)
	[24755] = true,  	-- Tricked or Treated (Hallow's End)
	[42966] = true, 	-- Upset Tummy (Hallow's End)
	[89798] = true, 	-- Master Adventurer Award (Maloriak kill title)
	[6788] = true,   	-- Weakened Soul
	[92331] = true, 	-- Blind Spot (Jar of Ancient Remedies)
	[71041] = true, 	-- Dungeon Deserter
	[26218] = true,  	-- Mistletoe
	[117870] = true,	-- Touch of the Titans
	[173658] = true, 	-- Delvar Ironfist defeated
	[173659] = true, 	-- Talonpriest Ishaal defeated
	[173661] = true, 	-- Vivianne defeated
	[173679] = true, 	-- Leorajh defeated
	[173649] = true, 	-- Tormmok defeated
	[173660] = true, 	-- Aeda Brightdawn defeated
	[173657] = true, 	-- Defender Illona defeated
	[206151] = true, 	-- 挑战者的负担
	[260738] = true, 	-- 艾泽里特残渣
	[279737] = true,
	[264689] = true,
}

-- buffs cast by the player on party/raid frames
C['myBuffs'] = {
	[774] = true,		-- 回春
	[8936] = true,		-- 愈合
	[33763] = true,		-- 生命绽放
	[48438] = true,		-- 野性成长
	[155777] = true,	-- 萌芽
	[102352] = true,	-- 塞纳里奥结界
	[200389] = true, 	-- 栽培

	[34477] = true, 	-- 误导

	[57934] = true, 	-- 嫁祸

	[12975] = true,		-- 援护
	[114030] = true, 	-- 警戒

	[61295] = true, 	-- 激流

	[1044] = true,		-- 自由祝福
	[6940] = true,		-- 牺牲祝福
	[25771] = true,		-- 自律
	[53563] = true,		-- 圣光道标
	[156910] = true,	-- 信仰道标
	[223306] = true,	-- 赋予信仰
	[200025] = true,	-- 美德道标
	[200654] = true,	-- 提尔的拯救
	[243174] = true, 	-- 神圣黎明

	[17] = true,		-- 真言术盾
	[139] = true,		-- 恢复
	[41635] = true,		-- 愈合祷言
	[47788] = true,		-- 守护之魂
	[194384] = true,	-- 救赎
	[152118] = true,	-- 意志洞悉
	[208065] = true, 	-- 图雷之光

	[119611] = true,	-- 复苏之雾
	[116849] = true,	-- 作茧缚命
	[124682] = true,	-- 氤氲之雾
	[124081] = true,	-- 禅意波
	[191840] = true,	-- 精华之泉
	[115175] = true, 	-- 抚慰之雾
}

-- buffs cast by anyone on party/raid frames
C['allBuffs'] = {
	[642] = true,		-- 圣盾术
	[1022] = true,		-- 保护祝福
	[27827] = true,		-- 救赎之魂
	[98008] = true,		-- 灵魂链接
	[31821] = true,		-- 光环掌握
	[97463] = true,		-- 命令怒吼
	[81782] = true,		-- 真言术障
	[33206] = true,		-- 痛苦压制
	[45438] = true,		-- 冰箱
	[204018] = true,	-- 破咒祝福
	[204150] = true,	-- 圣光护盾
	[102342] = true,	-- 铁木树皮
	[209426] = true,	-- 黑暗
	[186265] = true, 	-- 灵龟守护
}
