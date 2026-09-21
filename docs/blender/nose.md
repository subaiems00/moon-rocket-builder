# Nose cone — `nose_classic.glb`

**Path:** `assets/models/nose_classic.glb`
**Slot:** Nose (sticks ABOVE the tank)
**Origin convention:** Bottom of the cone = (0, 0, 0); the cone extends upward (+Z in Blender = +Y in Godot after import).

## Geometry

- Start from a cone primitive (top radius 0.0, bottom radius 0.6 m, depth 1.4 m).
- Apply a `Subdivision Surface` modifier (Levels Viewport = 2).
- Apply a `Bevel` modifier on the bottom edge (0.05 m) to round the lip.
- Add a circular **window** inset 0.3 m above the bottom, radius 0.18 m.
  Make it a separate small sphere embedded slightly into the cone.
- Add a small **antenna** sticking out the top: cylinder radius 0.02 m,
  height 0.3 m.

## Materials

| Mesh        | Material  | Base color             | Notes                              |
|-------------|-----------|------------------------|------------------------------------|
| Cone body   | `nose_white` | `#F5F0E6` (warm white) | Roughness 0.6, no metal            |
| Window      | `glass_blue` | `#7AD7FF`              | Roughness 0.05, semi-transparent   |
| Antenna     | `metal_dark` | `#3A3A4A`              | Roughness 0.4, slight metallic     |

## Dimensions

- Total height: 1.4 m (matches `attach_offset.y = 1.4` in `PartCatalog.gd`)
- Max diameter at base: 1.2 m
- Window diameter: 0.36 m

## Export

*File → Export → glTF 2.0 (.glb)*
- ✅ Apply Modifiers
- ❌ Compression (keep readability)
- ❌ Animation
- ✅ Materials
- Filename: `nose_classic.glb`
