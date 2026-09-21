extends Node
## Orchestrates the in-flight loop: ignite, monitor for landing/crash,
## forward telemetry to the HUD, hand off to ResultsScreen at the end.

signal flight_ended(payload: Dictionary)

@export var rocket_path: NodePath
@export var flight_manager_path: NodePath

var _rocket: Node
var _fm: Node
var _altitude_km: float = 0.0
var _started: bool = false
var _elapsed: float = 0.0


func _ready() -> void:
	_rocket = get_node_or_null(rocket_path)
	_fm = get_node_or_null(flight_manager_path)
	if _rocket:
		_rocket.altitude_changed.connect(_on_altitude)
		_rocket.fuel_changed.connect(_on_fuel)
		_rocket.speed_changed.connect(_on_speed)
		_rocket.stability_changed.connect(_on_stability)
		_rocket.landed.connect(_on_landed)
	# Auto-ignite after a small delay so the player sees the rocket.
	var t := get_tree().create_timer(1.2)
	t.timeout.connect(_ignite)


func _ignite() -> void:
	if _rocket and _rocket.has_method("ignite_engines"):
		_rocket.ignite_engines()
		_started = true


func _process(delta: float) -> void:
	if not _started:
		return
	_elapsed += delta
	# End conditions
	if _rocket:
		if _rocket.global_position.y < -30.0:
			_end(false, "Crashed into the ground")
		elif _elapsed > 90.0:
			_end(true, "Mission complete")
		elif bool(_rocket.get("_has_landed")):
			_end(true, "Touchdown!")


func _on_altitude(km: float) -> void:
	_altitude_km = km


func _on_fuel(_p: float) -> void:
	pass


func _on_speed(_s: float) -> void:
	pass


func _on_stability(_s: float) -> void:
	pass


func _on_landed(touchdown_v: float) -> void:
	_end(true, "Touchdown!", touchdown_v)


func _end(success: bool, reason: String, touchdown_v: float = 0.0) -> void:
	if not _started:
		return
	_started = false
	var payload := {
		"score": int(_altitude_km * 100.0) + (200 if success else 0),
		"max_altitude_km": _altitude_km,
		"fuel_remaining": float(_rocket.get("_fuel_units")) if _rocket and _rocket.get("_fuel_units") != null else 0.0,
		"stability_bonus": 0,
		"coins_earned": 100 if success else 25,
		"landed": success,
		"reason": reason,
	}
	GameManager.record_flight(payload)
	flight_ended.emit(payload)
	UIManager.goto_scene("res://scenes/ResultsScreen.tscn")
