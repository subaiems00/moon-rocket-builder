extends Control
## Big overlay text used by the launch countdown.

var _launch_sequence: Node = null


func _ready() -> void:
	$BigText.modulate = Color(1, 1, 1, 0)
	$BigText.scale = Vector2.ONE * 0.4
	_launch_sequence = get_parent().get_parent().get_node_or_null("LaunchSequence")
	if _launch_sequence:
		_launch_sequence.countdown_tick.connect(_on_tick)
		_launch_sequence.countdown_go.connect(_on_go)
		_launch_sequence.rocket_lifted_off.connect(_on_lift)
		_launch_sequence.sequence_finished.connect(_on_finish)


func _on_tick(value: int) -> void:
	$BigText.text = str(value)
	_animate_pop()


func _on_go() -> void:
	$BigText.text = "LAUNCH!"
	$BigText.add_theme_color_override("font_color", Color(1.0, 0.65, 0.30))
	_animate_pop()


func _on_lift() -> void:
	# Begin fade out so HUD takes over after the rocket is in the air.
	var tw := create_tween()
	tw.tween_interval(1.0)
	tw.tween_property(self, "modulate:a", 0.0, 0.4)
	tw.tween_callback(_go_to_flight)


func _on_finish() -> void:
	pass


func _go_to_flight() -> void:
	UIManager.goto_scene("res://scenes/FlightScene.tscn")


func _animate_pop() -> void:
	$BigText.modulate = Color(1, 1, 1, 1)
	$BigText.scale = Vector2.ONE * 0.4
	var tw := create_tween()
	tw.tween_property($BigText, "scale", Vector2.ONE * 1.1, 0.12)
	tw.tween_property($BigText, "scale", Vector2.ONE, 0.10)
