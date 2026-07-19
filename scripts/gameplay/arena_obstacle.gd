class_name ArenaObstacle
extends AnimatableBody2D

enum Kind { STATIC, PATROL, PULSE }

const DANGER_COLOR := Color(1.0, 0.38, 0.31, 1.0)
const PATROL_COLOR := Color(1.0, 0.68, 0.25, 1.0)
const SAFE_COLOR := Color(0.25, 0.78, 0.82, 1.0)

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
	position = _origin_position
	visible = active
	set_physics_process(active and kind != Kind.STATIC)
	_refresh_state()
	queue_redraw()


func set_progression_active(active: bool) -> void:
	if progression_active == active:
		return
	reset_for_run(active)


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
	collision_active = active
	collision_shape.set_deferred("disabled", not active)


func _draw() -> void:
	if not progression_active:
		return

	var rect := Rect2(-obstacle_size * 0.5, obstacle_size)
	var color := DANGER_COLOR
	if kind == Kind.PATROL:
		color = PATROL_COLOR
	elif kind == Kind.PULSE and not collision_active:
		color = SAFE_COLOR

	draw_rect(rect.grow(8.0), Color(color, 0.08), true)
	draw_rect(rect, Color(color, 0.2 if collision_active else 0.1), true)
	draw_rect(rect, Color(color, 0.95), false, 3.0)

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
