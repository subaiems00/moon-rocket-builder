extends Node
## Phase 5: central place for performance budgets and runtime helpers.
## Other systems query this instead of hard-coding particle counts.
##
## Why an autoload: lets the Settings screen expose a "Quality" preset
## in the future, and lets future CI benchmarks know the upper bound
## for a worst-case rocket.

const DEFAULT_PARTICLE_BUDGET := 600    # total live particles across all systems
const DEFAULT_DRAW_CALL_BUDGET := 200   # target for static + dynamic geometry
const DEFAULT_PHYSICS_TPS := 60        # ticks per second; physics is deterministic
const DEFAULT_TARGET_FPS := 60         # Engine.max_fps

# Effective values (can be lowered by settings).
var particle_budget: int = DEFAULT_PARTICLE_BUDGET
var draw_call_budget: int = DEFAULT_DRAW_CALL_BUDGET
var physics_tps: int = DEFAULT_PHYSICS_TPS
var target_fps: int = DEFAULT_TARGET_FPS


func _ready() -> void:
	# Phase 5: lock physics to 60 TPS for deterministic arcade feel.
	# Engine.physics_ticks_per_second is the actual knob.
	Engine.physics_ticks_per_second = physics_tps
	Engine.physics_jitter_fix = true
	Engine.max_fps = target_fps
	# Reduce console log noise; keep warnings/errors.
	OS.set_environment("GODOT_VERBOSE", "0")


## Clamp a desired particle amount to fit within the global budget.
## Use this when spawning transient particles (wind puffs, dust, confetti).
func clamp_amount(desired: int, current_total: int = 0) -> int:
	var remaining: int = maxf(particle_budget - current_total, 0)
	return mini(desired, remaining)


## Read the global render budget (read-only convenience).
func render_info() -> Dictionary:
	return {
		"particle_budget": particle_budget,
		"draw_call_budget": draw_call_budget,
		"physics_tps": physics_tps,
		"target_fps": target_fps,
		"performance_monitor_enabled": OS.has_feature("debug"),
	}
