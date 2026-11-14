class_name GameplayFeedback
extends Node2D

enum Cue { ECHO, RIFT, PHASE, PULSE, PRESSURE, HIT, HAZARD, DODGE, RESONANCE, MONUMENT }

const SAMPLE_RATE := 22050
const PLAYER_COUNT := 4

var cue_count := 0
var last_cue := -1
var _streams: Array[AudioStreamWAV] = []
var _players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer
var _next_player := 0
var _primary := Color(0.58, 1.0, 0.8)
var _danger := Color(1.0, 0.45, 0.36)
var _warning := Color(1.0, 0.68, 0.25)
var _music_intensity := 0.0
var _music_stage := 1
var _resonance_active := false
var _mobile_safe_override := false


func _ready() -> void:
	_streams = [
		_create_tone(520.0, 820.0, 0.13, 0.28),
		_create_tone(240.0, 620.0, 0.18, 0.28),
		_create_tone(360.0, 980.0, 0.24, 0.3),
		_create_tone(920.0, 680.0, 0.1, 0.22),
		_create_tone(310.0, 120.0, 0.2, 0.3),
		_create_tone(190.0, 52.0, 0.3, 0.38, 0.28),
		_create_tone(180.0, 1180.0, 0.3, 0.32, 0.12),
		_create_tone(1180.0, 1840.0, 0.16, 0.25),
		_create_tone(420.0, 1680.0, 0.42, 0.28),
		_create_tone(72.0, 740.0, 0.62, 0.38, 0.18),
	]
	for _index in PLAYER_COUNT:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_players.append(player)
	if not _uses_mobile_safe_mode():
		_music_player = AudioStreamPlayer.new()
		_music_player.name = "AdaptiveMusic"
		_music_player.bus = "Master"
		_music_player.volume_db = -18.0
		add_child(_music_player)


func _exit_tree() -> void:
	for player in _players:
		player.stop()
		player.stream = null
	_players.clear()
	_streams.clear()
	if is_instance_valid(_music_player):
		_music_player.stop()
		_music_player.stream = null


func play_echo(world_position: Vector2, generation := 1) -> void:
	var pitch := 1.0 if _uses_mobile_safe_mode() else 0.92 + float(posmod(generation - 1, 6)) * 0.065
	_play(Cue.ECHO, pitch)
	_spawn_ring(world_position, Color(_danger, 0.85), 2.0)


func play_rift(world_position: Vector2, pressured: bool) -> void:
	_play(Cue.RIFT)
	var color := Color(_warning, 0.95) if pressured else Color(_danger, 0.9)
	_spawn_ring(world_position, color, 2.6)


func play_phase(world_position: Vector2) -> void:
	_play(Cue.PHASE)
	_spawn_ring(world_position, Color(_primary, 0.9), 3.2)


func play_pulse(world_position: Vector2) -> void:
	_play(Cue.PULSE)
	_spawn_ring(world_position, Color(_danger, 0.9), 2.5)


func play_pressure(world_position: Vector2) -> void:
	_play(Cue.PRESSURE)
	_spawn_ring(world_position, Color(_warning, 0.95), 2.8)


func play_hit(world_position: Vector2) -> void:
	_play(Cue.HIT)
	_spawn_ring(world_position, Color(_danger.lightened(0.08), 1.0), 3.8)


func play_hazard(world_position: Vector2) -> void:
	_play(Cue.HAZARD)
	_spawn_ring(world_position, Color(_warning, 0.95), 3.4)


func play_perfect_dodge(world_position: Vector2) -> void:
	_play(Cue.DODGE)
	_spawn_ring(world_position, Color(_primary.lightened(0.2), 1.0), 4.2)


func play_resonance(world_position: Vector2) -> void:
	_play(Cue.RESONANCE)
	_spawn_ring(world_position, Color(_primary.lerp(_warning, 0.35), 1.0), 5.2)


func play_monument(world_position: Vector2) -> void:
	_play(Cue.MONUMENT)
	_spawn_ring(world_position, Color(_warning.lightened(0.12), 1.0), 5.8)


func configure_music(stage: int) -> void:
	_music_stage = clampi(stage, 1, 9)
	if _uses_mobile_safe_mode() or OS.has_feature("headless") or AudioServer.get_driver_name() == "Dummy":
		if is_instance_valid(_music_player):
			_music_player.stop()
			_music_player.stream = null
		return
	_music_player.stream = _create_music_loop(_music_stage)
	_music_player.play()
	set_intensity(0.0)


func set_intensity(intensity: float) -> void:
	_music_intensity = clampf(intensity, 0.0, 1.0)
	if _uses_mobile_safe_mode() or not is_instance_valid(_music_player):
		return
	_music_player.pitch_scale = 0.94 + _music_intensity * 0.14 + (0.08 if _resonance_active else 0.0)
	_music_player.volume_db = -19.0 + _music_intensity * 6.0 + (4.0 if _resonance_active else 0.0)


