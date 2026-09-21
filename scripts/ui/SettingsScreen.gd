extends Control
## Audio + accessibility settings sliders.

func _ready() -> void:
	$Root/Buttons/BackButton.pressed.connect(_on_back)
	$Root/Sliders/Master.value = GameManager.master_volume
	$Root/Sliders/Music.value = GameManager.music_volume
	$Root/Sliders/SFX.value = GameManager.sfx_volume
	$Root/Sliders/Shake.value = GameManager.camera_shake
	$Root/Sliders/Mute.button_pressed = GameManager.mute
	$Root/Sliders/ReduceMotion.button_pressed = GameManager.reduce_motion
	$Root/Sliders/Master.value_changed.connect(_on_master)
	$Root/Sliders/Music.value_changed.connect(_on_music)
	$Root/Sliders/SFX.value_changed.connect(_on_sfx)
	$Root/Sliders/Shake.value_changed.connect(_on_shake)
	$Root/Sliders/Mute.toggled.connect(_on_mute)
	$Root/Sliders/ReduceMotion.toggled.connect(_on_reduce_motion)
	$Root/Buttons/ResetButton.pressed.connect(_on_reset)


func _on_master(v: float) -> void:
	GameManager.set_setting("master_volume", v)
	AudioManager.apply_volumes()


func _on_music(v: float) -> void:
	GameManager.set_setting("music_volume", v)
	AudioManager.apply_volumes()


func _on_sfx(v: float) -> void:
	GameManager.set_setting("sfx_volume", v)
	AudioManager.apply_volumes()


func _on_shake(v: float) -> void:
	GameManager.set_setting("camera_shake", v)


func _on_mute(on: bool) -> void:
	GameManager.set_setting("mute", on)
	AudioManager.apply_volumes()


func _on_reduce_motion(on: bool) -> void:
	GameManager.set_setting("reduce_motion", on)
	UIManager.popup_message(
		"Reduce motion: %s" % ("ON — shakes and flashes disabled" if on else "OFF"),
		2.0
	)


func _on_reset() -> void:
	# Reset settings + progression to factory defaults.
	GameManager.reset_to_defaults()
	# Refresh the UI to reflect the new values.
	$Root/Sliders/Master.value = GameManager.master_volume
	$Root/Sliders/Music.value = GameManager.music_volume
	$Root/Sliders/SFX.value = GameManager.sfx_volume
	$Root/Sliders/Shake.value = GameManager.camera_shake
	$Root/Sliders/Mute.button_pressed = GameManager.mute
	$Root/Sliders/ReduceMotion.button_pressed = GameManager.reduce_motion
	AudioManager.apply_volumes()
	UIManager.popup_message("Settings and progression reset", 2.5)


func _on_back() -> void:
	UIManager.goto_scene("res://scenes/MainMenu.tscn")
