extends Node
## Lightweight audio bus + SFX/music hooks.
## Phase 1: synthesizes beeps with AudioStreamGenerator so the prototype
## is fully playable without external .wav files.
## Phase 2+ : swap generated streams for real .ogg imports.

const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

var _sfx_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer
var _stream_cache: Dictionary = {}

func _ready() -> void:
	_ensure_bus(BUS_MUSIC)
	_ensure_bus(BUS_SFX)
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = BUS_SFX
	add_child(_sfx_player)
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = BUS_MUSIC
	add_child(_music_player)
	_apply_volumes()


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) < 0:
		var idx := AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, bus_name)
		AudioServer.set_bus_send(idx, BUS_MASTER)


func apply_volumes() -> void:
	_apply_volumes()


func _apply_volumes() -> void:
	var m := 0.0 if GameManager.mute else GameManager.master_volume
	AudioServer.set_bus_volume_db(_bus_index(BUS_MASTER), linear_to_db(clamp(m, 0.001, 1.0)))
	AudioServer.set_bus_volume_db(_bus_index(BUS_MUSIC), linear_to_db(clamp(GameManager.music_volume, 0.001, 1.0)))
	AudioServer.set_bus_volume_db(_bus_index(BUS_SFX), linear_to_db(clamp(GameManager.sfx_volume, 0.001, 1.0)))


func _bus_index(bus_name: String) -> int:
	var i := AudioServer.get_bus_index(bus_name)
	if i < 0:
		push_warning("AudioManager: bus '%s' not found" % bus_name)
		return 0
	return i


func _on_settings_changed() -> void:
	_apply_volumes()


func play_sfx(name: String, pitch: float = 1.0, volume_db: float = 0.0) -> void:
	var stream := _get_or_generate_sfx(name)
	if stream == null:
		return
	_sfx_player.stream = stream
	_sfx_player.pitch_scale = pitch
	_sfx_player.volume_db = volume_db
	_sfx_player.play()


func play_music(name: String) -> void:
	pass  # Phase 4 — load looping ambient .ogg


# --- Procedural SFX (beeps / rumble) -----------------------------

func _get_or_generate_sfx(name: String) -> AudioStreamWAV:
	if _stream_cache.has(name):
		return _stream_cache[name]
	var stream: AudioStreamWAV
	match name:
		"ui_click":
			stream = _gen_beep(660.0, 0.08, "square", -10.0)
		"ui_hover":
			stream = _gen_beep(880.0, 0.05, "sine", -16.0)
		"countdown_beep":
			stream = _gen_beep(520.0, 0.18, "square", -8.0)
		"countdown_go":
			stream = _gen_beep(880.0, 0.40, "sawtooth", -6.0)
		"warning":
			stream = _gen_beep(380.0, 0.30, "square", -6.0)
		"engine_start":
			stream = _gen_rumble(80.0, 0.45, 12.0)
		"engine_loop":
			stream = _gen_rumble(55.0, 1.20, 8.0)
		"engine_thrust":
			stream = _gen_rumble(45.0, 1.50, 14.0)
		"launch":
			stream = _gen_rumble(40.0, 1.80, 6.0)
		"wind":
			stream = _gen_noise(0.6, -18.0)
		"wind_gust":
			stream = _gen_noise(1.4, -8.0)
		"booster_sep":
			stream = _gen_metallic_clank()
		"success_stinger":
			stream = _gen_stinger(880.0, 1320.0, 0.5)
		"touchdown":
			stream = _gen_rumble(70.0, 0.25, -4.0)
		"victory":
			stream = _gen_arpeggio([523.25, 659.25, 783.99, 1046.5], 0.12)
		"failure":
			stream = _gen_sad_trombone(0.6)
		"part_attach":
			stream = _gen_beep(720.0, 0.06, "triangle", -12.0)
		"part_detach":
			stream = _gen_beep(420.0, 0.06, "triangle", -12.0)
		_:
			stream = _gen_beep(440.0, 0.05, "sine", -20.0)
	_stream_cache[name] = stream
	return stream


# ---------- Phase 4 procedural generators -----------------------------

static func _gen_metallic_clank() -> AudioStreamWAV:
	# Booster separation = a quick metallic clank.
	var mix_rate := 44100
	var duration := 0.25
	var sample_count := int(mix_rate * duration)
	var stream := AudioStreamWAV.new()
	stream.mix_rate = mix_rate
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var amp: float = 16000.0
	for i in range(sample_count):
		var t: float = float(i) / mix_rate
		# Quick pitch drop from 1200 Hz to 200 Hz.
		var freq: float = 1200.0 * exp(-t * 12.0) + 200.0
		var env: float = clampf(1.0 - (t / duration), 0.0, 1.0)
		env = env * env
		# Two detuned oscillators + a noise burst at start.
		var v: float = sin(TAU * freq * t) * 0.5 + sin(TAU * freq * 1.03 * t) * 0.3
		if t < 0.02:
			v += randf_range(-1.0, 1.0) * (1.0 - t / 0.02) * 0.6
		var s: int = int(clampf(v * amp * env, -32768.0, 32767.0))
		data.encode_s16(i * 2, s)
	stream.data = data
	return stream


