extends Node
## Cross-screen UI helper: scene transitions, toast messages,
## modal dialogs. The actual UI lives inside each screen scene.

signal scene_changed(path: String)

func goto_scene(path: String) -> void:
	# Fade out, swap, fade in. Phase 4 will plug a real ColorRect transition here.
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("UIManager: failed to change scene to %s (err %d)" % [path, err])
		return
	scene_changed.emit(path)


func popup_message(text: String, duration: float = 2.0) -> void:
	# Lightweight toast using a CanvasLayer overlay. We attach to the
	# active scene so it persists across screen changes inside the same frame.
	var layer := CanvasLayer.new()
	layer.layer = 100
	get_tree().current_scene.add_child(layer)

	var panel := PanelContainer.new()
	panel.position = Vector2(40, 40)
	panel.modulate = Color(1, 1, 1, 0)
	layer.add_child(panel)

	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	panel.add_child(label)

	var tw := layer.create_tween()
	tw.tween_property(panel, "modulate:a", 1.0, 0.2)
	tw.tween_interval(duration)
	tw.tween_property(panel, "modulate:a", 0.0, 0.4)
	tw.tween_callback(layer.queue_free)
