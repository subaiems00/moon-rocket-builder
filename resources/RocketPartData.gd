extends Resource
class_name RocketPartData
## Data resource for a single rocket part. All stats live here so they
## can be inspected in the Godot editor and balanced without recompiling.
##
## Phase 1 uses primitive meshes; when a Blender `.glb` is exported for
## the same part_id, the loader (see RocketBuilder.gd) will use its mesh
## instead of the primitive fallback.

enum Slot { NOSE, BODY, TANK, ENGINE, FIN, BOOSTER }

@export var id: StringName
@export var display_name: String = "Rocket Part"
@export var slot: Slot = Slot.BODY
@export var description: String = ""

# Visual
@export var color: Color = Color(0.95, 0.96, 1.0)
@export var accent_color: Color = Color(0.92, 0.55, 0.30)
@export var primitive_mesh: Mesh   # fallback mesh used when no .glb is loaded
@export var glb_path: String       # optional Blender path (res://assets/models/...glb)
@export var icon: Texture2D

# Geometry attachment: offset (in local units) of the part's *next attach point*
# measured from the part origin. The builder uses this to stack parts.
@export var attach_offset: Vector3 = Vector3.ZERO

# Stats
@export_range(0.0, 10000.0, 1.0) var thrust: float = 100.0
@export_range(0.0, 10000.0, 1.0) var fuel: float = 100.0
@export_range(0.1, 1000.0, 0.1) var weight: float = 10.0
@export_range(0.0, 2.0, 0.01) var stability: float = 1.0
@export_range(0.1, 2.0, 0.01) var efficiency: float = 1.0
@export var price: int = 0
@export var unlock_requirement: StringName = &""
@export var unlocked_by_default: bool = false


func slot_name() -> String:
	return Slot.keys()[slot].capitalize()


func total_score() -> float:
	# Loose composite used by stats UI: higher thrust and stability good,
	# higher weight bad. Not physics — purely a UI feel gauge.
	var score := thrust * efficiency * 0.05 + stability * 50.0 - weight * 0.5
	return max(score, 0.0)