static func _gen_stinger(freq_start: float, freq_end: float, duration: float) -> AudioStreamWAV:
	# Bright ascending sweep — played on success.
	var mix_rate := 44100
	var sample_count := int(mix_rate * duration)
	var stream := AudioStreamWAV.new()
	stream.mix_rate = mix_rate
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var amp: float = 12000.0
	var phase: float = 0.0
	for i in range(sample_count):
		var t: float = float(i) / mix_rate
		var freq: float = lerpf(freq_start, freq_end, t / duration)
		phase += TAU * freq / mix_rate
		var env: float = clampf(1.0 - (t / duration) * 0.7, 0.0, 1.0)
		var v: float = sin(phase) * 0.6 + sin(phase * 2.0) * 0.3
		var s: int = int(clampf(v * amp * env, -32768.0, 32767.0))
		data.encode_s16(i * 2, s)
	stream.data = data
	return stream


func _gen_beep(freq: float, duration: float, waveform: String, gain_db: float) -> AudioStreamWAV:
	var mix_rate := 44100
	var sample_count := int(mix_rate * duration)
	var stream := AudioStreamWAV.new()
	stream.mix_rate = mix_rate
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	stream.stereo = false
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var amp: float = pow(10.0, gain_db / 20.0) * 32767.0
	for i in range(sample_count):
		var t: float = float(i) / mix_rate
		var env: float = clamp(1.0 - (t / duration), 0.0, 1.0)
		env *= env  # soft tail
		var v: float = 0.0
		match waveform:
			"square": v = 1.0 if fmod(t * freq, 1.0) < 0.5 else -1.0
			"sawtooth": v = 2.0 * fmod(t * freq, 1.0) - 1.0
			"triangle":
				var phase := fmod(t * freq, 1.0)
				v = 4.0 * abs(phase - 0.5) - 1.0
			_: v = sin(TAU * freq * t)
		var s: int = int(clamp(v * amp * env, -32768.0, 32767.0))
		data.encode_s16(i * 2, s)
	stream.data = data
	return stream


func _gen_rumble(freq: float, duration: float, gain_db: float) -> AudioStreamWAV:
	# Low rumble = two detuned sines + noise
	var mix_rate := 44100
	var sample_count := int(mix_rate * duration)
	var stream := AudioStreamWAV.new()
	stream.mix_rate = mix_rate
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var amp: float = pow(10.0, gain_db / 20.0) * 32767.0
	var rng := RandomNumberGenerator.new()
	rng.seed = int(freq * 13.37) + 42
	for i in range(sample_count):
		var t: float = float(i) / mix_rate
		var env: float = clamp(1.0 - pow(t / duration, 1.6), 0.0, 1.0)
		var v := sin(TAU * freq * t) * 0.6 + sin(TAU * freq * 1.5 * t) * 0.3
		v += rng.randf_range(-0.4, 0.4)
		v *= 0.5
		var s: int = int(clamp(v * amp * env, -32768.0, 32767.0))
		data.encode_s16(i * 2, s)
	stream.data = data
	return stream


func _gen_noise(duration: float, gain_db: float) -> AudioStreamWAV:
	var mix_rate := 44100
	var sample_count := int(mix_rate * duration)
	var stream := AudioStreamWAV.new()
	stream.mix_rate = mix_rate
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var amp: float = pow(10.0, gain_db / 20.0) * 32767.0
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in range(sample_count):
		var t: float = float(i) / mix_rate
		var env: float = clamp(1.0 - t / duration, 0.0, 1.0)
		var s: int = int(clamp(rng.randf_range(-1.0, 1.0) * amp * env, -32768.0, 32767.0))
		data.encode_s16(i * 2, s)
	stream.data = data
	return stream


func _gen_arpeggio(freqs: Array, per_note: float) -> AudioStreamWAV:
	var mix_rate := 44100
	var note_samples := int(mix_rate * per_note)
	var total := note_samples * freqs.size()
	var stream := AudioStreamWAV.new()
	stream.mix_rate = mix_rate
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	var data := PackedByteArray()
	data.resize(total * 2)
	var amp: float = 18000.0
	for n in freqs.size():
		var freq: float = freqs[n]
		for i in note_samples:
			var t: float = float(i) / mix_rate
			var env: float = clamp(1.0 - (t / per_note), 0.0, 1.0)
			env *= env
			var v := sin(TAU * freq * t) * 0.8
			var s: int = int(clamp(v * amp * env, -32768.0, 32767.0))
			data.encode_s16((n * note_samples + i) * 2, s)
	stream.data = data
	return stream


func _gen_sad_trombone(duration: float) -> AudioStreamWAV:
	var mix_rate := 44100
	var sample_count := int(mix_rate * duration)
	var stream := AudioStreamWAV.new()
	stream.mix_rate = mix_rate
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var amp: float = 14000.0
	var freqs := [392.0, 349.23, 329.63, 261.63]  # G4 -> F4 -> E4 -> C4
	var per := sample_count / freqs.size()
	for i in sample_count:
		var t: float = float(i) / mix_rate
		var note := int(i / per)
		note = clamp(note, 0, freqs.size() - 1)
		var freq: float = freqs[note]
		var env: float = 0.6
		var v: float = sin(TAU * freq * t) * env * (1.0 - 0.2 * fmod(t * freq, 1.0))
		var s: int = int(clamp(v * amp, -32768.0, 32767.0))
		data.encode_s16(i * 2, s)
	stream.data = data
	return stream
