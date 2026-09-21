extends ProgressBar
## Cartoon-style stat bar with chunky fill and gradient color.

class_name StatBar

@export var min_color: Color = Color(0.95, 0.30, 0.30)
@export var max_color: Color = Color(0.45, 0.95, 0.55)
@export var bar_height: int = 18

var _track: StyleBoxFlat
var _fill: StyleBoxFlat


func _ready() -> void:
	custom_minimum_size = Vector2(160, bar_height)
	show_percentage = false
	_track = StyleBoxFlat.new()
	_track.bg_color = Color(0.10, 0.10, 0.20, 0.85)
	_track.set_corner_radius_all(bar_height * 0.5)
	_track.content_margin_left = 4
	_track.content_margin_right = 4
	add_theme_stylebox_override("background", _track)

	_fill = StyleBoxFlat.new()
	_fill.bg_color = max_color
	_fill.set_corner_radius_all(bar_height * 0.5)
	add_theme_stylebox_override("fill", _fill)


func set_value_colored(percent: float) -> void:
	value = clamp(percent * 100.0, 0.0, 100.0)
	_fill.bg_color = min_color.lerp(max_color, clamp(percent, 0.0, 1.0))
