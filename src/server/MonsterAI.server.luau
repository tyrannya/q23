local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local runtimeFolder = ServerScriptService:WaitForChild("Runtime")
local queryNoise = runtimeFolder:WaitForChild("QueryNoise") :: BindableFunction

local monster = Workspace:WaitForChild(Config.Monster.ModelName) :: Model
local humanoid = monster:WaitForChild("Humanoid") :: Humanoid
local rootPart = monster:WaitForChild("HumanoidRootPart") :: BasePart
local state = "PATROL"
local patrolIndex = 1
local lastStimulusTime = 0
local targetPosition: Vector3? = nil
local chaseTarget: Player? = nil
local lastPathTime = 0

local function getWaypoints()
	local waypoints = {}
	local waypointFolder = Workspace:FindFirstChild(Config.Monster.WaypointFolderName)
	if not waypointFolder then
		return waypoints
	end

	for _, instance in waypointFolder:GetChildren() do
		if instance:IsA("BasePart") then
			table.insert(waypoints, instance)
		end
	end

	table.sort(waypoints, function(left, right)
		local leftOrder = left:GetAttribute("Order") or 0
		local rightOrder = right:GetAttribute("Order") or 0
		return leftOrder < rightOrder
	end)

	return waypoints
end

local function moveToPosition(position: Vector3)
	local path = PathfindingService:CreatePath()
	local success = pcall(function()
		path:ComputeAsync(rootPart.Position, position)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		local pathWaypoints = path:GetWaypoints()
		if #pathWaypoints >= 2 then
			humanoid:MoveTo(pathWaypoints[2].Position)
			return
		end
	end

	humanoid:MoveTo(position)
end

local function getClosestLivingPlayer(maxRange: number)
	local closestPlayer = nil
	local closestDistance = maxRange

	for _, player in Players:GetPlayers() do
		local character = player.Character
		local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
		local targetHumanoid = character and character:FindFirstChildOfClass("Humanoid")
		if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
			local distance = (targetRoot.Position - rootPart.Position).Magnitude
			if distance <= closestDistance then
				closestDistance = distance
				closestPlayer = player
			end
		end
	end

	return closestPlayer, closestDistance
end

local function setState(newState: string)
	if state == newState then
		return
	end

	state = newState
	monster:SetAttribute("State", state)
end

local function patrol()
	humanoid.WalkSpeed = Config.Monster.PatrolSpeed
	local waypoints = getWaypoints()
	if #waypoints == 0 then
		return
	end

	local waypoint = waypoints[patrolIndex]
	if (waypoint.Position - rootPart.Position).Magnitude < 4 then
		patrolIndex = (patrolIndex % #waypoints) + 1
		waypoint = waypoints[patrolIndex]
	end

	moveToPosition(waypoint.Position)
end

local function investigate(now: number)
	humanoid.WalkSpeed = Config.Monster.PatrolSpeed
	if targetPosition then
		moveToPosition(targetPosition)
		if (targetPosition - rootPart.Position).Magnitude < 5 and now - lastStimulusTime > Config.Monster.LoseInterestTime then
			targetPosition = nil
			setState("PATROL")
		end
	else
		setState("PATROL")
	end
end

local function chase(now: number)
	humanoid.WalkSpeed = Config.Monster.ChaseSpeed
	local player = chaseTarget
	local character = player and player.Character
	local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
	local targetHumanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not player or not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then
		chaseTarget = nil
		setState(if targetPosition then "INVESTIGATE" else "PATROL")
		return
	end

	local distance = (targetRoot.Position - rootPart.Position).Magnitude
	targetPosition = targetRoot.Position
	lastStimulusTime = now

	if distance <= Config.Monster.AttackRange then
		setState("ATTACK")
		return
	end

	if now - lastPathTime >= Config.Monster.PathRecomputeInterval then
		lastPathTime = now
		moveToPosition(targetRoot.Position)
	end
end

local function attack()
	local player = chaseTarget or getClosestLivingPlayer(Config.Monster.AttackRange)
	local character = player and player.Character
	local targetHumanoid = character and character:FindFirstChildOfClass("Humanoid")
	if targetHumanoid and targetHumanoid.Health > 0 then
		targetHumanoid.Health = 0
	end

	chaseTarget = nil
	targetPosition = nil
	setState("PATROL")
end

monster:SetAttribute("State", state)

task.spawn(function()
	while monster.Parent do
		local now = os.clock()
		local nearbyPlayer = getClosestLivingPlayer(Config.Monster.DirectDetectRange)
		if nearbyPlayer then
			chaseTarget = nearbyPlayer
			lastStimulusTime = now
			setState("CHASE")
		end

		if state ~= "CHASE" and state ~= "ATTACK" then
			local noise = queryNoise:Invoke(rootPart.Position, 0)
			if noise then
				targetPosition = noise.position
				lastStimulusTime = now
				setState("INVESTIGATE")
			end
		end

		if state == "PATROL" then
			patrol()
		elseif state == "INVESTIGATE" then
			investigate(now)
		elseif state == "CHASE" then
			chase(now)
		elseif state == "ATTACK" then
			attack()
		end

		task.wait(Config.Monster.HearingCheckInterval)
	end
end)
