class_name PlayerController
extends CharacterBody2D

signal danger_hit(collider: Node)

const StoreCatalogScript = preload("res://scripts/app/store_catalog.gd")

@export var move_speed := 520.0
@export var acceleration := 2400.0
@export var arrival_distance := 10.0

var target_position := Vector2.ZERO
var movement_enabled := true
var _active_touch := -1
var _danger_reported := false
var _primary_color := Color(0.584, 1.0, 0.796)
var _glow_color := Color(0.18, 0.82, 0.655)
var _trail: PackedVector2Array = PackedVector2Array()
var _visual_time := 0.0


func _ready() -> void:
	target_position = global_position
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not movement_enabled:
		return

	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag and event.index == _active_touch:
		set_target(_viewport_to_world(event.position))
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			set_target(get_global_mouse_position())
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			set_target(get_global_mouse_position())


func _physics_process(delta: float) -> void:
	_visual_time += delta
	if not movement_enabled:
		velocity = Vector2.ZERO
		queue_redraw()
		return

	var distance := global_position.distance_to(target_position)
	var desired_velocity := Vector2.ZERO
	if distance > arrival_distance:
		desired_velocity = global_position.direction_to(target_position) * move_speed

	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	move_and_slide()
	if _trail.is_empty() or _trail[-1].distance_to(global_position) >= 8.0:
		_trail.append(global_position)
		if _trail.size() > 16:
			_trail.remove_at(0)
	_check_danger_collisions()
	queue_redraw()


func set_target(viewport_position: Vector2) -> void:
	target_position = viewport_position


func set_movement_enabled(enabled: bool) -> void:
	movement_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO


func set_sensitivity(multiplier: float) -> void:
	var clamped_multiplier := clampf(multiplier, 0.65, 1.35)
	move_speed = 520.0 * clamped_multiplier
	acceleration = 2400.0 * clamped_multiplier


func set_skin(skin_id: String) -> void:
	var colors := StoreCatalogScript.skin_colors(skin_id)
	_primary_color = colors.primary
	_glow_color = colors.glow
	queue_redraw()


func clear_danger_report() -> void:
	_danger_reported = false


func reset_for_run(start_position: Vector2) -> void:
	global_position = start_position
	target_position = start_position
	velocity = Vector2.ZERO
	movement_enabled = true
	_danger_reported = false
	_trail.clear()
	_trail.append(start_position)
	_visual_time = 0.0
	queue_redraw()


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed and _active_touch == -1:
		_active_touch = event.index
		set_target(_viewport_to_world(event.position))
	elif not event.pressed and event.index == _active_touch:
		_active_touch = -1


func _viewport_to_world(viewport_position: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * viewport_position


func _check_danger_collisions() -> void:
	if _danger_reported:
		return

	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		var collider := collision.get_collider() as Node
		if collider != null and collider.is_in_group("danger"):
			_danger_reported = true
			danger_hit.emit(collider)
			return


func _draw() -> void:
	if _trail.size() > 1:
		for index in range(1, _trail.size()):
			var progress := float(index) / float(_trail.size())
			draw_line(
				to_local(_trail[index - 1]),
				to_local(_trail[index]),
				Color(_glow_color, progress * 0.34),
				2.0 + progress * 7.0,
				true
			)
	var pulse := 1.0 + sin(_visual_time * 6.5) * 0.08
	draw_circle(Vector2.ZERO, 42.0 * pulse, Color(_glow_color, 0.045))
	draw_circle(Vector2.ZERO, 31.0 * pulse, Color(_glow_color, 0.13))
	draw_arc(Vector2.ZERO, 29.0, _visual_time * 1.8, _visual_time * 1.8 + PI * 1.25, 28, Color(_primary_color, 0.75), 3.0, true)
	draw_arc(Vector2.ZERO, 35.0, -_visual_time * 1.2, -_visual_time * 1.2 + PI * 0.6, 18, Color(_glow_color, 0.46), 2.0, true)
	draw_circle(Vector2.ZERO, 22.0, _primary_color)
	draw_circle(Vector2.ZERO, 13.0, Color(_glow_color, 0.72))
	draw_circle(Vector2(-6.0, -7.0), 6.0, Color(0.96, 1.0, 0.98, 0.94))
