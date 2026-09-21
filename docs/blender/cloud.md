# Cloud puffs — `cloud_01.glb` … `cloud_05.glb`

**Path:** `assets/models/cloud_NN.glb` (NN = 01..05)
**Used in:** Flight scene atmosphere
**Origin:** Center of the cluster = (0, 0, 0).

## Geometry

Each cloud is a cluster of 3–5 **overlapping scaled spheres**.

For `cloud_01.glb` (small puff):
- 3 spheres, radius 1.5 m each.
- Place them at offsets like `(0,0,0)`, `(1.4, 0.2, 0)`, `(-1.0, -0.1, 0.5)`.
- Merge into a single mesh.

For `cloud_02.glb` (long cloud):
- 4 spheres in a row, slightly offset on Y for natural variation.

For `cloud_03.glb` (big puffy):
- 6 spheres in a roughly hexagonal pattern, radius 1.8 m each.

For `cloud_04.glb` (small wispy):
- 2 spheres, radius 1.2 m, slightly offset.

For `cloud_05.glb` (top cloud):
- 4 spheres stacked vertically, larger on top, smaller at bottom.

## Materials

- `cloud_white`: `#FAFAFF` (cool white).
- Roughness 1.0, no metal.
- **Slight subsurface look**: subsurface scattering 0.05, backlight
  color #B0C8E0, gives that soft volumetric cartoon feel.
- Vertex colors optional — add subtle blue tint to the underside.

## Dimensions

- Each cluster spans ~4–6 m.

## Export

Filename: `cloud_NN.glb`. No animation.
