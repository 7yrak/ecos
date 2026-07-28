class_name StoreTouchAction
extends Control

signal tapped

const DRAG_THRESHOLD := 8.0

var _touch_index := -1
var _press_position := Vector2.ZERO
var _dragged := false
var _mouse_pressed := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	focus_mode = Control.FOCUS_NONE


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_dragged = _dragged or event.position.distance_to(_press_position) > DRAG_THRESHOLD
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion and _mouse_pressed:
		_dragged = _dragged or event.position.distance_to(_press_position) > DRAG_THRESHOLD


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed and _touch_index < 0:
		_touch_index = event.index
		_press_position = event.position
		_dragged = false
	elif not event.pressed and event.index == _touch_index:
		if not _dragged:
			tapped.emit()
		_touch_index = -1


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.pressed:
		_mouse_pressed = true
		_press_position = event.position
		_dragged = false
	elif _mouse_pressed:
		if not _dragged:
			tapped.emit()
		_mouse_pressed = false
