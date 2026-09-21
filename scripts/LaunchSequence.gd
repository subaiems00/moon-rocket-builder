extends Node
class_name LaunchSequence
## Orchestrates the cinematic launch: countdown → warning lights → ignition
## → rocket lift-off → camera handoff to FlightScene camera.
##
## Lives inside LaunchPad.tscn. References the launch camera, the rocket
## pivot, the warning lights, and the engine exhaust particle spawner.

signal countdown_tick(value: int)
signal countdown_go()
signal rocket_lifted_off()
signal sequence_finished()

const RocketController = preload("res://scripts/RocketController.gd")

@export_node_path("Node3D") var rocket_path: NodePath
@export_node_path("Node3D") var launch_camera_path: NodePath
@export_node_path("Node3D") var warning_lights_path: NodePath
@export_node_path("Node3D") var exhaust_path: NodePath     # GPUParticles3D

@export var countdown_seconds: float = 3.0
@export var shake_intensity: float = 0.3

var _rocket: Node3D
var _camera: Camera3D
var _warning_lights: Node3D
var _exhaust: GPUParticles3D


func _ready() -> void:
	_rocket = get_node_or_null(rocket_path)
	_camera = get_node_or_null(launch_camera_path) as Camera3D
	_warning_lights = get_node_or_null(warning_lights_path)
	_exhaust = get_node_or_null(exhaust_path) as GPUParticles3D
	if _exhaust:
		_exhaust.emitting = false


func play() -> void:
	_countdown_then_launch()


# ---------- Stage internals ---------------------------------------

func _countdown_then_launch() -> void:
	AudioManager.play_sfx("warning")
	_pulse_warning_lights(true)
	var t := get_tree().create_tween()
	t.tween_interval(0.6)
	var n := int(countown_value_int())
	for i in range(int(countdown_seconds)):
		var value := int(countdown_seconds) - i
		countdown_tick.emit(value)
		AudioManager.play_sfx("countdown_beep", 1.0 + 0.05 * value)
		t.tween_interval(1.0)
	countdown_go.emit()
	AudioManager.play_sfx("countdown_go")
	_pulse_warning_lights(false)
	t.tween_callback(_ignite)
	t.tween_interval(0.4)
	t.tween_callback(_lift_off)
	t.tween_interval(4.0)
	t.tween_callback(_finish)
	t.finished.connect(func(): pass)  # keep tween alive


func countown_value_int() -> float:
	return countdown_seconds


func _pulse_warning_lights(on: bool) -> void:
	if _warning_lights == null:
		return
	for child in _warning_lights.get_children():
		if child is OmniLight3D:
			var light: OmniLight3D = child
			light.light_energy = 6.0 if on else 0.0


func _ignite() -> void:
	if _exhaust:
		_exhaust.emitting = true
	AudioManager.play_sfx("engine_start")
	# Brief engine glow ramp on every engine instance + the floor lamp.
	if _rocket and _rocket.has_node("RocketRoot"):
		var parts := _rocket.get_node("RocketRoot/Instances").get_children()
		for p in parts:
			if p.has_method("set_engine_glow"):
				p.set_engine_glow(2.5)
	# Phase 3: pump the ground-level exhaust lamp.
	var lamp: Node = _rocket.get_node_or_null("ExhaustGlow") if _rocket else null
	if lamp and lamp is OmniLight3D:
		var tw := create_tween()
		tw.tween_property(lamp, "light_energy", 8.0, 0.4)


func _lift_off() -> void:
	if _rocket and _rocket is RigidBody3D:
		var rb: RigidBody3D = _rocket
		rb.gravity_scale = 1.0
		rb.linear_velocity = Vector3(0, 8.0, 0)
	AudioManager.play_sfx("launch")
	# Camera shake kick.
	if _camera:
		(_camera.get_parent() as Node).set("shake_intensity", shake_intensity)
	rocket_lifted_off.emit()


func _finish() -> void:
	sequence_finished.emit()
