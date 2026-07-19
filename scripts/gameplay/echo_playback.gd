class_name EchoPlayback
extends Area2D

signal hit_player(echo: EchoPlayback)
signal expired(echo: EchoPlayback)

enum Mode { TRACE, HUNTER, RESONANCE }

@export var collision_grace := 0.7
@export var hunter_base_speed := 260.0
@export var hunter_duration := 6.0
@export var resonance_duration := 4.0

var _timeline: EchoTimeline
var _target: Node2D
var _playback_time := 0.0
var _age := 0.0
var _hit_reported := false
var _state_time := 0.0
var _expired := false
var playback_speed := 1.0
var mode := Mode.TRACE


func _ready() -> void:
	monitoring = false
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if _expired:
		return

	_age += delta
	match mode:
		Mode.TRACE:
			_update_trace(delta)
		Mode.HUNTER:
			_update_hunter(delta)
		Mode.RESONANCE:
			_update_resonance(delta)
	if _expired:
		return
	monitoring = _age >= collision_grace and not _hit_reported
	queue_redraw()


func configure(timeline: EchoTimeline, follow_updates := false) -> void:
	configure_trace(timeline if follow_updates else timeline.duplicate_timeline())


func configure_trace(timeline: EchoTimeline) -> void:
	_timeline = timeline
	_target = null
	mode = Mode.TRACE
	_playback_time = 0.0
	_age = 0.0
	_hit_reported = false
	_expired = false
	if _timeline.is_playable():
		global_position = _timeline.sample_at(0.0)


func configure_hunter(spawn_position: Vector2, target: Node2D) -> void:
	_timeline = null
	_target = target
	mode = Mode.HUNTER
	global_position = spawn_position
	_state_time = hunter_duration
	_age = 0.0
	_hit_reported = false
	_expired = false


func set_playback_speed(multiplier: float) -> void:
	playback_speed = maxf(multiplier, 1.0)
	queue_redraw()


func stop() -> void:
	set_deferred("monitoring", false)
	set_physics_process(false)
	_target = null


func _update_trace(delta: float) -> void:
	if _timeline == null or not _timeline.is_playable():
		_expire()
		return
	_playback_time = minf(_playback_time + delta * playback_speed, _timeline.duration())
	global_position = _timeline.sample_at(_playback_time)
	if _playback_time >= _timeline.duration():
		_enter_resonance()


func _update_hunter(delta: float) -> void:
	_state_time = maxf(0.0, _state_time - delta)
	if is_instance_valid(_target):
		global_position = global_position.move_toward(
			_target.global_position,
			hunter_base_speed * playback_speed * delta
		)
	if _state_time <= 0.0:
		_enter_resonance()


func _update_resonance(delta: float) -> void:
	_state_time = maxf(0.0, _state_time - delta)
	if _state_time <= 0.0:
		_expire()


func _enter_resonance() -> void:
	mode = Mode.RESONANCE
	_state_time = resonance_duration
	_target = null


func _expire() -> void:
	if _expired:
		return
	_expired = true
	set_deferred("monitoring", false)
	set_physics_process(false)
	expired.emit(self)
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if _hit_reported or not body.is_in_group("player"):
		return
	_hit_reported = true
	set_deferred("monitoring", false)
	hit_player.emit(self)


func _draw() -> void:
	var wave := 4.0 + sin(_age * 6.0 * playback_speed) * 3.0
	if mode == Mode.RESONANCE:
		var resonance_progress := _state_time / resonance_duration
		draw_circle(Vector2.ZERO, 38.0 + wave, Color(1.0, 0.2, 0.16, 0.1 + resonance_progress * 0.08))
		draw_arc(Vector2.ZERO, 34.0 + wave, 0.0, TAU, 36, Color(1.0, 0.32, 0.24, 0.8), 4.0, true)
		draw_circle(Vector2.ZERO, 10.0, Color(1.0, 0.32, 0.24, 0.55))
		return
	var color := Color(1.0, 0.68, 0.25) if mode == Mode.HUNTER else Color(1.0, 0.45, 0.36)
	draw_circle(Vector2.ZERO, 28.0 + wave, Color(color, 0.1))
	draw_arc(Vector2.ZERO, 24.0 + wave, 0.0, TAU, 36, Color(color, 0.7), 3.0, true)
	if playback_speed > 1.05:
		draw_arc(Vector2.ZERO, 31.0 + wave, -PI * 0.75, PI * 0.35, 18, Color(1.0, 0.72, 0.28, 0.75), 3.0, true)
	if mode == Mode.HUNTER:
		draw_line(Vector2(-12.0, 0.0), Vector2(12.0, 0.0), Color(color, 0.9), 3.0)
		draw_line(Vector2(0.0, -12.0), Vector2(0.0, 12.0), Color(color, 0.9), 3.0)
	else:
		draw_circle(Vector2.ZERO, 17.0, Color(1.0, 0.38, 0.31, 0.38))
