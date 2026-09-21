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
	# Phase 3: brighter, more numerous, layered (small + large stars) so the
	# field has depth when parallaxed.
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = MultiMesh.new()
	mmi.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	mmi.multimesh.use_colors = true
	mmi.multimesh.use_custom_data = false
	mmi.multimesh.mesh = QuadMesh.new()
	mmi.multimesh.mesh.size = Vector2(0.4, 0.4)
	var count := 2200
	mmi.multimesh.instance_count = count
	var rng := RandomNumberGenerator.new()
	rng.seed = 1234
	for i in count:
		var pos := Vector3(
			rng.randf_range(-1.0, 1.0),
			rng.randf_range(-0.2, 1.0),
			rng.randf_range(-1.0, 1.0)
		).normalized() * rng.randf_range(120.0, 380.0)
		var basis := Basis().rotated(Vector3.UP, rng.randf() * TAU)
		mmi.multimesh.set_instance_transform(i, Transform3D(basis, pos))
		# Tint variation: white / pale yellow / pale blue, with slight brightness jitter.
		var tint_choice := rng.randf()
		var tint: Color
		if tint_choice < 0.6:
			tint = Color(1.0, 1.0, 1.0)
		elif tint_choice < 0.85:
			tint = Color(1.0, 0.92, 0.78)
		else:
			tint = Color(0.78, 0.88, 1.0)
		var brightness: float = rng.randf_range(0.5, 1.0)
		mmi.multimesh.set_instance_color(i, tint * brightness)
	var mat := StandardMaterial3D.new()
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.albedo_color = Color(1, 1, 1)
	mat.albedo_texture = _soft_circle_texture()
	mmi.material_override = mat
	return mmi


static func build_cloud() -> MeshInstance3D:
	# Phase 3: a multi-sphere cluster for that puffy-cumulus look.
	# Use 4 spheres parented under a single Node3D so the cluster reads
	# as one fluffy puff from any angle.
	var root := Node3D.new()
	var sphere := SphereMesh.new()
	sphere.radial_segments = 18
	sphere.rings = 12
	sphere.radius = 1.0
	sphere.height = 1.0
	var positions: Array[Vector3] = [
		Vector3(0, 0, 0),
		Vector3(1.4, 0.25, 0.0),
		Vector3(-1.0, -0.1, 0.4),
		Vector3(0.4, 0.5, -0.8),
	]
	var radii: Array[float] = [1.5, 1.2, 1.1, 0.9]
	for i in positions.size():
		var mi := MeshInstance3D.new()
		var s: SphereMesh = sphere.duplicate() as SphereMesh
		s.radius = radii[i]
		s.height = radii[i] * 2.0
		mi.mesh = s
		mi.position = positions[i]
		root.add_child(mi)
	# Materials set externally.
	return null  # return root instead via build_cloud_cluster below.


static func build_cloud_cluster() -> Node3D:
	# Convenience wrapper that returns the actual cluster root.
	var root := Node3D.new()
	var sphere := SphereMesh.new()
	sphere.radial_segments = 18
	sphere.rings = 12
	sphere.radius = 1.0
	sphere.height = 1.0
	var positions: Array[Vector3] = [
		Vector3(0, 0, 0),
		Vector3(1.4, 0.25, 0.0),
		Vector3(-1.0, -0.1, 0.4),
		Vector3(0.4, 0.5, -0.8),
	]
	var radii: Array[float] = [1.5, 1.2, 1.1, 0.9]
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.98, 0.98, 1.0)
	mat.roughness = 1.0
	for i in positions.size():
		var mi := MeshInstance3D.new()
		var s: SphereMesh = sphere.duplicate() as SphereMesh
		s.radius = radii[i]
		s.height = radii[i] * 2.0
		mi.mesh = s
		mi.material_override = mat
		mi.position = positions[i]
		root.add_child(mi)
	return root


