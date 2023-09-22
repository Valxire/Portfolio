-- An AutoMove functionality relative to Isometric Camera, which also allows for W movement to follow the mouse Direction declared via an AimMechanism in a differing Script

local TURN_VELOCITY = math.rad(180)
local Isometric = true

local localPlayer = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

local walkKeyBinds = {
	Forward = { Key = Enum.KeyCode.W, Direction = Enum.NormalId.Front },
	Backward = { Key = Enum.KeyCode.S, Direction = Enum.NormalId.Back },
	Left = { Key = Enum.KeyCode.A, Direction = Enum.NormalId.Left },
	Right = { Key = Enum.KeyCode.D, Direction = Enum.NormalId.Right }
}

local connections = {}


local function getWalkDirectionCameraSpace()
	local walkDir = Vector3.new()

	if localPlayer:GetAttribute("SnowballActive") then
		walkDir += Vector3.FromNormalId(walkKeyBinds.Forward.Direction)
	else
		if inputService:IsKeyDown(walkKeyBinds.Forward.Key) then
			walkDir += Vector3.FromNormalId(walkKeyBinds.Forward.Direction )
		end
	end

	if walkDir.Magnitude > 0 then --(0, 0, 0).Unit = NaN, do not want
		walkDir = walkDir.Unit --Normalize, because we (probably) changed an Axis so it's no longer a unit vector
	end

	return walkDir
end

local function getWalkDirectionWorldSpace()
	local humanoidRootPart = commonUtils.WaitPlayerRootPart(localPlayer)
	local walkDir = humanoidRootPart.CFrame:VectorToWorldSpace( getWalkDirectionCameraSpace() )
	walkDir *= Vector3.new(1, 0, 1) --Set Y axis to 0

	if walkDir.Magnitude > 0 then --(0, 0, 0).Unit = NaN, do not want
		walkDir = walkDir.Unit --Normalize, because we (probably) changed an Axis so it's no longer a unit vector
	end

	return walkDir
end

local function updateMovement( dt )
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid:Move( getWalkDirectionWorldSpace() )
	end
end	
