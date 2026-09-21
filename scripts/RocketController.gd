extends RigidBody3D
class_name RocketController
## Flight-side controller for a built rocket. Phase 2: real arcade physics
## with fuel-pressure dynamics, lean stability math, wind gusts, and a
## detailed failure-event surface so FlightController can pick the right
## celebratory / comedic outcome.
##
## Designed for friendly arcade feel — NOT a realistic flight sim.
## All math is intentionally exaggerated so failures are funny and
## successes feel rewarding.

signal altitude_changed(altitude_km: float)
signal fuel_changed(percent: float)
signal speed_changed(speed: float)
signal stability_changed(percent: float)
signal thrust_changed(percent: float)
signal landed(touchdown_velocity: float)
signal lean_warning(active: bool)
signal wind_gust(strength: float)
signal failure_event(kind: StringName, details: Dictionary)
signal multiplier_changed(multiplier: float)

const RocketPartData = preload("res://resources/RocketPartData.gd")
const RocketBuilder = preload("res://scripts/RocketBuilder.gd")

@export var builder_path: NodePath = ^"../RocketBuilder"
@export var max_lean_degrees: float = 25.0
@export var pitch_torque: float = 6.0
@export var yaw_torque: float = 5.0
@export var drag_coefficient: float = 0.02
@export var altitude_scale_km: float = 0.001    # 1 m == 0.001 km

# Phase 2 tunables — all visible in the Inspector, easy to balance.
@export_range(0.0, 1.0, 0.01) var fuel_thrust_floor: float = 0.6
@export_range(0.0, 1.0, 0.01) var fuel_mass_floor: float = 0.4
@export_range(0.0, 100.0, 0.1) var fuel_burn_per_sec: float = 14.0
@export_range(0.0, 100.0, 0.1) var idle_thrust: float = 0.55
@export_range(0.0, 10000.0, 1.0) var idle_altitude_m: float = 50.0
@export_range(0.0, 200.0, 0.1) var stability_recovery_torque: float = 18.0
@export_range(0.0, 5.0, 0.05) var lean_warning_threshold_rad: float = 0.7
@export_range(0.0, 100.0, 0.5) var wind_gust_min_interval: float = 4.0
@export_range(0.0, 100.0, 0.5) var wind_gust_max_interval: float = 10.0
@export_range(0.0, 1000.0, 1.0) var wind_gust_peak_altitude: float = 350.0
@export_range(0.0, 5000.0, 1.0) var max_safe_landing_speed: float = 22.0

var builder: RocketBuilder

# Internal physics state
var _engine_thrust: float = 0.0
var _booster_thrust: float = 0.0
var _fuel_units: float = 0.0
var _max_fuel: float = 0.0
var _base_mass: float = 1.0
var _stability_score: float = 1.0
var _lean := Vector2.ZERO
var _has_landed: bool = false
var _launched: bool = false
var _launch_time: float = 0.0

# Phase 2 telemetry
var max_altitude_m: float = 0.0
var start_position: Vector3
var current_thrust_pct: float = 0.0
var current_fuel_pct: float = 1.0
var current_multiplier: float = 1.0
var avg_stability: float = 1.0          # running average since launch
var _stability_samples: int = 0
var _lean_warning_active: bool = false
var _next_gust_time: float = 0.0
var _spin_rate: float = 0.0           # tracks fast Y rotation for "spin-out" detection
var _last_booster_imbalance: float = 0.0


func _ready() -> void:
	builder = get_node(builder_path)
	start_position = global_position
	# Populate flight numbers from builder stats.
	var stats: Dictionary = builder.aggregated_stats()
	_max_fuel = max(stats.get("fuel", 0.0), 0.0)
	_fuel_units = _max_fuel
	_base_mass = max(stats.get("weight", 1.0), 1.0)
	_engine_thrust = _sum_thrust(RocketPartData.Slot.ENGINE)
	_booster_thrust = _sum_thrust(RocketPartData.Slot.BOOSTER)
	_stability_score = clamp(stats.get("stability", 1.0), 0.05, 4.0)
	mass = _base_mass * (fuel_mass_floor + (1.0 - fuel_mass_floor) * 1.0)   # full tank
	gravity_scale = 1.0
	contact_monitor = true
	max_contacts_reported = 4
	_schedule_next_gust(randf_range(wind_gust_min_interval, wind_gust_max_interval))


# ---------- Main loop ----------

