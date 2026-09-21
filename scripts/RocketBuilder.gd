extends Node3D
class_name RocketBuilder
## Owns the assembly tree for a rocket. Receives a RocketPartData per slot
## from the workshop and rebuilds the visual + collision stack.
##
## Slot stacking rules:
##   root
##     ├─ Booster[n]   (radial around body)
##     ├─ Body         (bottom of stack)
##     ├─ Tank         (above body)
##     ├─ Engine       (bottom of body)
##     ├─ Fin[n]       (radial around body bottom)
##     └─ Nose         (top of stack)
##
## Each part's local origin = its attach point. attach_offset is the offset
## at which the NEXT part in the vertical stack should be placed.

signal rocket_rebuilt(stats: Dictionary)
signal part_added(slot: int, part_id: StringName)
signal part_removed(slot: int, part_id: StringName)

const RocketPartData = preload("res://resources/RocketPartData.gd")
const RocketPartInstance = preload("res://scripts/parts/RocketPartInstance.gd")
const PartCatalog = preload("res://resources/PartCatalog.gd")

@export var rocket_root_path: NodePath = ^"RocketRoot"
@export var preview_spin_speed: float = 0.35   # rad/s

var rocket_root: Node3D
var _slots: Dictionary = {}   # slot_name -> Array of RocketPartData (fins/boosters can repeat)
var _instances_root: Node3D


func _ready() -> void:
	rocket_root = get_node_or_null(rocket_root_path)
	if rocket_root == null:
		rocket_root = Node3D.new()
		rocket_root.name = "RocketRoot"
		add_child(rocket_root)
	_instances_root = Node3D.new()
	_instances_root.name = "Instances"
	rocket_root.add_child(_instances_root)
	if not Engine.is_editor_hint():
		# Phase 1 convenience: if no parts installed, give the player
		# something visible to fly. Real builds come from RocketWorkshop.
		if _slots.is_empty():
			install_default()
		_spin()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	rocket_root.rotate_y(preview_spin_speed * delta)


# ---------- Public API --------------------------------------------

func install_part(slot: int, part: RocketPartData) -> bool:
	if part == null or part.slot != slot:
		return false
	if not GameManager.is_part_unlocked(part.id):
		# Disallow; UI should already gate this.
		push_warning("RocketBuilder: part %s is locked" % part.id)
		return false
	if slot == RocketPartData.Slot.FIN:
		var fins: Array = _slots.get("FIN", [])
		if fins.size() >= 4:
			# Remove oldest fin
			fins.pop_front()
		fins.append(part)
		_slots["FIN"] = fins
	else:
		var key: String = RocketPartData.Slot.keys()[slot]
		_slots[key] = [part]
	part_added.emit(slot, part.id)
	_rebuild()
	return true


func remove_part(slot: int) -> void:
	var key: String = RocketPartData.Slot.keys()[slot]
	if _slots.has(key):
		var removed: Array = _slots[key]
		if removed.is_empty():
			return
		var pid: StringName = removed.pop_back().id
		part_removed.emit(slot, pid)
		_rebuild()


func get_part(slot: int, instance_index: int = 0) -> RocketPartData:
	var key: String = RocketPartData.Slot.keys()[slot]
	if not _slots.has(key):
		return null
	var arr: Array = _slots[key]
	if instance_index >= arr.size():
		return null
	return arr[instance_index]


func get_parts(slot: int) -> Array:
	var key: String = RocketPartData.Slot.keys()[slot]
	if not _slots.has(key):
		return []
	return _slots[key].duplicate()


func apply_paint(paint) -> void:
	# Recolor every installed part.
	for slot in _slots.keys():
		for p: RocketPartData in _slots[slot]:
			p.color = paint.primary
			p.accent_color = paint.accent
	_rebuild()


func reset() -> void:
	_slots.clear()
	_rebuild()


