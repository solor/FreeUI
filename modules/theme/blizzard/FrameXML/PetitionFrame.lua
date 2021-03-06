local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
	if not _G.FREE_ADB.ReskinBlizz then return end

	F.ReskinPortraitFrame(PetitionFrame)
	F.Reskin(PetitionFrameSignButton)
	F.Reskin(PetitionFrameRequestButton)
	F.Reskin(PetitionFrameRenameButton)
	F.Reskin(PetitionFrameCancelButton)

	PetitionFrameCharterTitle:SetTextColor(1, .8, 0)
	PetitionFrameCharterTitle:SetShadowColor(0, 0, 0)
	PetitionFrameMasterTitle:SetTextColor(1, .8, 0)
	PetitionFrameMasterTitle:SetShadowColor(0, 0, 0)
	PetitionFrameMemberTitle:SetTextColor(1, .8, 0)
	PetitionFrameMemberTitle:SetShadowColor(0, 0, 0)
end)
