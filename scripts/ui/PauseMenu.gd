extends Control
## Pause overlay shown over FlightScene.

func _ready() -> void:
	$Root/Buttons/Resume.pressed.connect(_on_resume)
	$Root/Buttons/Restart.pressed.connect(_on_restart)
	$Root/Buttons/Menu.pressed.connect(_on_menu)
	visible = false


func show_pause() -> void:
	visible = true
	get_tree().paused = true


func _on_resume() -> void:
	visible = false
	get_tree().paused = false


func _on_restart() -> void:
	get_tree().paused = false
	UIManager.goto_scene("res://scenes/LaunchPad.tscn")


func _on_menu() -> void:
	get_tree().paused = false
	UIManager.goto_scene("res://scenes/MainMenu.tscn")
