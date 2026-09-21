extends Node
## Static catalog of all RocketPartData resources the game knows about.
## Phase 1 declares parts inline (no .tres files needed) so the project
## imports and runs immediately. Phase 3 swaps these for .tres loaded
## from res://resources/parts/ when Blender .glbs arrive.

class_name PartCatalog

const PART_DATA_SCRIPT := preload("res://resources/RocketPartData.gd")

static func all() -> Array[RocketPartData]:
	var out: Array[RocketPartData] = []
	for slot in [RocketPartData.Slot.NOSE, RocketPartData.Slot.BODY,
				 RocketPartData.Slot.TANK, RocketPartData.Slot.ENGINE,
				 RocketPartData.Slot.FIN, RocketPartData.Slot.BOOSTER]:
		out.append_array(by_slot(slot))
	return out


static func by_slot(slot: int) -> Array[RocketPartData]:
	var out: Array[RocketPartData] = []
	match slot:
		RocketPartData.Slot.NOSE:
			out.append(_nose_classic())
			out.append(_nose_pointy())
		RocketPartData.Slot.BODY:
			out.append(_body_classic())
			out.append(_body_chubby())
		RocketPartData.Slot.TANK:
			out.append(_tank_basic())
			out.append(_tank_jumbo())
		RocketPartData.Slot.ENGINE:
			out.append(_engine_standard())
			out.append(_engine_boost())
		RocketPartData.Slot.FIN:
			out.append(_fin_tri())
			out.append(_fin_square())
		RocketPartData.Slot.BOOSTER:
			out.append(_booster_small())
			out.append(_booster_big())
	return out


# ---------- factories ---------------------------------------------

static func _make(slot: int, id: StringName, name: String, mesh: Mesh,
		attach_offset: Vector3, color: Color, accent: Color,
		thrust: float, fuel: float, weight: float, stab: float, eff: float,
		price: int, default_unlocked: bool = false,
		glb_path: String = "") -> RocketPartData:
	var p := RocketPartData.new()
	p.id = id
	p.display_name = name
	p.slot = slot
	p.primitive_mesh = mesh
	p.attach_offset = attach_offset
	p.color = color
	p.accent_color = accent
	p.thrust = thrust
	p.fuel = fuel
	p.weight = weight
	p.stability = stab
	p.efficiency = eff
	p.price = price
	p.unlocked_by_default = default_unlocked
	# Phase 3: glb_path is checked at runtime. The RocketPartInstance will
	# load the .glb if it exists, fall back to the primitive if not.
	if glb_path != "":
		p.glb_path = glb_path
	return p


# ---------- NOSE --------------------------------------------------

static func _nose_classic() -> RocketPartData:
	var m := CapsuleMesh.new()
	m.radius = 0.6
	m.height = 1.6
	return _make(
		RocketPartData.Slot.NOSE, &"nose_classic", "Classic Cone",
		m, Vector3(0, 1.4, 0),
		Color(0.98, 0.96, 0.92), Color(0.93, 0.55, 0.30),
		0, 0, 4, 0.4, 1.0,
		0, true, "res://assets/models/nose_classic.glb")


static func _nose_pointy() -> RocketPartData:
	var m := PrismMesh.new()
	m.size = Vector3(0.9, 1.8, 0.9)
	return _make(
		RocketPartData.Slot.NOSE, &"nose_pointy", "Pointy Cone",
		m, Vector3(0, 1.6, 0),
		Color(0.92, 0.78, 1.0), Color(1.0, 0.42, 0.66),
		0, 0, 3, 0.5, 1.0,
		200, false, "res://assets/models/nose_pointy.glb")


# ---------- BODY --------------------------------------------------

static func _body_classic() -> RocketPartData:
	var m := CylinderMesh.new()
	m.top_radius = 0.6
	m.bottom_radius = 0.6
	m.height = 2.4
	return _make(
		RocketPartData.Slot.BODY, &"body_classic", "Slim Body",
		m, Vector3(0, 2.4, 0),
		Color(0.97, 0.97, 1.0), Color(0.40, 0.65, 1.0),
		0, 0, 6, 0.5, 1.0,
		0, true, "res://assets/models/body_classic.glb")


static func _body_chubby() -> RocketPartData:
	var m := CylinderMesh.new()
	m.top_radius = 0.9
	m.bottom_radius = 0.9
	m.height = 2.0
	return _make(
		RocketPartData.Slot.BODY, &"body_chubby", "Chubby Body",
		m, Vector3(0, 2.0, 0),
		Color(0.95, 0.90, 0.78), Color(0.85, 0.45, 0.30),
		0, 0, 10, 0.9, 0.9,
		250, false, "res://assets/models/body_chubby.glb")


