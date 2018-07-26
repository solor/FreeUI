local F, C, L = unpack(select(2, ...))

tinsert(C.themes["FreeUI"], function()
	if not C.themeconfig.chatBubbles then return end

	local function styleBubble(frame)
		for i = 1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if region:GetObjectType() == "Texture" then
				region:SetTexture(nil)
			elseif region:GetObjectType() == "FontString" then
				region:SetFont(C.font.normal, 20, "OUTLINE")
				region:SetShadowColor(0, 0, 0, 0)
			end
		end

		F.CreateBD(frame)
		F.CreateSD(frame)
		frame:SetScale(UIParent:GetScale())
	end

	local function findChatBubble(msg)
		local chatbubbles = C_ChatBubbles.GetAllChatBubbles()
		for index = 1, #chatbubbles do
			local chatbubble = chatbubbles[index]
			for i = 1, chatbubble:GetNumRegions() do
				local region = select(i, chatbubble:GetRegions())
				if region:GetObjectType() == "FontString" and region:GetText() == msg then
					return chatbubble
				end
			end
		end
	end

	local events = {
		CHAT_MSG_SAY = "chatBubbles",
		CHAT_MSG_YELL = "chatBubbles",
		CHAT_MSG_MONSTER_SAY = "chatBubbles",
		CHAT_MSG_MONSTER_YELL = "chatBubbles",
		CHAT_MSG_PARTY = "chatBubblesParty",
		CHAT_MSG_PARTY_LEADER = "chatBubblesParty",
		CHAT_MSG_MONSTER_PARTY = "chatBubblesParty",
	}

	local colors = {
		CHAT_MSG_SAY = {1, 1, 1},
		CHAT_MSG_YELL = {1, .25, .25},
		CHAT_MSG_PARTY = {.65, .65, 1},
		CHAT_MSG_PARTY_LEADER = {.65, .65, 1},
	}

	local bubbleHook = CreateFrame("Frame")
	for event in next, events do
		bubbleHook:RegisterEvent(event)
	end
	bubbleHook:SetScript("OnEvent", function(self, event, msg)
		if GetCVarBool(events[event]) then
			self.elapsed = 0
			self.msg = msg
			self.color = colors[event]
			self:Show()
		end
	end)

	bubbleHook:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		local chatbubble = findChatBubble(self.msg)
		if chatbubble or self.elapsed > .3 then
			self:Hide()
			if chatbubble and not chatbubble.styled then
				styleBubble(chatbubble)
				chatbubble.styled = true
			end

			if self.color and chatbubble.Shadow then
				chatbubble.Shadow:SetBackdropBorderColor(unpack(self.color))
			end
		end
	end)
	bubbleHook:Hide()
end)