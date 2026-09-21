extends Control
class_name VirtualJoystick
## Phase 4 touch input — a virtual joystick that emits Godot Input actions
## so the existing flight controller doesn't need to know about touch.
##
## Layout: a circular base with a draggable thumb. Drag from the base
## to set direction; release returns the thumb to center. Tilt distance
## is mapped to action strength (0 = released, 1 = max tilt).

@export var base_radius: float = 80.0
@export var dead_zone: float = 0.15
@export var action_x: String = "yaw_left"   # negative X = right
@export var action_y: String = "pitch_up"  # negative Y = down
@export var paired_action_x: String = "yaw_right"
@export var paired_action_y: String = "pitch_down"
@export var base_color: Color = Color(0.10, 0.08, 0.30, 0.45)
@export var thumb_color: Color = Color(0.95, 0.95, 1.0, 0.85)
@export var border_color: Color = Color(0.95, 0.95, 1.0, 0.4)

var _base: Control
var _thumb: Control
var _center: Vector2
var _dragging: bool = false
var _tilt: Vector2 = Vector2.ZERO    # normalized -1..1


func _ready() -> void:
	custom_minimum_size = Vector2(base_radius * 2, base_radius * 2)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_base = Control.new()
	_base.size = Vector2(base_radius * 2, base_radius * 2)
	_base.position = Vector2.ZERO
	_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_base)
	_thumb = Control.new()
	_thumb.size = Vector2(50, 50)
	_thumb.position = Vector2(base_radius - 25, base_radius - 25)
	_thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_thumb)
	_refresh_style()


func _refresh_style() -> void:
	var base_style := StyleBoxFlat.new()
	base_style.bg_color = base_color
	base_style.set_corner_radius_all(int(base_radius))
	base_style.border_color = border_color
	base_style.set_border_width_all(2)
	_base.add_theme_stylebox_override("panel", base_style)
	var thumb_style := StyleBoxFlat.new()
	thumb_style.bg_color = thumb_color
	thumb_style.set_corner_radius_all(25)
	_thumb.add_theme_stylebox_override("panel", thumb_style)


func _draw() -> void:
	pass


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event
		if touch.pressed:
			_dragging = true
			_center = touch.position
		else:
			_dragging = false
			_tilt = Vector2.ZERO
			_thumb.position = Vector2(base_radius - 25, base_radius - 25)
			_release_actions()
	elif event is InputEventScreenDrag:
		if _dragging:
			var drag: InputEventScreenDrag = event
			var offset: Vector2 = drag.position - _center
			var distance: float = offset.length()
			var clamped_distance: float = minf(distance, base_radius)
			var direction: Vector2 = offset.normalized() if distance > 0.001 else Vector2.ZERO
			_tilt = direction * (clamped_distance / base_radius)
			if _tilt.length() < dead_zone:
				_tilt = Vector2.ZERO
			# Move thumb visually.
			_thumb.position = _center + direction * clamped_distance - Vector2(25, 25)
			_apply_actions()


func _apply_actions() -> void:
	# Negative X = right (yaw_right), positive X = left (yaw_left).
	var x: float = _tilt.x
	var y: float = _tilt.y
	if x < 0:
		Input.action_release(action_x)
		Input.action_press(paired_action_x, -x)
	elif x > 0:
		Input.action_press(action_x, x)
		Input.action_release(paired_action_x)
	else:
		Input.action_release(action_x)
		Input.action_release(paired_action_x)
	if y < 0:
		Input.action_release(action_y)
		Input.action_press(paired_action_y, -y)
	elif y > 0:
		Input.action_press(action_y, y)
		Input.action_release(paired_action_y)
	else:
		Input.action_release(action_y)
		Input.action_release(paired_action_y)


func _release_actions() -> void:
	Input.action_release(action_x)
	Input.action_release(paired_action_x)
	Input.action_release(action_y)
	Input.action_release(paired_action_y)


func _notification(what: int) -> void:
	# Release on focus loss to avoid stuck inputs.
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		if _dragging:
			_dragging = false
			_tilt = Vector2.ZERO
			_release_actions()
