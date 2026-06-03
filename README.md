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

## Rojo setup

1. Install Roblox Studio and the Rojo Studio plugin.
2. Install Rojo locally.
3. From this repository, run:

   ```bash
   rojo serve
   ```

4. Connect the Studio plugin to the Rojo server.

## Studio scene requirements

Create these objects in Studio for the demo systems to activate:

- `Workspace/Monster` model with `Humanoid` and `HumanoidRootPart`.
- `Workspace/MonsterWaypoints` folder containing waypoint parts; optional `Order` attributes control patrol order.
- `Workspace/Checkpoints` folder containing invisible checkpoint parts; optional `Order` attributes are available for designers.
- Air pocket parts tagged with CollectionService tag `AirPocket` or with boolean attribute `IsAirPocket = true`.

## Recommended lighting

The Rojo project config sets a dark baseline with a cold color correction and atmosphere. In Studio, use `Lighting.Technology = Future` for stronger shadows and flashlight mood.
