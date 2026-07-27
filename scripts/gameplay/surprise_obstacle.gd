class_name SurpriseObstacle
extends AnimatableBody2D

signal armed(obstacle)
signal expired(obstacle)

enum State { WARNING, ACTIVE, RETRACTING }

const RETRACT_DURATION := 0.45

var beat_index := 0
var pattern_name := ""
var style := "wall"
var obstacle_size := Vector2(180.0, 28.0)
var warning_duration := 1.0
var active_duration := 4.0
var travel_offset := Vector2.ZERO
var state := State.WARNING
var collision_active := false

var _origin_position := Vector2.ZERO
var _state_time := 0.0
var _collision_shape: CollisionShape2D
var _warning_color := Color(1.0, 0.82, 0.28)
var _wall_color := Color(1.0, 0.3, 0.34)
var _sweep_color := Color(1.0, 0.58, 0.18)
var _gate_color := Color(0.34, 0.72, 1.0)


func _init() -> void:
	collision_layer = 4
	collision_mask = 0
	sync_to_physics = false
	z_index = 2


func configure(config: Dictionary, event_warning: float, event_duration: float, event_index: int, event_name: String) -> void:
	beat_index = event_index
	pattern_name = event_name
	style = str(config.get("style", "wall"))
	position = config.get("position", Vector2.ZERO)
	_origin_position = position
	obstacle_size = config.get("size", Vector2(180.0, 28.0))
	rotation = float(config.get("rotation", 0.0))
	travel_offset = config.get("travel", Vector2.ZERO)
	warning_duration = maxf(0.45, float(config.get("warning", event_warning)))
	active_duration = maxf(0.8, float(config.get("duration", event_duration)))
	state = State.WARNING
	_state_time = 0.0
	collision_active = false


func _ready() -> void:
	add_to_group("danger")
	_collision_shape = CollisionShape2D.new()
	_collision_shape.name = "Collision"
	var shape := RectangleShape2D.new()
	shape.size = obstacle_size
	_collision_shape.shape = shape
	_collision_shape.disabled = true
	add_child(_collision_shape)
	queue_redraw()


func _physics_process(delta: float) -> void:
	_state_time += delta
	match state:
		State.WARNING:
			if _state_time >= warning_duration:
				_state_time -= warning_duration
				_activate()
		State.ACTIVE:
			_update_travel()
			if _state_time >= active_duration:
				_state_time -= active_duration
				_begin_retract()
		State.RETRACTING:
			if _state_time >= RETRACT_DURATION:
				expired.emit(self)
				queue_free()
	queue_redraw()


func stop() -> void:
	_set_collision_active(false)
	set_physics_process(false)


func set_palette(palette: Dictionary) -> void:
	_warning_color = palette.get("warning", _warning_color)
	_wall_color = palette.get("danger", _wall_color)
	_sweep_color = palette.get("warning", _sweep_color)
	_gate_color = palette.get("secondary", _gate_color)
	queue_redraw()


func warning_progress() -> float:
	if state != State.WARNING:
		return 1.0
	return clampf(_state_time / warning_duration, 0.0, 1.0)


func active_progress() -> float:
	if state != State.ACTIVE:
		return 0.0
	return clampf(_state_time / active_duration, 0.0, 1.0)


func _activate() -> void:
	state = State.ACTIVE
	_set_collision_active(true)
	armed.emit(self)


func _begin_retract() -> void:
	state = State.RETRACTING
	_set_collision_active(false)


func _update_travel() -> void:
	if travel_offset.is_zero_approx():
		return
	var progress := active_progress()
	var eased_progress := smoothstep(0.0, 1.0, progress)
	position = _origin_position + travel_offset * eased_progress


func _set_collision_active(active: bool) -> void:
	collision_active = active
	if is_instance_valid(_collision_shape):
		_collision_shape.set_deferred("disabled", not active)


func _draw() -> void:
	var rect := Rect2(-obstacle_size * 0.5, obstacle_size)
	if state == State.WARNING:
		_draw_warning(rect)
	elif state == State.ACTIVE:
		_draw_active(rect)
	else:
		_draw_retracting(rect)


