# Booster — `booster_small.glb`

**Path:** `assets/models/booster_small.glb`
**Slot:** Booster (radial around the body, attached with brackets)
**Origin:** Bottom of the booster = (0, 0, 0); booster extends upward.

## Geometry

- Tall thin cylinder: top radius 0.25 m, bottom radius 0.3 m,
  depth 1.6 m.
- Subdivision = 2 (smooth).
- Top cap should be a small dome (half-sphere, scale Y = 0.3).
- Bracket that connects to the body: a small flat plate
  (Box 0.4 × 0.1 × 0.05 m) sticking out from the inner side.
  The builder will rotate the booster so this plate faces inward.
- Two thin **rings** (Torus, minor 0.02 m) at 0.5 m and 1.0 m
  height for visual interest.

## Materials

- Body: `booster_white`, `#E8E8F0`, roughness 0.6.
- Rings: `accent_blue`, `#5A8FE0`.
- Bracket: `metal_dark`, `#3A3A4A`.

## Dimensions

- Total height: 1.6 m
- Diameter: 0.5 m

## Export

Filename: `booster_small.glb`.
