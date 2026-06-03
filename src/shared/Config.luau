-- Shared tuning for the INVERTED Roblox demo.
-- Keep all balance numbers here so the prototype can be adjusted without
-- touching gameplay logic.

return {
	CO2 = {
		RatePerSecond = 0.6,
		Max = 100,
		WarnThreshold = 70,
		CriticalThreshold = 88,
		VentRatePerSecond = 8,
		TickInterval = 0.25,
		AirPocketTag = "AirPocket",
		AirPocketAttribute = "IsAirPocket",
	},

	Movement = {
		WalkSpeed = 8,
		SlowWalkSpeed = 3,
		CrouchSpeed = 2,
		NoiseEmitInterval = 0.3,
		CrouchCameraOffset = Vector3.new(0, -0.8, 0),
		DefaultCameraOffset = Vector3.new(0, 0, 0),
		FirstPersonZoom = 0.5,
	},

	Noise = {
		WalkRadius = 18,
		SlowWalkRadius = 7,
		CrouchRadius = 2,
		IdleRadius = 0,
		MaxEventAge = 8,
	},

	Camera = {
		WalkBobAmplitude = Vector3.new(0.035, 0.055, 0),
		SlowBobAmplitude = Vector3.new(0.018, 0.028, 0),
		CrouchBobAmplitude = Vector3.new(0.012, 0.018, 0),
		BobFrequency = 8,
		IdleBreathAmplitude = 0.012,
		IdleBreathFrequency = 1.1,
		TurnRollStrength = 0.018,
		MaxRollRadians = 0.045,
		CO2TremorAmplitude = 0.025,
		CO2TremorFrequency = 22,
	},

	Flashlight = {
		KeyCode = Enum.KeyCode.F,
		Angle = 38,
		Range = 42,
		Brightness = 2.2,
		TweenTime = 0.18,
		Color = Color3.fromRGB(205, 235, 230),
	},

	Watch = {
		KeyCode = Enum.KeyCode.LeftAlt,
		BasePulse = 70,
		DangerPulse = 110,
		TweenTime = 0.18,
	},

	Breathing = {
		BreathSoundId = "rbxassetid://0",
		MinBreathVolume = 0.1,
		MaxBreathVolume = 0.7,
		MaxBlur = 18,
		VignetteMaxTransparency = 0.35,
		CriticalOverlayTransparency = 0.45,
	},

	Checkpoint = {
		FolderName = "Checkpoints",
		RespawnDelay = 0.15,
		RespawnYOffset = 3,
		RespawnSoundId = "rbxassetid://0",
	},

	Objective = {
		ExitAttribute = "IsDemoExit",
		AirPocketObjectiveDistance = 18,
		NicheObjectiveDistance = 16,
		CompleteFadeTime = 0.35,
		Messages = {
			FindAirPocket = "FIND AIR POCKET — CO2 rising",
			ReachNiche = "REACH MAINTENANCE NICHE — stay quiet",
			Escape = "OPEN EMERGENCY HATCH — end of demo",
			Complete = "SIGNAL FOUND — DEMO COMPLETE",
		},
	},

	Monster = {
		ModelName = "Monster",
		WaypointFolderName = "MonsterWaypoints",
		PatrolSpeed = 6,
		ChaseSpeed = 11,
		HearingCheckInterval = 0.4,
		LoseInterestTime = 6,
		DirectDetectRange = 9,
		AttackRange = 4,
		PathRecomputeInterval = 1,
	},
}
