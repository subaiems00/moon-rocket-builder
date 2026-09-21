# Phase 5 — Polish test plan

## What shipped in Phase 5

| Feature                              | Where                                       |
|--------------------------------------|---------------------------------------------|
| Atomic save with backup               | `autoload/SaveManager.gd`                   |
| Schema versioning + corruption recovery | `autoload/SaveManager.gd`               |
| Performance budgets (FPS / particle) | `autoload/PerformanceManager.gd`            |
| Reduce motion toggle                  | `autoload/GameManager.gd` + SettingsScreen  |
| Reset-to-defaults button              | `scripts/ui/SettingsScreen.gd`              |
| Rendering budget (shadows / MSAA)     | `project.godot`                              |
| CONTRIBUTING.md + PR template + CODEOWNERS | repo root + `.github/`                  |

## How to test

### 1. Save atomicity
- [ ] Play through and let the game save (every flight and unlock
      triggers a save).
- [ ] Open `user://save.json` — file is valid JSON.
- [ ] Open `user://save.json.bak` — also valid, contains the previous
      good save.
- [ ] Delete `user://save.json` manually. Relaunch the game → it should
      load from `save.json.bak` and continue normally.
- [ ] Corrupt `save.json` (replace with `not valid json`). Relaunch →
      same: load from backup or start fresh.

### 2. Reduce motion
- [ ] Open Settings → toggle Reduce motion ON.
- [ ] Go to Workshop → Launch → launch the rocket. Notice:
      - Camera shake during ignition and lift-off is muted.
      - `add_shake()` impulses are no-ops.
      - The camera dolly and tween still play (they're positional, not
        shake).
- [ ] Toggle OFF → shake returns.

### 3. Reset defaults
- [ ] Open Settings → click "Reset defaults".
- [ ] Toast confirms "Settings and progression reset".
- [ ] Coins / landings / unlocks are wiped to defaults.
- [ ] Save file on disk reflects the wiped state.
- [ ] Toggle Reduce motion OFF, camera shake back to 1.0.

### 4. Performance budget
- [ ] Boot the game with a fresh save.
- [ ] Build a rocket with all boosters + max fins.
- [ ] Launch and fly — observe:
      - Engine.max_fps should cap at 60 (verify via
        `PerformanceManager.render_info()`).
      - Total live particles should not exceed the budget cap.
      - No shadow flicker on the launch tower.

### 5. CI gate
- [ ] Push a commit that intentionally adds a `class_name` to an
      autoload script (should fail CI with "Class hides an autoload").
- [ ] Revert. Push a normal commit. CI should pass within ~10 s.

### 6. Settings validation
- [ ] Try moving any slider past its visual max (drag it off the
      track). The clamped value should be respected and saved.
- [ ] Volume clamps: master / music / SFX never go negative or above
      1.0 in the saved file even if you try.

### 7. PR / contributor flow
- [ ] Open a PR against `main` from a branch.
- [ ] Fill in the PR template — phase selector + self-review
      checklist.
- [ ] CODEOWNERS auto-assigns the original author.
