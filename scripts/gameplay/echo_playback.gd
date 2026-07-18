class_name EchoPlayback
extends Area2D

signal hit_player(echo: EchoPlayback)

@export var collision_grace := 0.7

var _timeline: EchoTimeline
var _playback_time := 0.0
var _age := 0.0
var _hit_reported := false


func _ready() -> void:
	monitoring = false
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if _timeline == null or not _timeline.is_playable():
		return

	_age += delta
	_playback_time = fmod(_playback_time + delta, _timeline.duration())
	global_position = _timeline.sample_at(_playback_time)
	monitoring = _age >= collision_grace and not _hit_reported
	queue_redraw()


func configure(timeline: EchoTimeline) -> void:
	_timeline = timeline.duplicate_timeline()
	_playback_time = 0.0
	_age = 0.0
	_hit_reported = false
	if _timeline.is_playable():
		global_position = _timeline.sample_at(0.0)


func stop() -> void:
	set_deferred("monitoring", false)
	set_physics_process(false)


func _on_body_entered(body: Node2D) -> void:
	if _hit_reported or not body.is_in_group("player"):
		return
	_hit_reported = true
	set_deferred("monitoring", false)
	hit_player.emit(self)


func _draw() -> void:
	var wave := 4.0 + sin(_age * 6.0) * 3.0
	draw_circle(Vector2.ZERO, 28.0 + wave, Color(1.0, 0.38, 0.31, 0.08))
	draw_arc(Vector2.ZERO, 24.0 + wave, 0.0, TAU, 36, Color(1.0, 0.45, 0.36, 0.6), 3.0, true)
	draw_circle(Vector2.ZERO, 17.0, Color(1.0, 0.38, 0.31, 0.38))
