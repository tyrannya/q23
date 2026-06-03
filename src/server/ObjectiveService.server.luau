local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local OBJECTIVE_FIND_AIR = "FindAirPocket"
local OBJECTIVE_REACH_NICHE = "ReachNiche"
local OBJECTIVE_ESCAPE = "Escape"
local OBJECTIVE_COMPLETE = "Complete"

local function getRootPart(player: Player)
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function setObjective(player: Player, objectiveName: string)
	if player:GetAttribute("Objective") == objectiveName then
		return
	end

	player:SetAttribute("Objective", objectiveName)
	player:SetAttribute("ObjectiveText", Config.Objective.Messages[objectiveName] or objectiveName)
end

local function initialisePlayer(player: Player)
	player:SetAttribute("DemoComplete", false)
	setObjective(player, OBJECTIVE_FIND_AIR)

	player.CharacterAdded:Connect(function()
		if player:GetAttribute("DemoComplete") then
			setObjective(player, OBJECTIVE_COMPLETE)
		else
			setObjective(player, player:GetAttribute("Objective") or OBJECTIVE_FIND_AIR)
		end
	end)
end

local function getNamedPart(partName: string)
	local ship = Workspace:FindFirstChild("Ship")
	if not ship then
		return nil
	end

	local found = ship:FindFirstChild(partName, true)
	return if found and found:IsA("BasePart") then found else nil
end

local function distanceToPart(player: Player, partName: string)
	local rootPart = getRootPart(player)
	local part = getNamedPart(partName)
	if not rootPart or not part then
		return math.huge
	end

	return (rootPart.Position - part.Position).Magnitude
end

local function completeDemo(player: Player)
	player:SetAttribute("DemoComplete", true)
	setObjective(player, OBJECTIVE_COMPLETE)
end

local function bindExit(exitPart: BasePart)
	exitPart.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		local player = character and Players:GetPlayerFromCharacter(character)
		if player and player:GetAttribute("Objective") == OBJECTIVE_ESCAPE then
			completeDemo(player)
		end
	end)
end

local boundExits = {}
local function scanExits()
	for _, instance in Workspace:GetDescendants() do
		if instance:IsA("BasePart") and instance:GetAttribute(Config.Objective.ExitAttribute) == true and not boundExits[instance] then
			boundExits[instance] = true
			bindExit(instance)
		end
	end
end

Players.PlayerAdded:Connect(initialisePlayer)
for _, player in Players:GetPlayers() do
	initialisePlayer(player)
end

Workspace.DescendantAdded:Connect(function(instance)
	if instance:IsA("BasePart") and instance:GetAttribute(Config.Objective.ExitAttribute) == true and not boundExits[instance] then
		boundExits[instance] = true
		bindExit(instance)
	end
end)

scanExits()

task.spawn(function()
	while true do
		task.wait(0.25)
		scanExits()

		for _, player in Players:GetPlayers() do
			if player:GetAttribute("DemoComplete") then
				setObjective(player, OBJECTIVE_COMPLETE)
				continue
			end

			local objective = player:GetAttribute("Objective") or OBJECTIVE_FIND_AIR
			if objective == OBJECTIVE_FIND_AIR then
				if distanceToPart(player, "AirPocket_01") <= Config.Objective.AirPocketObjectiveDistance then
					setObjective(player, OBJECTIVE_REACH_NICHE)
				end
			elseif objective == OBJECTIVE_REACH_NICHE then
				if distanceToPart(player, "MaintenanceNiche_Floor") <= Config.Objective.NicheObjectiveDistance then
					setObjective(player, OBJECTIVE_ESCAPE)
				end
			end
		end
	end
end)
