local _G = _G
local mod = mod
local format = format
local strmatch = strmatch
local strfind = strfind
local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local hooksecurefunc = hooksecurefunc
local SetItemButtonTextureVertexColor = SetItemButtonTextureVertexColor
local GetCurrentGuildBankTab = GetCurrentGuildBankTab
local GetGuildBankItemInfo = GetGuildBankItemInfo
local GetGuildBankItemLink = GetGuildBankItemLink
local GetMerchantNumItems = GetMerchantNumItems
local GetMerchantItemInfo = GetMerchantItemInfo
local GetMerchantItemLink = GetMerchantItemLink
local GetNumBuybackItems = GetNumBuybackItems
local GetBuybackItemInfo = GetBuybackItemInfo
local GetBuybackItemLink = GetBuybackItemLink
local C_PetJournal_GetNumCollectedInfo = C_PetJournal.GetNumCollectedInfo
local HybridScrollFrame_GetButtons = HybridScrollFrame_GetButtons
local LE_ITEM_CLASS_CONSUMABLE = LE_ITEM_CLASS_CONSUMABLE
local LE_ITEM_CLASS_RECIPE = LE_ITEM_CLASS_RECIPE
local LE_ITEM_CLASS_MISCELLANEOUS = LE_ITEM_CLASS_MISCELLANEOUS
local LE_ITEM_CLASS_ITEM_ENHANCEMENT = LE_ITEM_CLASS_ITEM_ENHANCEMENT
local LE_ITEM_CLASS_BATTLEPET = LE_ITEM_CLASS_BATTLEPET

local F = unpack(select(2, ...))

local COLOR = {
    r = .1,
    g = 1,
    b = .1
}
local knowables = {
    [LE_ITEM_CLASS_CONSUMABLE] = true,
    [LE_ITEM_CLASS_RECIPE] = true,
    [LE_ITEM_CLASS_MISCELLANEOUS] = true,
    [LE_ITEM_CLASS_ITEM_ENHANCEMENT] = true
}
local knowns = {}

local function isPetCollected(speciesID)
    if not speciesID or speciesID == 0 then
        return
    end
    local numOwned = C_PetJournal_GetNumCollectedInfo(speciesID)
    if numOwned > 0 then
        return true
    end
end

local function IsAlreadyKnown(link, index)
    if not link then
        return
    end

    local linkType, linkID = strmatch(link, '|H(%a+):(%d+)')
    linkID = tonumber(linkID)

    if linkType == 'battlepet' then
        return isPetCollected(linkID)
    elseif linkType == 'item' then
        local name, _, _, level, _, _, _, _, _, _, _, itemClassID = GetItemInfo(link)
        if not name then
            return
        end

        if itemClassID == LE_ITEM_CLASS_BATTLEPET and index then
            local speciesID = F.ScanTip:SetGuildBankItem(GetCurrentGuildBankTab(), index)
            return isPetCollected(speciesID)
        elseif F:GetModule('Tooltip').ConduitData[linkID] and F:GetModule('Tooltip').ConduitData[linkID] >= level then
            return true
        else
            if knowns[link] then
                return true
            end
            if not knowables[itemClassID] then
                return
            end

            F.ScanTip:SetOwner(_G.UIParent, 'ANCHOR_NONE')
            F.ScanTip:SetHyperlink(link)
            for i = 1, F.ScanTip:NumLines() do
                local text = _G['FreeUI_ScanTooltipTextLeft' .. i]:GetText() or ''
                if strfind(text, _G.COLLECTED) or text == _G.ITEM_SPELL_KNOWN then
                    knowns[link] = true
                    return true
                end
            end
        end
    end
end

-- merchant frame
local function Hook_UpdateMerchantInfo()
    local numItems = GetMerchantNumItems()
    for i = 1, _G.MERCHANT_ITEMS_PER_PAGE do
        local index = (_G.MerchantFrame.page - 1) * _G.MERCHANT_ITEMS_PER_PAGE + i
        if index > numItems then
            return
        end

        local button = _G['MerchantItem' .. i .. 'ItemButton']
        if button and button:IsShown() then
            local _, _, _, _, numAvailable, isUsable = GetMerchantItemInfo(index)
            if isUsable and IsAlreadyKnown(GetMerchantItemLink(index)) then
                local r, g, b = COLOR.r, COLOR.g, COLOR.b
                if numAvailable == 0 then
                    r, g, b = r * .5, g * .5, b * .5
                end
                SetItemButtonTextureVertexColor(button, r, g, b)
            end
        end
    end
