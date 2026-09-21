extends Control
## HUD overlay for the FlightScene. Reads telemetry from RocketController
## and shows altitude, speed, fuel, stability, distance.

@export var rocket_path: NodePath


func _ready() -> void:
	var rocket := get_node_or_null(rocket_path) as Node
	if rocket:
		rocket.altitude_changed.connect(_on_altitude)
		rocket.fuel_changed.connect(_on_fuel)
		rocket.speed_changed.connect(_on_speed)
		rocket.stability_changed.connect(_on_stability)
	$Root/TopLeft/Altitude.text = "0 km"
	$Root/TopLeft/Speed.text = "0 m/s"
	$Root/TopLeft/Fuel.text = "100%"
	$Root/TopLeft/Stability.text = "100%"
	$Root/TopLeft/Moon.text = "∞ km"
	$Root/Pause/BackButton.pressed.connect(_on_back)
	$Root/Pause/PauseButton.pressed.connect(_on_pause_restart)


func _on_altitude(km: float) -> void:
	$Root/TopLeft/Altitude.text = "%.2f km" % km
	# Distance to "moon" — fake heuristic: starts ~384 000 km, decreases as
	# altitude grows. Phase 2 will use real spatial distance.
	var fake_distance := max(384000.0 - km * 1.0, 0.0)
	$Root/TopLeft/Moon.text = "%d km" % int(fake_distance)


func _on_fuel(percent: float) -> void:
	$Root/TopLeft/Fuel.text = "%d%%" % int(percent * 100.0)


func _on_speed(speed: float) -> void:
	$Root/TopLeft/Speed.text = "%d m/s" % int(speed)


func _on_stability(percent: float) -> void:
	$Root/TopLeft/Stability.text = "%d%%" % int(percent * 100.0)


func _on_back() -> void:
	UIManager.goto_scene("res://scenes/MainMenu.tscn")


func _on_pause_restart() -> void:
	UIManager.goto_scene("res://scenes/LaunchPad.tscn")
