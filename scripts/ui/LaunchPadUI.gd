extends Node
## Wires LaunchPad UI controls (GO button, auto-start, Back button).

@onready var _seq: Node = $LaunchSequence
@onready var _auto: Timer = $AutoStart
@onready var _back: Button = $UI/TopBar/BackButton
@onready var _go: Button = $UI/TopBar/GoButton


func _ready() -> void:
	_go.pressed.connect(_start)
	_back.pressed.connect(_on_back)
	_auto.timeout.connect(_start)


func _start() -> void:
	if _seq.has_method("play"):
		_seq.play()
	_go.disabled = true


func _on_back() -> void:
	UIManager.goto_scene("res://scenes/RocketWorkshop.tscn")
