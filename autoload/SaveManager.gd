extends Node
## Read/write the local save file. Pure I/O — no scene state.
##
## Phase 5: atomic writes (tmp file + rename), schema versioning,
## corruption recovery, defensive validation.
##
## On disk:
##   user://save.json          (current save)
##   user://save.json.bak      (last-known-good backup)
##   user://save.json.tmp      (in-flight write; renamed on success)
##
## Load order: try main → try backup → give up and start fresh.

const SAVE_PATH := "user://save.json"
const BACKUP_PATH := "user://save.json.bak"
const TMP_PATH := "user://save.json.tmp"
const SCHEMA_VERSION := 1


func save_from(game: Node) -> void:
	var data := {
		"schema_version": SCHEMA_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"coins": game.coins,
		"total_launches": game.total_launches,
		"successful_landings": game.successful_landings,
		"best_altitude_km": game.best_altitude_km,
		"best_score": game.best_score,
		"unlocked_parts": game.unlocked_parts,
		"unlocked_cosmetics": game.unlocked_cosmetics,
		"settings": {
			"master_volume": clampf(game.master_volume, 0.0, 1.0),
			"music_volume": clampf(game.music_volume, 0.0, 1.0),
			"sfx_volume": clampf(game.sfx_volume, 0.0, 1.0),
			"camera_shake": clampf(game.camera_shake, 0.0, 2.0),
			"mute": game.mute,
		},
		"flags": {
			"reduce_motion": game.reduce_motion,
		},
	}
	# Phase 5: atomic write — write to tmp, flush, then rename. On any
	# failure, the existing save.json is preserved.
	var f := FileAccess.open(TMP_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("SaveManager: cannot open %s (err %d)" % [TMP_PATH, FileAccess.get_open_error()])
		return
	f.store_string(JSON.stringify(data, "\t"))
	f.flush()  # forces OS-level flush; survives process kill mid-write.
	f.close()
	# Move the previous good save to backup, then promote tmp → main.
	if FileAccess.file_exists(SAVE_PATH):
		# Replace backup if it exists.
		if FileAccess.file_exists(BACKUP_PATH):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(BACKUP_PATH))
		var rename_err := DirAccess.rename_absolute(
			ProjectSettings.globalize_path(SAVE_PATH),
			ProjectSettings.globalize_path(BACKUP_PATH)
		)
		if rename_err != OK:
			push_warning("SaveManager: could not back up previous save (err %d)" % rename_err)
	var promote_err := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(TMP_PATH),
		ProjectSettings.globalize_path(SAVE_PATH)
	)
	if promote_err != OK:
		push_warning("SaveManager: could not promote tmp save (err %d)" % promote_err)


func load_into(game: Node) -> void:
	var parsed: Variant = _try_read(SAVE_PATH)
	if typeof(parsed) != TYPE_DICTIONARY:
		# Main is corrupt or missing. Fall back to backup.
		parsed = _try_read(BACKUP_PATH)
		if typeof(parsed) != TYPE_DICTIONARY:
			# Both unusable. Start fresh — defaults are already set in GameManager.
			return
	_apply_to_game(game, parsed)


# Try to read + parse a JSON file. Returns the parsed Variant or null.
func _try_read(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("SaveManager: cannot read %s (err %d)" % [path, FileAccess.get_open_error()])
		return null
	var raw := f.get_as_text()
	f.close()
	if raw.strip_edges() == "":
		return null
	return JSON.parse_string(raw)


func _apply_to_game(game: Node, parsed: Variant) -> void:
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var d: Dictionary = parsed
	# Schema version check. v1 is the only known version; unknown
	# versions still load best-effort.
	var version: int = int(d.get("schema_version", 1))

	game.coins = _safe_int(d.get("coins"), game.coins)
	game.total_launches = _safe_int(d.get("total_launches"), game.total_launches)
	game.successful_landings = _safe_int(d.get("successful_landings"), game.successful_landings)
	game.best_altitude_km = _safe_float(d.get("best_altitude_km"), game.best_altitude_km)
	game.best_score = _safe_int(d.get("best_score"), game.best_score)

	var up: Dictionary = d.get("unlocked_parts", {})
	for k in up.keys():
		if k is StringName:
			game.unlocked_parts[k] = up[k]
	var uc: Dictionary = d.get("unlocked_cosmetics", {})
	for k in uc.keys():
		if k is StringName:
			game.unlocked_cosmetics[k] = uc[k]

	var s: Dictionary = d.get("settings", {})
	if not s.is_empty():
		game.master_volume = clampf(_safe_float(s.get("master_volume"), game.master_volume), 0.0, 1.0)
		game.music_volume = clampf(_safe_float(s.get("music_volume"), game.music_volume), 0.0, 1.0)
		game.sfx_volume = clampf(_safe_float(s.get("sfx_volume"), game.sfx_volume), 0.0, 1.0)
		game.camera_shake = clampf(_safe_float(s.get("camera_shake"), game.camera_shake), 0.0, 2.0)
		game.mute = bool(s.get("mute", game.mute))

	# Phase 5: new flags block (forward-compatible).
	var flags: Dictionary = d.get("flags", {})
	game.reduce_motion = bool(flags.get("reduce_motion", game.reduce_motion))


# ---------- Safe type coercions ------------------------------------

func _safe_int(v: Variant, fallback: int) -> int:
	if v == null:
		return fallback
	if typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT:
		return int(v)
	if typeof(v) == TYPE_STRING and str(v).is_valid_int():
		return int(str(v))
	return fallback


func _safe_float(v: Variant, fallback: float) -> float:
	if v == null:
		return fallback
	if typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT:
		return float(v)
	if typeof(v) == TYPE_STRING:
		var s: String = str(v)
		if s.is_valid_float():
			return float(s)
	return fallback