func _draw_warning(rect: Rect2) -> void:
	var progress := warning_progress()
	var pulse := 0.45 + sin(progress * TAU * 4.0) * 0.2
	if not travel_offset.is_zero_approx():
		draw_line(Vector2.ZERO, travel_offset, Color(_warning_color, 0.24), 18.0, true)
		draw_line(Vector2.ZERO, travel_offset, Color(_warning_color, 0.72), 3.0, true)
	draw_rect(rect.grow(12.0 + progress * 8.0), Color(_warning_color, 0.05 + progress * 0.08), true)
	_draw_dashed_rect(rect, Color(_warning_color, pulse), 4.0)
	var marker_radius := minf(24.0, maxf(15.0, minf(obstacle_size.x, obstacle_size.y) * 0.35))
	draw_circle(Vector2.ZERO, marker_radius, Color(0.04, 0.08, 0.1, 0.88))
	draw_arc(Vector2.ZERO, marker_radius, -PI * 0.5, -PI * 0.5 + TAU * progress, 24, _warning_color, 4.0, true)
	draw_line(Vector2(0.0, -10.0), Vector2(0.0, 5.0), _warning_color, 4.0, true)
	draw_circle(Vector2(0.0, 12.0), 2.8, _warning_color)


func _draw_active(rect: Rect2) -> void:
	var color := _style_color()
	var pulse := 0.82 + sin(_state_time * 10.0) * 0.12
	draw_rect(rect.grow(14.0), Color(color, 0.1), true)
	draw_rect(rect, Color(color, 0.27), true)
	draw_rect(rect, Color(color, pulse), false, 4.0)
	if style == "sweep":
		_draw_sweep_arrows(rect, color)
	elif style == "gate":
		_draw_gate_core(rect, color)
	else:
		_draw_hazard_stripes(rect, color)


func _draw_retracting(rect: Rect2) -> void:
	var color := _style_color()
	var remaining := 1.0 - clampf(_state_time / RETRACT_DURATION, 0.0, 1.0)
	draw_rect(rect.grow(10.0 * remaining), Color(color, 0.08 * remaining), true)
	draw_rect(rect, Color(color, 0.7 * remaining), false, 4.0 * remaining)


func _draw_dashed_rect(rect: Rect2, color: Color, width: float) -> void:
	var dash := 18.0
	var gap := 12.0
	for x in range(int(rect.position.x), int(rect.end.x), int(dash + gap)):
		draw_line(Vector2(x, rect.position.y), Vector2(minf(x + dash, rect.end.x), rect.position.y), color, width)
		draw_line(Vector2(x, rect.end.y), Vector2(minf(x + dash, rect.end.x), rect.end.y), color, width)
	for y in range(int(rect.position.y), int(rect.end.y), int(dash + gap)):
		draw_line(Vector2(rect.position.x, y), Vector2(rect.position.x, minf(y + dash, rect.end.y)), color, width)
		draw_line(Vector2(rect.end.x, y), Vector2(rect.end.x, minf(y + dash, rect.end.y)), color, width)


func _draw_hazard_stripes(rect: Rect2, color: Color) -> void:
	for x in range(int(rect.position.x) + 14, int(rect.end.x), 34):
		draw_line(Vector2(x - 11.0, rect.end.y), Vector2(x + 11.0, rect.position.y), Color(color, 0.62), 3.0)


func _draw_sweep_arrows(rect: Rect2, color: Color) -> void:
	var horizontal := obstacle_size.x >= obstacle_size.y
	var direction := travel_offset.normalized()
	if direction.is_zero_approx():
		direction = Vector2.RIGHT if horizontal else Vector2.DOWN
	var side := direction.orthogonal()
	for offset in [-28.0, 0.0, 28.0]:
		var center: Vector2 = side * float(offset)
		draw_line(center - direction * 16.0, center + direction * 16.0, Color(color, 0.95), 3.0, true)
		draw_line(center + direction * 16.0, center + direction * 7.0 + side * 8.0, Color(color, 0.95), 3.0, true)
		draw_line(center + direction * 16.0, center + direction * 7.0 - side * 8.0, Color(color, 0.95), 3.0, true)


func _draw_gate_core(rect: Rect2, color: Color) -> void:
	var radius := minf(26.0, minf(obstacle_size.x, obstacle_size.y) * 0.42)
	draw_circle(Vector2.ZERO, radius + 8.0, Color(color, 0.12))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 28, Color(color, 0.95), 4.0, true)
	draw_circle(Vector2.ZERO, 5.0, Color(color, 1.0))
	draw_line(Vector2(rect.position.x, 0.0), Vector2(-radius - 5.0, 0.0), Color(color, 0.65), 3.0)
	draw_line(Vector2(radius + 5.0, 0.0), Vector2(rect.end.x, 0.0), Color(color, 0.65), 3.0)


func _style_color() -> Color:
	if style == "sweep":
		return _sweep_color
	if style == "gate":
		return _gate_color
	return _wall_color
