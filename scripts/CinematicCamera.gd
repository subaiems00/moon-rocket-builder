extends Camera3D
class_name CinematicCamera
## Smoothly tracks a target with configurable offset + smooth time.
## Phase 4: adds an impulse-driven shake layer on top of continuous
## jitter, so ignition kicks feel meaty without being nauseating.

@export var target_path: NodePath
@export var offset: Vector3 = Vector3(0, 2.5, 7.0)
@export var look_ahead: Vector3 = Vector3(0, 1.0, 0)
@export var follow_speed: float = 4.0
@export var shake_intensity: float = 0.0
@export var shake_decay: float = 4.5
@export var max_shake: float = 0.6
@export var jitter_hz: float = 30.0          # high-freq jitter rate
@export var throb_hz: float = 3.0           # low-freq throb rate
@export var throb_scale: float = 0.6        # throb is this fraction of total shake

var _target: Node3D
var _shake: float = 0.0
var _rng := RandomNumberGenerator.new()
var _t: float = 0.0


func _ready() -> void:
	_rng.randomize()
	if target_path != NodePath(""):
		_target = get_node_or_null(target_path) as Node3D
		if _target:
			top_level = true


func _process(delta: float) -> void:
	if _target == null:
		return
	# Lerp toward target + offset.
	var desired: Vector3 = _target.global_position + offset
	global_position = global_position.lerp(desired, clampf(delta * follow_speed, 0.0, 1.0))
	# Look at the target + look-ahead point.
	var look: Vector3 = _target.global_position + look_ahead
	if look.distance_to(global_position) > 0.001:
		look_at(look, Vector3.UP)

	# Smoothly approach the externally-set shake_intensity so impulses decay.
	_shake = lerpf(_shake, clampf(shake_intensity, 0.0, max_shake), clampf(delta * 4.0, 0.0, 1.0))
	if _shake > 0.001:
		_t += delta
		# High-frequency jitter for grit.
		var jitter: Vector3 = Vector3(
			_rng.randf_range(-1.0, 1.0),
			_rng.randf_range(-1.0, 1.0),
			_rng.randf_range(-1.0, 1.0)
		) * _shake * (1.0 - throb_scale)
		# Low-frequency throb using a sin wave, larger amplitude on Y.
		var throb: Vector3 = Vector3(
			sin(_t * TAU * throb_hz + 1.7) * 0.6,
			sin(_t * TAU * throb_hz) * 1.4,         # Y throb is biggest
			sin(_t * TAU * throb_hz + 3.1) * 0.6
		) * _shake * throb_scale
		global_position += jitter + throb


## Called by external events (ignition, lift-off, crash) to add a
## one-shot shake impulse on top of the continuous shake_intensity.
func add_shake(impulse: float = 0.4) -> void:
	_shake = clampf(_shake + impulse, 0.0, max_shake * 1.5)


## Phase 4: animate the offset over time (used by LaunchSequence for
## the ground → chase dolly transition). Tween externally, this just
## receives the new value.
func set_offset(value: Vector3) -> void:
	offset = value
