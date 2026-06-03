local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local SHIP_FOLDER_NAME = "Ship"
local CHECKPOINT_FOLDER_NAME = Config.Checkpoint.FolderName
local WAYPOINT_FOLDER_NAME = Config.Monster.WaypointFolderName

local function makePart(parent: Instance, name: string, cframe: CFrame, size: Vector3, color: Color3, material: Enum.Material?)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.Metal
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeZone(parent: Instance, name: string, cframe: CFrame, size: Vector3, color: Color3)
	local part = makePart(parent, name, cframe, size, color, Enum.Material.ForceField)
	part.Transparency = 0.78
	part.CanCollide = false
	part.CanTouch = true
	part.CanQuery = true
	return part
end

local function buildCorridor(ship: Folder)
	local metal = Color3.fromRGB(38, 54, 55)
	local darkMetal = Color3.fromRGB(18, 28, 30)
	local rust = Color3.fromRGB(96, 52, 32)
	local emergency = Color3.fromRGB(110, 20, 18)

	makePart(ship, "Corridor_01_Floor_InvertedCeiling", CFrame.new(0, 0, 0), Vector3.new(14, 1, 90), darkMetal)
	makePart(ship, "Corridor_01_LeftWall", CFrame.new(-7, 5, 0), Vector3.new(1, 10, 90), metal)
	makePart(ship, "Corridor_01_RightWall", CFrame.new(7, 5, 0), Vector3.new(1, 10, 90), metal)
	makePart(ship, "Corridor_01_Ceiling_FormerFloor", CFrame.new(0, 10, 0), Vector3.new(14, 1, 90), Color3.fromRGB(24, 36, 38))
	makePart(ship, "Corridor_EndBulkhead", CFrame.new(0, 5, 45), Vector3.new(14, 10, 1), metal)

	for index = 1, 7 do
		local z = -35 + (index - 1) * 12
		makePart(ship, `Rib_Left_{index}`, CFrame.new(-6.3, 5, z), Vector3.new(0.7, 10, 0.9), rust)
		makePart(ship, `Rib_Right_{index}`, CFrame.new(6.3, 5, z), Vector3.new(0.7, 10, 0.9), rust)
		makePart(ship, `OverheadPipe_OnFloor_{index}`, CFrame.new(-2.4, 0.65, z), Vector3.new(0.5, 0.5, 8), rust, Enum.Material.CorrodedMetal)
	end

	makePart(ship, "Room_A_Floor", CFrame.new(-20, 0, -8), Vector3.new(24, 1, 24), darkMetal)
	makePart(ship, "Room_A_BackWall", CFrame.new(-32, 5, -8), Vector3.new(1, 10, 24), metal)
	makePart(ship, "Room_A_SideWall_1", CFrame.new(-20, 5, -20), Vector3.new(24, 10, 1), metal)
	makePart(ship, "Room_A_SideWall_2", CFrame.new(-20, 5, 4), Vector3.new(24, 10, 1), metal)
	makePart(ship, "Room_A_Ceiling", CFrame.new(-20, 10, -8), Vector3.new(24, 1, 24), Color3.fromRGB(24, 36, 38))
	makePart(ship, "Room_A_DoorLip", CFrame.new(-8.5, 5, -8), Vector3.new(2, 10, 4), emergency)

	makePart(ship, "Room_B_Floor", CFrame.new(20, 0, 22), Vector3.new(24, 1, 24), darkMetal)
	makePart(ship, "Room_B_BackWall", CFrame.new(32, 5, 22), Vector3.new(1, 10, 24), metal)
	makePart(ship, "Room_B_SideWall_1", CFrame.new(20, 5, 10), Vector3.new(24, 10, 1), metal)
	makePart(ship, "Room_B_SideWall_2", CFrame.new(20, 5, 34), Vector3.new(24, 10, 1), metal)
	makePart(ship, "Room_B_Ceiling", CFrame.new(20, 10, 22), Vector3.new(24, 1, 24), Color3.fromRGB(24, 36, 38))
	makePart(ship, "Room_B_DoorLip", CFrame.new(8.5, 5, 22), Vector3.new(2, 10, 4), emergency)

	makePart(ship, "MaintenanceNiche_Floor", CFrame.new(0, 0, 57), Vector3.new(10, 1, 18), darkMetal)
	makePart(ship, "MaintenanceNiche_Back", CFrame.new(0, 5, 66), Vector3.new(10, 10, 1), metal)
	makePart(ship, "MaintenanceNiche_Left", CFrame.new(-5, 5, 57), Vector3.new(1, 10, 18), metal)
	makePart(ship, "MaintenanceNiche_Right", CFrame.new(5, 5, 57), Vector3.new(1, 10, 18), metal)
	local hatch = makeZone(ship, "EmergencyHatch_Exit", CFrame.new(0, 3, 63), Vector3.new(7, 5, 2), Color3.fromRGB(240, 190, 80))
	hatch:SetAttribute(Config.Objective.ExitAttribute, true)
	hatch.Transparency = 0.45
	makePart(ship, "EmergencyHatch_Frame", CFrame.new(0, 3, 64.1), Vector3.new(8, 6, 0.5), emergency, Enum.Material.CorrodedMetal)

	local airPocket = makeZone(ship, "AirPocket_01", CFrame.new(-20, 3.2, -8), Vector3.new(20, 6, 20), Color3.fromRGB(82, 180, 195))
	airPocket:SetAttribute(Config.CO2.AirPocketAttribute, true)
	CollectionService:AddTag(airPocket, Config.CO2.AirPocketTag)
	local glimmer = makePart(ship, "AirPocket_Surface_Glimmer", CFrame.new(-20, 6.4, -8), Vector3.new(19, 0.25, 19), Color3.fromRGB(120, 210, 220), Enum.Material.Neon)
	glimmer.Transparency = 0.35
