class_name EchoRiftWarning
extends Node2D

signal opened(rift: EchoRiftWarning)

var timeline: EchoTimeline
var hunter := false
var run_id := 0
var warning_duration := 0.7
var _time_remaining := 0.7
var _opened := false


func configure(
	segment: EchoTimeline,
	spawn_position: Vector2,
	is_hunter: bool,
	duration: float,
	current_run_id: int
) -> void:
	timeline = segment
	global_position = spawn_position
	hunter = is_hunter
	warning_duration = maxf(0.05, duration)
	_time_remaining = warning_duration
	run_id = current_run_id
	z_index = 3
	queue_redraw()


func _physics_process(delta: float) -> void:
	if _opened:
		return
	_time_remaining = maxf(0.0, _time_remaining - delta)
	queue_redraw()
	if _time_remaining > 0.0:
		return
	_opened = true
	opened.emit(self)
	queue_free()


func _draw() -> void:
	var progress := 1.0 - _time_remaining / warning_duration
	var color := Color(1.0, 0.68, 0.25) if hunter else Color(1.0, 0.34, 0.28)
	var pulse := 0.65 + sin(progress * TAU * 3.0) * 0.2
	draw_circle(Vector2.ZERO, 34.0 + progress * 12.0, Color(color, 0.08 + progress * 0.12))
	draw_arc(Vector2.ZERO, 28.0 + progress * 10.0, -PI * 0.8, PI * 0.35, 24, Color(color, pulse), 4.0, true)
	draw_arc(Vector2.ZERO, 43.0 - progress * 8.0, PI * 0.15, PI * 1.25, 24, Color(color, pulse * 0.75), 3.0, true)
	draw_line(Vector2(-12.0, 0.0), Vector2(12.0, 0.0), Color(color, 0.9), 3.0)
	if hunter:
		draw_line(Vector2(0.0, -12.0), Vector2(0.0, 12.0), Color(color, 0.9), 3.0)
