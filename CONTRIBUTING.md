# Contributing to Moon Rocket Builder

Thanks for your interest in making this game better! Every PR is welcome
— even tiny doc fixes. This file explains how to set up your environment
and what conventions the project follows.

## Setting up

1. Install **Godot 4.3+** (Standard or Mono, Mono not required).
2. Clone the repo and open `project.godot` in Godot.
3. Press **F5** to run. The default scene is `MainMenu.tscn`.
4. (Optional) Install **Blender 4.x** to author `.glb` assets — see
   [`docs/blender/README.md`](docs/blender/README.md).

## Running CI locally

Before pushing, you can validate that your changes don't break the
project by running the same import check the CI runs:

```bash
godot --headless --import
```

If you see `SCRIPT ERROR:` or `Parse Error:` lines, CI will fail too.

## Project conventions

- **GDScript only** — no C# in this project. The game is small enough
  that GDScript is faster to iterate on.
- **4-space indent** for `.gd` files. Godot's editor will do this for
  you if you set it in *Editor → Editor Settings → Text Editor*.
- **LF line endings** — enforced by `.gitattributes`. Don't normalize.
- **class_name for cross-script types** — every reusable script declares
  `class_name X`. Autoload scripts **must NOT** declare `class_name`
  (it conflicts with the autoload singleton — see memory landmines).
- **No `.tres` files in Phase 1** — parts, paints, and decals are
  declared inline in `resources/PartCatalog.gd` so the prototype is
  runnable from a fresh clone. Phase 3+ can migrate to `.tres` as
  needed.
- **Asset paths** — models go in `assets/models/`, textures in
  `assets/textures/`. Loaded via `AssetLoader.gd` which prefers `.glb`
  and falls back to the inline `primitive_mesh`.
- **Signals** — every long-running system exposes signals, not direct
  refs. Use `await get_tree().create_timer(...).timeout` for time-based
  sequences instead of polling.

## Common pitfalls (full list in Hermes memory)

If CI fails, check these first:

1. `const SomeDict: Dictionary = {}` — invalid in 4.3; use `static var`.
2. `Sky` is a Resource, not a Node — read via `env.environment.sky`.
3. `const Foo = preload(...)` shadows `class_name Foo` → drop the const.
4. GDShader vars: plain `float x = 0.0;`, not `float x: float = 0.0;`.
5. Don't add `class_name X` to an autoload script.

## PR workflow

1. Branch from `main`.
2. Make your changes.
3. Run the project locally — at minimum walk through `MainMenu →
   Workshop → Launch → Flight → Results`.
4. Update the relevant `docs/phase-N.md` test plan if your change is
   user-visible.
5. Update `CHANGELOG.md` under a new `[Unreleased]` section.
6. Push and open a PR. The CI badge must be green before review.

## Filing issues

Use the issue templates (`.github/ISSUE_TEMPLATE/`):
- **bug**: what's broken, steps to reproduce, Godot version, OS.
- **feature**: one-line summary, motivation, sketch of how it'd work,
  which Phase it fits.

Please **search first** to avoid duplicates.

## Code of conduct

Be kind. This is a small project made for fun. Disagreement is fine;
meanness is not.