func set_resonance(active: bool) -> void:
	_resonance_active = active
	set_intensity(_music_intensity)


func music_intensity() -> float:
	return _music_intensity


func resonance_active() -> bool:
	return _resonance_active


func set_mobile_safe_override(enabled: bool) -> void:
	_mobile_safe_override = enabled


func adaptive_music_active() -> bool:
	return is_instance_valid(_music_player) and _music_player.playing and _music_player.stream != null


func _uses_mobile_safe_mode() -> bool:
	return _mobile_safe_override or OS.has_feature("mobile")


func set_palette(palette: Dictionary) -> void:
	_primary = palette.get("primary", _primary)
	_danger = palette.get("danger", _danger)
	_warning = palette.get("warning", _warning)


func clear_active() -> void:
	for player in _players:
		player.stop()
	for child in get_children():
		if child is Line2D:
			child.queue_free()


func stream_data_size(cue: Cue) -> int:
	if cue < 0 or cue >= _streams.size():
		return 0
	return _streams[cue].data.size()


func active_ring_count() -> int:
	var count := 0
	for child in get_children():
		if child is Line2D:
			count += 1
	return count


func _play(cue: Cue, pitch_scale := 1.0) -> void:
	if _players.is_empty() or cue < 0 or cue >= _streams.size():
		return
	cue_count += 1
	last_cue = cue
	if OS.has_feature("headless") or AudioServer.get_driver_name() == "Dummy":
		return
	var player := _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	player.stream = _streams[cue]
	player.pitch_scale = pitch_scale
	player.play()


func _spawn_ring(world_position: Vector2, color: Color, target_scale: float) -> void:
	var ring := Line2D.new()
	ring.name = "FeedbackRing"
	ring.width = 4.0
	ring.default_color = color
	ring.closed = true
	var points := PackedVector2Array()
	for index in 32:
		var angle := TAU * float(index) / 32.0
		points.append(Vector2.from_angle(angle) * 24.0)
	ring.points = points
	add_child(ring)
	ring.global_position = world_position
	ring.scale = Vector2.ONE * 0.65

	var tween := ring.create_tween().set_parallel(true)
	tween.tween_property(ring, "scale", Vector2.ONE * target_scale, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "modulate:a", 0.0, 0.42)
	tween.chain().tween_callback(ring.queue_free)


func _create_tone(
	start_frequency: float,
	end_frequency: float,
	duration: float,
	amplitude: float,
	noise_amount: float = 0.0
) -> AudioStreamWAV:
	var sample_count := maxi(1, roundi(duration * SAMPLE_RATE))
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var phase := 0.0
	for index in sample_count:
		var progress := float(index) / float(sample_count)
		var frequency := lerpf(start_frequency, end_frequency, progress)
		phase += TAU * frequency / SAMPLE_RATE
		var attack := minf(1.0, progress * 28.0)
		var decay := pow(1.0 - progress, 2.2)
		var noise := (sin(float(index) * 17.17) + sin(float(index) * 37.91)) * 0.5
		var sample := (sin(phase) * (1.0 - noise_amount) + noise * noise_amount) * amplitude * attack * decay
		data.encode_s16(index * 2, clampi(roundi(sample * 32767.0), -32768, 32767))

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream


func _create_music_loop(stage: int) -> AudioStreamWAV:
	var duration := 2.4
	var sample_count := roundi(duration * SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var root_frequency := 72.0 + float(stage) * 7.0
	var phase_low := 0.0
	var phase_high := 0.0
	for index in sample_count:
		var time := float(index) / SAMPLE_RATE
		var beat_position := fmod(time * (1.45 + float(stage) * 0.035), 1.0)
		var beat := exp(-beat_position * 11.0)
		var step := int(floor(time * 4.0)) % 4
		var harmonic: float = [1.0, 1.5, 1.25, 1.75][step]
		phase_low += TAU * root_frequency / SAMPLE_RATE
		phase_high += TAU * root_frequency * harmonic * 2.0 / SAMPLE_RATE
		var low := sin(phase_low) * 0.13
		var signal_tone := sin(phase_high) * 0.045 * (0.4 + beat * 0.6)
		var percussion := sin(TAU * (52.0 + 90.0 * (1.0 - beat_position)) * time) * beat * 0.08
		var loop_fade := minf(1.0, minf(time / 0.035, (duration - time) / 0.035))
		var sample := (low + signal_tone + percussion) * 0.72 * loop_fade
		data.encode_s16(index * 2, clampi(roundi(sample * 32767.0), -32768, 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count
	stream.data = data
	return stream
