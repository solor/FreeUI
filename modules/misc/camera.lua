--[[
    Increases camera zoom speed
    Based on FasterCamera by Ketho
    https://www.wowinterface.com/downloads/info20483-FasterCamera.html
]]

local _G = _G
local unpack = unpack
local select = select
local GetCameraZoom = GetCameraZoom
local SetCVar = SetCVar
local ConsoleExec = ConsoleExec

local F, C = unpack(select(2, ...))
local EC = F:RegisterModule('EnhancedCamera')

local datas = {
    increment = 4,
    speed = 20,
    distance = 2.6,
    nearDistance = 5,
    nearIncrement = 1
}

local function CameraZoom(func, increment)
    -- anything not 1 could be a custom zoom increment from another addon
    if increment ~= 1 then
        func(increment)
    else
        local isCloseUp = GetCameraZoom() < datas.nearDistance and datas.increment > 1
        func(isCloseUp and datas.nearIncrement or datas.increment)
    end
end

local oldZoomIn = _G.CameraZoomIn
local oldZoomOut = _G.CameraZoomOut

function _G.CameraZoomIn(v)
    CameraZoom(oldZoomIn, v)
end

function _G.CameraZoomOut(v)
    CameraZoom(oldZoomOut, v)
end

function EC:OnEvent(event)
    if not C.DB.General.FasterZooming then
        return
    end
    F:Delay(1, function()
        -- not actually necessary to override from savedvars
        -- but better to do this if other addons also set it
        SetCVar('cameraDistanceMaxZoomFactor', datas.distance)
        SetCVar('cameraZoomSpeed', datas.speed)
    end)

    -- self:UnregisterEvent(event)
end

-- Camera action mode
local function Exec(cmd)
    ConsoleExec('ActionCam ' .. cmd)
end

function EC:UpdateActionCamera()
    if C.DB.General.ActionCamera then
        Exec('basic')
    else
        Exec('off')
    end
end

function EC:ActionCamera()
    _G.UIParent:UnregisterEvent('EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED')

    EC:UpdateActionCamera()
end

function EC:OnLogin()
    F:RegisterEvent('ADDON_LOADED', EC.OnEvent)
    F:RegisterEvent('PLAYER_ENTERING_WORLD', EC.ActionCamera)
end
