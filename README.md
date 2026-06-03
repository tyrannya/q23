# INVERTED Roblox Demo

Rojo/Luau scaffold for a 5–10 minute horror prototype of **INVERTED**: a first-person survival slice inside an inverted research vessel.

## What is included

- Shared `Config` module with balance values for CO₂, movement, noise, camera, flashlight, watch UI, checkpoints, and the monster.
- Shared `Signals` module that creates/returns `RemoteEvent` instances under `ReplicatedStorage.Shared.Remotes`.
- First-person movement controller with walk / slow-walk / crouch states and server noise emission.
- Body-cam camera controller with subtle bob, turn roll, idle breathing motion, and CO₂ tremor.
- Toggleable camera-facing flashlight.
- Server-authoritative CO₂ service with `AirPocket` tag / `IsAirPocket` attribute support.
- Client breathing effects and watch UI.
- Checkpoint respawn service.
- Blind monster state machine driven by noise and proximity, not vision.
- Runtime greybox builder that creates the demo corridor, a dressed bio-lab air-pocket room, a stealth bunk room with cover, maintenance niche, emergency hatch, checkpoints, patrol waypoints, spawn, and a placeholder monster if they do not already exist in Studio.
- Objective flow and minimal objective UI so the demo has a start-to-finish path: find air, reach the niche, open the hatch.

## Rojo setup

1. Install Roblox Studio and the Rojo Studio plugin.
2. Install Rojo locally.
3. From this repository, run:

   ```bash
   rojo serve
   ```

4. Connect the Studio plugin to the Rojo server.
5. Press **Play**. `LevelBuilder.server.luau` will create a minimal playable greybox scene unless you already created your own `Workspace/Ship` or `Workspace/Monster`.

## Studio scene requirements

The generated scene is enough for a first playtest. If you replace it with hand-built content, keep these names/contracts:

- `Workspace/Ship` contains the playable corridor/rooms.
- `Workspace/Ship/EmergencyHatch_Exit` or another exit part has boolean attribute `IsDemoExit = true`.
- `Workspace/Monster` model has `Humanoid` and `HumanoidRootPart`.
- `Workspace/MonsterWaypoints` contains waypoint parts; optional `Order` attributes control patrol order.
- `Workspace/Checkpoints` contains invisible checkpoint parts; optional `Order` attributes are available for designers.
- Air pocket parts use CollectionService tag `AirPocket` or boolean attribute `IsAirPocket = true`.

## Generated rooms

- **Room A — Atlas Bio-Lab / Air:** specimen tanks, fallen shelves, lab tables, floating debris, cyan vent glow, and the active `AirPocket_01` CO₂ recovery zone.
- **Room B — Crew Berth / Quiet:** overturned bunks, mattresses, lockers, a central grate/noise-trap landmark, and red emergency light for the stealth encounter.

## Recommended lighting

The Rojo project config and runtime builder set a dark baseline with cold color correction and atmosphere. Use `Lighting.Technology = Future` for stronger shadows and flashlight mood.

## Controls

- Move: default Roblox movement keys.
- Slow walk: hold **Left Shift**.
- Crouch: hold **C** or **Left Ctrl**.
- Flashlight: press **F**.
- Watch: hold **Left Alt**.

## Current demo route

1. Start in the inverted corridor.
2. Reach the dressed Room A bio-lab and its `AirPocket_01` vent zone to lower CO₂.
3. Cross Room B, using overturned bunks/lockers as quiet cover while the monster patrols/reacts to noise.
4. Touch the emergency hatch exit to complete the demo slice.

## Validation

Run the lightweight repository checks before updating a PR or resolving merge conflicts:

```bash
python3 scripts/validate_project.py
```

This validates `default.project.json`, required Rojo paths, unresolved conflict markers, and basic Luau delimiter sanity.
