extends Button
## Pill-shaped cartoon button with hover & press tween animation.

class_name MRBButton

@export var base_color: Color = Color(1.0, 0.55, 0.30)
@export var hover_color: Color = Color(1.0, 0.70, 0.42)
@export var press_color: Color = Color(0.85, 0.40, 0.20)
@export var corner_radius: int = 22
@export var font_size: int = 24


func _ready() -> void:
	var normal := _make_style(base_color)
	var hover := _make_style(hover_color)
	var pressed := _make_style(press_color)
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("pressed", pressed)
	add_theme_stylebox_override("focus", _make_style(hover_color))
	add_theme_color_override("font_color", Color(0.10, 0.07, 0.20))
	add_theme_color_override("font_hover_color", Color(0.10, 0.07, 0.20))
	add_theme_font_size_override("font_size", font_size)
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)
	connect("pressed", _on_pressed)
	connect("focus_entered", _on_focus)
	connect("focus_exited", _on_unfocus)
	modulate = Color(1, 1, 1, 0)
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.25)


func _make_style(color: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(corner_radius)
	s.content_margin_left = 24
	s.content_margin_right = 24
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	s.shadow_color = Color(0, 0, 0, 0.30)
	s.shadow_size = 8
	return s


func _on_hover() -> void:
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2.ONE * 1.04, 0.12)
	AudioManager.play_sfx("ui_hover")


func _on_unhover() -> void:
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2.ONE, 0.12)


func _on_pressed() -> void:
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2.ONE * 0.94, 0.06)
	tw.tween_property(self, "scale", Vector2.ONE, 0.10)
	AudioManager.play_sfx("ui_click")


func _on_focus() -> void:
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2.ONE * 1.04, 0.12)


func _on_unfocus() -> void:
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2.ONE, 0.12)
