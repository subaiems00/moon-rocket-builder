# Launch platform — `platform.glb`

**Path:** `assets/models/platform.glb`
**Used in:** LaunchPad scene (under the rocket)
**Origin:** Center of the platform = (0, 0, 0); platform extends along XZ plane.

## Geometry

- A short cylinder (the base disc): radius 4.0 m, height 0.5 m.
- 4 **flame trench slots**: rectangular cuts at N, E, S, W around
  the base, each 1.2 m × 0.5 m × 0.3 m deep. Just visible notches
  cut into the platform — model them as small dark recessed boxes.
- A **centered concrete pad** under the rocket: cylinder radius 1.0 m,
  height 0.1 m, slightly raised.
- 4 small **safety bollards** at the corners: small yellow spheres
  or capsules 0.2 m tall.

## Materials

| Mesh          | Material     | Base color       |
|---------------|--------------|------------------|
| Base disc     | `pad_concrete` | `#9B9B95` (warm gray) |
| Flame trenches | `pad_dark`   | `#1A1A1F`         |
| Center pad    | `pad_white`  | `#F0F0F0`         |
| Bollards      | `pad_yellow` | `#D9B040`         |

## Dimensions

- Base radius: 4 m
- Center pad radius: 1 m
- Footprint: 8 m × 8 m

## Export

Filename: `platform.glb`.
