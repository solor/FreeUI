local _G = _G
local unpack = unpack
local select = select
local tinsert = tinsert
local hooksecurefunc = hooksecurefunc
local FCF_GetCurrentChatFrame = FCF_GetCurrentChatFrame

local F, C = unpack(select(2, ...))

local function reskinPickerOptions(self)
    local scrollTarget = self.ScrollBox.ScrollTarget
    if scrollTarget then
        for i = 1, scrollTarget:GetNumChildren() do
            local child = select(i, scrollTarget:GetChildren())
            if not child.styled then
                child.UnCheck:SetTexture(nil)
                child.Highlight:SetColorTexture(C.r, C.g, C.b, .25)

                local check = child.Check
                check:SetColorTexture(C.r, C.g, C.b, .6)
                check:SetSize(10, 10)
                check:SetPoint('LEFT', 2, 0)
                F.CreateBDFrame(check, .25)

                child.styled = true
            end
        end
    end
end

local function ReskinVoicePicker(voicePicker)
    local customFrame = voicePicker:GetChildren()
    F.StripTextures(customFrame)
    F.SetBD(customFrame, .7)
    voicePicker:HookScript('OnShow', reskinPickerOptions)
end

tinsert(
    C.BlizzThemes,
    function()
        F.StripTextures(_G.ChatConfigFrame)
        F.SetBD(_G.ChatConfigFrame)
        F.StripTextures(_G.ChatConfigFrame.Header)

        hooksecurefunc(
            'ChatConfig_UpdateCheckboxes',
            function(frame)
                if not FCF_GetCurrentChatFrame() then
                    return
                end

                local nameString = frame:GetName() .. 'CheckBox'
                for index in ipairs(frame.checkBoxTable) do
                    local checkBoxName = nameString .. index
                    local checkbox = _G[checkBoxName]
                    if checkbox and not checkbox.styled then
                        checkbox:SetBackdrop(nil)
                        local bg = F.CreateBDFrame(checkbox, .25)
                        bg:SetInside()
                        F.ReskinCheck(_G[checkBoxName .. 'Check'])

                        checkbox.styled = true
                    end
                end
            end
        )

        hooksecurefunc(
            'ChatConfig_CreateTieredCheckboxes',
            function(frame, checkBoxTable)
                if frame.styled then
                    return
                end

                local nameString = frame:GetName() .. 'CheckBox'
                for index, value in ipairs(checkBoxTable) do
                    local checkBoxName = nameString .. index
                    F.ReskinCheck(_G[checkBoxName])

                    if value.subTypes then
                        for i in ipairs(value.subTypes) do
                            F.ReskinCheck(_G[checkBoxName .. '_' .. i])
                        end
                    end
                end

                frame.styled = true
            end
        )

        hooksecurefunc(
            _G.ChatConfigFrameChatTabManager,
            'UpdateWidth',
            function(self)
                for tab in self.tabPool:EnumerateActive() do
                    if not tab.styled then
                        F.StripTextures(tab)

                        tab.styled = true
                    end
                end
            end
        )

        for i = 1, 5 do
            F.StripTextures(_G['CombatConfigTab' .. i])
        end

        local line = _G.ChatConfigFrame:CreateTexture()
        line:SetSize(C.Mult, 460)
        line:SetPoint('TOPLEFT', _G.ChatConfigCategoryFrame, 'TOPRIGHT')
        line:SetColorTexture(1, 1, 1, .25)

        local backdrops = {
            _G.ChatConfigCategoryFrame,
            _G.ChatConfigBackgroundFrame,
            _G.ChatConfigCombatSettingsFilters,
            _G.CombatConfigColorsHighlighting,
            _G.CombatConfigColorsColorizeUnitName,
            _G.CombatConfigColorsColorizeSpellNames,
            _G.CombatConfigColorsColorizeDamageNumber,
            _G.CombatConfigColorsColorizeDamageSchool,
            _G.CombatConfigColorsColorizeEntireLine,
            _G.ChatConfigChatSettingsLeft,
            _G.ChatConfigOtherSettingsCombat,
            _G.ChatConfigOtherSettingsPVP,
            _G.ChatConfigOtherSettingsSystem,
            _G.ChatConfigOtherSettingsCreature,
            _G.ChatConfigChannelSettingsLeft,
            _G.CombatConfigMessageSourcesDoneBy,
            _G.CombatConfigColorsUnitColors,
            _G.CombatConfigMessageSourcesDoneTo
        }
        for _, frame in pairs(backdrops) do
            F.StripTextures(frame)
        end

        local combatBoxes = {
            _G.CombatConfigColorsHighlightingLine,
            _G.CombatConfigColorsHighlightingAbility,
            _G.CombatConfigColorsHighlightingDamage,
            _G.CombatConfigColorsHighlightingSchool,
            _G.CombatConfigColorsColorizeUnitNameCheck,
            _G.CombatConfigColorsColorizeSpellNamesCheck,
            _G.CombatConfigColorsColorizeSpellNamesSchoolColoring,
            _G.CombatConfigColorsColorizeDamageNumberCheck,
            _G.CombatConfigColorsColorizeDamageNumberSchoolColoring,
            _G.CombatConfigColorsColorizeDamageSchoolCheck,
            _G.CombatConfigColorsColorizeEntireLineCheck,
            _G.CombatConfigFormattingShowTimeStamp,
            _G.CombatConfigFormattingShowBraces,
            _G.CombatConfigFormattingUnitNames,
            _G.CombatConfigFormattingSpellNames,
            _G.CombatConfigFormattingItemNames,
            _G.CombatConfigFormattingFullText,
            _G.CombatConfigSettingsShowQuickButton,
            _G.CombatConfigSettingsSolo,
            _G.CombatConfigSettingsParty,
            _G.CombatConfigSettingsRaid
        }
        for _, box in pairs(combatBoxes) do
            F.ReskinCheck(box)
        end

        local bg = F.CreateBDFrame(_G.ChatConfigCombatSettingsFilters, .25)
        bg:SetPoint('TOPLEFT', 3, 0)
        bg:SetPoint('BOTTOMRIGHT', 0, 1)

        F.Reskin(_G.CombatLogDefaultButton)
        F.Reskin(_G.ChatConfigCombatSettingsFiltersCopyFilterButton)
        F.Reskin(_G.ChatConfigCombatSettingsFiltersAddFilterButton)
        F.Reskin(_G.ChatConfigCombatSettingsFiltersDeleteButton)
        F.Reskin(_G.CombatConfigSettingsSaveButton)
        F.Reskin(_G.ChatConfigFrameOkayButton)
        F.Reskin(_G.ChatConfigFrameDefaultButton)
        F.Reskin(_G.ChatConfigFrameRedockButton)
        F.ReskinArrow(_G.ChatConfigMoveFilterUpButton, 'up')
        F.ReskinArrow(_G.ChatConfigMoveFilterDownButton, 'down')
        F.ReskinInput(_G.CombatConfigSettingsNameEditBox)
        F.ReskinRadio(_G.CombatConfigColorsColorizeEntireLineBySource)
        F.ReskinRadio(_G.CombatConfigColorsColorizeEntireLineByTarget)
        F.ReskinColorSwatch(_G.CombatConfigColorsColorizeSpellNamesColorSwatch)
        F.ReskinColorSwatch(_G.CombatConfigColorsColorizeDamageNumberColorSwatch)
        F.ReskinScroll(_G.ChatConfigCombatSettingsFiltersScrollFrameScrollBar)

        _G.ChatConfigMoveFilterUpButton:SetSize(22, 22)
        _G.ChatConfigMoveFilterDownButton:SetSize(22, 22)

        _G.ChatConfigCombatSettingsFiltersAddFilterButton:SetPoint('RIGHT', _G.ChatConfigCombatSettingsFiltersDeleteButton, 'LEFT', -1, 0)
        _G.ChatConfigCombatSettingsFiltersCopyFilterButton:SetPoint('RIGHT', _G.ChatConfigCombatSettingsFiltersAddFilterButton, 'LEFT', -1, 0)
        _G.ChatConfigMoveFilterUpButton:SetPoint('TOPLEFT', _G.ChatConfigCombatSettingsFilters, 'BOTTOMLEFT', 3, 0)
        _G.ChatConfigMoveFilterDownButton:SetPoint('LEFT', _G.ChatConfigMoveFilterUpButton, 'RIGHT', 1, 0)

        -- TextToSpeech
        F.StripTextures(_G.TextToSpeechButton, 5)

        F.Reskin(_G.TextToSpeechFramePlaySampleButton)
        F.Reskin(_G.TextToSpeechFramePlaySampleAlternateButton)
        F.Reskin(_G.TextToSpeechDefaultButton)

        F.ReskinDropDown(_G.TextToSpeechFrameTtsVoiceDropdown)
        F.ReskinDropDown(_G.TextToSpeechFrameTtsVoiceAlternateDropdown)
        F.ReskinSlider(_G.TextToSpeechFrameAdjustRateSlider)
        F.ReskinSlider(_G.TextToSpeechFrameAdjustVolumeSlider)

        local checkboxes = {
            'PlayActivitySoundWhenNotFocusedCheckButton',
            'PlaySoundSeparatingChatLinesCheckButton',
            'AddCharacterNameToSpeechCheckButton',
            'NarrateMyMessagesCheckButton',
            'UseAlternateVoiceForSystemMessagesCheckButton'
        }
        for _, checkbox in pairs(checkboxes) do
            F.ReskinCheck(_G.TextToSpeechFramePanelContainer[checkbox])
        end

        hooksecurefunc(
            'TextToSpeechFrame_UpdateMessageCheckboxes',
            function(frame)
                local checkBoxTable = frame.checkBoxTable
                if checkBoxTable then
                    local checkBoxNameString = frame:GetName() .. 'CheckBox'
                    local checkBoxName, checkBox
                    for index in ipairs(checkBoxTable) do
                        checkBoxName = checkBoxNameString .. index
                        checkBox = _G[checkBoxName]
                        if checkBox and not checkBox.styled then
                            F.ReskinCheck(checkBox)
                            checkBox.styled = true
                        end
                    end
                end
            end
        )

        -- voice pickers
        ReskinVoicePicker(_G.TextToSpeechFrameTtsVoicePicker)
        ReskinVoicePicker(_G.TextToSpeechFrameTtsVoiceAlternatePicker)

        F.StripTextures(_G.ChatConfigTextToSpeechChannelSettingsLeft)
    end
)
