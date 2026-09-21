# Blender asset specs — Moon Rocket Builder

This folder contains per-asset recipes. Each is a markdown spec that
describes the geometry, materials, and export settings for one `.glb`
that the game will load.

**Quick start for the artist:**

1. Open Blender 4.x.
2. New scene → delete default cube.
3. Follow the recipe for one part.
4. Export: *File → Export → glTF 2.0 (.glb)* with the settings listed
   at the bottom of every recipe.
5. Drop the file at the path the recipe specifies
   (e.g. `assets/models/nose_classic.glb`).
6. The next time the game runs, `RocketBuilder` will pick it up.

**Axis convention:** Godot is Y-up, Blender is Z-up. The glTF importer
handles this automatically — your model will appear standing upright
in Godot without manual rotation. Just model in Z-up and export.

**Scale:** 1 unit = 1 meter. Godot reads it directly.

**Origin:** The **origin is the attach point**. The bottom of the
rocket part sits at (0, 0, 0); the rocket stacks upward from there.
See each recipe for the per-part convention.

---

## Files in this folder

| Spec | Resulting `.glb` | Used in |
|------|-------------------|---------|
| [nose.md](nose.md)         | `assets/models/nose_classic.glb`         | Workshop preview + Launch |
| [body.md](body.md)         | `assets/models/body_classic.glb`         | Workshop preview + Launch |
| [tank.md](tank.md)         | `assets/models/tank_basic.glb`           | Workshop preview + Launch |
| [engine.md](engine.md)     | `assets/models/engine_standard.glb`      | Workshop preview + Launch |
| [fin.md](fin.md)           | `assets/models/fin_tri.glb`              | Workshop preview + Launch |
| [booster.md](booster.md)   | `assets/models/booster_small.glb`        | Workshop preview + Launch |
| [moon.md](moon.md)         | `assets/models/moon.glb`                 | Flight scene |
| [cloud.md](cloud.md)       | `assets/models/cloud_01.glb` … cloud_05 | Flight scene atmosphere |
| [tower.md](tower.md)       | `assets/models/tower.glb`               | Launch pad |
| [platform.md](platform.md) | `assets/models/platform.glb`            | Launch pad |

---

## Style guide

All assets should match these visual rules:

- **Rounded, chunky forms.** No sharp edges. Use bevel modifiers
  liberally. Target a `Bevel > Width / 0.04 m` on every part.
- **Exaggerated proportions.** Bigger engines, wider fins, rounder
  nose cones than realistic.
- **Bright, saturated colors.** Avoid muted grays.
- **Hand-painted feel.** Solid color + soft bevel + light texture noise.
  No PBR realism.
- **Strong readable silhouette.** A child should recognize a rocket
  at a glance.
- **No small details under 5 cm.** They won't read on screen and will
  cost polygon budget.

---

## Default material setup

Use a Principled BSDF with these baseline values:

| Input        | Value (default) | Notes                                  |
|--------------|-----------------|----------------------------------------|
| Base Color   | per-asset       | See the recipe                         |
| Roughness    | 0.55            | Soft cartoon                           |
| Metallic     | 0.0             | Pure cartoon, no realism               |
| Specular     | 0.3             | Glints but doesn't reflect             |
| Sheen        | 0.0             | Off                                    |
| Clearcoat    | 0.0             | Off                                    |

For **emissive parts** (engines, lights, indicator strips) bump
`Emission Color` to match the part's accent and `Emission Strength`
to 1.5–3.0.
