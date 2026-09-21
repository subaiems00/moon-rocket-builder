# Phase 3 — Visual polish test plan

## What shipped in Phase 3

| Feature                          | Where                                  |
|----------------------------------|----------------------------------------|
| Toon shader (cartoon shading)    | `shaders/toon.gdshader` + applied to every rocket part |
| Moon shader (procedural craters) | `shaders/moon.gdshader` + `ParticleManager.build_moon` |
| Earth (procedural continents)    | `ParticleManager.build_earth` |
| Sky gradient (3-band blend)      | `shaders/sky.gdshader` + `FlightManager` driver |
| Star field (2200 stars, tinted)  | `ParticleManager.build_stars` |
| Cloud puff clusters              | `ParticleManager.build_cloud_cluster` + `ScenePopulator` |
| Wind gust puff (one-shot)        | `ParticleManager.build_wind_puff` + HUD wire |
| `.glb` asset loader              | `scripts/AssetLoader.gd` + `RocketPartData.glb_path` |
| Blender asset specs              | `docs/blender/` (10 recipes + README) |
| LaunchPad overhaul               | `scenes/LaunchPad.tscn` (grass, platform, gantry, exhaust light) |
| FlightScene overhaul             | `scenes/FlightScene.tscn` (stars, earth, clouds, sky shader) |

## How to test

### 1. Toon shading on parts
- [ ] Open Workshop — every rocket part has visible color bands and a
      rim glow against the dark sky.
- [ ] Paint the rocket white → all parts switch to white with red rim
      glow on the engines.

### 2. Toon shading on the moon
- [ ] In the flight scene, the moon shows clear darker patches (craters).
- [ ] Tints the same shader produces continents on the Earth (visible
      when looking back down).

### 3. Atmospheric transition
- [ ] Fly the rocket from ground level.
- [ ] Below 600 m: blue sky, no stars, clouds visible.
- [ ] 600–1500 m: stars begin fading in, clouds begin fading out, sky
      deepens toward purple.
- [ ] Above 1500 m: black sky, full star field, no clouds. Earth
      fades in below.

### 4. Star field
- [ ] ~2200 stars visible behind the moon.
- [ ] Stars have subtle color variation (mostly white, some pale
      yellow, some pale blue).

### 5. Cloud puffs
- [ ] Visible between 200 m and 1200 m altitude.
- [ ] Each cluster is 4 overlapping spheres (puffy cumulus look).
- [ ] 8 clusters scattered at varied positions.

### 6. Wind gust visualizer
- [ ] Below 1500 m, wait for a wind gust event (4–10 s intervals).
- [ ] A cloud puff spawns at the rocket's position, billboarded,
      fades over ~0.8 s.
- [ ] The HUD shows a brief "💨 Gust!" flash.

### 7. .glb swap-in
- [ ] Drop any `.glb` file at `assets/models/nose_classic.glb`.
- [ ] Restart the game. The Workshop's nose now uses the `.glb`
      instead of the primitive capsule. The toon shader applies
      automatically on top.
- [ ] Remove the `.glb`, restart → falls back to primitive capsule.

### 8. LaunchPad visuals
- [ ] Green grass ground.
- [ ] Cylindrical launch platform under the rocket.
- [ ] Yellow tower with 3 white gantry arms reaching toward the rocket.
- [ ] Red warning lights at the top of the tower pulse during the
      countdown.
- [ ] During ignition, a bright orange `OmniLight` below the rocket
      ramps up.

### 9. Earth visible from space
- [ ] Once you exceed 1500 m, an Earth appears below (back of the
      camera when looking up).
- [ ] Has visible cartoon continents (green patches).

## Known gaps (Phase 4+)
- Outlines: planned via duplicate-inverted-hull mesh, not yet wired.
- Animated Earth rotation: not yet — it's static for now.
- Per-launch sky variation: same colors every flight. Phase 4 may add
  sunrise/sunset variants.
- Cloud shadows on the ground: not yet — would need shadow-atlas setup.
