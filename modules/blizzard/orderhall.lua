local _G = _G
local unpack = unpack
local select = select
local ipairs = ipairs
local format = format
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded
local IsShiftKeyDown = IsShiftKeyDown
local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local C_Garrison_GetCurrencyTypes = C_Garrison.GetCurrencyTypes
local C_Garrison_GetClassSpecCategoryInfo = C_Garrison.GetClassSpecCategoryInfo
local C_Garrison_RequestClassSpecCategoryInfo = C_Garrison.RequestClassSpecCategoryInfo
local LE_GARRISON_TYPE_7_0 = Enum.GarrisonType.Type_7_0
local LE_FOLLOWER_TYPE_GARRISON_7_0 = Enum.GarrisonFollowerType.FollowerType_7_0

local F, C, L = unpack(select(2, ...))
local BLIZZARD = F:GetModule('Blizzard')

function BLIZZARD:OrderHall_CreateIcon()
    local hall = CreateFrame('Frame', 'FreeUI_OrderHallIcon', _G.UIParent)
    hall:SetSize(50, 50)
    hall:SetPoint('TOP', 0, -30)
    hall:SetFrameStrata('HIGH')
    hall:Hide()
    F.CreateMF(hall, nil, true)
    F.RestoreMF(hall)
    BLIZZARD.OrderHallIcon = hall

    hall.Icon = hall:CreateTexture(nil, 'ARTWORK')
    hall.Icon:SetAllPoints()
    hall.Icon:SetTexture('Interface\\TargetingFrame\\UI-Classes-Circles')
    hall.Icon:SetTexCoord(unpack(_G.CLASS_ICON_TCOORDS[C.MyClass]))
    hall.Category = {}

    hall:SetScript('OnEnter', BLIZZARD.OrderHall_OnEnter)
    hall:SetScript('OnLeave', BLIZZARD.OrderHall_OnLeave)
    hooksecurefunc(_G.OrderHallCommandBar, 'SetShown', function(_, state)
        hall:SetShown(state)
    end)

    -- Default objects
    F.HideOption(_G.OrderHallCommandBar)
    F.HideObject(_G.OrderHallCommandBar.CurrencyHitTest)
end

function BLIZZARD:OrderHall_Refresh()
    C_Garrison_RequestClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
    local currency = C_Garrison_GetCurrencyTypes(LE_GARRISON_TYPE_7_0)
    local info = C_CurrencyInfo_GetCurrencyInfo(currency)
    self.name = info.name
    self.amount = info.quantity
    self.texture = info.iconFileID

    local categoryInfo = C_Garrison_GetClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
    for index, info in ipairs(categoryInfo) do
        local category = self.Category
        if not category[index] then
            category[index] = {}
        end
        category[index].name = info.name
        category[index].count = info.count
        category[index].limit = info.limit
        category[index].description = info.description
        category[index].icon = info.icon
    end
    self.numCategory = #categoryInfo
end

function BLIZZARD:OrderHall_OnShiftDown(btn)
    if btn == 'LSHIFT' then
        BLIZZARD.OrderHall_OnEnter(BLIZZARD.OrderHallIcon)
    end
end

local function getIconString(texture)
    return format('|T%s:12:12:0:0:64:64:5:59:5:59|t ', texture)
end

function BLIZZARD:OrderHall_OnEnter()
    BLIZZARD.OrderHall_Refresh(self)

    _G.GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT', 5, -5)
    _G.GameTooltip:ClearLines()
    _G.GameTooltip:AddLine(C.MyColor .. _G['ORDER_HALL_' .. C.MyClass])
    _G.GameTooltip:AddLine(' ')
    _G.GameTooltip:AddDoubleLine(getIconString(self.texture) .. self.name, self.amount, 1, 1, 1, 1, 1, 1)

    local blank
    for i = 1, self.numCategory do
        if not blank then
            _G.GameTooltip:AddLine(' ')
            blank = true
        end
        local category = self.Category[i]
        if category then
            _G.GameTooltip:AddDoubleLine(getIconString(category.icon) .. category.name, category.count .. '/' .. category.limit, 1, 1, 1, 1, 1, 1)
            if IsShiftKeyDown() then
                _G.GameTooltip:AddLine(category.description, .6, .8, 1, 1)
            end
        end
    end

    _G.GameTooltip:AddDoubleLine(' ', C.LineString)
    _G.GameTooltip:AddDoubleLine(' ', L['Hold SHIFT for details'], 1, 1, 1, .6, .8, 1)
    _G.GameTooltip:Show()

    F:RegisterEvent('MODIFIER_STATE_CHANGED', BLIZZARD.OrderHall_OnShiftDown)
end

function BLIZZARD:OrderHall_OnLeave()
    _G.GameTooltip:Hide()
    F:UnregisterEvent('MODIFIER_STATE_CHANGED', BLIZZARD.OrderHall_OnShiftDown)
end

function BLIZZARD:OrderHall_OnLoad(addon)
    if addon == 'Blizzard_OrderHallUI' then
        BLIZZARD:OrderHall_CreateIcon()
        F:UnregisterEvent(self, BLIZZARD.OrderHall_OnLoad)
    end
end

function BLIZZARD:OrderHall_OnInit()
    if not C.DB.General.OrderHallIcon then
        return
    end

    if IsAddOnLoaded('Blizzard_OrderHallUI') then
        BLIZZARD:OrderHall_CreateIcon()
    else
        F:RegisterEvent('ADDON_LOADED', BLIZZARD.OrderHall_OnLoad)
    end
end

BLIZZARD:RegisterBlizz('OrderHallIcon', BLIZZARD.OrderHall_OnInit)
