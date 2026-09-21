# Phase 1 — Prototype test plan

## What ships in Phase 1

| Feature                                 | Where                                        |
|-----------------------------------------|----------------------------------------------|
| Main menu with title + chips + CTA      | `scenes/MainMenu.tscn`                       |
| Settings screen (volume, mute, shake)   | `scenes/SettingsScreen.tscn`                 |
| Workshop with part picker + 3D preview  | `scenes/RocketWorkshop.tscn`                 |
| Modular rocket assembly (data-driven)   | `scripts/RocketBuilder.gd`                   |
| Rocket stats (thrust/fuel/weight/stab)  | `scripts/ui/RocketWorkshop.gd`               |
| Launch pad with cinematic countdown     | `scenes/LaunchPad.tscn`                      |
| Engine ignition + smoke + sparks        | `scripts/ParticleManager.gd` + `LaunchSequence.gd` |
| Arcade flight + chase camera            | `scenes/FlightScene.tscn`                    |
| HUD (altitude / speed / fuel / etc.)    | `scripts/ui/FlightHUD.gd`                    |
| Moon distance indicator                 | `scripts/ui/FlightHUD.gd`                    |
| Results screen with score + coins       | `scenes/ResultsScreen.tscn`                  |
| Local save (coins, best altitude, etc.) | `autoload/SaveManager.gd`                    |
| Procedural SFX (beeps, rumble, music)   | `autoload/AudioManager.gd`                   |

## How to test

### 1. Project loads
- [ ] Open `project.godot` in Godot 4.3+.
- [ ] Wait for the import dialog (if shown) and click **Import**.
- [ ] Confirm no errors appear in the Output panel.
- [ ] Press **F5**. The main menu appears within ~1 second.

### 2. Main menu
- [ ] Title reads "🌙 Moon Rocket Builder".
- [ ] Coin / best-altitude / landings chips display `0` / `0 km` / `0`.
- [ ] Hover any button → small scale-up animation + soft click SFX.
- [ ] Click **Start Building** → transitions to Workshop.
- [ ] Click **Settings** → transitions to Settings.
- [ ] Click **Quit** → window closes (when running as desktop build).

### 3. Workshop
- [ ] A default rocket is already assembled (nose, body, tank, engine, 4× fins).
- [ ] Rocket slowly rotates in the 3D preview.
- [ ] Stat panel shows Thrust / Fuel / Weight / Stability / Efficiency.
- [ ] Click a category tab (Body / Engine / Fin / ...) → grid swaps.
- [ ] Click a part card → rocket updates within 1 frame, stats update.
- [ ] Hover a paint swatch → rocket repaints; click locks it in.
- [ ] Click **🚀 LAUNCH** → transitions to LaunchPad.

### 4. Launch pad
- [ ] Ground + launch tower visible.
- [ ] Auto-start triggers countdown after ~1.5s.
- [ ] Big number "3" → "2" → "1" → "LAUNCH!" appears center-screen.
- [ ] Warning lights pulse during countdown.
- [ ] Exhaust particles emit downward, smoke appears.
- [ ] Rocket lifts off, camera follows upward.
- [ ] After ~4s the screen fades and switches to FlightScene.

### 5. Flight
- [ ] Sky is light blue with fog.
- [ ] HUD shows altitude (km), speed (m/s), fuel %, stability %, distance.
- [ ] Press **W** or **Space** → rocket thrusts upward.
- [ ] Press **A/D** → rocket yaws slightly.
- [ ] Press **S** → rocket pitches down.
- [ ] Fuel % decreases while thrusting.
- [ ] After 90s OR when rocket falls below ground → ResultsScreen.

### 6. Results
- [ ] Title reads "MOON LANDING!" if succeeded, "Try Again!" if not.
- [ ] Score, max altitude, fuel left, bonus, coins earned all visible.
- [ ] **Fly Again** → back to LaunchPad.
- [ ] **Back to Build** → back to Workshop.
- [ ] **Menu** → back to MainMenu.
- [ ] Returning to MainMenu, coin count is incremented.

### 7. Save
- [ ] Quit and relaunch the game.
- [ ] Main menu coins / best-altitude / landings still reflect last session.

---

## Known gaps (Phase 2+)

- **Cinematic camera transitions** are minimal; only the ground-to-flight
  cross-fade exists.
- **Atmospheric transition** is wired (`FlightManager`) but the visuals
  (stars fading in, sky color grading) ship in Phase 3.
- **Failure events** (spin out, run out of fuel, etc.) are detected but
  only the "ran out" path has distinct visuals in Phase 1.
- **Moon landing cinematic** is a placeholder scene (`MoonLanding.tscn`)
  with a "Continue" button. Phase 3 will animate approach + touchdown.
- **No .glb assets.** Primitive meshes only — see
  `docs/blender-workflow.md` for how to add Blender models without code
  changes.
