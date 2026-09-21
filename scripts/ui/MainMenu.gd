extends Control
## Main menu: title, primary CTA to the workshop, settings entry, chip row.

@onready var _coins_label: Label = $Root/TopBar/Coins/CoinValue
@onready var _best_label: Label = $Root/TopBar/Best/BestValue
@onready var _landings_label: Label = $Root/TopBar/Landings/LandingValue


func _ready() -> void:
	$Root/Buttons/PlayButton.pressed.connect(_on_play)
	$Root/Buttons/SettingsButton.pressed.connect(_on_settings)
	$Root/Buttons/QuitButton.pressed.connect(_on_quit)
	_refresh_chips()
	GameManager.coins_changed.connect(_refresh_chips)
	GameManager.landings_changed.connect(_refresh_chips)
	GameManager.best_altitude_changed.connect(_refresh_chips)


func _refresh_chips(_a = null, _b = null) -> void:
	if _coins_label:
		_coins_label.text = str(GameManager.coins)
	if _best_label:
		_best_label.text = "%d km" % int(GameManager.best_altitude_km)
	if _landings_label:
		_landings_label.text = str(GameManager.successful_landings)


func _on_play() -> void:
	UIManager.goto_scene("res://scenes/RocketWorkshop.tscn")


func _on_settings() -> void:
	UIManager.goto_scene("res://scenes/SettingsScreen.tscn")


func _on_quit() -> void:
	get_tree().quit()
