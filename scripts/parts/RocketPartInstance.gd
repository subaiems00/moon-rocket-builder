extends Node3D
class_name RocketPartInstance
## Runtime wrapper for a single part instance inside a rocket. Owns its
## MeshInstance3D + collision shape + attached exhaust (for engines).
## Receives part data from RocketBuilder and re-builds the visuals on demand.

signal material_changed()

const RocketPartData = preload("res://resources/RocketPartData.gd")

@export var data: RocketPartData
@export var slot_index: int = 0   # which fin/booster index this is (0..3)

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
	mesh_instance.mesh = data.primitive_mesh
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
	if mesh_instance and mesh_instance.get_surface_override_material(0) is StandardMaterial3D:
		var mat: StandardMaterial3D = mesh_instance.get_surface_override_material(0)
		mat.emission_energy_multiplier = 0.4 + strength * 0.6


func apply_paint(paint: PaintData) -> void:
	if data == null or paint == null:
		return
	data.color = paint.primary
	data.accent_color = paint.accent
	if is_inside_tree():
		_rebuild()
