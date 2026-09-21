# Changelog

All notable changes to this project are documented here. Dates are
ISO-8601 (YYYY-MM-DD).

## [0.1.0] - 2026-09-20 — Phase 1: Prototype

### Added
- Main menu with cartoon branding, coin/altitude/landings chips, three
  large pill-shaped buttons with hover + click tweens.
- Settings screen with master / music / SFX / camera-shake sliders and
  mute toggle. All settings persisted via `SaveManager`.
- Workshop: 3-column layout (parts picker / live 3D preview / stats).
  Six slot tabs (Nose / Body / Tank / Engine / Fin / Booster) with a
  grid of unlockable part cards. Six paint swatches. Stats panel
  displays live Thrust / Fuel / Weight / Stability / Efficiency bars.
- Modular rocket assembly: data-driven `RocketPartData` resources,
  auto-stacked by slot via `RocketBuilder.gd`. Supports up to 4 fins
  and any number of boosters, radial placement around the body.
- Live 3D preview: rocket slowly rotates in a `SubViewport`, real-time
  updates the moment a part is swapped.
- Launch pad scene with ground + tower + dual warning lights. Auto-start
  countdown after 1.5 s with big "3 / 2 / 1 / LAUNCH!" overlay.
- Cinematic launch: warning lights pulse, exhaust particles emit
  downward, smoke trail, engine glow ramps up, rocket lifts off with
  `linear_velocity = Vector3(0, 8, 0)`, camera follows upward.
- Flight scene: arcade physics (`RigidBody3D`), chase camera, HUD with
  altitude / speed / fuel / stability / distance-to-Moon. WASD +
  Space controls.
- `FlightController` end-of-flight logic: detects out-of-fuel drift,
  ground crash, or 90-second mission-end. Records result via
  `GameManager.record_flight`.
- Results screen: large title, score, altitude, fuel, bonus, coins
  earned, confetti on success. Three exits: Fly Again / Back to Build /
  Menu.
- `GameManager` autoload: persistent coins, unlocks, best altitude,
  total launches, successful landings, settings.
- `AudioManager` autoload: three buses (Master / Music / SFX) and
  procedural SFX (beeps, rumbles, arpeggios) — no `.wav` files
  required for Phase 1.
- `SaveManager` autoload: `user://save.json` round-trip.
- `UIManager` autoload: scene router + lightweight toast helper.
- Toon shader (`shaders/toon.gdshader`) and sky shader
  (`shaders/sky.gdshader`) authored, ready for Phase 3 visual swap.
- `ParticleManager` static helpers for procedural exhaust, smoke, and
  star fields.
- Documentation: `README.md`, `docs/phase-1.md` (test plan),
  `docs/blender-workflow.md` (asset pipeline guide).
- GitHub Actions workflow: `.github/workflows/godot-validate.yml`
  imports the project headlessly on every push to `main` and on PRs.

### Known gaps (deferred to Phase 2+)
- Cinematic camera transitions between scenes are minimal.
- Atmospheric transition wiring is in place but visual sky-color
  grading ships in Phase 3.
- Failure events other than "out of fuel" / "ground crash" deferred.
- Moon landing cinematic is a placeholder scene with a Continue button.
- No `.glb` assets yet — primitive meshes only. The loader is wired
  to prefer `.glb` the moment one is dropped into `assets/models/`.
