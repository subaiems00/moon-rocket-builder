# Launch tower — `tower.glb`

**Path:** `assets/models/tower.glb`
**Used in:** LaunchPad scene
**Origin:** Base of the tower at (0, 0, 0); tower extends upward.

## Geometry

A gantry-style launch tower:

- **Main pylon**: cylinder, radius 0.4 m, height 11 m.
- **Gantry arms**: 3 horizontal box arms reaching OUT from the tower
  toward the rocket at heights 4 m, 6 m, 8 m. Each arm: Box
  (1.5 × 0.2 × 0.2 m), one end attached to the tower.
- **Cross-bracing**: add 4 diagonal struts (thin cylinders) along
  the pylon for that classic launch-tower look.
- **Service platform**: a small disc (cylinder, radius 1.0 m,
  height 0.1 m) at the top, where the rocket sits before launch.
- **Warning light cluster**: 2 small spheres at the top of the pylon,
  emissive red, position 0.5 m above the platform.

## Materials

| Mesh                | Material        | Base color       |
|---------------------|-----------------|------------------|
| Main pylon          | `tower_yellow`  | `#D9B040`        |
| Gantry arms         | `tower_white`   | `#F5F5F5`        |
| Cross bracing       | `metal_dark`    | `#3A3A4A`        |
| Service platform    | `tower_white`   | (same)           |
| Warning lights      | `light_red`     | `#FF5050`, **Emission 3.0** |

## Dimensions

- Pylon height: 11 m
- Gantry arms extend 1.5 m outward
- Total tower footprint: ~3 m radius

## Export

Filename: `tower.glb`. No animation (warning lights pulse via Godot
script, not Blender keyframes).
