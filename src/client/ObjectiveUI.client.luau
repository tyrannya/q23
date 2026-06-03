local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "ObjectiveUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 25
gui.Parent = playerGui

local label = Instance.new("TextLabel")
label.Name = "ObjectiveLabel"
label.AnchorPoint = Vector2.new(0.5, 0)
label.Position = UDim2.fromScale(0.5, 0.06)
label.Size = UDim2.fromOffset(560, 40)
label.BackgroundColor3 = Color3.fromRGB(3, 12, 13)
label.BackgroundTransparency = 0.35
label.BorderSizePixel = 0
label.Font = Enum.Font.Code
label.TextColor3 = Color3.fromRGB(130, 255, 225)
label.TextSize = 18
label.TextWrapped = true
label.Text = ""
label.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = label

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(70, 225, 205)
stroke.Thickness = 1
stroke.Transparency = 0.45
stroke.Parent = label

local completionOverlay = Instance.new("Frame")
completionOverlay.Name = "CompletionOverlay"
completionOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
completionOverlay.BackgroundTransparency = 1
completionOverlay.BorderSizePixel = 0
completionOverlay.Size = UDim2.fromScale(1, 1)
completionOverlay.Visible = true
completionOverlay.Parent = gui

local completionText = Instance.new("TextLabel")
completionText.Name = "CompletionText"
completionText.AnchorPoint = Vector2.new(0.5, 0.5)
completionText.Position = UDim2.fromScale(0.5, 0.5)
completionText.Size = UDim2.fromOffset(700, 80)
completionText.BackgroundTransparency = 1
completionText.Font = Enum.Font.Code
completionText.TextColor3 = Color3.fromRGB(150, 255, 235)
completionText.TextSize = 30
completionText.TextTransparency = 1
completionText.Text = Config.Objective.Messages.Complete
completionText.Parent = completionOverlay

local function updateObjective()
	local objectiveText = player:GetAttribute("ObjectiveText") or Config.Objective.Messages.FindAirPocket
	label.Text = objectiveText

	if player:GetAttribute("DemoComplete") then
		TweenService:Create(
			completionOverlay,
			TweenInfo.new(Config.Objective.CompleteFadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = 0.18 }
		):Play()
		TweenService:Create(
			completionText,
			TweenInfo.new(Config.Objective.CompleteFadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ TextTransparency = 0 }
		):Play()
	end
end

player:GetAttributeChangedSignal("ObjectiveText"):Connect(updateObjective)
player:GetAttributeChangedSignal("DemoComplete"):Connect(updateObjective)
updateObjective()
