# Fin — `fin_tri.glb`

**Path:** `assets/models/fin_tri.glb`
**Slot:** Fin (radial around the body bottom)
**Origin:** Inner edge (closest to body) at (0, 0, 0); the fin extends outward along +X.

> A single fin is exported. The builder clones it 4 times around the body
> at 90° intervals. Don't worry about angular placement — model it pointing
> along +X and the builder handles the rotation.

## Geometry

- Triangle prism: 1.0 m tall, 1.2 m wide at base, tapering to a point
  at the top (use a scaled cone or a custom mesh).
- Use the **Pyramid** primitive in Blender (radius 0.4 m, depth 1.0 m),
  then scale Z = 1.0 (tall) and add a **Bisect** operation to keep
  only one half (mirrored to make a flat triangle).
- Bevel the leading edge (0.06 m) for a chunky cartoon look.
- Inner edge should be flat so it sits flush against the body cylinder.

## Materials

- Single material: `fin_red`, `#FF6B6B`, roughness 0.6, no metal.

## Dimensions

- Total height: 1.0 m
- Width at base: 1.2 m
- Thickness: 0.1 m

## Export

Filename: `fin_tri.glb`.
