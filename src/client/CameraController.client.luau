local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local lastLookVector = camera.CFrame.LookVector
local bobTime = 0

local function getCharacterParts()
	local character = player.Character
	if not character then
		return nil, nil
	end

	return character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("HumanoidRootPart")
end

local function getBobAmplitude(state: string)
	if state == "SlowWalk" then
		return Config.Camera.SlowBobAmplitude
	elseif state == "Crouch" then
		return Config.Camera.CrouchBobAmplitude
	end

	return Config.Camera.WalkBobAmplitude
end

RunService:BindToRenderStep("InvertedBodyCam", Enum.RenderPriority.Camera.Value + 1, function(deltaTime)
	camera = Workspace.CurrentCamera
	local humanoid = nil
	local rootPart = nil
	humanoid, rootPart = getCharacterParts()

	if not humanoid or not rootPart then
		return
	end

	local moveMagnitude = humanoid.MoveDirection.Magnitude
	local state = player:GetAttribute("MovementState") or "Walk"
	local offset = Vector3.zero
	local roll = 0

	if moveMagnitude > 0.05 then
		bobTime += deltaTime * Config.Camera.BobFrequency * math.max(rootPart.AssemblyLinearVelocity.Magnitude / Config.Movement.WalkSpeed, 0.25)
		local amplitude = getBobAmplitude(state)
		offset = Vector3.new(
			math.sin(bobTime) * amplitude.X,
			math.abs(math.cos(bobTime * 0.5)) * amplitude.Y,
			0
		)
	else
		bobTime += deltaTime * Config.Camera.IdleBreathFrequency
		offset = Vector3.new(0, math.sin(bobTime) * Config.Camera.IdleBreathAmplitude, 0)
	end

	local lookVector = camera.CFrame.LookVector
	local turnAmount = lastLookVector:Cross(lookVector).Y
	roll = math.clamp(-turnAmount * Config.Camera.TurnRollStrength / math.max(deltaTime, 1 / 120), -Config.Camera.MaxRollRadians, Config.Camera.MaxRollRadians)
	lastLookVector = lookVector

	local co2 = player:GetAttribute("CO2") or 0
	if co2 >= Config.CO2.CriticalThreshold then
		local severity = math.clamp((co2 - Config.CO2.CriticalThreshold) / (Config.CO2.Max - Config.CO2.CriticalThreshold), 0, 1)
		local tremor = math.sin(os.clock() * Config.Camera.CO2TremorFrequency) * Config.Camera.CO2TremorAmplitude * severity
		offset += Vector3.new(tremor, -tremor * 0.5, 0)
	end

	camera.CFrame = camera.CFrame * CFrame.new(offset) * CFrame.Angles(0, 0, roll)
end)
