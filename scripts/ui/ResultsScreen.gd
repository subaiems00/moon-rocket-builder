extends Control
## ResultsScreen: shows score, altitude, fuel, bonus, coins earned.

func _ready() -> void:
	$Root/Buttons/Again.pressed.connect(_on_again)
	$Root/Buttons/Build.pressed.connect(_on_build)
	$Root/Buttons/Menu.pressed.connect(_on_menu)
	_populate()


func _populate() -> void:
	var r: Dictionary = GameManager.last_result
	var score: int = int(r.get("score", 0))
	var max_alt: float = float(r.get("max_altitude_km", 0.0))
	var fuel: float = float(r.get("fuel_remaining", 0.0))
	var bonus: int = int(r.get("stability_bonus", 0))
	var coins: int = int(r.get("coins_earned", 0))
	var landed: bool = bool(r.get("landed", false))
	$Root/Title.text = "MOON LANDING!" if landed else "Try Again!"
	$Root/Score.text = "Score: %d" % score
	$Root/Stats/Altitude.text = "Max altitude: %.1f km" % max_alt
	$Root/Stats/Fuel.text = "Fuel left: %.0f" % fuel
	$Root/Stats/Bonus.text = "Stability bonus: %d" % bonus
	$Root/Coins.text = "+%d ¢" % coins
	if landed:
		AudioManager.play_sfx("victory")
		$Root/Confetti.visible = true
	else:
		AudioManager.play_sfx("failure")
		$Root/Confetti.visible = false


func _on_again() -> void:
	UIManager.goto_scene("res://scenes/LaunchPad.tscn")


func _on_build() -> void:
	UIManager.goto_scene("res://scenes/RocketWorkshop.tscn")


func _on_menu() -> void:
	UIManager.goto_scene("res://scenes/MainMenu.tscn")
