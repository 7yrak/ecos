class_name GameplayFeedback
extends Node2D

enum Cue { ECHO, RIFT, PHASE, PULSE, PRESSURE, HIT }

const SAMPLE_RATE := 22050
const PLAYER_COUNT := 4

var cue_count := 0
var last_cue := -1
var _streams: Array[AudioStreamWAV] = []
var _players: Array[AudioStreamPlayer] = []
var _next_player := 0


func _ready() -> void:
	_streams = [
		_create_tone(520.0, 820.0, 0.13, 0.28),
		_create_tone(240.0, 620.0, 0.18, 0.28),
		_create_tone(360.0, 980.0, 0.24, 0.3),
		_create_tone(920.0, 680.0, 0.1, 0.22),
		_create_tone(310.0, 120.0, 0.2, 0.3),
		_create_tone(190.0, 52.0, 0.3, 0.38, 0.28),
	]
	for _index in PLAYER_COUNT:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_players.append(player)


func _exit_tree() -> void:
	for player in _players:
		player.stop()
		player.stream = null
	_players.clear()
	_streams.clear()


func play_echo(world_position: Vector2) -> void:
	_play(Cue.ECHO)
	_spawn_ring(world_position, Color(1.0, 0.45, 0.36, 0.85), 2.0)


func play_rift(world_position: Vector2, pressured: bool) -> void:
	_play(Cue.RIFT)
	var color := Color(1.0, 0.68, 0.25, 0.95) if pressured else Color(1.0, 0.34, 0.28, 0.9)
	_spawn_ring(world_position, color, 2.6)


func play_phase(world_position: Vector2) -> void:
	_play(Cue.PHASE)
	_spawn_ring(world_position, Color(1.0, 0.72, 0.28, 0.9), 3.2)


func play_pulse(world_position: Vector2) -> void:
	_play(Cue.PULSE)
	_spawn_ring(world_position, Color(1.0, 0.38, 0.31, 0.9), 2.5)


func play_pressure(world_position: Vector2) -> void:
	_play(Cue.PRESSURE)
	_spawn_ring(world_position, Color(1.0, 0.68, 0.25, 0.95), 2.8)


func play_hit(world_position: Vector2) -> void:
	_play(Cue.HIT)
	_spawn_ring(world_position, Color(1.0, 0.22, 0.18, 1.0), 3.8)


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


func _play(cue: Cue) -> void:
	if _players.is_empty() or cue < 0 or cue >= _streams.size():
		return
	cue_count += 1
	last_cue = cue
	if OS.has_feature("headless") or AudioServer.get_driver_name() == "Dummy":
		return
	var player := _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	player.stream = _streams[cue]
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