end
hooksecurefunc('MerchantFrame_UpdateMerchantInfo', Hook_UpdateMerchantInfo)

local function Hook_UpdateBuybackInfo()
    local numItems = GetNumBuybackItems()
    for index = 1, _G.BUYBACK_ITEMS_PER_PAGE do
        if index > numItems then
            return
        end

        local button = _G['MerchantItem' .. index .. 'ItemButton']
        if button and button:IsShown() then
            local _, _, _, _, _, isUsable = GetBuybackItemInfo(index)
            if isUsable and IsAlreadyKnown(GetBuybackItemLink(index)) then
                SetItemButtonTextureVertexColor(button, COLOR.r, COLOR.g, COLOR.b)
            end
        end
    end
end
hooksecurefunc('MerchantFrame_UpdateBuybackInfo', Hook_UpdateBuybackInfo)

-- auction house
local function Hook_UpdateAuctionHouse(self)
    local numResults = self.getNumEntries()

    local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame)
    local buttonCount = #buttons
    local offset = self:GetScrollOffset()
    for i = 1, buttonCount do
        local visible = i + offset <= numResults
        local button = buttons[i]
        if visible then
            if button.rowData.itemKey.itemID then
                local itemLink
                if button.rowData.itemKey.itemID == 82800 then -- BattlePet
                    itemLink = format('|Hbattlepet:%d::::::|h[Dummy]|h', button.rowData.itemKey.battlePetSpeciesID)
                else -- Normal item
                    itemLink = format('item:%d', button.rowData.itemKey.itemID)
                end

                if itemLink and IsAlreadyKnown(itemLink) then
                    -- Highlight
                    button.SelectedHighlight:Show()
                    button.SelectedHighlight:SetVertexColor(COLOR.r, COLOR.g, COLOR.b)
                    button.SelectedHighlight:SetAlpha(.25)
                    -- Icon
                    button.cells[2].Icon:SetVertexColor(COLOR.r, COLOR.g, COLOR.b)
                    button.cells[2].IconBorder:SetVertexColor(COLOR.r, COLOR.g, COLOR.b)
                else
                    -- Highlight
                    button.SelectedHighlight:SetVertexColor(1, 1, 1)
                    -- Icon
                    button.cells[2].Icon:SetVertexColor(1, 1, 1)
                    button.cells[2].IconBorder:SetVertexColor(1, 1, 1)
                end
            end
        end
    end
end

-- guild bank frame
local function Hook_GuildBankUpdate()
    if _G.GuildBankFrame.mode ~= 'bank' then
        return
    end

    local tab = GetCurrentGuildBankTab()
    for i = 1, _G.MAX_GUILDBANK_SLOTS_PER_TAB do
        local index = mod(i, _G.NUM_SLOTS_PER_GUILDBANK_GROUP)
        if index == 0 then
            index = _G.NUM_SLOTS_PER_GUILDBANK_GROUP
        end

        local button = _G['GuildBankColumn' .. math.ceil((i - .5) / _G.NUM_SLOTS_PER_GUILDBANK_GROUP) .. 'Button' .. index]
        if button and button:IsShown() then
            local texture, _, locked = GetGuildBankItemInfo(tab, i)
            if texture and not locked then
                if IsAlreadyKnown(GetGuildBankItemLink(tab, i), i) then
                    SetItemButtonTextureVertexColor(button, COLOR.r, COLOR.g, COLOR.b)
                else
                    SetItemButtonTextureVertexColor(button, 1, 1, 1)
                end
            end
        end
    end
end

local hookCount = 0
local f = CreateFrame('Frame')
f:RegisterEvent('ADDON_LOADED')
f:SetScript(
    'OnEvent',
    function(_, event, addon)
        if addon == 'Blizzard_AuctionHouseUI' then
            hooksecurefunc(_G.AuctionHouseFrame.BrowseResultsFrame.ItemList, 'RefreshScrollFrame', Hook_UpdateAuctionHouse)
            hookCount = hookCount + 1
        elseif addon == 'Blizzard_GuildBankUI' then
            hooksecurefunc('GuildBankFrame_Update', Hook_GuildBankUpdate)
            hookCount = hookCount + 1
        end

        if hookCount >= 2 then
            f:UnregisterEvent(event)
        end
    end
)
