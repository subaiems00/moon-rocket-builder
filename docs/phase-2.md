# Phase 2 — Gameplay test plan

## What shipped in Phase 2

| Feature                         | Where                                    |
|---------------------------------|------------------------------------------|
| Fuel-pressure physics           | `scripts/RocketController.gd`            |
| Real stability / lean math      | `scripts/RocketController.gd`            |
| Wind gust system                | `scripts/RocketController.gd`            |
| Failure event classification    | `scripts/FailureManager.gd` (new)        |
| Score breakdown + multipliers   | `scripts/FlightController.gd`            |
| Phase-2 part unlocks            | `autoload/GameManager.gd`                 |
| Thrust %, Multiplier, Wind, Lean| `scripts/ui/FlightHUD.gd`                 |
| ResultsScreen with breakdown    | `scripts/ui/ResultsScreen.gd`            |

## How to test

### 1. Fuel pressure
- [ ] Build a rocket with the standard parts. Press LAUNCH.
- [ ] As fuel drains (watch the `%` label), thrust scales smoothly
      downward (the rocket feels "tired" near empty).
- [ ] Mass decreases — the rocket accelerates faster as it climbs.
- [ ] When fuel hits 0%, the rocket stops thrusting and starts to fall.
      A "OUT OF FUEL" outcome fires.

### 2. Stability math
- [ ] With **no fins**, hold `A` or `D` — the rocket spins uncontrollably,
      lean warning shows "⚠ Too steep!".
- [ ] With **4 fins** and a high-stability engine, lean should self-correct.
- [ ] Push the lean past ~40° and the warning banner pulses red.

### 3. Wind gusts
- [ ] Below 1500 m, watch for a brief "💨 Gust!" flash at the top-center.
- [ ] The rocket gets a sideways impulse — visible shake on the chase
      camera, slight lateral drift.

### 4. Failure events
- [ ] **Out of fuel**: stop thrusting above 50 m. After a few seconds
      the rocket falls, lands on the ground at low speed → "OUT OF FUEL".
- [ ] **Spin-out**: hold `A` or `D` continuously with no fins → after
      spin rate exceeds 2 rad/s, an "SPIN-OUT!" outcome fires.
- [ ] **Too fast**: rocket reaches high altitude with low fuel, falls
      fast — landing velocity > 22 m/s triggers "TOO FAST!".
- [ ] **Upside down**: rotate the rocket 180° before landing — "UPSIDE
      DOWN!" outcome with a comedic sad-trombone SFX.
- [ ] **Crash**: don't ignite. After 90 s the flight ends in "OOPS!".

### 5. Score multipliers
- [ ] Build a balanced rocket, fly normally → see "×1.0" badge during
      flight, "Flight: ×1.00" on the results screen.
- [ ] Drain fuel below 25% without crashing → badge becomes "×1.5"
      (magenta).
- [ ] Fly cleanly without ever triggering lean warning → badge becomes
      "×2.0" (gold).
- [ ] Land with low fuel and high stability → "PERFECT LANDING!" with
      the ×2.0 multiplier on the results screen.

### 6. Progression gates
- [ ] New save: Workshop only shows the 6 default parts.
      (Advanced parts appear greyed out / 🔒.)
- [ ] Fly successfully → toast "New parts unlocked! Visit Workshop."
      appears on the next scene.
- [ ] Return to Workshop: nose_pointy, body_chubby, tank_jumbo,
      engine_boost, fin_square, booster_big are now selectable.

### 7. Results screen
- [ ] Title is the outcome-specific text ("MOON LANDING!",
      "PERFECT LANDING!", "BARELY MADE IT!", "UPSIDE DOWN!", etc.).
- [ ] Subtitle explains it in one line.
- [ ] Score breakdown lists:
      - Base:           1200
      - Fuel bonus:     +45
      - Stability:      +180
      - Outcome:        ×1.00
      - Flight:         ×1.50
      ─── Total:        2137 ¢
- [ ] Coins earned reflects outcome bonus + altitude tier.

## Known gaps (Phase 3+)
- No cinematic camera transitions between Workshop → Launch → Flight.
- Wind gusts have no audio cue yet (only visual pulse).
- Failure animation hooks are wired (signals) but no per-kind
  particles ship until Phase 4.
- The "altitude_km" HUD value is still a fake heuristic
  (`384000 - km*1.0`); Phase 3 will use real spatial distance.
