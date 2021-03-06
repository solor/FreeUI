local _G = _G
local unpack = unpack
local select = select
local strsplit = strsplit
local CreateFrame = CreateFrame
local HideUIPanel = HideUIPanel
local ShowUIPanel = ShowUIPanel
local IsModifiedClick = IsModifiedClick

local F = unpack(select(2, ...))
local TOOLTIP = F:GetModule('Tooltip')

local tips = {
    [1] = _G['ItemRefTooltip']
}

local types = {
    item = true,
    enchant = true,
    spell = true,
    quest = true,
    unit = true,
    talent = true,
    achievement = true,
    glyph = true,
    instancelock = true,
    currency = true,
}

local function CreateTip(link)
    for _, v in ipairs(tips) do
        for _, tip in ipairs(tips) do
            if tip:IsShown() and tip.link == link then
                tip.link = nil
                HideUIPanel(tip)
                return
            end
        end
        if not v:IsShown() then
            v.link = link
            return v
        end
    end

    local num = #tips + 1
    local tip = CreateFrame('GameTooltip', 'ItemRefTooltip' .. num, _G.UIParent, 'GameTooltipTemplate')
    if num == 2 then
        tip:SetPoint('LEFT', _G.ItemRefTooltip, 'RIGHT', 3, 0)
    else
        tip:SetPoint('LEFT', 'ItemRefTooltip' .. num - 1, 'RIGHT', 3, 0)
    end
    tip:SetSize(128, 64)
    tip:EnableMouse(true)
    tip:SetMovable(true)
    tip:SetClampedToScreen(true)
    tip:RegisterForDrag('LeftButton')
    tip:SetScript('OnDragStart', function(self)
        self:StartMoving()
    end)
    tip:SetScript('OnDragStop', function(self)
        self:StopMovingOrSizing()
    end)

    tip:SetBackdrop(nil)
    tip.SetBackdrop = F.Dummy
    if tip.BackdropFrame then
        tip.BackdropFrame:SetBackdrop(nil)
    end
    local bg = CreateFrame('Frame', nil, tip)
    bg:SetPoint('TOPLEFT')
    bg:SetPoint('BOTTOMRIGHT')
    bg:SetFrameLevel(tip:GetFrameLevel() - 1)
    F.SetBD(bg)

    local close = CreateFrame('Button', 'ItemRefTooltip' .. num .. 'CloseButton', tip)
    close:SetScript('OnClick', function()
        HideUIPanel(tip)
    end)
    F.ReskinClose(close)

    table.insert(_G.UISpecialFrames, tip:GetName())

    tip.link = link
    tips[num] = tip

    return tip
end

local function ShowTip(tip, link)
    ShowUIPanel(tip)
    if not tip:IsShown() then
        tip:SetOwner(_G.UIParent, 'ANCHOR_PRESERVE')
    end
    TOOLTIP.MultiShown = true
    tip:SetHyperlink(link)
    TOOLTIP.MultiShown = nil
end

local SetHyperlink = _G.ItemRefTooltip.SetHyperlink
function _G.ItemRefTooltip:SetHyperlink(link, ...)
    local handled = strsplit(':', link)
    if not IsModifiedClick() and handled and types[handled] and not TOOLTIP.MultiShown then
        local tip = CreateTip(link)
        if tip then
            ShowTip(tip, link)
        end
        return
    end

    SetHyperlink(self, link, ...)
end
