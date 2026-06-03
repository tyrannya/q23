local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Config)
local Signals = require(ReplicatedStorage.Shared.Signals)

local player = Players.LocalPlayer
local noiseRemote = Signals.getRemoteEvent("PlayerNoise")

local character: Model? = nil
local humanoid: Humanoid? = nil
local rootPart: BasePart? = nil
local shiftHeld = false
local crouchHeld = false
local lastNoiseTime = 0
local currentState = "Walk"

local function setLocalBodyVisibility(char: Model)
	for _, instance in char:GetDescendants() do
		if instance:IsA("BasePart") and instance.Name ~= "Head" then
			instance.LocalTransparencyModifier = 0.35
		elseif instance:IsA("BasePart") then
			instance.LocalTransparencyModifier = 1
		end
	end
end

local function bindCharacter(char: Model)
	character = char
	humanoid = char:WaitForChild("Humanoid") :: Humanoid
	rootPart = char:WaitForChild("HumanoidRootPart") :: BasePart

	player.CameraMode = Enum.CameraMode.LockFirstPerson
	player.CameraMinZoomDistance = Config.Movement.FirstPersonZoom
	player.CameraMaxZoomDistance = Config.Movement.FirstPersonZoom
	humanoid.WalkSpeed = Config.Movement.WalkSpeed
	humanoid.CameraOffset = Config.Movement.DefaultCameraOffset
	setLocalBodyVisibility(char)
end

local function getMovementState()
	if crouchHeld then
		return "Crouch", Config.Movement.CrouchSpeed, Config.Noise.CrouchRadius, Config.Movement.CrouchCameraOffset
	end

	if shiftHeld then
		return "SlowWalk", Config.Movement.SlowWalkSpeed, Config.Noise.SlowWalkRadius, Config.Movement.DefaultCameraOffset
	end

	return "Walk", Config.Movement.WalkSpeed, Config.Noise.WalkRadius, Config.Movement.DefaultCameraOffset
end

local function applyMovementState()
	if not humanoid then
		return
	end

	local state, speed, _, cameraOffset = getMovementState()
	currentState = state
	humanoid.WalkSpeed = speed
	humanoid.CameraOffset = cameraOffset
	player:SetAttribute("MovementState", state)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		shiftHeld = true
		applyMovementState()
	elseif input.KeyCode == Enum.KeyCode.C or input.KeyCode == Enum.KeyCode.LeftControl then
		crouchHeld = true
		applyMovementState()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		shiftHeld = false
		applyMovementState()
	elseif input.KeyCode == Enum.KeyCode.C or input.KeyCode == Enum.KeyCode.LeftControl then
		crouchHeld = false
		applyMovementState()
	end
end)

RunService.Heartbeat:Connect(function()
	if not humanoid or not rootPart then
		return
	end

	local _, _, noiseRadius = getMovementState()
	local isMoving = humanoid.MoveDirection.Magnitude > 0.05
	local now = os.clock()

	if isMoving and noiseRadius > Config.Noise.IdleRadius and now - lastNoiseTime >= Config.Movement.NoiseEmitInterval then
		lastNoiseTime = now
		noiseRemote:FireServer(rootPart.Position, noiseRadius, currentState)
	end
end)

if player.Character then
	bindCharacter(player.Character)
end

player.CharacterAdded:Connect(bindCharacter)
