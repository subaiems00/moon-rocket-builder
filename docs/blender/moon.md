# Moon — `moon.glb`

**Path:** `assets/models/moon.glb`
**Used in:** Flight scene (replaces the primitive sphere)
**Origin:** Center of the sphere = (0, 0, 0).

## Geometry

- UV sphere, radius 5.0 m, segments 64, rings 32.
- Apply a `Subdivision Surface` modifier level 2 for a smoother
  cartoon look (still low enough to render fast).
- **Craters**: scatter 8–12 small craters around the visible hemisphere.
  Each crater:
  - Outer ring: torus, major 0.4–0.8 m, minor 0.05–0.1 m.
  - Inner shade: a small flat disk recessed into the sphere surface,
    color slightly darker than the moon base.
- Don't add too many craters — a "less is more" approach reads
  better at distance.

## Materials

- Single material: `moon_base`, `#F5EFD9` (warm cream).
- Roughness 0.95, no metal.
- **Optional emission**: very subtle warm tint at `Emission 0.05`
  to give it a glow against space.
- Crater inner shade via Vertex Colors (paint a slightly darker
  tone inside each crater ring).

## Dimensions

- Radius: 5.0 m

## Export

Filename: `moon.glb`. Scale 1.0, no animation, no compression.
