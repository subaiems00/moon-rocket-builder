extends Node
class_name ParticleManager
## Builds & spawns procedural particle configurations at runtime so we don't
## need to author ParticleProcessMaterial .tres files in the editor.

static func build_exhaust() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.amount = 80
	particles.lifetime = 0.6
	particles.explosiveness = 0.0
	particles.local_coords = false
	particles.fixed_fps = 60

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 12.0
	mat.initial_velocity_min = 4.0
	mat.initial_velocity_max = 8.0
	mat.gravity = Vector3.ZERO
	mat.scale_min = 0.3
	mat.scale_max = 0.6
	mat.color = Color(1.0, 0.55, 0.20, 0.85)

	# Color ramp: yellow → orange → red → transparent.
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 0.95, 0.50))
	gradient.set_color(1, Color(1.0, 0.40, 0.20))
	gradient.set_color(2, Color(0.60, 0.20, 0.15))
	var ramp := GradientTexture1D.new()
	ramp.gradient = gradient
	mat.color_ramp = ramp

	particles.process_material = mat

	var mesh := SphereMesh.new()
	mesh.radius = 0.18
	mesh.height = 0.36
	var mesh_mat := StandardMaterial3D.new()
	mesh_mat.albedo_color = Color(1.0, 0.55, 0.20)
	mesh_mat.emission_enabled = true
	mesh_mat.emission = Color(1.0, 0.45, 0.10)
	mesh_mat.emission_energy_multiplier = 2.0
	mesh_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_mat.albedo_color.a = 0.9
	mesh.material = mesh_mat
	particles.draw_pass_1 = mesh
	return particles


static func build_smoke() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.amount = 120
	particles.lifetime = 1.8
	particles.explosiveness = 0.0
	particles.local_coords = false
	particles.fixed_fps = 30

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 25.0
	mat.initial_velocity_min = 1.0
	mat.initial_velocity_max = 2.5
	mat.gravity = Vector3(0, -0.6, 0)
	mat.scale_min = 0.6
	mat.scale_max = 1.2
	mat.damping_min = 0.4
	mat.damping_max = 0.8
	mat.color = Color(0.95, 0.95, 1.0)

	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.97, 0.97, 1.0))
	gradient.set_color(1, Color(0.55, 0.55, 0.65))
	gradient.set_color(2, Color(0.55, 0.55, 0.65, 0.0))
	var ramp := GradientTexture1D.new()
	ramp.gradient = gradient
	mat.color_ramp = ramp

	particles.process_material = mat
	var mesh := QuadMesh.new()
	mesh.size = Vector2(2.0, 2.0)
	var mesh_mat := StandardMaterial3D.new()
	mesh_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mesh_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_mat.albedo_color = Color(1, 1, 1)
	mesh_mat.albedo_texture = _soft_circle_texture()
	mesh.material = mesh_mat
	particles.draw_pass_1 = mesh
	return particles


static func build_stars() -> MultiMeshInstance3D:
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = MultiMesh.new()
	mmi.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	mmi.multimesh.use_colors = false
	mmi.multimesh.use_custom_data = false
	mmi.multimesh.mesh = QuadMesh.new()
	mmi.multimesh.mesh.size = Vector2(0.4, 0.4)
	var count := 1500
	mmi.multimesh.instance_count = count
	var rng := RandomNumberGenerator.new()
	rng.seed = 1234
	for i in count:
		var pos := Vector3(
			rng.randf_range(-1.0, 1.0),
			rng.randf_range(-0.2, 1.0),
			rng.randf_range(-1.0, 1.0)
		).normalized() * rng.randf_range(80.0, 250.0)
		var basis := Basis().rotated(Vector3.UP, rng.randf() * TAU)
		mmi.multimesh.set_instance_transform(i, Transform3D(basis, pos))
	var mat := StandardMaterial3D.new()
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1, 1, 1)
	mat.albedo_texture = _soft_circle_texture()
	mmi.material_override = mat
	return mmi


static func build_cloud() -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 1.5
	sphere.height = 1.5
	mi.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.98, 0.98, 1.0)
	mat.roughness = 1.0
	mi.material_override = mat
	mi.scale = Vector3.ONE * 4.0
	return mi


static func build_moon() -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 5.0
	sphere.height = 10.0
	sphere.radial_segments = 48
	sphere.rings = 32
	mi.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.97, 0.94, 0.86)
	mat.roughness = 0.85
	mat.metallic = 0.0
	# Add subtle craters as colored noise via emission.
	mat.emission_enabled = true
	mat.emission = Color(0.30, 0.20, 0.10)
	mat.emission_energy_multiplier = 0.05
	mi.material_override = mat
	return mi


static func _soft_circle_texture() -> Texture2D:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for y in 64:
		for x in 64:
			var d := Vector2(x - 32, y - 32).length() / 32.0
			var a := clamp(1.0 - d, 0.0, 1.0)
			a *= a
			img.set_pixel(x, y, Color(1, 1, 1, a))
	return ImageTexture.create_from_image(img)