static func build_moon() -> MeshInstance3D:
	# Phase 3: use the toon-style moon shader for procedural craters.
	var mi := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 5.0
	sphere.height = 10.0
	sphere.radial_segments = 64
	sphere.rings = 32
	mi.mesh = sphere
	var shader := load("res://shaders/moon.gdshader") as Shader
	if shader:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("albedo", Color(0.97, 0.94, 0.86))
		mat.set_shader_parameter("crater_color", Color(0.55, 0.45, 0.34))
		mat.set_shader_parameter("crater_density", 7.0)
		mat.set_shader_parameter("crater_size", 0.22)
		mat.set_shader_parameter("crater_softness", 0.06)
		mat.set_shader_parameter("rim_strength", 0.7)
		mat.set_shader_parameter("band_strength", 0.10)
		mi.material_override = mat
	else:
		# Fallback to standard material if the shader didn't load.
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.97, 0.94, 0.86)
		mat.roughness = 0.85
		mi.material_override = mat
	return mi


static func build_earth() -> MeshInstance3D:
	# Big Earth visible from space, low in the sky when looking back at home.
	# Toon-shaded blue with green "continents" baked in via the moon shader's
	# crater field (re-purposed for continents).
	var mi := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 25.0
	sphere.height = 50.0
	sphere.radial_segments = 64
	sphere.rings = 32
	mi.mesh = sphere
	var shader := load("res://shaders/moon.gdshader") as Shader
	if shader:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("albedo", Color(0.30, 0.50, 0.85))
		mat.set_shader_parameter("crater_color", Color(0.42, 0.65, 0.35))
		mat.set_shader_parameter("crater_density", 4.0)
		mat.set_shader_parameter("crater_size", 0.30)
		mat.set_shader_parameter("crater_softness", 0.10)
		mat.set_shader_parameter("rim_strength", 0.6)
		mat.set_shader_parameter("band_strength", 0.12)
		mi.material_override = mat
	else:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.30, 0.50, 0.85)
		mi.material_override = mat
	return mi


static func build_wind_puff() -> GPUParticles3D:
	# One-shot puff spawned when a wind gust hits the rocket. Pure white
	# cloud, billboarded, fades quickly.
	var particles := GPUParticles3D.new()
	particles.amount = 24
	particles.lifetime = 0.8
	particles.explosiveness = 1.0
	particles.one_shot = true
	particles.local_coords = false
	particles.fixed_fps = 30

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 0, 0)
	mat.spread = 60.0
	mat.initial_velocity_min = 0.5
	mat.initial_velocity_max = 1.5
	mat.gravity = Vector3(0, 0.5, 0)
	mat.scale_min = 0.8
	mat.scale_max = 1.4
	mat.damping_min = 0.5
	mat.damping_max = 1.0
	mat.color = Color(1.0, 1.0, 1.0)

	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 1.0, 1.0, 0.9))
	gradient.set_color(1, Color(0.9, 0.92, 1.0, 0.6))
	gradient.set_color(2, Color(0.85, 0.90, 1.0, 0.0))
	var ramp := GradientTexture1D.new()
	ramp.gradient = gradient
	mat.color_ramp = ramp

	particles.process_material = mat
	var mesh := QuadMesh.new()
	mesh.size = Vector2(1.2, 1.2)
	var mesh_mat := StandardMaterial3D.new()
	mesh_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mesh_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_mat.albedo_color = Color(1, 1, 1)
	mesh_mat.albedo_texture = _soft_circle_texture()
	mesh.material = mesh_mat
	particles.draw_pass_1 = mesh
	return particles


static func _soft_circle_texture() -> Texture2D:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for y: int in 64:
		for x: int in 64:
			var d: float = Vector2(x - 32, y - 32).length() / 32.0
			var a: float = clampf(1.0 - d, 0.0, 1.0)
			a *= a
			img.set_pixel(x, y, Color(1, 1, 1, a))
	return ImageTexture.create_from_image(img)
