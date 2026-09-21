extends Camera3D
class_name CinematicCamera
## Smoothly tracks a target with configurable offset + smooth time.
## Adds a tiny procedural shake so it feels alive without being nauseating.

@export var target_path: NodePath
@export var offset: Vector3 = Vector3(0, 2.5, 7.0)
@export var look_ahead: Vector3 = Vector3(0, 1.0, 0)
@export var follow_speed: float = 4.0
@export var shake_intensity: float = 0.0
@export var shake_decay: float = 6.0

var _target: Node3D
var _shake: float = 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	if target_path != NodePath(""):
		_target = get_node_or_null(target_path) as Node3D
		if _target:
			top_level = true


func _process(delta: float) -> void:
	if _target == null:
		return
	var desired := _target.global_position + offset
	global_position = global_position.lerp(desired, clamp(delta * follow_speed, 0.0, 1.0))
	var look := _target.global_position + look_ahead
	if look.distance_to(global_position) > 0.001:
		look_at(look, Vector3.UP)
	if _shake > 0.001:
		_shake = max(0.0, _shake - delta * shake_decay)
		var j := Vector3(
			_rng.randf_range(-_shake, _shake),
			_rng.randf_range(-_shake, _shake),
			_rng.randf_range(-_shake, _shake)
		)
		global_position += j
