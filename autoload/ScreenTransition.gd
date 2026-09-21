extends CanvasLayer
class_name ScreenTransition
## Phase 4: a global fade-through-black overlay that sits at layer 200.
## Trigger `fade_out(duration)` before a scene swap and `fade_in(duration)`
## after. Callers chain them via signals.
##
## Lives at scene root, persists across scenes via the autoload pattern.
## Place inside `MainMenu.tscn` and add it as an autoload OR set it as
## a child of every scene root (UIManager looks it up by name).

signal fade_out_finished
signal fade_in_finished

@export var default_duration: float = 0.35

var _rect: ColorRect
var _tween: Tween


func _ready() -> void:
	layer = 200  # above everything
	_rect = ColorRect.new()
	_rect.color = Color(0, 0, 0, 0)
	_rect.anchor_right = 1.0
	_rect.anchor_bottom = 1.0
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)


func fade_out(duration: float = -1.0) -> void:
	if duration < 0:
		duration = default_duration
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_rect, "color:a", 1.0, duration).set_trans(Tween.TRANS_SINE)
	_tween.finished.connect(func(): fade_out_finished.emit(), CONNECT_ONE_SHOT)


func fade_in(duration: float = -1.0) -> void:
	if duration < 0:
		duration = default_duration
	if _tween:
		_tween.kill()
	# Start fully black, then tween back to transparent.
	_rect.color.a = 1.0
	_tween = create_tween()
	_tween.tween_property(_rect, "color:a", 0.0, duration).set_trans(Tween.TRANS_SINE)
	_tween.finished.connect(func(): fade_in_finished.emit(), CONNECT_ONE_SHOT)


func is_busy() -> bool:
	return _tween != null and _tween.is_valid() and _tween.is_running()
