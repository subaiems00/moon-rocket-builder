# 🚀 Moon Rocket Builder

![Godot](https://img.shields.io/badge/Godot-4.3+-478cbf?logo=godotengine&logoColor=white)
![GDScript](https://img.shields.io/badge/GDScript-100%25-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Status](https://img.shields.io/badge/All%205%20phases-shipped-brightgreen)
[![CI](https://github.com/subaiems00/moon-rocket-builder/actions/workflows/godot-validate.yml/badge.svg)](https://github.com/subaiems00/moon-rocket-builder/actions/workflows/godot-validate.yml)
[![Latest release](https://img.shields.io/github/v/release/subaiems00/moon-rocket-builder?label=Download)](https://github.com/subaiems00/moon-rocket-builder/releases/latest)

A stylized 3D cartoon rocket-builder and lunar landing game.
Assemble modular parts, ignite, ride the atmosphere → space transition,
and try to land on the Moon.

> Playful, cinematic, satisfying — not realistic, not military, no real
> engineering specs. Built in **Godot 4.x** with **GDScript**, with
> **Blender** as an optional asset pipeline.

---

## ✨ What's in Phase 1

- 🛠 **Modular rocket builder** — pick a nose / body / tank / engine /
  fins / boosters, see stats update live
- 🎨 **Paint swatches** — recolor every part with one click
- 🔥 **Cinematic launch sequence** — countdown, warning lights,
  particle exhaust, smoke, sparks, camera shake
- 🌍 **Atmospheric transition** — sky color, fog, and stars change
  with altitude
- 🌙 **Arcade flight** — `WASD` controls, chase camera, fuel & stability
- 🏆 **Results screen** — score, altitude, fuel, coins earned
- 💾 **Local save** — coins, unlocks, best altitude, settings persist
- ⚙️ **Settings** — master / music / SFX / camera shake / mute
- 🔊 **Procedural audio** — no .wav files needed; everything is synthesized
  at runtime so the project is fully playable out-of-the-box
- 🎭 **Toon shader + sky shader** — ready for the Phase 3 art pass

## 🎮 Controls

| Context  | Action                              |
|----------|-------------------------------------|
| Menus    | Mouse                               |
| Flight   | `W` / `↑` — thrust                  |
|          | `S` / `↓` — brake / pitch down      |
|          | `A` / `D` — yaw                     |
|          | `Space` — main engine / booster     |

Touch controls are a planned Phase 2 addition.

## 🏃 Quick start

1. Install **Godot 4.3 or newer** ([download](https://godotengine.org/download)).
2. **Pre-built binaries**: grab the latest release at
   [github.com/subaiems00/moon-rocket-builder/releases/latest](https://github.com/subaiems00/moon-rocket-builder/releases/latest)
   — Windows `.exe`, Linux `.x86_64`, macOS `.app`, or Web `.html`.
   No Godot install required.
3. **Or run from source**:
   ```bash
   git clone https://github.com/subaiems00/moon-rocket-builder.git
   cd moon-rocket-builder
   # Open project.godot in Godot, press F5.
   ```

> **No Blender required.** Every rocket is built procedurally from
> `CapsuleMesh`, `CylinderMesh`, `PrismMesh`, and `BoxMesh` primitives
> declared in `resources/PartCatalog.gd`. Drop in `.glb` exports later
> — the loader is already wired to prefer them.

## 📦 Project layout

```
moon_rocket_builder/
├── project.godot                # Godot 4.x project file (autoloads, input map, render)
├── assets/                      # Optional textures / icon
├── autoload/                    # Singletons (GameManager, AudioManager, Save, UI)
├── resources/                   # RocketPartData, PaintData, DecalData, catalogs
├── scripts/                     # Core gameplay logic
│   ├── RocketBuilder.gd         # Modular assembly engine
│   ├── RocketController.gd      # Arcade flight physics
│   ├── LaunchSequence.gd        # Countdown → ignition → lift-off
│   ├── FlightManager.gd         # Phase state machine
│   ├── CinematicCamera.gd       # Smooth-follow cam + procedural shake
│   ├── ChaseCamera.gd           # Behind-and-above flight cam
│   ├── ParticleManager.gd       # Procedural GPU particle factory
│   ├── FlightController.gd      # End-to-end orchestrator
│   └── ui/                      # All Control scripts + button/bar helpers
├── shaders/                     # toon.gdshader + sky.gdshader
├── scenes/                      # All 11 .tscn files (6 required + reusable parts)
└── docs/                        # Phase docs + Blender workflow
```

## 🏗 Architecture

- **Singletons (autoloads) own state, not scenes.**
  `GameManager` (currency / unlocks / save data), `AudioManager`
  (buses + SFX), `SaveManager` (I/O), `UIManager` (scene router),
  `ScreenTransition` (global fade overlay), `PerformanceManager`
  (FPS / physics locks).
- **Signals, not direct refs.** Screens connect to autoload signals
  (`coins_changed`, `flight_finished`, `settings_changed`).
- **Resources for data.** Every rocket part is a `RocketPartData`;
  `PartCatalog` returns them by slot. UI buttons call
  `builder.install_part(slot, part)` — visuals update instantly.
- **Procedural where it matters.** Particles, exhaust, SFX, star
  fields all generate at runtime so the prototype runs without
  imported `.wav` / `.png` assets.
- **Blender is optional.** Set `data.glb_path` on a `RocketPartData` and
  the builder loads it instead of the primitive mesh. Code stays the
  same — visuals improve.

## 🛠 Build pipeline

Every push to a `v*` tag triggers `.github/workflows/export-builds.yml`,
which builds the project for **Windows / Linux / macOS / Web** in
parallel and attaches the binaries to the GitHub release. The same
workflow can be triggered manually via the Actions tab
(`workflow_dispatch`) for ad-hoc builds that don't attach to any
release.

Local equivalent (requires Godot 4.3+ and the matching export
templates in `~/.local/share/godot/export_templates/4.3.stable/`):

```bash
godot --headless --export-release "Windows Desktop" --path .
godot --headless --export-release "Linux/X11 Desktop" --path .
godot --headless --export-release "macOS Desktop" --path .
godot --headless --export-release "Web" --path .
```

Export presets live in `export_presets.cfg`. Edit them in Godot's
*Project → Export* dialog or by hand.

## 🛣 Roadmap

| Phase | Theme              | Status      |
|-------|--------------------|-------------|
| 1     | Prototype          | ✅ shipped   |
| 2     | Gameplay loop      | ✅ shipped   |
| 3     | Visual polish      | ✅ shipped   |
| 4     | Game feel          | ✅ shipped   |
| 5     | Optimization       | ✅ shipped   |

See [`docs/phase-1.md`](docs/phase-1.md) for the Phase 1 test plan and
[`docs/blender-workflow.md`](docs/blender-workflow.md) for how to add
Blender models without changing code.

## 🤝 Contributing

Bug reports and PRs welcome. The project is small and well-decomposed:
each system lives in its own `.gd` file with a single responsibility,
and the data flow is signal-driven.

When adding a new rocket part:
1. Add a factory in `resources/PartCatalog.gd` (`_nose_*`, `_body_*`, etc.).
2. (Optional) export a `.glb` from Blender into `assets/models/`.
3. Set `glb_path` on the resource if a model exists.
4. Update `unlocked_by_default` in `GameManager.default_unlocked_parts()`
   if it should be free.

## 📄 License

MIT — see [LICENSE](LICENSE).

Built with ❤️ for anyone who ever wanted a rocket that actually feels
fun.
