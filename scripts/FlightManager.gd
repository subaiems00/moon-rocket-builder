extends Node
class_name FlightManager
## Owns the FlightScene state machine: ground → atmosphere → space → moon.
## Updates environment visuals and HUD telemetry, and decides when the
## flight is over (out of fuel, crashed, landed).

signal phase_changed(phase: StringName)
signal crash(reason: String)
signal success(reason: String)

enum Phase { GROUND, ASCENT, ATMOSPHERE, SPACE, LANDING, ENDED }

@export var rocket_path: NodePath
@export var environment_path: NodePath
@export var moon_path: NodePath
@export var moon_distance_threshold: float = 250.0

var _rocket: Node3D
var _environment: WorldEnvironment
var _moon: Node3D
var phase: int = Phase.GROUND


func _ready() -> void:
	_rocket = get_node_or_null(rocket_path) as Node3D
	_environment = get_node_or_null(environment_path) as WorldEnvironment
	_moon = get_node_or_null(moon_path) as Node3D


func begin_flight() -> void:
	phase = Phase.ASCENT
	phase_changed.emit(&"ASCENT")


func _process(_delta: float) -> void:
	if _rocket == null:
		return
	if phase in [Phase.ASCENT, Phase.ATMOSPHERE, Phase.SPACE, Phase.LANDING]:
		_update_phase_by_altitude()


func _update_phase_by_altitude() -> void:
	var alt_m := _rocket.global_position.y
	if alt_m > 1200.0:
		_set_phase(Phase.SPACE)
	elif alt_m > 300.0:
		_set_phase(Phase.ATMOSPHERE)
	elif alt_m > 5.0:
		_set_phase(Phase.ASCENT)
	# Check moon proximity in space.
	if phase == Phase.SPACE and _moon:
		var d := _moon.global_position.distance_to(_rocket.global_position)
		if d < moon_distance_threshold:
			_set_phase(Phase.LANDING)


func force_phase(p: int) -> void:
	_set_phase(p)


func end_success(reason: String = "moon") -> void:
	_set_phase(Phase.ENDED)
	success.emit(reason)


func end_crash(reason: String) -> void:
	_set_phase(Phase.ENDED)
	crash.emit(reason)


func _set_phase(p: int) -> void:
	if phase == p:
		return
	phase = p
	phase_changed.emit(StringName(Phase.keys()[p]))
	_apply_phase_visuals()


func _apply_phase_visuals() -> void:
	if _environment == null:
		return
	var env := _environment.environment
	if env == null:
		return
	match phase:
		Phase.ASCENT:
			env.background_mode = Environment.BG_COLOR
			env.background_color = Color(0.55, 0.78, 0.96)
			env.ambient_light_color = Color(0.85, 0.85, 0.95)
		Phase.ATMOSPHERE:
			env.background_mode = Environment.BG_SKY
			env.ambient_light_color = Color(0.45, 0.50, 0.75)
		Phase.SPACE:
			env.background_mode = Environment.BG_COLOR
			env.background_color = Color(0.04, 0.03, 0.12)
			env.ambient_light_color = Color(0.10, 0.10, 0.20)
		Phase.LANDING:
			env.ambient_light_color = Color(0.25, 0.25, 0.30)