func _physics_process(delta: float) -> void:
	if _has_landed:
		return
	if not _launched:
		return
	_launch_time += delta
	_update_multiplier()
	_apply_thrust(delta)
	_apply_lean_input(delta)
	_apply_stability_recovery(delta)
	_apply_wind_gust(delta)
	_apply_drag()
	_update_telemetry()
	_track_spin()


# ---------- Thrust & fuel ----------

func _apply_thrust(delta: float) -> void:
	# Throttle from input + idle hover above safe altitude.
	var throttle: float = 0.0
	if Input.is_action_pressed("pitch_up") or Input.is_action_pressed("booster"):
		throttle = 1.0
	var altitude_m: float = global_position.y - start_position.y
	if altitude_m > idle_altitude_m:
		throttle = maxf(throttle, idle_thrust)

	# Drain fuel if throttle > 0.
	if throttle > 0.0 and _fuel_units > 0.0:
		var burn: float = throttle * delta * fuel_burn_per_sec
		_fuel_units = maxf(0.0, _fuel_units - burn)
		if _fuel_units <= 0.0:
			throttle = 0.0
			if not _has_landed:
				failure_event.emit(&"out_of_fuel", {"altitude_km": altitude_m * altitude_scale_km})
		current_fuel_pct = _fuel_units / _max_fuel if _max_fuel > 0.0 else 0.0
		fuel_changed.emit(current_fuel_pct)

	# Fuel-pressure dynamics: thrust decreases as tank drains.
	var fuel_ratio: float = current_fuel_pct
	var thrust_scale: float = fuel_thrust_floor + (1.0 - fuel_thrust_floor) * fuel_ratio
	var mass_scale: float = fuel_mass_floor + (1.0 - fuel_mass_floor) * fuel_ratio
	mass = _base_mass * mass_scale

	# Apply central thrust along local -Y (rocket points up).
	var thrust_force: float = (_engine_thrust + _booster_thrust) * throttle * 8.0 * thrust_scale
	if thrust_force > 0.0:
		apply_central_force(-transform.basis.y * thrust_force)

	current_thrust_pct = throttle * thrust_scale
	thrust_changed.emit(current_thrust_pct)


# ---------- Lean + stability ----------

func _apply_lean_input(delta: float) -> void:
	var lean_target := Vector2(
		Input.get_action_strength("pitch_down") - Input.get_action_strength("pitch_up"),
		Input.get_action_strength("yaw_right") - Input.get_action_strength("yaw_left")
	)
	_lean = _lean.lerp(lean_target, clampf(delta * 5.0, 0.0, 1.0))
	var max_lean: float = deg_to_rad(max_lean_degrees)
	var target_pitch: float = _lean.x * max_lean
	var target_yaw: float = _lean.y * max_lean
	# Apply torque around local X (pitch) and world Z (yaw).
	var pitch_torque_vec: Vector3 = -global_transform.basis.x * target_pitch * pitch_torque * mass
	var yaw_torque_vec: Vector3 = global_transform.basis.z * target_yaw * yaw_torque * mass
	apply_torque(pitch_torque_vec)
	apply_torque(yaw_torque_vec)

	# Booster imbalance: if player holds yaw, the boosters try to spin the
	# craft in the opposite direction. We track the *intent* lean (the smoothed
	# `_lean` value), not the actual orientation.
	_last_booster_imbalance = absf(_lean.y) - absf(_lean.x)


func _apply_stability_recovery(delta: float) -> void:
	# Recovery torque toward upright. Stronger when stability stat is higher.
	var recovery_scale: float = clampf(_stability_score * 0.7 + 0.3, 0.3, 4.0)
	# World-up deviation of the rocket's local up vector.
	var up_dot: float = global_transform.basis.y.dot(Vector3.UP)
	# The further from upright, the more correction we apply.
	var correction_axis: Vector3 = global_transform.basis.y.cross(Vector3.UP)
	var correction_torque: Vector3 = correction_axis * stability_recovery_torque * recovery_scale
	apply_torque(correction_torque)

	# Lean warning — emit when lean angle exceeds threshold.
	var lean_angle: float = acos(clampf(up_dot, -1.0, 1.0))
	var warning: bool = lean_angle > lean_warning_threshold_rad
	if warning != _lean_warning_active:
		_lean_warning_active = warning
		lean_warning.emit(warning)


func _apply_drag() -> void:
	var v: Vector3 = linear_velocity
	if v.length() > 0.01:
		apply_central_force(-v * drag_coefficient)


# ---------- Wind gusts ----------

