extends RigidBody3D
class_name RocketController
## Flight-side controller for a built rocket. Receives a RocketBuilder,
## computes combined thrust + drag from the part catalog, and steers
## arcade-style based on player input.
##
## Designed for friendly arcade feel: low gravity, high thrust, gentle
## drag. NOT a realistic flight sim.

signal altitude_changed(altitude_km: float)
signal fuel_changed(percent: float)
signal speed_changed(speed: float)
signal stability_changed(percent: float)
signal landed(touchdown_velocity: float)

const RocketPartData = preload("res://resources/RocketPartData.gd")
const RocketBuilder = preload("res://scripts/RocketBuilder.gd")

@export var builder_path: NodePath = ^"../RocketBuilder"
@export var gravity: float = 9.8
@export var max_lean_degrees: float = 25.0
@export var stability_recovery: float = 4.0     # how quickly rocket straightens up
@export var pitch_torque: float = 6.0
@export var yaw_torque: float = 5.0
@export var drag_coefficient: float = 0.02
@export var altitude_scale_km: float = 0.001    # 1m == 0.001 km

var builder: RocketBuilder
var _engine_thrust: float = 0.0
var _booster_thrust: float = 0.0
var _fuel_units: float = 0.0
var _max_fuel: float = 0.0
var _thrust_per_unit: float = 1.0
var _weight: float = 1.0
var _lean := Vector2.ZERO   # pitch/yaw target
var _has_landed: bool = false
var _launched: bool = false
var _launch_time: float = 0.0

# Telemetry
var max_altitude_m: float = 0.0
var start_position: Vector3


func _ready() -> void:
	builder = get_node(builder_path)
	start_position = global_position
	# Populate flight numbers from builder stats.
	var stats: Dictionary = builder.aggregated_stats()
	_max_fuel = stats.get("fuel", 0.0)
	_fuel_units = _max_fuel
	_weight = max(stats.get("weight", 1.0), 1.0)
	_engine_thrust = _sum_thrust(RocketPartData.Slot.ENGINE)
	_booster_thrust = _sum_thrust(RocketPartData.Slot.BOOSTER)
	# Stiffer the heavier; looser if stability stat is high.
	mass = _weight
	gravity_scale = 1.0
	contact_monitor = true
	max_contacts_reported = 4


func _physics_process(delta: float) -> void:
	if _has_landed:
		return
	if not _launched:
		return
	_launch_time += delta

	# Throttle: hold W/Space to thrust up; release = coast down.
	var throttle := 0.0
	if Input.is_action_pressed("pitch_up") or Input.is_action_pressed("booster"):
		throttle = 1.0
	# Add gentle constant hover when altitude > 50m so the rocket doesn't
	# immediately fall during testing.
	var altitude_m := global_position.y - start_position.y
	if altitude_m > 50.0:
		throttle = max(throttle, 0.55)

	# Drain fuel if any main engine thrust is applied.
	if throttle > 0.0 and _fuel_units > 0.0:
		var burn := throttle * delta * 20.0
		_fuel_units = max(0.0, _fuel_units - burn)
		# No main thrust when fuel is empty — slow gravity drift only.
		throttle = 0.0 if _fuel_units <= 0.0 else throttle
		fuel_changed.emit(_fuel_units / _max_fuel)

	# Apply thrust along the rocket's local -Y (rocket points up).
	var thrust_force := (_engine_thrust + _booster_thrust) * throttle * 8.0
	if thrust_force > 0.0:
		apply_central_force(-transform.basis.y * thrust_force)

	# Player intent: lean by WASD; recovery force pulls back toward upright.
	var lean_target := Vector2(
		Input.get_action_strength("pitch_down") - Input.get_action_strength("pitch_up"),
		Input.get_action_strength("yaw_right") - Input.get_action_strength("yaw_left")
	)
	_lean = _lean.lerp(lean_target, clamp(delta * 6.0, 0.0, 1.0))
	var max_lean := deg_to_rad(max_lean_degrees)
	var target_pitch := _lean.x * max_lean
	var target_yaw := _lean.y * max_lean
	# Convert lean target into a torque around X (pitch) and Y (yaw).
	var pitch_torque_vec := -global_transform.basis.x * target_pitch * pitch_torque * mass
	var yaw_torque_vec := global_transform.basis.z * target_yaw * yaw_torque * mass
	apply_torque(pitch_torque_vec)
	apply_torque(yaw_torque_vec)

	# Stability: pull rotation back toward level (penalty for high lean).
	angular_velocity = angular_velocity.lerp(
		Vector3(_lean.x * 0.5, _lean.y * 0.5, 0.0),
		clamp(delta * stability_recovery * 0.15, 0.0, 0.2)
	)

	# Drag.
	var v := linear_velocity
	if v.length() > 0.01:
		apply_central_force(-v * drag_coefficient)

	# Gravity (RigidBody3D handles gravity_scale automatically; we let it).

	# Telemetry.
	var alt_km := altitude_m * altitude_scale_km
	max_altitude_m = max(max_altitude_m, altitude_m)
	altitude_changed.emit(alt_km)
	speed_changed.emit(linear_velocity.length())
	stability_changed.emit(1.0 - clamp(rotation.x * rotation.x + rotation.z * rotation.z, 0.0, 1.0))


func ignite_engines() -> void:
	_launched = true


func reset_to_launchpad() -> void:
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	_has_landed = false
	_fuel_units = _max_fuel
	_launched = false
	_launch_time = 0.0


func soft_land(touchdown_v: float = 0.0) -> void:
	if _has_landed:
		return
	_has_landed = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	landed.emit(touchdown_v)


func _sum_thrust(slot: int) -> float:
	var total := 0.0
	for p: RocketPartData in builder.get_parts(slot):
		total += p.thrust * p.efficiency
	return total
