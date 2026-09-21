# Blender → Godot workflow

This project is **art-ready**. Every rocket part is described by a
`RocketPartData` resource (see `resources/RocketPartData.gd`). Each
resource can point to a `.glb` file via `glb_path`. The rocket builder
will prefer the `.glb` when present, falling back to `primitive_mesh`
when not.

This means you can drop new models into `assets/models/` and have them
appear in-game **without any code changes**.

---

## Naming

| Part id              | Suggested file name                       |
|----------------------|-------------------------------------------|
| `nose_classic`       | `assets/models/nose_classic.glb`          |
| `nose_pointy`        | `assets/models/nose_pointy.glb`           |
| `body_classic`       | `assets/models/body_classic.glb`          |
| `body_chubby`        | `assets/models/body_chubby.glb`           |
| `tank_basic`         | `assets/models/tank_basic.glb`            |
| `tank_jumbo`         | `assets/models/tank_jumbo.glb`            |
| `engine_standard`    | `assets/models/engine_standard.glb`       |
| `engine_boost`       | `assets/models/engine_boost.glb`          |
| `fin_tri`            | `assets/models/fin_tri.glb`               |
| `fin_square`         | `assets/models/fin_square.glb`            |
| `booster_small`      | `assets/models/booster_small.glb`         |
| `booster_big`        | `assets/models/booster_big.glb`           |

(Other assets: `tower.glb`, `launchpad.glb`, `moon.glb`,
`cloud_01.glb` … `cloud_05.glb`, `satellite_01.glb`.)

---

## How to author a single rocket part in Blender

1. **New scene.** Delete the default cube.
2. **Mesh the part.** Use the part's *real-world footprint* in meters
   (≈ 1 unit = 1 meter). For Phase 1's defaults, target
   `~0.6–0.9 m` radius and `~1.0–2.4 m` height.
3. **Set the part origin.** The origin is the snap point — the bottom
   of the part where it meets the next-lower part. Move the geometry so
   the bottom face touches the world origin (Z = 0 in Blender, which
   becomes Y = 0 in Godot because of axis swap).
4. **Single root object.** If you have multiple sub-meshes (e.g. body
   + window + bolts), parent them to a single empty at the origin.
5. **Apply transforms.** Press **Ctrl-A → All Transforms**.
6. **Scale check.** Verify the model size in the viewport — Godot
   inherits 1 unit = 1 meter.
7. **UV unwrap** if you want to use a texture. For the Phase 1
   cartoon look, you can also just rely on vertex colors.
8. **Materials.** Use simple Principled BSDFs (Base Color, Roughness,
   optional Emission). Avoid metallic anything above 0.4 — toon shading
   reads better with matte surfaces.
9. **Save as** `assets/models/<part_id>.glb`.

### Godot-side alignment

Godot's coordinate system is **Y-up**, Blender is **Z-up**. The
GLTF importer in Godot 4 handles this automatically (Y-up to Y-up,
Z-up rotation applied at import time). So your model will appear
standing upright in the Godot preview without manual rotation.

### Attachment convention

| Slot      | Origin                              | Stack direction |
|-----------|-------------------------------------|-----------------|
| Nose      | Bottom of cone                      | Sits ABOVE tank |
| Body      | Bottom of cylinder                  | Center          |
| Tank      | Bottom of cylinder                  | Above body      |
| Engine    | Top of bell (nozzle exits downward) | Below body      |
| Fin       | Inner (top) edge near body          | Radial          |
| Booster   | Bottom                              | Radial          |

The `attach_offset` field on each `RocketPartData` records how far the
**next** part should sit above this one in world space (Y axis).
Make sure your model's height along the stacking axis matches the
`attach_offset` declared in `PartCatalog.gd` (default ≈ 1.4–2.4 m).

---

## Exporting from Blender

1. **File → Export → glTF 2.0 (.glb)**.
2. Recommended settings:
   - Format: **glTF Binary (.glb)**
   - ✅ Apply Modifiers
   - ✅ Compression
   - Texture format: **Auto**
   - Materials: **Export**
   - ❌ do NOT check "Animation" (animations stay in Godot).
3. Filename: matches the part id, e.g. `nose_classic.glb`.

Place the file at `assets/models/<part_id>.glb`. The next time the game
runs, `RocketBuilder` will pick it up.

---

## Authoring the moon

1. Subdivision sphere, ~5 m radius.
2. Use a noise-based displacement or just paint subtle dark spots via
   vertex colors / texture.
3. Origin = center.
4. Export to `assets/models/moon.glb`. Phase 3 will replace
   `Moon.tscn`'s primitive with `MoonMesh.instance()` from this glb.

---

## Authoring clouds

1. Cluster of 3–5 metaballs or scaled spheres, all parented to one empty.
2. Origin = center of the cluster.
3. Materials: white, fully rough, slight subsurface tint.
4. Export `assets/models/cloud_01.glb` … `cloud_05.glb`.
5. `ParticleManager.build_cloud()` will be swapped to load a random
   cloud `.glb` per particle.