func _schedule_next_gust(after: float) -> void:
	_next_gust_time = _launch_time + after


func _apply_wind_gust(_delta: float) -> void:
	if _launch_time < _next_gust_time:
		return
	# Gusts only occur in atmosphere (alt < ~1500m).
	var altitude_m: float = global_position.y - start_position.y
	var atmosphere_top: float = 1500.0
	if altitude_m > atmosphere_top:
		_schedule_next_gust(wind_gust_max_interval)
		return
	# Strength peaks at `wind_gust_peak_altitude`, fades to 0 at atmosphere_top.
	var height_factor: float = clampf(1.0 - altitude_m / atmosphere_top, 0.0, 1.0)
	var peak_factor: float = clampf(1.0 - absf(altitude_m - wind_gust_peak_altitude) / wind_gust_peak_altitude, 0.0, 1.0)
	var strength: float = 12.0 * height_factor * (0.5 + peak_factor * 0.5)
	if strength < 1.0:
		_schedule_next_gust(wind_gust_max_interval)
		return
	# Random horizontal direction.
	var angle: float = randf() * TAU
	var dir: Vector3 = Vector3(cos(angle), 0, sin(angle))
	apply_impulse(dir * strength * mass)
	wind_gust.emit(strength)
	_schedule_next_gust(randf_range(wind_gust_min_interval, wind_gust_max_interval))


# ---------- Telemetry ----------

func _update_telemetry() -> void:
	var altitude_m: float = global_position.y - start_position.y
	max_altitude_m = maxf(max_altitude_m, altitude_m)
	var alt_km: float = altitude_m * altitude_scale_km
	var up_dot: float = global_transform.basis.y.dot(Vector3.UP)
	var stability_pct: float = clampf((up_dot + 1.0) * 0.5, 0.0, 1.0)
	avg_stability = (avg_stability * _stability_samples + stability_pct) / float(_stability_samples + 1)
	_stability_samples += 1
	altitude_changed.emit(alt_km)
	speed_changed.emit(linear_velocity.length())
	stability_changed.emit(stability_pct)


func _track_spin() -> void:
	_spin_rate = absf(angular_velocity.y)
	if _spin_rate > 2.0 and not _has_landed:
		# Player spun the rocket beyond control. Emit the event but only once.
		failure_event.emit(&"spin_out", {"spin_rate": _spin_rate})


# ---------- Multiplier ----------

func _update_multiplier() -> void:
	# Tier:
	#   1.0x — normal
	#   1.5x — kept below 25% fuel
	#   2.0x — perfect stability
	var m: float = 1.0
	if current_fuel_pct < 0.25:
		m = maxf(m, 1.5)
	if avg_stability >= 0.95:
		m = maxf(m, 2.0)
	if not is_equal_approx(m, current_multiplier):
		current_multiplier = m
		multiplier_changed.emit(m)


# ---------- External API ----------

func ignite_engines() -> void:
	_launched = true


func reset_to_launchpad() -> void:
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	_has_landed = false
	_fuel_units = _max_fuel
	_launched = false
	_launch_time = 0.0
	current_fuel_pct = 1.0
	current_thrust_pct = 0.0
	current_multiplier = 1.0
	avg_stability = 1.0
	_stability_samples = 0
	_lean_warning_active = false
	max_altitude_m = 0.0


## Called by FlightController or by collision when the rocket touches ground.
## `touchdown_velocity` is the vertical speed at impact (positive = downwards).
## Decides whether this was a clean landing or a failure event.
func soft_land(touchdown_v: float = 0.0) -> void:
	if _has_landed:
		return
	_has_landed = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	# Failure classification — always comedic.
	var orientation_up: float = global_transform.basis.y.dot(Vector3.UP)
	var kind: StringName = &"landed"
	var details: Dictionary = {"touchdown_v": touchdown_v}
	if orientation_up < -0.5:
		kind = &"upside_down"
	elif absf(touchdown_v) > max_safe_landing_speed:
		kind = &"too_fast"
	elif current_fuel_pct < 0.05 and max_altitude_m > 100.0:
		# Barely coasted down on fumes — bonus comedy.
		kind = &"fumes_landing"
	failure_event.emit(kind, details)
	landed.emit(touchdown_v)


# ---------- Helpers ----------

func _sum_thrust(slot: int) -> float:
	var total: float = 0.0
	for p: RocketPartData in builder.get_parts(slot):
		total += p.thrust * p.efficiency
	return total
