extends Node
class_name FlightManager
## Owns the FlightScene state machine: ground → atmosphere → space → moon.
## Drives the sky shader uniforms, star / cloud / earth visibility,
## and HUD telemetry.
##
## Phase 3: the environment now uses a Sky shader with `atmosphere_mix`
## and `space_mix` parameters that we blend with altitude. Stars fade in
## around 800m altitude, clouds fade out around 1500m, Earth becomes
## visible once we're in space.

signal phase_changed(phase: StringName)
signal crash(reason: String)
signal success(reason: String)

enum Phase { GROUND, ASCENT, ATMOSPHERE, SPACE, LANDING, ENDED }

@export var rocket_path: NodePath
@export var environment_path: NodePath
@export var moon_path: NodePath
@export var earth_path: NodePath
@export var stars_path: NodePath
@export var clouds_path: NodePath
@export var sky_material_path: NodePath
@export var moon_distance_threshold: float = 250.0

var _rocket: Node3D
var _environment: WorldEnvironment
var _moon: Node3D
var _earth: Node3D
var _stars: MultiMeshInstance3D
var _clouds: Node3D
var _sky_material: ShaderMaterial
var phase: int = Phase.GROUND


func _ready() -> void:
	_rocket = get_node_or_null(rocket_path) as Node3D
	_environment = get_node_or_null(environment_path) as WorldEnvironment
	_moon = get_node_or_null(moon_path) as Node3D
	_earth = get_node_or_null(earth_path) as Node3D
	_stars = get_node_or_null(stars_path) as MultiMeshInstance3D
	_clouds = get_node_or_null(clouds_path) as Node3D
	if sky_material_path != NodePath(""):
		var sky_node: Node = get_node_or_null(sky_material_path)
		if sky_node and sky_node.has_method("get"):
			# Sky is a Resource, not a Node — it lives in environment.sky.
			# We grab it via the parent WorldEnvironment.environment.
			var env_node: WorldEnvironment = get_node_or_null(environment_path)
			if env_node and env_node.environment:
				var sky_res: Sky = env_node.environment.sky
				if sky_res and sky_res.sky_material is ShaderMaterial:
					_sky_material = sky_res.sky_material as ShaderMaterial
	if _stars:
		_stars.visible = false
	if _clouds:
		_clouds.visible = false
	if _earth:
		_earth.visible = false
	if _moon:
		_moon.visible = false


func begin_flight() -> void:
	phase = Phase.ASCENT
	phase_changed.emit(&"ASCENT")
	if _moon:
		_moon.visible = true


func _process(_delta: float) -> void:
	if _rocket == null:
		return
	if phase in [Phase.ASCENT, Phase.ATMOSPHERE, Phase.SPACE, Phase.LANDING]:
		_update_phase_by_altitude()
		_update_visuals()


func _update_phase_by_altitude() -> void:
	var alt_m: float = _rocket.global_position.y
	if alt_m > 1200.0:
		_set_phase(Phase.SPACE)
	elif alt_m > 300.0:
		_set_phase(Phase.ATMOSPHERE)
	elif alt_m > 5.0:
		_set_phase(Phase.ASCENT)
	if phase == Phase.SPACE and _moon:
		var d: float = _moon.global_position.distance_to(_rocket.global_position)
		if d < moon_distance_threshold:
			_set_phase(Phase.LANDING)


func _update_visuals() -> void:
	var alt_m: float = _rocket.global_position.y
	# Sky shader: blend from ground → atmosphere → space.
	if _sky_material:
		var space_mix: float = clampf((alt_m - 1500.0) / 1500.0, 0.0, 1.0)
		var atmos_mix: float = clampf((alt_m - 200.0) / 800.0, 0.0, 1.0) * (1.0 - space_mix)
		_sky_material.set_shader_parameter("atmosphere_mix", atmos_mix)
		_sky_material.set_shader_parameter("space_mix", space_mix)
	# Stars fade in past 800m.
	if _stars:
		_stars.visible = alt_m > 600.0
	# Clouds fade out past 1200m.
	if _clouds:
		_clouds.visible = alt_m < 1500.0
		var fade: float = clampf(1.0 - (alt_m - 800.0) / 700.0, 0.0, 1.0)
		var mat: StandardMaterial3D = null
		if _clouds is Node3D:
			for child in _clouds.get_children():
				if child is MeshInstance3D:
					var mi: MeshInstance3D = child
					var mm: StandardMaterial3D = mi.material_override as StandardMaterial3D
					if mm:
						mm.albedo_color.a = fade
	# Earth visible once in space.
	if _earth:
		_earth.visible = alt_m > 1500.0


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
	var env: Environment = _environment.environment
	if env == null:
		return
	match phase:
		Phase.ASCENT:
			env.ambient_light_color = Color(0.85, 0.85, 0.95)
		Phase.ATMOSPHERE:
			env.ambient_light_color = Color(0.45, 0.50, 0.75)
		Phase.SPACE:
			env.ambient_light_color = Color(0.10, 0.10, 0.20)
		Phase.LANDING:
			env.ambient_light_color = Color(0.25, 0.25, 0.30)
