# Changelog

All notable changes to this project are documented here. Dates are
ISO-8601 (YYYY-MM-DD).

## [0.2.0] - 2026-09-21 — Phase 2: Gameplay

### Added
- **Fuel pressure physics** (`RocketController.gd`):
  thrust scales linearly `0.6 → 1.0` with the fuel ratio (`current_fuel_pct`).
  Mass scales `0.4 → 1.0` so the rocket accelerates as the tank drains.
  Tunable via the inspector (`fuel_thrust_floor`, `fuel_mass_floor`,
  `fuel_burn_per_sec`).
- **Real stability math**: world-up correction torque that scales with the
  stability stat. New `lean_warning` signal fires when the rocket is too
  steep for too long.
- **Wind gusts**: random horizontal impulses in the atmosphere (alt
  < 1500 m), strength peaks at 350 m. New `wind_gust(strength)` signal
  drives HUD pulse + audio.
- **Failure events** (`FailureManager.gd`): a single API that classifies
  every landing kind into an `Outcome` struct — `success`,
  `success_perfect`, `fail_upside_down`, `fail_too_fast`, `fail_out_of_fuel`,
  `fail_spin_out`, `fail_crash`, `fumes_landing`. Each has a title,
  subtitle, sfx name, score multiplier, coin bonus, and camera jolt.
- **Score breakdown** (`FlightController.gd`):
  `score = (altitude × 100 + fuel_bonus + stab_bonus) × outcome_multiplier × flight_multiplier`.
  Flight multiplier is 1.0 / 1.5 (low-fuel bonus) / 2.0 (perfect stability).
- **Currency rewards**: outcome-specific coin bonus (10–120 ¢) + altitude
  tier bonuses (50 ¢ above 5 km, 100 ¢ above 20 km).
- **Progression gates**: 6 advanced parts (`nose_pointy`, `body_chubby`,
  `tank_jumbo`, `engine_boost`, `fin_square`, `booster_big`) unlock on
  the first successful landing. Toast message via `UIManager.popup_message`.
- **Flight HUD** overhaul: new Thrust %, Multiplier badge (golden ×2.0,
  magenta ×1.5), Wind Gust pulse, Lean Warning banner. Fuel + Stability
  labels turn red when low.
- **Results screen** overhaul: outcome title + subtitle, full score
  breakdown (base / fuel / stab / outcome / flight), avg stability,
  fuel remaining %, plays the outcome-specific SFX.

### Changed
- `RocketController` split from a single 154-line `_physics_process` into
  focused helpers (`_apply_thrust`, `_apply_lean_input`,
  `_apply_stability_recovery`, `_apply_wind_gust`, `_apply_drag`,
  `_update_telemetry`, `_track_spin`, `_update_multiplier`).
- `FlightController` now delegates outcome classification to `FailureManager`
  instead of computing scores inline.
- All persistent flight data is now structured in `score_breakdown` so
  other screens can read individual components.

### CI
- All parse errors from Phase 1 round are now caught at author time.
  Phase 2 commit `114d986` passed CI on first push.

---

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
