local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
	if not FreeDB['theme']['reskin_blizz'] then return end

	GuildRegistrarFrameEditBox:SetHeight(20)
	AvailableServicesText:SetTextColor(1, 1, 1)
	AvailableServicesText:SetShadowColor(0, 0, 0)

	F.ReskinPortraitFrame(GuildRegistrarFrame)
	GuildRegistrarFrameEditBox:DisableDrawLayer("BACKGROUND")
	F.CreateBDFrame(GuildRegistrarFrameEditBox, .25)
	F.Reskin(GuildRegistrarFrameGoodbyeButton)
	F.Reskin(GuildRegistrarFramePurchaseButton)
	F.Reskin(GuildRegistrarFrameCancelButton)
end)
