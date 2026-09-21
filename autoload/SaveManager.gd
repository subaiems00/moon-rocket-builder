extends Node
## Read/write the local save file. Pure I/O — no scene state.

const SAVE_PATH := "user://save.json"

func save_from(game: Node) -> void:
	var data := {
		"coins": game.coins,
		"total_launches": game.total_launches,
		"successful_landings": game.successful_landings,
		"best_altitude_km": game.best_altitude_km,
		"best_score": game.best_score,
		"unlocked_parts": game.unlocked_parts,
		"unlocked_cosmetics": game.unlocked_cosmetics,
		"settings": {
			"master_volume": game.master_volume,
			"music_volume": game.music_volume,
			"sfx_volume": game.sfx_volume,
			"camera_shake": game.camera_shake,
			"mute": game.mute,
		},
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("SaveManager: cannot write to %s (err %d)" % [SAVE_PATH, FileAccess.get_open_error()])
		return
	f.store_string(JSON.stringify(data, "\t"))
	f.close()


func load_into(game: Node) -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var raw := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var d: Dictionary = parsed
	game.coins = int(d.get("coins", game.coins))
	game.total_launches = int(d.get("total_launches", game.total_launches))
	game.successful_landings = int(d.get("successful_landings", game.successful_landings))
	game.best_altitude_km = float(d.get("best_altitude_km", game.best_altitude_km))
	game.best_score = int(d.get("best_score", game.best_score))
	var up: Dictionary = d.get("unlocked_parts", {})
	for k in up.keys():
		game.unlocked_parts[k] = up[k]
	var uc: Dictionary = d.get("unlocked_cosmetics", {})
	for k in uc.keys():
		game.unlocked_cosmetics[k] = uc[k]
	var s: Dictionary = d.get("settings", {})
	if not s.is_empty():
		game.master_volume = float(s.get("master_volume", game.master_volume))
		game.music_volume = float(s.get("music_volume", game.music_volume))
		game.sfx_volume = float(s.get("sfx_volume", game.sfx_volume))
		game.camera_shake = float(s.get("camera_shake", game.camera_shake))
		game.mute = bool(s.get("mute", game.mute))
