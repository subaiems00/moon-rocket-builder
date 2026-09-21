extends Resource
class_name PaintData

@export var id: StringName
@export var display_name: String = "White"
@export var primary: Color = Color(0.95, 0.96, 1.0)
@export var accent: Color = Color(0.92, 0.55, 0.30)
@export var unlock_requirement: StringName = &""
@export var unlocked_by_default: bool = false
