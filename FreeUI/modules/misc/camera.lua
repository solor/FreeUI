local F, C = unpack(select(2, ...))
local MISC, cfg = F:GetModule('Misc'), C.General


function MISC:FasterCamera()
	if not cfg.faster_camera then return end

	local oldZoomIn = CameraZoomIn
	local oldZoomOut = CameraZoomOut
	local oldVehicleZoomIn = VehicleCameraZoomIn
	local oldVehicleZoomOut = VehicleCameraZoomOut
	local newZoomSpeed = 4

	function CameraZoomIn(distance)
		oldZoomIn(newZoomSpeed)
	end

	function CameraZoomOut(distance)
		oldZoomOut(newZoomSpeed)
	end

	function VehicleCameraZoomIn(distance)
		oldVehicleZoomIn(newZoomSpeed)
	end

	function VehicleCameraZoomOut(distance)
		oldVehicleZoomOut(newZoomSpeed)
	end
end

MISC:RegisterMisc("FasterCamera", MISC.FasterCamera)



UIParent:UnregisterEvent('EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED')
local function SetCam(cmd)
	ConsoleExec('ActionCam ' .. cmd)
end
SetCam(cfg.action_camera and 'basic' or 'off')






