local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Config)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:FindFirstChild("WatchUI") :: ScreenGui?

if not gui then
	gui = Instance.new("ScreenGui")
	gui.Name = "WatchUI"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.Parent = playerGui
end

gui.DisplayOrder = 30

local panel = gui:FindFirstChild("Panel") :: Frame?
if not panel then
	panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 1)
	panel.Position = UDim2.fromScale(0.5, 1.18)
	panel.Size = UDim2.fromOffset(230, 120)
	panel.BackgroundColor3 = Color3.fromRGB(4, 18, 19)
	panel.BackgroundTransparency = 0.12
	panel.BorderSizePixel = 0
	panel.Visible = true
	panel.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 18)
	corner.Parent = panel

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(70, 225, 205)
	stroke.Thickness = 1
	stroke.Transparency = 0.25
	stroke.Parent = panel

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(14, 8)
	title.Size = UDim2.new(1, -28, 0, 20)
	title.Font = Enum.Font.Code
	title.Text = "AEGIR DIVE WATCH"
	title.TextColor3 = Color3.fromRGB(120, 255, 230)
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = panel

	local co2Text = Instance.new("TextLabel")
	co2Text.Name = "CO2Text"
	co2Text.BackgroundTransparency = 1
	co2Text.Position = UDim2.fromOffset(14, 36)
	co2Text.Size = UDim2.new(1, -28, 0, 24)
	co2Text.Font = Enum.Font.Code
	co2Text.TextColor3 = Color3.fromRGB(235, 255, 250)
	co2Text.TextSize = 20
	co2Text.TextXAlignment = Enum.TextXAlignment.Left
	co2Text.Parent = panel

	local barBack = Instance.new("Frame")
	barBack.Name = "CO2BarBack"
	barBack.BackgroundColor3 = Color3.fromRGB(12, 35, 38)
	barBack.BorderSizePixel = 0
	barBack.Position = UDim2.fromOffset(14, 66)
	barBack.Size = UDim2.new(1, -28, 0, 12)
	barBack.Parent = panel

	local barFill = Instance.new("Frame")
	barFill.Name = "CO2BarFill"
	barFill.BackgroundColor3 = Color3.fromRGB(80, 245, 200)
	barFill.BorderSizePixel = 0
	barFill.Size = UDim2.fromScale(0, 1)
	barFill.Parent = barBack

	local pulseText = Instance.new("TextLabel")
	pulseText.Name = "PulseText"
	pulseText.BackgroundTransparency = 1
	pulseText.Position = UDim2.fromOffset(14, 86)
	pulseText.Size = UDim2.new(1, -28, 0, 22)
	pulseText.Font = Enum.Font.Code
	pulseText.TextColor3 = Color3.fromRGB(180, 255, 235)
	pulseText.TextSize = 18
	pulseText.TextXAlignment = Enum.TextXAlignment.Left
	pulseText.Parent = panel
end

local co2Text = panel:WaitForChild("CO2Text") :: TextLabel
local pulseText = panel:WaitForChild("PulseText") :: TextLabel
local barFill = panel:WaitForChild("CO2BarBack"):WaitForChild("CO2BarFill") :: Frame
local visible = false
local currentTween: Tween? = nil

local function setVisible(shouldShow: boolean)
	visible = shouldShow
	if currentTween then
		currentTween:Cancel()
	end

	currentTween = TweenService:Create(
		panel,
		TweenInfo.new(Config.Watch.TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = if visible then UDim2.fromScale(0.5, 0.95) else UDim2.fromScale(0.5, 1.18) }
	)
	currentTween:Play()
end

local function updateReadout()
	local co2 = player:GetAttribute("CO2") or 0
	local pulse = player:GetAttribute("Pulse") or Config.Watch.BasePulse
	local fraction = math.clamp(co2 / Config.CO2.Max, 0, 1)

	co2Text.Text = (`CO2 {math.floor(co2 + 0.5)}%`)
	pulseText.Text = (`PULSE {math.floor(pulse + 0.5)} BPM`)
	barFill.Size = UDim2.fromScale(fraction, 1)

	if co2 >= Config.CO2.CriticalThreshold then
		barFill.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
	elseif co2 >= Config.CO2.WarnThreshold then
		barFill.BackgroundColor3 = Color3.fromRGB(255, 190, 65)
	else
		barFill.BackgroundColor3 = Color3.fromRGB(80, 245, 200)
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Config.Watch.KeyCode then
		setVisible(true)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Config.Watch.KeyCode then
		setVisible(false)
	end
end)

player:GetAttributeChangedSignal("CO2"):Connect(updateReadout)
player:GetAttributeChangedSignal("Pulse"):Connect(updateReadout)
setVisible(false)
updateReadout()
