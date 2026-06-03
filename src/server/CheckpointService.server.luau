local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local checkpoints = {}
local lastCheckpointByPlayer: { [Player]: CFrame } = {}

local function getCheckpointCFrame(part: BasePart)
	return part.CFrame + Vector3.new(0, Config.Checkpoint.RespawnYOffset, 0)
end

local function registerCheckpoint(part: BasePart)
	checkpoints[part] = true
	part.Transparency = 1
	part.CanCollide = false
	part.CanQuery = false

	part.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		local player = character and Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		lastCheckpointByPlayer[player] = getCheckpointCFrame(part)
	end)
end

local function scanCheckpoints()
	local folder = Workspace:FindFirstChild(Config.Checkpoint.FolderName)
	if not folder then
		return
	end

	for _, instance in folder:GetDescendants() do
		if instance:IsA("BasePart") and not checkpoints[instance] then
			registerCheckpoint(instance)
		end
	end
end

local function playRespawnCue(player: Player)
	if Config.Checkpoint.RespawnSoundId == "rbxassetid://0" then
		return
	end

	local sound = Instance.new("Sound")
	sound.Name = "CheckpointRespawnCue"
	sound.SoundId = Config.Checkpoint.RespawnSoundId
	sound.Volume = 0.35
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
end

local function bindCharacter(player: Player, character: Model)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart

	if not lastCheckpointByPlayer[player] then
		lastCheckpointByPlayer[player] = rootPart.CFrame
	end

	humanoid.Died:Connect(function()
		local respawnCFrame = lastCheckpointByPlayer[player]
		task.delay(Config.Checkpoint.RespawnDelay, function()
			if player.Parent ~= Players then
				return
			end

			player:LoadCharacter()
			local newCharacter = player.Character or player.CharacterAdded:Wait()
			local newRoot = newCharacter:WaitForChild("HumanoidRootPart") :: BasePart
			newRoot.CFrame = respawnCFrame
			player:SetAttribute("CO2", 0)
			player:SetAttribute("Pulse", Config.Watch.BasePulse)
			playRespawnCue(player)
		end)
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		bindCharacter(player, character)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	lastCheckpointByPlayer[player] = nil
end)

scanCheckpoints()
Workspace.ChildAdded:Connect(function(child)
	if child.Name == Config.Checkpoint.FolderName then
		task.defer(scanCheckpoints)
	end
end)
