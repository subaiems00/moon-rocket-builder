extends Button
class_name VirtualBoostButton
## Phase 4: a touchscreen-friendly boost button. Press and hold to
## fire the main engine. Visually pulses when active so the player
## gets feedback their input is registering.

@export var base_color: Color = Color(1.0, 0.55, 0.30)
@export var active_color: Color = Color(1.0, 0.85, 0.45)
@export var action: String = "pitch_up"  # press to thrust

var _style_normal: StyleBoxFlat
var _style_pressed: StyleBoxFlat
var _pulse_tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(120, 120)
	text = "🚀"
	add_theme_font_size_override("font_size", 36)
	_style_normal = StyleBoxFlat.new()
	_style_normal.bg_color = base_color
	_style_normal.set_corner_radius_all(60)
	_style_normal.border_color = Color(1, 1, 1, 0.4)
	_style_normal.set_border_width_all(3)
	add_theme_stylebox_override("normal", _style_normal)
	_style_pressed = StyleBoxFlat.new()
	_style_pressed.bg_color = active_color
	_style_pressed.set_corner_radius_all(60)
	_style_pressed.border_color = Color(1, 1, 1, 0.7)
	_style_pressed.set_border_width_all(3)
	add_theme_stylebox_override("pressed", _style_pressed)
	add_theme_stylebox_override("hover_pressed", _style_pressed)
	# When the user presses, hold the action as long as they hold the button.
	button_down.connect(_on_down)
	button_up.connect(_on_up)


func _on_down() -> void:
	Input.action_press(action)
	_start_pulse()


func _on_up() -> void:
	Input.action_release(action)
	_stop_pulse()


func _start_pulse() -> void:
	_stop_pulse()
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(self, "scale", Vector2.ONE * 1.10, 0.18)
	_pulse_tween.tween_property(self, "scale", Vector2.ONE * 0.96, 0.18)


func _stop_pulse() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
	_pulse_tween = null
	scale = Vector2.ONE
