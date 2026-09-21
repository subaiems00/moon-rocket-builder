# Phase 4 — Game feel test plan

## What shipped in Phase 4

| Feature                       | Where                                       |
|-------------------------------|---------------------------------------------|
| Multi-stage ignition          | `scripts/LaunchSequence.gd` (starter → idle → main) |
| Cinematic camera dolly        | `scripts/LaunchSequence.gd` + `CinematicCamera.offset` tween |
| Camera shake (throb + jitter) | `scripts/CinematicCamera.gd` (`add_shake()`) |
| Fade-through-black            | `autoload/ScreenTransition.gd`              |
| Per-failure beats             | `scripts/FailureAnimations.gd`              |
| Confetti + dust particle fx   | `ParticleManager.build_confetti`, `build_dust_burst` |
| Virtual joystick              | `scripts/ui/VirtualJoystick.gd`             |
| Virtual boost button          | `scripts/ui/VirtualBoostButton.gd`          |
| Throttle-driven exhaust       | `RocketController._apply_thrust()` updates ParticleProcessMaterial |
| Score-count-up animation      | `scripts/ui/ResultsScreen.gd`                |
| Multiplier badge bounce       | `scripts/ui/FlightHUD.gd`                   |

## How to test

### 1. Cinematic launch sequence
- [ ] Press LAUNCH on LaunchPad.
- [ ] Warning lights pulse during countdown.
- [ ] At ignition: brief low-frequency rumble, exhaust particles start
      small and yellow, exhaust OmniLight ramps from 0 to bright.
- [ ] Over 0.6 s the exhaust grows into a bright orange flame, the
      camera dollies back, you hear `engine_thrust`.
- [ ] At lift-off: 0.6 m/s upward kick, big camera shake, camera
      pulls further back as the rocket climbs out of frame.

### 2. Camera shake character
- [ ] During idle hover: subtle continuous jitter (low amplitude).
- [ ] On launch: high-amplitude throb + jitter for ~3 s.
- [ ] On wind gust: brief kick that decays back to idle over ~0.5 s.
- [ ] No motion sickness at default camera shake setting.

### 3. Scene transitions
- [ ] Every button that changes screens does a 0.25 s fade-out → swap
      → 0.30 s fade-in. No instant pop.

### 4. Failure beats
- [ ] **Landed softly** (low velocity, good stability) → confetti
      burst above the rocket + squash-and-settle.
- [ ] **Coasted on fumes** → same confetti + slower settle + extra
      sparkle particles.
- [ ] **Landed too fast** (touchdown velocity > 22 m/s) → big bounce
      squash, camera jolt, dust burst at touchdown.
- [ ] **Upside down** → 180° tumble tween + dust at touchdown.
- [ ] **Out of fuel drift** → quiet dust settle on ground impact.
- [ ] **Spin-out** → 3-loop slow tumble, dust, then the scene swap.
- [ ] **Crash** → big dust + squash, camera jolt.

### 5. Touch input (if testing on a touchscreen)
- [ ] Virtual joystick bottom-left, base 160 px. Drag the thumb to
      yaw/pitch.
- [ ] Virtual boost button bottom-right, 144 px round. Press and hold
      to thrust — the button pulses 1.10 ↔ 0.96.
- [ ] Desktop: WASD still works alongside these.

### 6. Particle polish
- [ ] With throttle at 0 (idle), exhaust is a small yellow flame.
- [ ] With throttle at 1 (full thrust), exhaust is bigger, brighter,
      and more orange/red.
- [ ] Particle amount visibly scales between idle and thrust.

### 7. UI micro-interactions
- [ ] When the multiplier ticks up to ×1.5 or ×2.0, the badge scales
      from 0.8 → 1.25 → 1.0 with a back-out spring.
- [ ] When lean warning fires, the banner pulses alpha 1.0 → 0.4 → 1.0
      twice.
- [ ] ResultsScreen: title pops in with overshoot, score label counts
      up from 0 over 1 s, coins badge bounces in from zero.

### 8. Audio timing
- [ ] Countdown beeps rise in pitch (1.00 → 1.10 across ticks).
- [ ] Engine start (starter) is a single short rumble.
- [ ] Engine thrust (idle → main) ramps in.
- [ ] Launch is a deep long rumble.
- [ ] Each failure outcome plays its own SFX (the ResultsScreen plays
      the outcome-specific one — already in Phase 2).
