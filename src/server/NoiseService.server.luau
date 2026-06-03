local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage.Shared.Config)
local Signals = require(ReplicatedStorage.Shared.Signals)

local noiseRemote = Signals.getRemoteEvent("PlayerNoise")
local runtimeFolder = ServerScriptService:FindFirstChild("Runtime")
if not runtimeFolder then
	runtimeFolder = Instance.new("Folder")
	runtimeFolder.Name = "Runtime"
	runtimeFolder.Parent = ServerScriptService
end

local queryNoise = runtimeFolder:FindFirstChild("QueryNoise") :: BindableFunction?
if not queryNoise then
	queryNoise = Instance.new("BindableFunction")
	queryNoise.Name = "QueryNoise"
	queryNoise.Parent = runtimeFolder
end

local noises = {}

local function pruneExpired(now: number)
	for index = #noises, 1, -1 do
		if now - noises[index].time > Config.Noise.MaxEventAge then
			table.remove(noises, index)
		end
	end
end

noiseRemote.OnServerEvent:Connect(function(player, position, radius, movementState)
	if typeof(position) ~= "Vector3" or typeof(radius) ~= "number" then
		return
	end

	radius = math.clamp(radius, 0, Config.Noise.WalkRadius)
	if radius <= Config.Noise.IdleRadius then
		return
	end

	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if rootPart and (rootPart.Position - position).Magnitude > 12 then
		position = rootPart.Position
	end

	table.insert(noises, {
		player = player,
		position = position,
		radius = radius,
		movementState = tostring(movementState),
		time = os.clock(),
	})
	pruneExpired(os.clock())
end)

queryNoise.OnInvoke = function(origin: Vector3, extraRadius: number?)
	local now = os.clock()
	pruneExpired(now)

	local loudest = nil
	local bestScore = -math.huge
	for _, noise in noises do
		local distance = (noise.position - origin).Magnitude
		local hearingRadius = noise.radius + (extraRadius or 0)
		if distance <= hearingRadius then
			local score = noise.radius - distance + (Config.Noise.MaxEventAge - (now - noise.time))
			if score > bestScore then
				bestScore = score
				loudest = noise
			end
		end
	end

	return loudest
end
