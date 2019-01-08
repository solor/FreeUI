local F, C = unpack(select(2, ...))

C.themes["Blizzard_PVPUI"] = function()
	local r, g, b = C.r, C.g, C.b

	local PVPQueueFrame = PVPQueueFrame
	local HonorFrame = HonorFrame
	local ConquestFrame = ConquestFrame

	-- Category buttons

	for i = 1, 3 do
		local bu = PVPQueueFrame["CategoryButton"..i]
		local icon = bu.Icon
		local cu = bu.CurrencyDisplay

		bu.Ring:Hide()

		F.Reskin(bu, true)

		bu.Background:SetAllPoints()
		bu.Background:SetColorTexture(r, g, b, .25)
		bu.Background:Hide()

		icon:SetTexCoord(unpack(C.TexCoord))
		icon:SetPoint("LEFT", bu, "LEFT")
		icon:SetDrawLayer("OVERLAY")
		icon.bg = F.CreateBG(icon)
		--icon.bg:SetDrawLayer("ARTWORK")

		if cu then
			local ic = cu.Icon

			ic:SetSize(16, 16)
			ic:SetPoint("TOPLEFT", bu.Name, "BOTTOMLEFT", 0, -8)
			cu.Amount:SetPoint("LEFT", ic, "RIGHT", 4, 0)

			ic:SetTexCoord(unpack(C.TexCoord))
			ic.bg = F.CreateBG(ic)
			--ic.bg:SetDrawLayer("BACKGROUND", 1)
		end
	end

	PVPQueueFrame.CategoryButton1.Icon:SetTexture("Interface\\Icons\\achievement_bg_winwsg")
	PVPQueueFrame.CategoryButton2.Icon:SetTexture("Interface\\Icons\\achievement_bg_killxenemies_generalsroom")
	PVPQueueFrame.CategoryButton3.Icon:SetTexture("Interface\\Icons\\ability_warrior_offensivestance")

	hooksecurefunc("PVPQueueFrame_SelectButton", function(index)
		local self = PVPQueueFrame
		for i = 1, 3 do
			local bu = self["CategoryButton"..i]
			if i == index then
				bu.Background:Show()
			else
				bu.Background:Hide()
			end
		end
	end)

	PVPQueueFrame.CategoryButton1.Background:Show()
	F.StripTextures(PVPQueueFrame.HonorInset)
	F.RemoveSlice(PVPQueueFrame.HonorInset)

	local popup = PVPQueueFrame.NewSeasonPopup
	F.Reskin(popup.Leave)
	popup.NewSeason:SetTextColor(1, .8, 0)
	popup.SeasonDescription:SetTextColor(1, 1, 1)
	popup.SeasonDescription2:SetTextColor(1, 1, 1)
	local SeasonRewardFrame = SeasonRewardFrame
	SeasonRewardFrame.CircleMask:Hide()
	SeasonRewardFrame.Ring:Hide()
	F.ReskinIcon(SeasonRewardFrame.Icon)
	select(3, SeasonRewardFrame:GetRegions()):SetTextColor(1, .8, 0)

	-- Honor frame

	local BonusFrame = HonorFrame.BonusFrame

	HonorFrame.Inset:Hide()
	BonusFrame.WorldBattlesTexture:Hide()
	BonusFrame.ShadowOverlay:Hide()

	for _, bonusButton in pairs({"RandomBGButton", "RandomEpicBGButton", "Arena1Button", "BrawlButton"}) do
		local bu = BonusFrame[bonusButton]
		F.Reskin(bu, true)
		bu.SelectedTexture:SetDrawLayer("BACKGROUND")
		bu.SelectedTexture:SetColorTexture(r, g, b, .25)
		bu.SelectedTexture:SetAllPoints()

		local reward = bu.Reward
		if reward then
			reward.Border:Hide()
			F.ReskinIcon(reward.Icon)
		end
	end

	local function reskinConquestBar(bar)
		F.StripTextures(bar.ConquestBar)
		F.CreateBDFrame(bar.ConquestBar, .25)
		bar.ConquestBar:SetStatusBarTexture(C.media.sbTex)
		bar.ConquestBar:SetStatusBarColor(219/255, 34/255, 70/255)
		--bar.ConquestBar:GetStatusBarTexture():SetGradient("VERTICAL", 1, .8, 0, 6, .4, 0)
	end
	reskinConquestBar(HonorFrame)

	-- Role buttons

	local function styleRole(f)
		f:DisableDrawLayer("BACKGROUND")
		f:DisableDrawLayer("BORDER")

		for _, roleButton in pairs({f.HealerIcon, f.TankIcon, f.DPSIcon}) do
			roleButton.cover:SetTexture(C.media.roleIcons)
			roleButton:SetNormalTexture(C.media.roleIcons)
			roleButton.checkButton:SetFrameLevel(roleButton:GetFrameLevel() + 2)
			local bg = F.CreateBDFrame(roleButton, 1)
			bg:SetPoint("TOPLEFT", roleButton, 3, -2)
			bg:SetPoint("BOTTOMRIGHT", roleButton, -3, 4)

			F.ReskinCheck(roleButton.checkButton)
		end
	end
	styleRole(HonorFrame)
	styleRole(ConquestFrame)

	-- Honor frame specific

	for _, bu in pairs(HonorFrame.SpecificFrame.buttons) do
		bu.Bg:Hide()
		bu.Border:Hide()

		bu:SetNormalTexture("")
		bu:SetHighlightTexture("")

		local bg = F.CreateBDFrame(bu, 0)
		bg:SetPoint("TOPLEFT", 2, 0)
		bg:SetPoint("BOTTOMRIGHT", -1, 2)

		bu.tex = F.CreateGradient(bu)
		bu.tex:SetDrawLayer("BACKGROUND")
		bu.tex:SetPoint("TOPLEFT", bg, C.Mult, -C.Mult)
		bu.tex:SetPoint("BOTTOMRIGHT", bg, -C.Mult, C.Mult)

		bu.SelectedTexture:SetDrawLayer("BACKGROUND")
		bu.SelectedTexture:SetColorTexture(r, g, b, .25)
		bu.SelectedTexture:SetAllPoints(bu.tex)

		bu.Icon:SetTexCoord(unpack(C.TexCoord))
		bu.Icon.bg = F.CreateBG(bu.Icon)
		--bu.Icon.bg:SetDrawLayer("BACKGROUND", 1)
		bu.Icon:SetPoint("TOPLEFT", 5, -3)
	end

	-- Conquest Frame

	ConquestFrame.Inset:Hide()
	ConquestFrame.RatedBGTexture:Hide()
	ConquestFrame.ShadowOverlay:Hide()

	F.ReskinTooltip(ConquestTooltip)

	local function ConquestFrameButton_OnEnter(self)
		ConquestTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 1, 0)
	end

	ConquestFrame.Arena2v2:HookScript("OnEnter", ConquestFrameButton_OnEnter)
	ConquestFrame.Arena3v3:HookScript("OnEnter", ConquestFrameButton_OnEnter)
	ConquestFrame.RatedBG:HookScript("OnEnter", ConquestFrameButton_OnEnter)

	for _, bu in pairs({ConquestFrame.Arena2v2, ConquestFrame.Arena3v3, ConquestFrame.RatedBG}) do
		F.Reskin(bu, true)
		local reward = bu.Reward
		if reward then
			reward.Border:Hide()
			F.ReskinIcon(reward.Icon)
		end

		bu.SelectedTexture:SetDrawLayer("BACKGROUND")
		bu.SelectedTexture:SetColorTexture(r, g, b, .25)
		bu.SelectedTexture:SetAllPoints()
	end

	ConquestFrame.Arena3v3:SetPoint("TOP", ConquestFrame.Arena2v2, "BOTTOM", 0, -1)
	reskinConquestBar(ConquestFrame)

	-- Main style

	F.Reskin(HonorFrame.QueueButton)
	F.Reskin(ConquestFrame.JoinButton)
	F.ReskinDropDown(HonorFrameTypeDropDown)
	F.ReskinScroll(HonorFrameSpecificFrameScrollBar)
end