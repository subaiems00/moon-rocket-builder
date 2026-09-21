extends Node3D

func _ready() -> void:
	$ContinueButton.pressed.connect(_on_continue)


func _on_continue() -> void:
	UIManager.goto_scene("res://scenes/ResultsScreen.tscn")
