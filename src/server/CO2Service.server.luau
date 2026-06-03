local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include

local function getAirPocketParts()
	local parts = {}

	for _, tagged in CollectionService:GetTagged(Config.CO2.AirPocketTag) do
		if tagged:IsA("BasePart") then
			table.insert(parts, tagged)
		end
	end

	for _, instance in Workspace:GetDescendants() do
		if instance:IsA("BasePart") and instance:GetAttribute(Config.CO2.AirPocketAttribute) == true then
			table.insert(parts, instance)
		end
	end

	return parts
end

local function isCharacterInAirPocket(character: Model?)
	if not character then
		return false
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return false
	end

	local airPocketParts = getAirPocketParts()
	if #airPocketParts == 0 then
		return false
	end

	overlapParams.FilterDescendantsInstances = airPocketParts
	local nearby = Workspace:GetPartBoundsInBox(rootPart.CFrame, Vector3.new(3, 5, 3), overlapParams)
	return #nearby > 0
end

local function killForCO2(player: Player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid.Health = 0
	end
end

local function initialisePlayer(player: Player)
	player:SetAttribute("CO2", 0)
	player:SetAttribute("Pulse", Config.Watch.BasePulse)

	player.CharacterAdded:Connect(function()
		player:SetAttribute("CO2", 0)
		player:SetAttribute("Pulse", Config.Watch.BasePulse)
	end)
end

Players.PlayerAdded:Connect(initialisePlayer)
for _, player in Players:GetPlayers() do
	initialisePlayer(player)
end

task.spawn(function()
	while true do
		task.wait(Config.CO2.TickInterval)
		for _, player in Players:GetPlayers() do
			local co2 = player:GetAttribute("CO2") or 0
			local inAirPocket = isCharacterInAirPocket(player.Character)
			local delta = if inAirPocket then -Config.CO2.VentRatePerSecond else Config.CO2.RatePerSecond
			co2 = math.clamp(co2 + delta * Config.CO2.TickInterval, 0, Config.CO2.Max)
			player:SetAttribute("CO2", co2)

			local dangerPulse = Config.Watch.BasePulse + math.clamp(co2 / Config.CO2.Max, 0, 1) * 28
			player:SetAttribute("Pulse", dangerPulse)

			if co2 >= Config.CO2.Max then
				killForCO2(player)
			end
		end
	end
end)
