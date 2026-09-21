# Body — `body_classic.glb`

**Path:** `assets/models/body_classic.glb`
**Slot:** Body (center of the rocket)
**Origin:** Bottom of the cylinder = (0, 0, 0); cylinder extends upward.

## Geometry

- Start from a cylinder primitive (radius 0.6 m, depth 2.4 m).
- Subdivision Surface Levels Viewport = 2 (smooth body).
- Bevel top + bottom edges at 0.04 m.
- Add **2 stripe decals** around the body: thin torus rings at 0.6 m
  and 1.8 m above the bottom (use Torus, major 0.62 m, minor 0.04 m).
- Optional: a single round **porthole window** 0.35 m diameter at
  1.2 m height on the +X side.

## Materials

| Mesh       | Material   | Base color      | Notes                          |
|------------|------------|-----------------|--------------------------------|
| Cylinder   | `body_white` | `#F8F4FF` (cool white) | Slight blue tint           |
| Stripe rings | `accent_red` | `#FF5C5C`     | Roughness 0.5, no metal        |
| Porthole   | `glass_blue` | `#7AD7FF`      | (same as nose)                 |

## Dimensions

- Total height: 2.4 m (matches `attach_offset.y = 2.4`)
- Diameter: 1.2 m
- 2 stripes at 0.6 m and 1.8 m

## Export

Same as nose. Filename: `body_classic.glb`.
