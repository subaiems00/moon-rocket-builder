extends Node
class_name FailureAnimations
## Phase 4: per-failure-kind animations on landing/crash.
## Plays a short cinematic beat that matches the outcome title, so the
## player sees the joke land.
##
## Each method takes a Node3D `rocket` and the failure context, and is
## safe to call from `FlightController._end` (the rocket may already be
## stationary or tumbling).
##
## Particles are spawned into the parent 3D space (not into a CanvasLayer)
## so they show up in the chase camera.

const ParticleManager = preload("res://scripts/ParticleManager.gd")


## Top-level entry. Plays the right beat for the kind, plus a tween to
## the camera jolt level from the outcome.
static func play_failure(rocket: Node3D, kind: StringName, camera: Camera3D = null,
		camera_jolt: float = 0.4) -> void:
	if rocket == null:
		return
	match kind:
		&"success", &"perfect":
			_play_success(rocket, camera)
		&"fail_speed":
			_play_bounce_crash(rocket, camera, camera_jolt)
		&"fail_upside_down":
			_play_upside_down(rocket, camera, camera_jolt)
		&"fail_out_of_fuel":
			_play_dust_settle(rocket, camera, camera_jolt)
		&"fail_spin":
			_play_spin_out(rocket, camera, camera_jolt)
		&"fail_crash":
			_play_dust_settle(rocket, camera, camera_jolt * 1.3)
		&"fumes_landing":
			_play_fumes(rocket, camera)
		_:
			_play_dust_settle(rocket, camera, camera_jolt)


# ---------- Per-kind beats ---------------------------------------

static func _play_success(rocket: Node3D, camera: Camera3D) -> void:
	# Confetti burst around the rocket.
	var confetti: GPUParticles3D = ParticleManager.build_confetti()
	confetti.global_position = rocket.global_position + Vector3.UP * 1.5
	rocket.get_tree().current_scene.add_child(confetti)
	confetti.emitting = true
	var ft := rocket.get_tree().create_timer(confetti.lifetime + 0.5)
	ft.timeout.connect(func():
		if is_instance_valid(confetti):
			confetti.queue_free()
	)
	# Gentle squash-and-settle on the rocket.
	_play_squash_and_settle(rocket, 0.85)


static func _play_fumes(rocket: Node3D, camera: Camera3D) -> void:
	# Fumes = success variant with extra sparkles.
	_play_success(rocket, camera)


static func _play_bounce_crash(rocket: Node3D, camera: Camera3D, jolt: float) -> void:
	# Cartoon bounce — compress vertically, then spring back, then
	# wobble. Squashes and stretches instead of breaking.
	if rocket is RigidBody3D:
		(rocket as RigidBody3D).linear_velocity = Vector3.ZERO
	_apply_camera_jolt(camera, jolt)
	_play_squash_and_settle(rocket, 0.6, true)
	_play_dust_burst(rocket)


static func _play_upside_down(rocket: Node3D, camera: Camera3D, jolt: float) -> void:
	_apply_camera_jolt(camera, jolt)
	# Slow tumble that ends upside-down + dust at touchdown.
	if rocket is RigidBody3D:
		(rocket as RigidBody3D).linear_velocity = Vector3.ZERO
		var rb: RigidBody3D = rocket
		var tween := rocket.create_tween()
		tween.tween_property(rb, "rotation_degrees",
			Vector3(rb.rotation_degrees.x + 35.0, rb.rotation_degrees.y + 180.0, rb.rotation_degrees.z),
			0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_play_dust_burst(rocket, 1.4)


static func _play_out_of_fuel(rocket: Node3D, camera: Camera3D, jolt: float) -> void:
	_apply_camera_jolt(camera, jolt * 0.5)
	_play_dust_settle(rocket, camera, jolt)


static func _play_spin_out(rocket: Node3D, camera: Camera3D, jolt: float) -> void:
	_apply_camera_jolt(camera, jolt)
	# Continued slow tumble — the player gets to watch it spin out.
	if rocket is RigidBody3D:
		var rb: RigidBody3D = rocket
		var tween := rocket.create_tween()
		tween.set_loops(3)
		tween.tween_property(rb, "rotation_degrees",
			Vector3(rb.rotation_degrees.x, rb.rotation_degrees.y + 360.0, rb.rotation_degrees.z),
			1.5).set_trans(Tween.TRANS_LINEAR)
		tween.finished.connect(func(): if tween: tween.kill())
	_play_dust_burst(rocket)


static func _play_dust_settle(rocket: Node3D, camera: Camera3D, jolt: float) -> void:
	_apply_camera_jolt(camera, jolt)
	_play_dust_burst(rocket)
	_play_squash_and_settle(rocket, 0.7)


# ---------- Building blocks --------------------------------------

static func _play_squash_and_settle(rocket: Node3D, intensity: float = 1.0, wobble: bool = false) -> void:
	if rocket == null:
		return
	var t := rocket.create_tween()
	var base_scale: Vector3 = Vector3.ONE
	t.tween_property(rocket, "scale", Vector3(1.2, 0.7, 1.2) * intensity, 0.08)
	t.tween_property(rocket, "scale", Vector3(0.92, 1.15, 0.92) * intensity, 0.10)
	t.tween_property(rocket, "scale", base_scale, 0.16)
	if wobble:
		t.tween_property(rocket, "rotation_degrees:z", 6.0, 0.10)
		t.tween_property(rocket, "rotation_degrees:z", -4.0, 0.12)
		t.tween_property(rocket, "rotation_degrees:z", 0.0, 0.10)


static func _play_dust_burst(rocket: Node3D, scale: float = 1.0) -> void:
	var dust: GPUParticles3D = ParticleManager.build_dust_burst(scale)
	dust.global_position = rocket.global_position + Vector3.DOWN * 0.4
	rocket.get_tree().current_scene.add_child(dust)
	dust.emitting = true
	var ft := rocket.get_tree().create_timer(dust.lifetime + 0.4)
	ft.timeout.connect(func():
		if is_instance_valid(dust):
			dust.queue_free()
	)


static func _apply_camera_jolt(camera: Camera3D, jolt: float) -> void:
	if camera == null:
		return
	if camera is CinematicCamera:
		(camera as CinematicCamera).add_shake(jolt)
	else:
		var cam_root: Node = camera.get_parent()
		if cam_root:
			var cur: float = float(cam_root.get("shake_intensity"))
			cam_root.set("shake_intensity", maxf(cur, jolt))
