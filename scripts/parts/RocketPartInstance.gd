extends Node3D
class_name RocketPartInstance
## Runtime wrapper for a single part instance inside a rocket. Owns its
## MeshInstance3D + collision shape + attached exhaust (for engines).
## Receives part data from RocketBuilder and re-builds the visuals on demand.
##
## Phase 3: if the part has a `glb_path` and the file exists, the .glb is
## loaded and its first mesh replaces the primitive. Otherwise the
## primitive fallback is used.

signal material_changed()

const RocketPartData = preload("res://resources/RocketPartData.gd")
const ToonShader = preload("res://shaders/toon.gdshader")

@export var data: RocketPartData
@export var slot_index: int = 0   # which fin/booster index this is (0..3)
@export var use_toon_shader: bool = true   # Phase 3: cartoon shading

var mesh_instance: MeshInstance3D
var collision: CollisionShape3D
var engine_glow: OmniLight3D
var part_root: Node3D


func _ready() -> void:
	part_root = Node3D.new()
	part_root.name = "PartRoot"
	add_child(part_root)
	mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "Mesh"
	part_root.add_child(mesh_instance)
	collision = CollisionShape3D.new()
	collision.name = "Collision"
	part_root.add_child(collision)
	if data and data.slot == RocketPartData.Slot.ENGINE:
		_build_engine_glow()


func setup(d: RocketPartData) -> void:
	data = d
	if is_inside_tree():
		_rebuild()


func _rebuild() -> void:
	if data == null:
		return
	# Phase 3: try .glb first via AssetLoader, fall back to primitive.
	var mesh: Mesh = AssetLoader.load_part_mesh(data)
	mesh_instance.mesh = mesh
	# Use the toon shader on top of whatever mesh we got, so primitives
	# and .glb meshes share the same cartoon look.
	if use_toon_shader and ToonShader:
		var mat := ShaderMaterial.new()
		mat.shader = ToonShader
		mat.set_shader_parameter("albedo", data.color)
		mat.set_shader_parameter("accent", data.accent_color)
		mat.set_shader_parameter("bands", 3.0)
		mat.set_shader_parameter("rim_strength", 1.6)
		mat.set_shader_parameter("rim_power", 2.5)
		var is_engine: bool = data.slot == RocketPartData.Slot.ENGINE
		mat.set_shader_parameter("emission_strength", 1.5 if is_engine else 0.0)
		# The toon shader draws its own albedo — let it.
		mesh_instance.material_override = mat
		# Don't also set a per-surface override; the shader handles it.
	else:
		mesh_instance.set_surface_override_material(0, _make_material())
	collision.shape = _make_shape()
	if data.slot == RocketPartData.Slot.ENGINE and engine_glow == null:
		_build_engine_glow()
	material_changed.emit()


func _make_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = data.color
	mat.metallic = 0.0
	mat.roughness = 0.55
	mat.emission_enabled = data.slot == RocketPartData.Slot.ENGINE
	mat.emission = data.accent_color
	mat.emission_energy_multiplier = 0.4 if data.slot == RocketPartData.Slot.ENGINE else 0.0
	return mat


func _make_shape() -> Shape3D:
	# Use a primitive shape that closely hugs the mesh.
	match data.slot:
		RocketPartData.Slot.NOSE, RocketPartData.Slot.BODY, \
		RocketPartData.Slot.TANK, RocketPartData.Slot.ENGINE, \
		RocketPartData.Slot.BOOSTER:
			var cap := CapsuleShape3D.new()
			cap.radius = 0.6
			cap.height = 1.4
			return cap
		RocketPartData.Slot.FIN:
			var box := BoxShape3D.new()
			box.size = Vector3(0.1, 1.0, 1.2)
			return box
	return null


func _build_engine_glow() -> void:
	engine_glow = OmniLight3D.new()
	engine_glow.name = "EngineGlow"
	engine_glow.light_color = Color(1.0, 0.55, 0.20)
	engine_glow.light_energy = 0.0
	engine_glow.omni_range = 6.0
	engine_glow.position = Vector3(0, -0.6, 0)
	part_root.add_child(engine_glow)


func set_engine_glow(strength: float) -> void:
	if engine_glow == null:
		return
	engine_glow.light_energy = clamp(strength, 0.0, 6.0)
	# Update toon shader emission strength too, so the rim glow tracks the burn.
	if mesh_instance and mesh_instance.material_override is ShaderMaterial:
		var mat: ShaderMaterial = mesh_instance.material_override
		var is_engine: bool = data != null and data.slot == RocketPartData.Slot.ENGINE
		if is_engine:
			mat.set_shader_parameter("emission_strength", 1.5 + strength * 0.6)


func apply_paint(paint: PaintData) -> void:
	if data == null or paint == null:
		return
	data.color = paint.primary
	data.accent_color = paint.accent
	if is_inside_tree():
		_rebuild()