end

local function buildCheckpoints()
	local folder = Workspace:FindFirstChild(CHECKPOINT_FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = CHECKPOINT_FOLDER_NAME
		folder.Parent = Workspace
	end

	local checkpointData = {
		{ name = "Checkpoint_01_Start", order = 1, cframe = CFrame.new(0, 2, -38) },
		{ name = "Checkpoint_02_AirPocket", order = 2, cframe = CFrame.new(-14, 2, -8) },
		{ name = "Checkpoint_03_Niche", order = 3, cframe = CFrame.new(0, 2, 52) },
	}

	for _, data in checkpointData do
		if not folder:FindFirstChild(data.name) then
			local checkpoint = makeZone(folder, data.name, data.cframe, Vector3.new(7, 4, 7), Color3.fromRGB(80, 255, 170))
			checkpoint:SetAttribute("Order", data.order)
			checkpoint.Transparency = 1
		end
	end
end

local function buildWaypoints()
	local folder = Workspace:FindFirstChild(WAYPOINT_FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = WAYPOINT_FOLDER_NAME
		folder.Parent = Workspace
	end

	local waypointPositions = {
		Vector3.new(0, 1, 34),
		Vector3.new(20, 1, 22),
		Vector3.new(0, 1, 6),
		Vector3.new(-20, 1, -8),
		Vector3.new(0, 1, -30),
	}

	for index, position in waypointPositions do
		local name = `Waypoint_{index}`
		if not folder:FindFirstChild(name) then
			local waypoint = makeZone(folder, name, CFrame.new(position), Vector3.new(2, 2, 2), Color3.fromRGB(255, 90, 90))
			waypoint.Transparency = 1
			waypoint:SetAttribute("Order", index)
		end
	end
end

local function buildSpawn()
	if Workspace:FindFirstChild("InvertedDemoSpawn") then
		return
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "InvertedDemoSpawn"
	spawn.Anchored = true
	spawn.CFrame = CFrame.new(0, 1.2, -40)
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = Workspace
end

local function buildMonsterPlaceholder()
	if Workspace:FindFirstChild(Config.Monster.ModelName) then
		return
	end

	local model = Instance.new("Model")
	model.Name = Config.Monster.ModelName

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2.2, 2.2, 2.2)
	root.CFrame = CFrame.new(0, 3, 28)
	root.Color = Color3.fromRGB(55, 8, 8)
	root.Material = Enum.Material.Slate
	root.CanCollide = false
	root.Parent = model

	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(3.2, 5, 2.2)
	torso.CFrame = root.CFrame * CFrame.new(0, 0.2, 0)
	torso.Color = Color3.fromRGB(88, 18, 18)
	torso.Material = Enum.Material.Slate
	torso.Parent = model

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = torso
	weld.Parent = root

	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.WalkSpeed = Config.Monster.PatrolSpeed
	humanoid.Parent = model

	model.PrimaryPart = root
	model.Parent = Workspace
end

local function applyLighting()
	Lighting.Brightness = 0.7
	Lighting.ClockTime = 0
	Lighting.Ambient = Color3.fromRGB(0, 0, 0)
	Lighting.OutdoorAmbient = Color3.fromRGB(4, 8, 10)
	pcall(function()
		Lighting.Technology = Enum.Technology.Future
	end)
end

local function buildDemoScene()
	applyLighting()

	if not Workspace:FindFirstChild(SHIP_FOLDER_NAME) then
		local ship = Instance.new("Folder")
		ship.Name = SHIP_FOLDER_NAME
		ship.Parent = Workspace
		buildCorridor(ship)
	end

	buildSpawn()
	buildCheckpoints()
	buildWaypoints()
	buildMonsterPlaceholder()
end

buildDemoScene()
