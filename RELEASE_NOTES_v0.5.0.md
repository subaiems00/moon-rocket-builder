# Moon Rocket Builder v0.5.0 — "First Complete Build"

> Phase 1 through Phase 5 are all shipped. The 5-phase roadmap is done.
> This is the first complete build of the prototype.

## Highlights

A stylized 3D cartoon rocket-builder and lunar landing game built in
**Godot 4.3** with **GDScript**. Pick parts, hit LAUNCH, ride the
atmosphere → space transition, and try to land on the Moon — without
realistic engineering, just colorful chaos.

- 🛠 **Modular rocket builder** — pick a nose / body / tank / engine /
  fins / boosters, see stats update live, paint the rocket.
- 🎯 **12 named parts, 6 paint colors, 6 progression-gated unlocks**
  earned by completing your first successful landing.
- 🔥 **Cinematic launch** — countdown → 3-stage ignition → multi-stage
  exhaust (yellow idle → bright orange main thrust) → screen-shake lift-off.
- 🎬 **Failure animations** — confetti on success, dust bursts on
  crash, slow tumble on spin-out, squash-and-settle on every landing.
- 🌍 **Atmospheric transition** — sky blends ground → atmosphere →
  space as you climb; stars and an Earth fade in past 600 m.
- 🎨 **Toon shader** — soft color bands + rim light on every part,
  procedural craters on the moon.
- 📱 **Touch controls** — virtual joystick and boost button for
  tablets; desktop WASD/space still works.
- 💾 **Atomic save** — survives mid-write process kills via
  tmp-then-rename, with backup recovery.
- ⚙️ **Accessibility** — Reduce motion toggle mutes all camera shake.
- ✅ **CI gate** — every push to `main` runs Godot 4.3 headless and
  fails on any parse error.
- 📦 **Export-builds workflow** — `.github/workflows/export-builds.yml`
  builds Windows / Linux / macOS / Web binaries on every tag push and
  attaches them to the GitHub release.

## Run it

**Requirements:** Godot 4.3 or newer ([download](https://godotengine.org/download)).

```bash
git clone https://github.com/subaiems00/moon-rocket-builder.git
cd moon-rocket-builder
# Open project.godot in Godot, press F5.
```

Pre-built binaries are attached to every release at
https://github.com/subaiems00/moon-rocket-builder/releases — no Godot
install required, just download and run.

That's it — no dependencies to install, no build step. The procedural
SFX are synthesized at runtime, the toon shader is included, every
part has a primitive-mesh fallback. Drop a `.glb` export from Blender
into `assets/models/` and the loader picks it up automatically (see
[`docs/blender/README.md`](https://github.com/subaiems00/moon-rocket-builder/blob/main/docs/blender/README.md)).

## Controls

| Context | Action |
|---------|--------|
| Menus   | Mouse  |
| Flight  | `W` / `↑` thrust • `S` / `↓` pitch down • `A`/`D` yaw • `Space` boost |

## What ships in this release

**Phase 1 — Prototype**: 11 scenes, modular rocket builder, cinematic
launch, arcade flight, results screen, settings, procedural SFX,
save system.

**Phase 2 — Gameplay**: fuel-pressure physics, real stability math,
wind gusts, 7 failure-event classifications, score multipliers
(×1.0 / ×1.5 low-fuel / ×2.0 perfect), progression-gated unlocks.

**Phase 3 — Visual polish**: toon shader, moon shader with procedural
craters, sky gradient (ground → atmosphere → space), 2200-star star
field, 8 procedural cloud clusters, Earth, Blender `.glb` loader with
10 asset specs.

**Phase 4 — Game feel**: 3-stage ignition, cinematic camera dolly,
additive camera shake, fade-through-black screen transitions,
per-failure beats (confetti / dust / tumble), virtual joystick +
boost button, UI micro-interactions.

**Phase 5 — Polish**: atomic save with backup + corruption recovery,
schema versioning, `PerformanceManager` autoload (FPS/physics
locks), Reduce motion accessibility toggle, Reset defaults, settings
validation, CONTRIBUTING.md + PR template + CODEOWNERS, rendering
budget in `project.godot`.

**Export pipeline**: `export_presets.cfg` defines Windows / Linux /
macOS / Web presets; `.github/workflows/export-builds.yml` builds all
platforms on every `v*` tag and attaches the binaries to the release.

## Known limitations / what's deferred

- No `.glb` assets shipped — primitive meshes only. The loader is
  fully wired and 10 Blender recipes are provided. Drop a `.glb` into
  `assets/models/` to swap it in (no code changes).
- One ambient loop SFX per scene — the existing procedural SFX are
  enough for a prototype, but real `.ogg` files would be a clear
  upgrade.
- No localization — UI strings are inline English. The strings are
  factored enough that adding `ar.po` / `es.po` would be straightforward.
- Mobile-specific tuning (dpi scaling, notch handling) is unverified
  — touch controls ship, but the rest of the UI was designed for
  1280×720 desktop.

## Stats

- 85+ files committed
- ~260 KB uncompressed source
- 6 Godot autoloads (GameManager, AudioManager, SaveManager, UIManager,
  ScreenTransition, PerformanceManager)
- 17 GDScript classes
- 11 scenes, 3 custom shaders
- 4 export presets (Windows / Linux / macOS / Web)

## Acknowledgements

Built with [Godot Engine](https://godotengine.org/) 4.3. CI runs on
[GitHub Actions](https://github.com/features/actions).

— Munther (subaiems00), September 2026
