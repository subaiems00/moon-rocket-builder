extends Control
## HUD overlay for the FlightScene. Reads telemetry from RocketController
## and shows altitude, speed, fuel, stability, distance, thrust, multiplier,
## lean warning, and wind-gust pulse.

@export var rocket_path: NodePath


func _ready() -> void:
	var rocket := get_node_or_null(rocket_path) as Node
	if rocket:
		rocket.altitude_changed.connect(_on_altitude)
		rocket.fuel_changed.connect(_on_fuel)
		rocket.speed_changed.connect(_on_speed)
		rocket.stability_changed.connect(_on_stability)
		rocket.thrust_changed.connect(_on_thrust)
		rocket.lean_warning.connect(_on_lean_warning)
		rocket.wind_gust.connect(_on_wind_gust)
		rocket.multiplier_changed.connect(_on_multiplier)
	$Root/TopLeft/Altitude.text = "0 km"
	$Root/TopLeft/Speed.text = "0 m/s"
	$Root/TopLeft/Fuel.text = "100%"
	$Root/TopLeft/Stability.text = "100%"
	$Root/TopLeft/Thrust.text = "0%"
	$Root/TopLeft/Moon.text = "∞ km"
	$Root/Multiplier.text = "×1.0"
	$Root/Multiplier.visible = false
	$Root/WindPulse.visible = false
	$Root/LeanWarning.visible = false
	$Root/Pause/BackButton.pressed.connect(_on_back)
	$Root/Pause/PauseButton.pressed.connect(_on_pause_restart)


func _on_altitude(km: float) -> void:
	$Root/TopLeft/Altitude.text = "%.2f km" % km
	var fake_distance: float = maxf(384000.0 - km * 1.0, 0.0)
	$Root/TopLeft/Moon.text = "%d km" % int(fake_distance)


func _on_fuel(percent: float) -> void:
	$Root/TopLeft/Fuel.text = "%d%%" % int(percent * 100.0)
	if percent < 0.15:
		$Root/TopLeft/Fuel.add_theme_color_override("font_color", Color(1.0, 0.45, 0.30))
	else:
		$Root/TopLeft/Fuel.add_theme_color_override("font_color", Color(1, 1, 1))


func _on_speed(speed: float) -> void:
	$Root/TopLeft/Speed.text = "%d m/s" % int(speed)


func _on_stability(percent: float) -> void:
	$Root/TopLeft/Stability.text = "%d%%" % int(percent * 100.0)
	if percent < 0.5:
		$Root/TopLeft/Stability.add_theme_color_override("font_color", Color(1.0, 0.55, 0.30))
	else:
		$Root/TopLeft/Stability.add_theme_color_override("font_color", Color(1, 1, 1))


func _on_thrust(percent: float) -> void:
	$Root/TopLeft/Thrust.text = "%d%%" % int(percent * 100.0)


func _on_lean_warning(active: bool) -> void:
	$Root/LeanWarning.visible = active
	if active:
		# Tween a brief flash
		var tw := create_tween()
		tw.tween_property($Root/LeanWarning, "modulate:a", 0.4, 0.15)
		tw.tween_property($Root/LeanWarning, "modulate:a", 1.0, 0.15)


func _on_wind_gust(strength: float) -> void:
	$Root/WindPulse.visible = true
	$Root/WindPulse.text = "💨 Gust!"
	var tw := create_tween()
	tw.tween_property($Root/WindPulse, "modulate:a", 0.0, 0.6)
	tw.tween_callback(func(): $Root/WindPulse.visible = false)


func _on_multiplier(value: float) -> void:
	if value <= 1.0:
		$Root/Multiplier.visible = false
		return
	$Root/Multiplier.visible = true
	$Root/Multiplier.text = "×%.1f" % value
	if value >= 2.0:
		$Root/Multiplier.add_theme_color_override("font_color", Color(1.0, 0.85, 0.30))
	elif value >= 1.5:
		$Root/Multiplier.add_theme_color_override("font_color", Color(0.95, 0.55, 0.95))
	else:
		$Root/Multiplier.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))


func _on_back() -> void:
	UIManager.goto_scene("res://scenes/MainMenu.tscn")


func _on_pause_restart() -> void:
	UIManager.goto_scene("res://scenes/LaunchPad.tscn")
