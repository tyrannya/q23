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

local function addPointLight(parent: BasePart, color: Color3, brightness: number, range: number)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = brightness
	light.Range = range
	light.Shadows = true
	light.Parent = parent
	return light
end

local function makeLabel(parent: Instance, name: string, text: string, cframe: CFrame)
	local sign = makePart(parent, name, cframe, Vector3.new(5, 0.2, 1.4), Color3.fromRGB(12, 34, 34), Enum.Material.Neon)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.LightInfluence = 0
	gui.Parent = sign

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.Code
	label.Text = text
	label.TextColor3 = Color3.fromRGB(120, 255, 230)
	label.TextScaled = true
	label.Parent = gui
	return sign
end

local function buildAirPocketLab(ship: Folder, metal: Color3, darkMetal: Color3, rust: Color3)
	local glass = Color3.fromRGB(75, 145, 150)
	local warning = Color3.fromRGB(195, 130, 45)

	makeLabel(ship, "Room_A_Label_AtlasLab", "ATLAS BIO-LAB / AIR", CFrame.new(-19, 6.6, 3.45) * CFrame.Angles(0, math.rad(180), 0))

	local tableA = makePart(ship, "Room_A_OverturnedLabTable_A", CFrame.new(-22, 1.2, -14) * CFrame.Angles(0, 0, math.rad(12)), Vector3.new(8, 1.4, 2.8), metal)
	tableA:SetAttribute("GameplayNote", "Low obstacle: breaks sightlines and reinforces inverted-room dressing.")
	makePart(ship, "Room_A_OverturnedLabTable_B", CFrame.new(-15, 1.2, -1) * CFrame.Angles(0, math.rad(18), math.rad(-10)), Vector3.new(7, 1.4, 2.5), metal)
	makePart(ship, "Room_A_FallenShelf", CFrame.new(-29, 1.3, -2) * CFrame.Angles(0, math.rad(90), math.rad(8)), Vector3.new(9, 1, 2.2), rust, Enum.Material.CorrodedMetal)

	for index = 1, 3 do
		local z = -16 + (index - 1) * 6
		local tank = makePart(ship, `Room_A_BrokenSpecimenTank_{index}`, CFrame.new(-29.6, 3.1, z), Vector3.new(1.2, 4.2, 2.2), glass, Enum.Material.Glass)
		tank.Transparency = 0.35
		makePart(ship, `Room_A_TankFrame_{index}`, CFrame.new(-29.6, 3.1, z), Vector3.new(1.35, 4.4, 2.4), rust, Enum.Material.CorrodedMetal).Transparency = 0.55
	end

	for index = 1, 4 do
		local debris = makePart(ship, `Room_A_FloatingDebris_{index}`, CFrame.new(-26 + index * 2.5, 6.1 + (index % 2) * 0.35, -17 + index * 4), Vector3.new(2.2, 0.35, 0.6), warning, Enum.Material.WoodPlanks)
		debris.CanCollide = false
		debris.CFrame *= CFrame.Angles(math.rad(0), math.rad(index * 21), math.rad(index * 9))
	end

	local ventGlow = makePart(ship, "Room_A_AirVent_Glow", CFrame.new(-12.2, 5.4, -8), Vector3.new(0.4, 2.6, 5), Color3.fromRGB(95, 230, 220), Enum.Material.Neon)
	ventGlow.Transparency = 0.2
	addPointLight(ventGlow, Color3.fromRGB(90, 220, 215), 0.9, 16)
end

local function buildStealthBunkRoom(ship: Folder, metal: Color3, darkMetal: Color3, rust: Color3)
	makeLabel(ship, "Room_B_Label_CrewDeck", "CREW BERTH / QUIET", CFrame.new(20, 6.6, 10.55))

	local bunkPositions = {
		Vector3.new(13.5, 1.4, 15),
		Vector3.new(26.5, 1.4, 15),
		Vector3.new(13.5, 1.4, 29),
		Vector3.new(26.5, 1.4, 29),
	}

	for index, position in bunkPositions do
		local bunk = makePart(ship, `Room_B_OverturnedBunk_{index}`, CFrame.new(position) * CFrame.Angles(0, math.rad(if index % 2 == 0 then -12 else 12), math.rad(8)), Vector3.new(6, 1.4, 2.2), metal)
		bunk:SetAttribute("StealthCover", true)
		makePart(ship, `Room_B_Mattress_{index}`, CFrame.new(position + Vector3.new(0, 0.8, 0)), Vector3.new(5.6, 0.45, 2), Color3.fromRGB(28, 45, 45), Enum.Material.Fabric)
	end

	makePart(ship, "Room_B_CentralNoiseTrap_Grate", CFrame.new(20, 0.58, 22), Vector3.new(7, 0.18, 7), Color3.fromRGB(80, 86, 78), Enum.Material.CorrodedMetal)
	makePart(ship, "Room_B_CollapsedLocker_Left", CFrame.new(14, 2.2, 22) * CFrame.Angles(0, math.rad(28), math.rad(18)), Vector3.new(2.2, 4.2, 1.2), rust, Enum.Material.CorrodedMetal)
	makePart(ship, "Room_B_CollapsedLocker_Right", CFrame.new(26, 2.2, 22) * CFrame.Angles(0, math.rad(-28), math.rad(-18)), Vector3.new(2.2, 4.2, 1.2), rust, Enum.Material.CorrodedMetal)

	local flicker = makePart(ship, "Room_B_FlickerLight_Red", CFrame.new(20, 8.8, 22), Vector3.new(1.4, 0.35, 1.4), Color3.fromRGB(190, 30, 24), Enum.Material.Neon)
	addPointLight(flicker, Color3.fromRGB(190, 35, 28), 0.65, 18)
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
	addPointLight(glimmer, Color3.fromRGB(105, 230, 225), 0.7, 22)

	buildAirPocketLab(ship, metal, darkMetal, rust)
	buildStealthBunkRoom(ship, metal, darkMetal, rust)
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
