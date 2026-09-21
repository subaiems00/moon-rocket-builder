extends Node
class_name LaunchSequence
## Orchestrates the cinematic launch: countdown → warning lights →
## multi-stage ignition → rocket lift-off → camera handoff.
##
## Phase 4 polish:
## - The countdown beeps get a slight pitch rise with each tick.
## - Ignition is staged: starter pulse → idle → main thrust.
## - The exhaust particle material color and scale ramp with thrust.
## - The chase camera position tweens from ground to chase during
##   the first 2 s after lift-off (handled by the CinematicCamera).
## - Camera shake kicks in on ignition and intensifies at lift-off.

signal countdown_tick(value: int)
signal countdown_go()
signal rocket_lifted_off()
signal sequence_finished()
signal thrust_level_changed(level: float)   # 0..1, drives exhaust visuals

const RocketController = preload("res://scripts/RocketController.gd")
const ParticleManager = preload("res://scripts/ParticleManager.gd")

@export_node_path("Node3D") var rocket_path: NodePath
@export_node_path("Node3D") var launch_camera_path: NodePath
@export_node_path("Node3D") var warning_lights_path: NodePath
@export_node_path("Node3D") var exhaust_path: NodePath
@export_node_path("Node3D") var exhaust_glow_path: NodePath

@export var countdown_seconds: float = 3.0
@export var shake_intensity: float = 0.4

var _rocket: Node3D
var _camera: Camera3D
var _warning_lights: Node3D
var _exhaust: GPUParticles3D
var _exhaust_glow: OmniLight3D
var _thrust_level: float = 0.0


func _ready() -> void:
	_rocket = get_node_or_null(rocket_path)
	_camera = get_node_or_null(launch_camera_path) as Camera3D
	_warning_lights = get_node_or_null(warning_lights_path)
	_exhaust = get_node_or_null(exhaust_path) as GPUParticles3D
	_exhaust_glow = get_node_or_null(exhaust_glow_path) as OmniLight3D
	if _exhaust:
		_exhaust.emitting = false
	if _exhaust_glow:
		_exhaust_glow.light_energy = 0.0


func play() -> void:
	_countdown_then_launch()


# ---------- Stage internals ---------------------------------------

func _countdown_then_launch() -> void:
	AudioManager.play_sfx("warning")
	_pulse_warning_lights(true)
	# Brief pre-roll of low rumble for ambience.
	var t := get_tree().create_tween()
	t.tween_interval(0.6)
	for i in range(int(countdown_seconds)):
		var value := int(countdown_seconds) - i
		countdown_tick.emit(value)
		# Beeps rise in pitch (1.00 → 1.10) — feels alive.
		AudioManager.play_sfx("countdown_beep", 1.0 + 0.05 * value)
		t.tween_interval(1.0)
	countdown_go.emit()
	AudioManager.play_sfx("countdown_go")
	_pulse_warning_lights(false)
	t.tween_callback(_ignition_starter)
	t.tween_interval(0.35)
	t.tween_callback(_ignition_idle)
	t.tween_interval(0.35)
	t.tween_callback(_lift_off)
	t.tween_interval(4.0)
	t.tween_callback(_finish)
	t.finished.connect(func(): pass)


func _pulse_warning_lights(on: bool) -> void:
	if _warning_lights == null:
		return
	for child in _warning_lights.get_children():
		if child is OmniLight3D:
			var light: OmniLight3D = child
			light.light_energy = 6.0 if on else 0.0


# ---------- Staged ignition ---------------------------------------

func _set_thrust(level: float) -> void:
	_thrust_level = clamp(level, 0.0, 1.0)
	thrust_level_changed.emit(_thrust_level)

	# Ramp exhaust particles (amount scales, scale curve scales).
	if _exhaust and _exhaust.process_material is ParticleProcessMaterial:
		var mat: ParticleProcessMaterial = _exhaust.process_material
		# Scale bigger on main thrust, baseline on starter.
		var scale_factor := 0.4 + _thrust_level * 1.4
		mat.scale_min = 0.3 * scale_factor
		mat.scale_max = 0.6 * scale_factor
		# Color: idle = yellow, main = bright orange/red core.
		var color := Color(1.0, 0.95, 0.50).lerp(
			Color(1.0, 0.40, 0.20) if _thrust_level > 0.5 else Color(1.0, 0.65, 0.30),
			_thrust_level
		)
		mat.color = color
		# Amount grows with thrust for visual density.
		_exhaust.amount = int(40 + _thrust_level * 100)

	# Ramp the floor exhaust light.
	if _exhaust_glow:
		var target_energy: float = _thrust_level * 10.0
		var tw := create_tween()
		tw.tween_property(_exhaust_glow, "light_energy", target_energy, 0.15)

	# Per-part engine glow on every engine instance.
	if _rocket and _rocket.has_node("RocketRoot"):
		var parts := _rocket.get_node("RocketRoot/Instances").get_children()
		for p in parts:
			if p.has_method("set_engine_glow"):
				p.set_engine_glow(0.6 + _thrust_level * 2.5)

	# Camera shake scales with thrust.
	if _camera:
		var cam_root: Node = _camera.get_parent()
		if cam_root:
			cam_root.set("shake_intensity", _thrust_level * shake_intensity)


func _ignition_starter() -> void:
	# Phase 4: a brief "starter motor" puff before main thrust.
	AudioManager.play_sfx("engine_start")
	_set_thrust(0.25)


func _ignition_idle() -> void:
	# Ramp to main thrust, with a tween for smooth visual transition.
	AudioManager.play_sfx("engine_thrust")
	var tw := create_tween()
	tw.tween_method(_set_thrust, _thrust_level, 1.0, 0.6)
	if _exhaust:
		_exhaust.emitting = true
	# Brief overshoot shake pulse just before lift-off.
	var cam_root: Node = _camera.get_parent() if _camera else null
	if cam_root:
		var stw := create_tween()
		stw.tween_property(cam_root, "shake_intensity", shake_intensity * 1.4, 0.15)
		stw.tween_interval(0.4)
	# Cinematic camera: dolly back and rise during ignition so we tilt
	# up to follow the rocket.
	if _camera and _camera is CinematicCamera:
		var cam: CinematicCamera = _camera
		var dolly := create_tween().set_parallel(true)
		dolly.tween_property(cam, "offset", Vector3(7, 6, 14), 1.2)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		dolly.tween_property(cam, "look_ahead", Vector3(0, 3, 0), 1.2)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		cam.add_shake(0.15)


func _lift_off() -> void:
	if _rocket and _rocket is RigidBody3D:
		var rb: RigidBody3D = _rocket
		rb.gravity_scale = 1.0
		# Lift-off velocity scaled so the first frames feel weightless.
		rb.linear_velocity = Vector3(0, 7.0, 0)
	AudioManager.play_sfx("launch")
	# Sustained big shake as the rocket clears the tower.
	if _camera:
		var cam_root: Node = _camera.get_parent()
		if cam_root:
			cam_root.set("shake_intensity", shake_intensity * 2.0)
		# Phase 4: cinematic kick.
		if _camera is CinematicCamera:
			var cam: CinematicCamera = _camera
			cam.add_shake(0.6)
			# Lift the camera further back so we frame the rocket climbing.
			var dolly := create_tween().set_parallel(true)
			dolly.tween_property(cam, "offset", Vector3(10, 8, 18), 2.5)\
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			dolly.tween_property(cam, "look_ahead", Vector3(0, 6, 0), 2.5)\
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	rocket_lifted_off.emit()


func _finish() -> void:
	sequence_finished.emit()
