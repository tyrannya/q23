local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage.Shared.Config)

local player = Players.LocalPlayer

local blur = Lighting:FindFirstChild("CO2Blur") :: BlurEffect?
if not blur then
	blur = Instance.new("BlurEffect")
	blur.Name = "CO2Blur"
	blur.Size = 0
	blur.Parent = Lighting
end

local gui = Instance.new("ScreenGui")
gui.Name = "BreathingEffects"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.Parent = player:WaitForChild("PlayerGui")

local overlay = Instance.new("Frame")
overlay.Name = "CO2TunnelOverlay"
overlay.BackgroundColor3 = Color3.fromRGB(3, 9, 10)
overlay.BackgroundTransparency = 1
overlay.BorderSizePixel = 0
overlay.Size = UDim2.fromScale(1, 1)
overlay.Parent = gui

local stroke = Instance.new("UIStroke")
stroke.Name = "VignetteStroke"
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Color = Color3.fromRGB(0, 0, 0)
stroke.Thickness = 80
stroke.Transparency = 1
stroke.Parent = overlay

local breathing = Instance.new("Sound")
breathing.Name = "PlayerBreathingLoop"
breathing.SoundId = Config.Breathing.BreathSoundId
breathing.Looped = true
breathing.Volume = 0
breathing.Parent = SoundService

if Config.Breathing.BreathSoundId ~= "rbxassetid://0" then
	breathing:Play()
end

local function inverseLerp(minValue: number, maxValue: number, value: number)
	return math.clamp((value - minValue) / (maxValue - minValue), 0, 1)
end

RunService.RenderStepped:Connect(function()
	local co2 = player:GetAttribute("CO2") or 0
	local warnSeverity = inverseLerp(Config.CO2.WarnThreshold, Config.CO2.Max, co2)
	local criticalSeverity = inverseLerp(Config.CO2.CriticalThreshold, Config.CO2.Max, co2)

	stroke.Transparency = 1 - warnSeverity * (1 - Config.Breathing.VignetteMaxTransparency)
	overlay.BackgroundTransparency = 1 - criticalSeverity * (1 - Config.Breathing.CriticalOverlayTransparency)
	blur.Size = criticalSeverity * Config.Breathing.MaxBlur

	breathing.Volume = Config.Breathing.MinBreathVolume + warnSeverity * (Config.Breathing.MaxBreathVolume - Config.Breathing.MinBreathVolume)
	breathing.PlaybackSpeed = 0.95 + warnSeverity * 0.65
end)
