# Changelog

All notable changes to this project are documented here. Dates are
ISO-8601 (YYYY-MM-DD).

## [0.4.0] - 2026-09-21 — Phase 4: Game feel

### Added
- **Cinematic launch** — 3-stage ignition: starter motor → idle → main
  thrust. Exhaust particles scale and color-shift with thrust (idle =
  small yellow flame, full thrust = bright orange/red flame). Exhaust
  `OmniLight` ramps 0 → 10 over 0.15 s. Engine glow per-part scales
  with thrust. `LaunchSequence` dollies the camera offset (ground →
  chase) over 1.2 s during ignition, 2.5 s at lift-off, both with
  cubic-out easing.
- **Camera shake upgrade** — `CinematicCamera.add_shake(impulse)` for
  one-shot kicks plus a continuous throb (low-freq sin wave) +
  jitter (high-freq white noise), so shakes feel meaty without being
  nauseating. Decays smoothly toward `shake_intensity`.
- **Scene transitions** — new `ScreenTransition` autoload does
  fade-through-black on every `UIManager.goto_scene` call
  (0.25 s out, 0.30 s in).
- **Failure animations** — `FailureAnimations.play_failure(kind, rocket,
  camera)` routes to per-kind beats:
    - `success` / `perfect` → confetti + squash-and-settle
    - `fumes_landing` → success variant with extra sparkle
    - `fail_speed` → big bounce + camera jolt + dust burst
    - `fail_upside_down` → 180° tumble tween + dust
    - `fail_out_of_fuel` → quiet dust settle
    - `fail_spin` → 3-loop slow tumble
    - `fail_crash` → dust + squash
  `FlightController._end` delays the scene swap by 1.4 s so the
  player sees the beat.
- **Audio polish** — 4 new procedural SFX: `engine_thrust`,
  `wind_gust`, `booster_sep` (metallic clank), `success_stinger`
  (ascending sweep). `LaunchSequence` swaps `engine_loop` for
  `engine_thrust` on main ignition.
- **Touch input** — `VirtualJoystick` (160 px circular base + draggable
  thumb) emits `yaw_left/right` and `pitch_up/down` via
  `Input.action_press`. `VirtualBoostButton` (144 px round button) holds
  `pitch_up` while pressed with a pulse animation.
- **Particle polish** — `RocketController` now drives the exhaust
  `ParticleProcessMaterial`: scale, initial velocity, color, and
  amount all scale with throttle. `ParticleManager.build_confetti`
  (80 particles, 4-color ramp) and `build_dust_burst` (sand-colored
  ground kick) for the new failure beats.
- **UI micro-interactions** — `FlightHUD` multiplier badge scales with a
  back-out overshoot (1.25 → 1.0) when it ticks up. LeanWarning pulses
  via `set_loops(2)`. `ResultsScreen` title pops in with back-out,
  score label counts up from 0 to final over 1 s, coins badge bounces
  in from zero.

### Fixed (CI catches these)
- DO NOT add `class_name X` to an autoload script — the autoload
  name is already the global identifier. `class_name X` triggers
  `Class 'X' hides an autoload singleton` and every method call
  becomes `Cannot call non-static function on the class`.

---

## [0.3.0] - 2026-09-21 — Phase 3: Visual polish

### Added
- **Toon shader** (`shaders/toon.gdshader`): soft color bands + rim
  light + ambient fill + manual lambert against a uniform `light_dir`.
  Applied to every rocket part via `RocketPartInstance.use_toon_shader`,
  so primitive meshes AND `.glb` exports share the same cartoon look.
  Uses `render_mode unshaded` to dodge the inconsistent `LIGHT` built-in
  across Godot 4 minor versions.
- **Moon shader** (`shaders/moon.gdshader`): procedural craters via a
  hash-grid field + toon banding + soft rim glow. Re-purposed by the
  Earth to draw cartoon continents.
- **Sky shader upgrade**: 3-band gradient (ground blue → atmosphere
  purple → space black) driven by `atmosphere_mix` and `space_mix`
  uniforms. `FlightManager` blends these with altitude every frame.
- **Asset loader** (`scripts/AssetLoader.gd`): loads `.glb` files for
  parts that declare a `glb_path`. Falls back to the primitive mesh
  if the file isn't present, so the prototype stays fully playable.
  `PartCatalog` now declares `glb_path` for every part.
- **Blender asset specs** (`docs/blender/`): 10 per-asset recipes +
  README with style guide, axis convention, material defaults. An
  artist can drop a `.glb` into `assets/models/` and the loader
  picks it up automatically.
- **Cloud cluster** (`ParticleManager.build_cloud_cluster`): 4-sphere
  puffy cluster. `ScenePopulator` scatters 8 of them at altitude
  ~200–320m in the flight scene.
- **Earth**: 25m cartoon Earth visible from space, with green-tinted
  "continents" baked in via the moon shader.
- **Wind puff** (`ParticleManager.build_wind_puff`): one-shot cloud
  puff spawned at the rocket's current position when a wind gust hits.
  Wired via the new `wind_gust(strength, world_position)` signal.
- **Improved stars**: 2200 stars with white / pale-yellow / pale-blue
  tint variation and per-instance brightness jitter.
- **LaunchPad scene overhaul**: green grass ground, dedicated launch
  platform cylinder, taller tower with 3 white gantry arms, dedicated
  exhaust `OmniLight` below the rocket that ramps up on ignition.
- **FlightScene overhaul**: bigger moon (12m), Earth node, populated
  star field via `ScenePopulator`, 8 cloud clusters, inline sky
  shader, dedicated `WindPulse` and `LeanWarning` HUD labels.

### Fixed (CI catches these)
- `const SomeDict: Dictionary = {}` is invalid in Godot 4.3 because
  Dictionaries are mutable — use `static var` instead.
- `Sky` is a Resource, not a Node — can't `as Sky` cast from
  `get_node_or_null`. Read via `env.environment.sky`.
- `const Foo = preload(...)` shadows any `class_name Foo` globally
  and breaks the parser — drop the const when the class_name already
  exists.

---

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
