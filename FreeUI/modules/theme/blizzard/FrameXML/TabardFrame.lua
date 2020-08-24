local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
	if not FreeDB['theme']['reskin_blizz'] then return end

	F.ReskinPortraitFrame(TabardFrame)
	TabardFrameMoneyInset:Hide()
	TabardFrameMoneyBg:Hide()
	F.CreateBD(TabardFrameCostFrame, .25)
	F.Reskin(TabardFrameAcceptButton)
	F.Reskin(TabardFrameCancelButton)
	F.ReskinArrow(TabardCharacterModelRotateLeftButton, "left")
	F.ReskinArrow(TabardCharacterModelRotateRightButton, "right")
	TabardCharacterModelRotateRightButton:SetPoint("TOPLEFT", TabardCharacterModelRotateLeftButton, "TOPRIGHT", 1, 0)

	TabardFrameCustomizationBorder:Hide()
	for i = 1, 5 do
		F.StripTextures(_G["TabardFrameCustomization"..i])
		F.ReskinArrow(_G["TabardFrameCustomization"..i.."LeftButton"], "left")
		F.ReskinArrow(_G["TabardFrameCustomization"..i.."RightButton"], "right")
	end
end)
