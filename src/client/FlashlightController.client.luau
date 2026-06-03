local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local camera = Workspace.CurrentCamera
local holder = Instance.new("Part")
holder.Name = "FirstPersonFlashlight"
holder.Anchored = true
holder.CanCollide = false
holder.CanQuery = false
holder.CanTouch = false
holder.Transparency = 1
holder.Size = Vector3.new(0.2, 0.2, 0.2)
holder.Parent = Workspace

local light = Instance.new("SpotLight")
light.Name = "DiveFlashlight"
light.Angle = Config.Flashlight.Angle
light.Range = Config.Flashlight.Range
light.Brightness = 0
light.Color = Config.Flashlight.Color
light.Shadows = true
light.Enabled = true
light.Parent = holder

local enabled = false
local currentTween: Tween? = nil

local function tweenBrightness(targetBrightness: number)
	if currentTween then
		currentTween:Cancel()
	end

	currentTween = TweenService:Create(
		light,
		TweenInfo.new(Config.Flashlight.TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Brightness = targetBrightness }
	)
	currentTween:Play()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Config.Flashlight.KeyCode then
		enabled = not enabled
		tweenBrightness(if enabled then Config.Flashlight.Brightness else 0)
	end
end)

RunService.RenderStepped:Connect(function()
	camera = Workspace.CurrentCamera
	holder.CFrame = camera.CFrame * CFrame.new(0.35, -0.25, -0.6)
end)