func install_default() -> void:
	# Convenience: install a representative rocket if no parts are present.
	if not _slots.is_empty():
		return
	var nose = PartCatalog._nose_classic()
	var body = PartCatalog._body_classic()
	var tank = PartCatalog._tank_basic()
	var engine = PartCatalog._engine_standard()
	var fin = PartCatalog._fin_tri()
	install_part(RocketPartData.Slot.NOSE, nose)
	install_part(RocketPartData.Slot.BODY, body)
	install_part(RocketPartData.Slot.TANK, tank)
	install_part(RocketPartData.Slot.ENGINE, engine)
	for i in 4:
		install_part(RocketPartData.Slot.FIN, fin)


func aggregated_stats() -> Dictionary:
	var thrust := 0.0
	var fuel := 0.0
	var weight := 0.0
	var stab := 0.0
	var eff := 1.0
	for slot_key in _slots.keys():
		for p: RocketPartData in _slots[slot_key]:
			thrust += p.thrust
			fuel += p.fuel
			weight += p.weight
			stab += p.stability
			eff = min(eff, p.efficiency)
	# Smooth a default-stability baseline
	if _slots.is_empty():
		stab = 0.0
	return {
		"thrust": thrust,
		"fuel": fuel,
		"weight": weight,
		"stability": stab,
		"efficiency": eff,
	}


# ---------- Internal ----------------------------------------------

func _rebuild() -> void:
	# Clear previous instances.
	for child in _instances_root.get_children():
		child.queue_free()

	# Layered building: boosters first (radial), then central stack bottom→up,
	# then fins (radial), then nose on top.

	# Boosters — placed radially around body center.
	var body := get_part(RocketPartData.Slot.BODY)
	var boosters: Array = get_parts(RocketPartData.Slot.BOOSTER)
	if body != null and not boosters.is_empty():
		var radius := 0.85
		var angle_step := TAU / boosters.size()
		for i in boosters.size():
			var p: RocketPartData = boosters[i]
			var inst := _spawn_instance(p)
			inst.slot_index = i
			var a := angle_step * i
			inst.position = Vector3(cos(a) * radius, 0, sin(a) * radius)

	# Central stack — body, tank, nose. Each top edge of current piece is
	# the next piece's origin (handled via attach_offset on the part).
	var y_cursor := 0.0
	var body_inst: RocketPartInstance = null
	var pieces_in_stack: Array = []
	if body != null:
		pieces_in_stack.append(body)
	var tank := get_part(RocketPartData.Slot.TANK)
	if tank != null:
		pieces_in_stack.append(tank)
	var nose := get_part(RocketPartData.Slot.NOSE)
	if nose != null:
		pieces_in_stack.append(nose)
	for p: RocketPartData in pieces_in_stack:
		var inst := _spawn_instance(p)
		inst.position = Vector3(0, y_cursor, 0)
		y_cursor += p.attach_offset.y
		if p.slot == RocketPartData.Slot.BODY:
			body_inst = inst

	# Engine — bottom of body.
	var engine := get_part(RocketPartData.Slot.ENGINE)
	if engine != null:
		var e_inst := _spawn_instance(engine)
		if body != null:
			e_inst.position = Vector3(0, -0.5, 0)
		else:
			e_inst.position = Vector3(0, y_cursor - 0.5, 0)

	# Fins — radial around body bottom.
	var fins: Array = get_parts(RocketPartData.Slot.FIN)
	if body_inst != null and not fins.is_empty():
		var fin_radius := 0.65
		var fin_step := TAU / fins.size()
		for i in fins.size():
			var p: RocketPartData = fins[i]
			var inst := _spawn_instance(p)
			inst.slot_index = i
			var a := fin_step * i
			inst.position = Vector3(cos(a) * fin_radius, -0.3, sin(a) * fin_radius)
			inst.rotation.y = a + PI * 0.5

	rocket_rebuilt.emit(aggregated_stats())


func _spawn_instance(data: RocketPartData) -> RocketPartInstance:
	var inst := RocketPartInstance.new()
	inst.name = "Part_%s_%d" % [RocketPartData.Slot.keys()[data.slot].capitalize(), randi() % 10000]
	inst.setup(data)
	_instances_root.add_child(inst)
	return inst


func _spin() -> void:
	# Continuous slow spin handled in _process — placeholder for future
	# per-state animation (e.g. faster spin while user is browsing parts).
	pass
