# Fuel tank — `tank_basic.glb`

**Path:** `assets/models/tank_basic.glb`
**Slot:** Tank (sits ABOVE the body)
**Origin:** Bottom of the tank = (0, 0, 0); tank extends upward.

## Geometry

- Cylinder primitive: radius 0.6 m, depth 1.6 m.
- Subdivision Surface Levels = 2.
- Top cap should be a slight dome — model a UV sphere with the top
  half, scale Y to 0.25, place at the top of the cylinder and merge.
- Add 3 thin **panel lines** (small indented rectangles, scale 0.6 × 0.04 × 0.02 m)
  placed at 0.4 m, 0.8 m, 1.2 m height, distributed evenly around the circumference.
- One **fuel gauge** window (small dark inset) at 0.5 m height on the +Z side.

## Materials

| Mesh      | Material   | Base color      |
|-----------|------------|-----------------|
| Tank body | `tank_blue` | `#6FA8E0` (light cobalt)  |
| Gauge     | `glass_dark` | `#1A2530` (almost black)  |
| Panels    | same as body | subtle line indents — use a single slightly darker shade via Vertex Colors |

## Dimensions

- Total height: 1.6 m
- Diameter: 1.2 m
- Dome top adds 0.2 m above the cylinder (extra 1.6 m flat + 0.2 m dome)

## Export

Filename: `tank_basic.glb`.
