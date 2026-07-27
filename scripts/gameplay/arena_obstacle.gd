class_name ArenaObstacle
extends AnimatableBody2D

signal danger_state_changed(active: bool)

enum Kind { STATIC, PATROL, PULSE }

@export var kind: Kind = Kind.STATIC
@export var obstacle_size := Vector2(200.0, 30.0)
@export var movement_offset := Vector2.ZERO
@export_range(1.0, 12.0, 0.1) var movement_period := 5.0
@export_range(0.2, 3.0, 0.1) var pulse_warning_duration := 0.8
@export_range(0.5, 4.0, 0.1) var pulse_active_duration := 2.0
@export_range(0.5, 4.0, 0.1) var pulse_safe_duration := 1.2

@onready var collision_shape: CollisionShape2D = $Collision

var progression_active := true
var collision_active := false
var _origin_position := Vector2.ZERO
var _elapsed := 0.0
var _visual_time := 0.0
var _danger_color := Color(1.0, 0.38, 0.31, 1.0)
var _patrol_color := Color(1.0, 0.68, 0.25, 1.0)
var _safe_color := Color(0.25, 0.78, 0.82, 1.0)


func _ready() -> void:
	_origin_position = position
	var shape := RectangleShape2D.new()
	shape.size = obstacle_size
	collision_shape.shape = shape
	_refresh_state()
	queue_redraw()


func _physics_process(delta: float) -> void:
	if not progression_active:
		return

	_elapsed += delta
	if kind == Kind.PATROL:
		var wave := sin(_elapsed * TAU / movement_period)
		position = _origin_position + movement_offset * wave
	elif kind == Kind.PULSE:
		_refresh_state()
	queue_redraw()


func reset_for_run(active: bool) -> void:
	progression_active = active
	_elapsed = 0.0
	_visual_time = 0.0
	position = _origin_position
	visible = active
	set_physics_process(active and kind != Kind.STATIC)
	_refresh_state()
	queue_redraw()


func set_progression_active(active: bool) -> void:
	if progression_active == active:
		return
	reset_for_run(active)


func configure_geometry(
	new_position: Vector2,
	new_size: Vector2,
	new_rotation: float = 0.0
) -> void:
	position = new_position
	_origin_position = new_position
	obstacle_size = new_size
	rotation = new_rotation
	var shape := RectangleShape2D.new()
	shape.size = obstacle_size
	collision_shape.shape = shape
	queue_redraw()


func _process(delta: float) -> void:
	_visual_time = fmod(_visual_time + delta, 1000.0)
	queue_redraw()


func set_palette(palette: Dictionary) -> void:
	_danger_color = palette.get("danger", _danger_color)
	_patrol_color = palette.get("warning", _patrol_color)
	_safe_color = palette.get("secondary", _safe_color)
	queue_redraw()


func _refresh_state() -> void:
	var should_collide := progression_active
	if kind == Kind.PULSE:
		var cycle_duration := pulse_warning_duration + pulse_active_duration + pulse_safe_duration
		var cycle_time := fmod(_elapsed, cycle_duration)
		should_collide = progression_active \
			and cycle_time >= pulse_warning_duration \
			and cycle_time < pulse_warning_duration + pulse_active_duration
	_set_collision_active(should_collide)


func _set_collision_active(active: bool) -> void:
	if collision_active == active and collision_shape.disabled == not active:
		return
	var changed := collision_active != active
	collision_active = active
	collision_shape.set_deferred("disabled", not active)
	if changed and kind == Kind.PULSE and progression_active:
		danger_state_changed.emit(active)


func _draw() -> void:
	if not progression_active:
		return

	var rect := Rect2(-obstacle_size * 0.5, obstacle_size)
	var color := _danger_color
	if kind == Kind.PATROL:
		color = _patrol_color
	elif kind == Kind.PULSE and not collision_active:
		color = _safe_color
	var energy := 0.78 + sin(_visual_time * 5.0 + float(kind)) * 0.16

	draw_rect(rect.grow(18.0), Color(color, 0.028), true)
	draw_rect(rect.grow(10.0), Color(color, 0.09), true)
	draw_rect(rect.grow(5.0), Color(0.015, 0.035, 0.045, 0.9), true)
	draw_rect(rect, Color(color, 0.2 if collision_active else 0.1), true)
	draw_rect(rect, Color(color, energy), false, 3.0)
	draw_line(Vector2(rect.position.x + 8.0, rect.position.y + 5.0), Vector2(rect.end.x - 8.0, rect.position.y + 5.0), Color(color.lightened(0.35), 0.45), 2.0)
	_draw_energy_nodes(rect, color)

	if kind == Kind.STATIC:
		for x in range(int(rect.position.x) + 20, int(rect.end.x), 34):
			draw_line(Vector2(x - 10, rect.end.y), Vector2(x + 10, rect.position.y), Color(color, 0.5), 2.0)
	elif kind == Kind.PATROL:
		draw_line(Vector2(-28.0, 0.0), Vector2(28.0, 0.0), Color(color, 0.9), 3.0)
		draw_polyline(PackedVector2Array([Vector2(-28.0, 0.0), Vector2(-16.0, -8.0), Vector2(-16.0, 8.0)]), Color(color, 0.9), 3.0)
		draw_polyline(PackedVector2Array([Vector2(28.0, 0.0), Vector2(16.0, -8.0), Vector2(16.0, 8.0)]), Color(color, 0.9), 3.0)
	else:
		var radius := minf(obstacle_size.x * 0.2, 34.0)
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 24, Color(color, 0.9), 3.0, true)
		draw_circle(Vector2.ZERO, 5.0, Color(color, 0.95))


func _draw_energy_nodes(rect: Rect2, color: Color) -> void:
	var horizontal := obstacle_size.x >= obstacle_size.y
	var axis: Vector2 = Vector2.RIGHT if horizontal else Vector2.DOWN
	var span: float = obstacle_size.x if horizontal else obstacle_size.y
	for direction in [-1.0, 1.0]:
		var center: Vector2 = axis * (span * 0.5 - 8.0) * direction
		draw_circle(center, 10.0, Color(0.01, 0.025, 0.035, 0.95))
		draw_circle(center, 6.0 + sin(_visual_time * 7.0 + direction) * 1.0, Color(color, 0.86))
		draw_arc(center, 13.0, _visual_time * direction, _visual_time * direction + PI * 1.25, 16, Color(color, 0.45), 2.0)
	if horizontal:
		draw_line(Vector2(rect.position.x + 18.0, rect.end.y - 5.0), Vector2(rect.end.x - 18.0, rect.end.y - 5.0), Color(color, 0.3), 2.0)
	else:
		draw_line(Vector2(rect.end.x - 5.0, rect.position.y + 18.0), Vector2(rect.end.x - 5.0, rect.end.y - 18.0), Color(color, 0.3), 2.0)
