extends Camera3D
class_name ChaseCamera
## Pulls behind and slightly above the target, looking forward.

@export var target_path: NodePath
@export var distance: float = 9.0
@export var height: float = 3.0
@export var smooth_speed: float = 5.0

var _target: Node3D


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node3D
	if _target:
		top_level = true


func _process(delta: float) -> void:
	if _target == null:
		return
	var back := _target.global_transform.basis.z
	var desired := _target.global_position - back * distance + Vector3.UP * height
	global_position = global_position.lerp(desired, clamp(delta * smooth_speed, 0.0, 1.0))
	look_at(_target.global_position + Vector3.UP * 1.5, Vector3.UP)
