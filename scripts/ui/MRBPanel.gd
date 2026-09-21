extends PanelContainer
## Custom rounded panel with a soft drop shadow. Used by menus & HUD chips.

class_name MRBPanel

@export var corner_radius: int = 18
@export var bg_color: Color = Color(0.12, 0.10, 0.36, 0.78)
@export var border_color: Color = Color(0.85, 0.78, 1.0, 0.18)


func _ready() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(corner_radius)
	style.shadow_color = Color(0, 0, 0, 0.35)
	style.shadow_size = 14
	add_theme_stylebox_override("panel", style)
