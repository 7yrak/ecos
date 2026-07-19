class_name PlayerController
extends CharacterBody2D

signal danger_hit(collider: Node)

@export var move_speed := 520.0
@export var acceleration := 2400.0
@export var arrival_distance := 10.0

var target_position := Vector2.ZERO
var movement_enabled := true
var _active_touch := -1
var _danger_reported := false


func _ready() -> void:
	target_position = global_position
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not movement_enabled:
		return

	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag and event.index == _active_touch:
		set_target(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			set_target(event.position)
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			set_target(event.position)


func _physics_process(delta: float) -> void:
	if not movement_enabled:
		velocity = Vector2.ZERO
		return

	var distance := global_position.distance_to(target_position)
	var desired_velocity := Vector2.ZERO
	if distance > arrival_distance:
		desired_velocity = global_position.direction_to(target_position) * move_speed

	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	move_and_slide()
	_check_danger_collisions()


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


func reset_for_run(start_position: Vector2) -> void:
	global_position = start_position
	target_position = start_position
	velocity = Vector2.ZERO
	movement_enabled = true
	_danger_reported = false


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed and _active_touch == -1:
		_active_touch = event.index
		set_target(event.position)
	elif not event.pressed and event.index == _active_touch:
		_active_touch = -1


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
	draw_circle(Vector2.ZERO, 30.0, Color(0.18, 0.82, 0.655, 0.16))
	draw_circle(Vector2.ZERO, 22.0, Color(0.584, 1.0, 0.796, 1.0))
	draw_circle(Vector2(-6.0, -7.0), 6.0, Color(0.94, 1.0, 0.97, 0.9))
