extends Node
## Central game state. Owns currency, unlocks, last-flight results.
## Singletons must stay cheap and signal-driven — no scene refs here.

signal coins_changed(amount: int)
signal best_altitude_changed(value: float)
signal landings_changed(value: int)
signal unlocks_changed()
signal settings_changed()
signal flight_finished(payload: Dictionary)

const SAVE_PATH := "user://save.json"

# Persistent fields
var coins: int = 0
var total_launches: int = 0
var successful_landings: int = 0
var best_altitude_km: float = 0.0
var best_score: int = 0

# Unlocks: parts keyed by id. A part is unlocked if its id is in this set
# OR if its `unlock_requirement` is satisfied (default: owned from start).
var unlocked_parts: Dictionary = {}

# Cosmetic unlocks (paint colors, decals, exhaust colors) keyed by id.
var unlocked_cosmetics: Dictionary = {}

# Last flight result (read by ResultsScreen)
var last_result: Dictionary = {}

# Settings
var master_volume: float = 0.9
var music_volume: float = 0.7
var sfx_volume: float = 0.9
var camera_shake: float = 1.0     # multiplier 0..1
var mute: bool = false


func _ready() -> void:
	# Default unlocks — first prototype ships these for free.
	for part_id in default_unlocked_parts():
		unlocked_parts[part_id] = true
	for cosmetic_id in default_unlocked_cosmetics():
		unlocked_cosmetics[cosmetic_id] = true
	# Try to load persisted state (SaveManager will inject this if user has a save).
	if SaveManager and SaveManager.has_method("load_into"):
		SaveManager.load_into(self)


func default_unlocked_parts() -> Array[StringName]:
	# Default — works for new players. The advanced parts are gated behind
	# a first successful landing (see record_flight -> unlock_from_first_landing).
	return [
		&"body_classic",
		&"tank_basic",
		&"engine_standard",
		&"fin_tri",
		&"nose_classic",
		&"booster_small",
	]


# Parts gated behind progression. They become available after the first
# successful landing — encourages the player to actually reach the Moon.
const PHASE_2_UNLOCK_PARTS: Array[StringName] = [
	&"nose_pointy",
	&"body_chubby",
	&"tank_jumbo",
	&"engine_boost",
	&"fin_square",
	&"booster_big",
]


func default_unlocked_cosmetics() -> Array[StringName]:
	return [
		&"paint_white",
		&"paint_coral",
		&"paint_mint",
		&"paint_lavender",
		&"decal_stars",
	]


func is_part_unlocked(part_id: StringName) -> bool:
	return unlocked_parts.get(part_id, false)


func unlock_part(part_id: StringName) -> void:
	if unlocked_parts.get(part_id, false):
		return
	unlocked_parts[part_id] = true
	unlocks_changed.emit()
	if SaveManager and SaveManager.has_method("save_from"):
		SaveManager.save_from(self)


func unlock_cosmetic(cosmetic_id: StringName) -> void:
	if unlocked_cosmetics.get(cosmetic_id, false):
		return
	unlocked_cosmetics[cosmetic_id] = true
	unlocks_changed.emit()
	if SaveManager and SaveManager.has_method("save_from"):
		SaveManager.save_from(self)


func add_coins(amount: int) -> void:
	coins = max(0, coins + amount)
	coins_changed.emit(coins)


func record_flight(payload: Dictionary) -> void:
	total_launches += 1
	if payload.get("landed", false):
		successful_landings += 1
	var alt: float = float(payload.get("max_altitude_km", 0.0))
	if alt > best_altitude_km:
		best_altitude_km = alt
		best_altitude_changed.emit(best_altitude_km)
	var score: int = int(payload.get("score", 0))
	if score > best_score:
		best_score = score
	add_coins(int(payload.get("coins_earned", 0)))
	last_result = payload.duplicate(true)
	landings_changed.emit(successful_landings)
	flight_finished.emit(payload)
	# Phase 2 progression: gate advanced parts behind the first landing.
	if payload.get("landed", false) and successful_landings == 1:
		_unlock_phase_2_parts()
	if SaveManager and SaveManager.has_method("save_from"):
		SaveManager.save_from(self)


func _unlock_phase_2_parts() -> void:
	var newly_unlocked: Array[StringName] = []
	for part_id in PHASE_2_UNLOCK_PARTS:
		if not unlocked_parts.get(part_id, false):
			unlocked_parts[part_id] = true
			newly_unlocked.append(part_id)
	if not newly_unlocked.is_empty():
		unlocks_changed.emit()
		# Surface a toast so the player knows.
		UIManager.popup_message("New parts unlocked! Visit Workshop.", 4.0)


func set_setting(name: String, value) -> void:
	match name:
		"master_volume": master_volume = value
		"music_volume": music_volume = value
		"sfx_volume": sfx_volume = value
		"camera_shake": camera_shake = value
		"mute": mute = value
	settings_changed.emit()
	if SaveManager and SaveManager.has_method("save_from"):
		SaveManager.save_from(self)
