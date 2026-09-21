extends Node
## Orchestrates the in-flight loop: ignite, monitor for landing/crash,
## classify the outcome via FailureManager, build the score payload,
## forward telemetry to the HUD, hand off to ResultsScreen.
##
## Phase 4: plays a per-kind failure animation (confetti, dust burst,
## squash-and-settle, slow tumble) before transitioning.

signal flight_ended(payload: Dictionary)

const FailureManager = preload("res://scripts/FailureManager.gd")
const FailureAnimations = preload("res://scripts/FailureAnimations.gd")

@export var rocket_path: NodePath
@export var flight_manager_path: NodePath
@export var camera_path: NodePath    # optional — for cinematic jolts

var _rocket: Node
var _fm: Node
var _altitude_km: float = 0.0
var _started: bool = false
var _elapsed: float = 0.0
var _pending_failure_kind: StringName = &""
var _pending_failure_details: Dictionary = {}


func _ready() -> void:
	_rocket = get_node_or_null(rocket_path)
	_fm = get_node_or_null(flight_manager_path)
	if _rocket:
		_rocket.altitude_changed.connect(_on_altitude)
		_rocket.fuel_changed.connect(_on_fuel)
		_rocket.speed_changed.connect(_on_speed)
		_rocket.stability_changed.connect(_on_stability)
		_rocket.landed.connect(_on_landed)
		_rocket.failure_event.connect(_on_failure_event)
	# Auto-ignite after a small delay so the player sees the rocket.
	var t := get_tree().create_timer(1.2)
	t.timeout.connect(_ignite)


func _ignite() -> void:
	if _rocket and _rocket.has_method("ignite_engines"):
		_rocket.ignite_engines()
		_started = true


func _process(delta: float) -> void:
	if not _started or not _rocket:
		return
	_elapsed += delta

	# Check pending failure events that didn't terminate the flight directly.
	# "spin_out" and "out_of_fuel" are emitted continuously while the condition
	# holds; we just sample once.
	if _pending_failure_kind == &"":
		if _rocket.global_position.y < -30.0:
			# Below ground level -> crash
			_end_with_kind(&"crash", {"altitude_km": _altitude_km}, false)


func _on_failure_event(kind: StringName, details: Dictionary) -> void:
	# Cache the latest event for use in `_end` if the flight ends without a touchdown.
	# We don't terminate here — let the actual end condition close the flight.
	_pending_failure_kind = kind
	_pending_failure_details = details


func _on_altitude(km: float) -> void:
	_altitude_km = km


func _on_fuel(_p: float) -> void:
	pass


func _on_speed(_s: float) -> void:
	pass


func _on_stability(_s: float) -> void:
	pass


func _on_landed(touchdown_v: float) -> void:
	_end_with_kind(&"landed", {"touchdown_v": touchdown_v}, true)


func _end_with_kind(kind: StringName, details: Dictionary, success: bool) -> void:
	if not _started:
		return
	_started = false
	var payload := _build_payload(kind, details, success)
	# Phase 4: play the failure animation before the results screen.
	# We delay the scene swap by 1.4 s so the player sees the beat.
	var cam := get_node_or_null(camera_path) as Camera3D
	FailureAnimations.play_failure(_rocket as Node3D, payload.get("outcome_kind", &"fail_crash"),
		cam, float(payload.get("outcome_camera_jolt", 0.4)))
	var ft: SceneTreeTimer = get_tree().create_timer(1.4)
	ft.timeout.connect(func() -> void:
		GameManager.record_flight(payload)
		flight_ended.emit(payload)
		UIManager.goto_scene("res://scenes/ResultsScreen.tscn")
	)


# Keep the old API as a thin wrapper so we don't break anywhere that calls it.
func _end(success: bool, reason: String, touchdown_v: float = 0.0) -> void:
	var kind: StringName = &"landed" if success else &"crash"
	if reason == "Crashed into the ground":
		kind = &"crash"
	_end_with_kind(kind, {"touchdown_v": touchdown_v, "reason": reason}, success)


func _build_payload(kind: StringName, details: Dictionary, success: bool) -> Dictionary:
	var rocket_dict: Dictionary = _rocket.aggregated_stats() if _rocket and _rocket.has_method("aggregated_stats") else {}
	# The RocketController doesn't expose aggregated_stats — query its fields instead.
	var max_alt_m: float = float(_rocket.get("max_altitude_m")) if _rocket and _rocket.get("max_altitude_m") != null else 0.0
	var fuel_pct: float = float(_rocket.get("current_fuel_pct")) if _rocket and _rocket.get("current_fuel_pct") != null else 0.0
	var avg_stab: float = float(_rocket.get("avg_stability")) if _rocket and _rocket.get("avg_stability") != null else 0.0
	var flight_multiplier: float = float(_rocket.get("current_multiplier")) if _rocket and _rocket.get("current_multiplier") != null else 1.0
	var touchdown_v: float = float(details.get("touchdown_v", 0.0))

	var outcome = FailureManager.classify(kind, details, touchdown_v, max_alt_m, avg_stab)

	# Score breakdown — Phase 2:
	#   base        = altitude_km * 100
	#   fuel bonus  = up to +50 (best when fuel_pct < 0.1)
	#   stab bonus  = avg_stab * 200
	#   subtotal    = (base + fuel_bonus + stab_bonus) * outcome.score_multiplier
	#   multiplier  = subtotal * flight_multiplier
	var base_score: float = _altitude_km * 100.0
	var fuel_bonus: float = clampf((1.0 - fuel_pct) * 50.0, 0.0, 50.0)
	var stab_bonus: float = avg_stab * 200.0
	var subtotal: float = (base_score + fuel_bonus + stab_bonus) * outcome.score_multiplier
	var final_score: int = int(round(subtotal * flight_multiplier))

	# Coins: outcome bonus + altitude-tier bonus.
	var coin_bonus: int = outcome.coin_bonus
	if max_alt_m > 5000.0:
		coin_bonus += 50
	if max_alt_m > 20000.0:
		coin_bonus += 100

	return {
		"score": final_score,
		"score_breakdown": {
			"base": int(base_score),
			"fuel_bonus": int(fuel_bonus),
			"stab_bonus": int(stab_bonus),
			"outcome_multiplier": outcome.score_multiplier,
			"flight_multiplier": flight_multiplier,
		},
		"max_altitude_km": _altitude_km,
		"max_altitude_m": max_alt_m,
		"fuel_remaining_pct": fuel_pct,
		"stability_bonus": int(stab_bonus),
		"avg_stability": avg_stab,
		"flight_multiplier": flight_multiplier,
		"coins_earned": coin_bonus,
		"landed": success,
		"outcome_kind": String(outcome.kind),
		"outcome_title": outcome.title,
		"outcome_subtitle": outcome.subtitle,
		"outcome_sfx": outcome.sfx,
		"outcome_camera_jolt": outcome.camera_jolt,
		"reason": details.get("reason", outcome.subtitle),
	}
