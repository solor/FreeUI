local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
	if not FreeDB['theme']['reskin_blizz'] then return end

	F.Reskin(SplashFrame.BottomCloseButton)
	F.ReskinClose(SplashFrame.TopCloseButton)

	SplashFrame.TopCloseButton:ClearAllPoints()
	SplashFrame.TopCloseButton:SetPoint("TOPRIGHT", SplashFrame, "TOPRIGHT", -18, -18)

	SplashFrame.Label:SetTextColor(1, .8, 0)
end)
