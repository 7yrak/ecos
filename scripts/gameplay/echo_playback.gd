class_name EchoPlayback
extends Area2D

signal hit_player(echo: EchoPlayback)

enum Mode { FOLLOWER }

@export var collision_grace := 0.7
@export var follow_delay := 1.2

var _follow_timeline: EchoTimeline
var _target: Node2D
var _follow_time := 0.0
var _age := 0.0
var _hit_reported := false
var _collision_activation_age := 0.7
var pressure_multiplier := 1.0
var mode := Mode.FOLLOWER
var generation := 0
var pressured := false
var _trail: PackedVector2Array = PackedVector2Array()
var _level_danger := Color(1.0, 0.45, 0.36)
var _level_warning := Color(1.0, 0.68, 0.25)


func _ready() -> void:
	monitoring = false
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _physics_process(delta: float) -> void:
	_age += delta
	_update_follower(delta)
	monitoring = _age >= _collision_activation_age and not _hit_reported
	if _trail.is_empty() or _trail[-1].distance_to(global_position) >= 9.0:
		_trail.append(global_position)
		if _trail.size() > 12:
			_trail.remove_at(0)
	queue_redraw()


func configure_follower(
	spawn_position: Vector2,
	target: Node2D,
	delay: float,
	is_pressured := false
) -> void:
	_target = target
	follow_delay = maxf(0.2, delay)
	pressured = is_pressured
	mode = Mode.FOLLOWER
	global_position = spawn_position
	_follow_time = 0.0
	_age = 0.0
	_hit_reported = false
	_collision_activation_age = maxf(collision_grace, follow_delay + 0.1)
	_follow_timeline = EchoTimeline.new()
	if is_instance_valid(_target):
		_follow_timeline.add_sample(0.0, _target.global_position)
	process_physics_priority = generation + 1
	_trail.clear()
	_trail.append(spawn_position)


func set_palette(palette: Dictionary) -> void:
	_level_danger = palette.get("danger", _level_danger)
	_level_warning = palette.get("warning", _level_warning)
	queue_redraw()


func set_pressure_multiplier(multiplier: float) -> void:
	pressure_multiplier = maxf(1.0, multiplier)
	queue_redraw()


func effective_follow_delay() -> float:
	return follow_delay / pressure_multiplier


func follow_target() -> Node2D:
	return _target


func stop() -> void:
	set_deferred("monitoring", false)
	set_physics_process(false)
	_target = null


func _update_follower(delta: float) -> void:
	if not is_instance_valid(_target) or _follow_timeline == null:
		return
	_follow_time += delta
	_follow_timeline.add_sample(_follow_time, _target.global_position)
	var delayed_time := maxf(0.0, _follow_time - effective_follow_delay())
	global_position = _follow_timeline.sample_at(delayed_time)


func _on_body_entered(body: Node2D) -> void:
	if _hit_reported or not body.is_in_group("player"):
		return
	_hit_reported = true
	set_deferred("monitoring", false)
	hit_player.emit(self)


func _draw() -> void:
	var wave := 4.0 + sin(_age * 6.0 * pressure_multiplier) * 3.0
	var color := _level_warning if pressured else _level_danger
	if _trail.size() > 1:
		for index in range(1, _trail.size()):
			var progress := float(index) / float(_trail.size())
			draw_line(
				to_local(_trail[index - 1]),
				to_local(_trail[index]),
				Color(color, progress * 0.2),
				1.0 + progress * 4.0,
				true
			)
	draw_circle(Vector2.ZERO, 28.0 + wave, Color(color, 0.1))
	draw_arc(Vector2.ZERO, 24.0 + wave, 0.0, TAU, 36, Color(color, 0.75), 3.0, true)
	draw_circle(Vector2.ZERO, 17.0, Color(color, 0.4))
	for tick in mini(8, generation + 2):
		var angle := _age * (0.8 + generation * 0.04) + TAU * float(tick) / float(mini(8, generation + 2))
		var start := Vector2.from_angle(angle) * (30.0 + wave)
		draw_line(start, start + Vector2.from_angle(angle) * 6.0, Color(color, 0.5), 2.0, true)
	if pressure_multiplier > 1.05:
		draw_arc(Vector2.ZERO, 31.0 + wave, -PI * 0.75, PI * 0.35, 18, Color(1.0, 0.82, 0.32, 0.85), 3.0, true)
	if is_instance_valid(_target):
		var target_direction := to_local(_target.global_position).normalized()
		draw_line(Vector2.ZERO, target_direction * 20.0, Color(color, 0.9), 4.0, true)
		draw_circle(target_direction * 22.0, 4.5, Color(color, 0.95))
