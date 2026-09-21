extends Control
## ResultsScreen: shows outcome, score breakdown (base + fuel + stab +
## outcome multiplier + flight multiplier), altitude, fuel, bonus,
## coins earned.

func _ready() -> void:
	$Root/Buttons/Again.pressed.connect(_on_again)
	$Root/Buttons/Build.pressed.connect(_on_build)
	$Root/Buttons/Menu.pressed.connect(_on_menu)
	_populate()
	_play_intro_animation()


func _play_intro_animation() -> void:
	# Title pops in with overshoot.
	$Root/Title.scale = Vector2.ONE * 0.7
	$Root/Title.modulate.a = 0.0
	var title_tw := create_tween().set_parallel(true)
	title_tw.tween_property($Root/Title, "scale", Vector2.ONE, 0.5)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	title_tw.tween_property($Root/Title, "modulate:a", 1.0, 0.3)
	# Score counts up from 0 to final.
	var final_score: int = int(GameManager.last_result.get("score", 0))
	$Root/Score.text = "Score: 0"
	var score_tw := create_tween()
	score_tw.tween_method(_set_score_label, 0, final_score, 1.0)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Coins badge bounces in.
	$Root/Coins.scale = Vector2.ZERO
	var coins_tw := create_tween().set_parallel(true)
	coins_tw.tween_property($Root/Coins, "scale", Vector2.ONE * 1.2, 0.4)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	coins_tw.tween_property($Root/Coins, "scale", Vector2.ONE, 0.2)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)


func _set_score_label(value: int) -> void:
	$Root/Score.text = "Score: %d" % value


func _populate() -> void:
	var r: Dictionary = GameManager.last_result
	var score: int = int(r.get("score", 0))
	var breakdown: Dictionary = r.get("score_breakdown", {})
	var base_score: int = int(breakdown.get("base", 0))
	var fuel_bonus: int = int(breakdown.get("fuel_bonus", 0))
	var stab_bonus: int = int(breakdown.get("stab_bonus", 0))
	var outcome_mult: float = float(breakdown.get("outcome_multiplier", 1.0))
	var flight_mult: float = float(breakdown.get("flight_multiplier", 1.0))
	var max_alt: float = float(r.get("max_altitude_km", 0.0))
	var fuel_pct: float = float(r.get("fuel_remaining_pct", 0.0)) * 100.0
	var avg_stab: float = float(r.get("avg_stability", 0.0)) * 100.0
	var coins: int = int(r.get("coins_earned", 0))
	var landed: bool = bool(r.get("landed", false))
	var title: String = String(r.get("outcome_title", "MOON LANDING!" if landed else "Try Again!"))
	var subtitle: String = String(r.get("outcome_subtitle", ""))
	var sfx: String = String(r.get("outcome_sfx", "victory" if landed else "failure"))

	$Root/Title.text = title
	$Root/Subtitle.text = subtitle
	$Root/Score.text = "Score: %d" % score

	$Root/Breakdown/Base.text = "Base: %d" % base_score
	$Root/Breakdown/Fuel.text = "Fuel bonus: +%d" % fuel_bonus
	$Root/Breakdown/Stab.text = "Stability bonus: +%d" % stab_bonus
	$Root/Breakdown/Outcome.text = "Outcome: ×%.2f" % outcome_mult
	$Root/Breakdown/Flight.text = "Flight: ×%.2f" % flight_mult

	$Root/Stats/Altitude.text = "Max altitude: %.1f km" % max_alt
	$Root/Stats/Fuel.text = "Fuel left:   %d%%" % int(fuel_pct)
	$Root/Stats/Stability.text = "Avg stability:  %d%%" % int(avg_stab)
	$Root/Bonus.text = ""
	$Root/Coins.text = "+%d ¢" % coins

	if landed:
		$Root/Confetti.visible = true
	else:
		$Root/Confetti.visible = false

	# Play the outcome-specific SFX
	if not sfx.is_empty() and AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx(sfx)


func _on_again() -> void:
	UIManager.goto_scene("res://scenes/LaunchPad.tscn")


func _on_build() -> void:
	UIManager.goto_scene("res://scenes/RocketWorkshop.tscn")


func _on_menu() -> void:
	UIManager.goto_scene("res://scenes/MainMenu.tscn")
