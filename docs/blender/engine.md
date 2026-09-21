# Engine — `engine_standard.glb`

**Path:** `assets/models/engine_standard.glb`
**Slot:** Engine (sits BELOW the body)
**Origin:** **Top of the bell nozzle** = (0, 0, 0); engine extends downward.

> Note: the engine origin is *flipped* compared to body/tank/nose.
> The rocket builder rotates the engine instance by 180° around X so
> its bell nozzle exits downward. Don't worry — model in this spec's
> orientation and the engine will appear in the right place in-game.

## Geometry

- Bell nozzle: cylinder with tapered profile. Top radius 0.45 m,
  bottom radius 0.7 m, depth 1.2 m. Subdivision = 3 (smooth).
- **Nozzle lip ring**: torus at the bottom, major 0.7 m, minor 0.06 m,
  bright accent color.
- **Combustion chamber dome**: half-sphere on TOP of the bell,
  radius 0.5 m, flat side down. Color matches the body.
- **Fins on the bell**: 4 small fins (NOT to be confused with the
  rocket's main fins — these are on the engine itself), placed at
  0°, 90°, 180°, 270° around the bell, 0.5 m wide × 0.2 m tall,
  tapering.

## Materials

| Mesh         | Material     | Base color      | Notes                          |
|--------------|--------------|-----------------|--------------------------------|
| Bell nozzle  | `metal_dark` | `#3A3A4A`       | Roughness 0.5, slight metal    |
| Lip ring     | `engine_glow`| `#FFB347`       | **Emission: 2.5** strength     |
| Dome         | `body_white` | `#F8F4FF`       | Same as body                   |
| Bell fins    | `metal_dark` | (same as bell)  |                                |

## Dimensions

- Bell nozzle depth: 1.2 m
- Bell nozzle top: 0.9 m diameter
- Bell nozzle bottom: 1.4 m diameter (chopped-cone / flared)
- Dome adds 0.5 m above the bell

## Why the origin is the TOP

Modeling with origin = top lets you `Ctrl-A → All Transforms` and
export without surprises. The `RocketBuilder` knows to flip the engine
instance by 180° around X so the bell points downward when attached.
The internal `attach_offset` for the engine slot is `Vector3.ZERO` —
the engine is positioned at the body's bottom edge by the builder.

## Export

Filename: `engine_standard.glb`.