# ---------- TANK --------------------------------------------------

static func _tank_basic() -> RocketPartData:
	var m := CylinderMesh.new()
	m.top_radius = 0.6
	m.bottom_radius = 0.6
	m.height = 1.6
	return _make(
		RocketPartData.Slot.TANK, &"tank_basic", "Basic Tank",
		m, Vector3(0, 1.6, 0),
		Color(0.55, 0.78, 0.95), Color(0.93, 0.55, 0.30),
		0, 120, 5, 0.2, 1.0,
		0, true, "res://assets/models/tank_basic.glb")


static func _tank_jumbo() -> RocketPartData:
	var m := CylinderMesh.new()
	m.top_radius = 0.85
	m.bottom_radius = 0.85
	m.height = 2.4
	return _make(
		RocketPartData.Slot.TANK, &"tank_jumbo", "Jumbo Tank",
		m, Vector3(0, 2.4, 0),
		Color(0.45, 0.65, 0.95), Color(0.93, 0.55, 0.30),
		0, 220, 11, 0.3, 0.9,
		300, false, "res://assets/models/tank_jumbo.glb")


# ---------- ENGINE ------------------------------------------------

static func _engine_standard() -> RocketPartData:
	var m := CylinderMesh.new()
	m.top_radius = 0.55
	m.bottom_radius = 0.7
	m.height = 1.2
	return _make(
		RocketPartData.Slot.ENGINE, &"engine_standard", "Standard Engine",
		m, Vector3(0, 0, 0),
		Color(0.65, 0.65, 0.72), Color(1.0, 0.55, 0.20),
		220, 0, 8, 0.4, 1.0,
		0, true, "res://assets/models/engine_standard.glb")


static func _engine_boost() -> RocketPartData:
	var m := CylinderMesh.new()
	m.top_radius = 0.7
	m.bottom_radius = 0.95
	m.height = 1.6
	return _make(
		RocketPartData.Slot.ENGINE, &"engine_boost", "Boost Engine",
		m, Vector3(0, 0, 0),
		Color(0.55, 0.55, 0.65), Color(0.95, 0.30, 0.20),
		420, 0, 14, 0.5, 0.95,
		500, false, "res://assets/models/engine_boost.glb")


# ---------- FIN ---------------------------------------------------

static func _fin_tri() -> RocketPartData:
	var m := PrismMesh.new()
	m.size = Vector3(0.1, 1.0, 1.2)
	return _make(
		RocketPartData.Slot.FIN, &"fin_tri", "Tri Fin",
		m, Vector3(0, 0, 0),
		Color(0.95, 0.55, 0.45), Color(0.30, 0.35, 0.85),
		0, 0, 1, 1.0, 1.0,
		0, true, "res://assets/models/fin_tri.glb")


static func _fin_square() -> RocketPartData:
	var m := BoxMesh.new()
	m.size = Vector3(0.08, 0.8, 1.3)
	return _make(
		RocketPartData.Slot.FIN, &"fin_square", "Square Fin",
		m, Vector3(0, 0, 0),
		Color(0.45, 0.75, 0.95), Color(0.95, 0.55, 0.30),
		0, 0, 1, 1.2, 1.0,
		150, false, "res://assets/models/fin_square.glb")


# ---------- BOOSTER -----------------------------------------------

static func _booster_small() -> RocketPartData:
	var m := CylinderMesh.new()
	m.top_radius = 0.28
	m.bottom_radius = 0.28
	m.height = 1.6
	return _make(
		RocketPartData.Slot.BOOSTER, &"booster_small", "Small Booster",
		m, Vector3(0, 1.6, 0),
		Color(0.85, 0.85, 0.9), Color(0.95, 0.55, 0.30),
		180, 30, 4, 0.6, 1.0,
		0, true, "res://assets/models/booster_small.glb")


static func _booster_big() -> RocketPartData:
	var m := CylinderMesh.new()
	m.top_radius = 0.42
	m.bottom_radius = 0.42
	m.height = 2.4
	return _make(
		RocketPartData.Slot.BOOSTER, &"booster_big", "Big Booster",
		m, Vector3(0, 2.4, 0),
		Color(0.78, 0.78, 0.85), Color(0.95, 0.30, 0.20),
		340, 70, 9, 0.8, 0.9,
		400, false, "res://assets/models/booster_big.glb")
