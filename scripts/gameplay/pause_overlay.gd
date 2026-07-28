class_name PauseOverlay
extends ColorRect

signal resume_requested


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		resume_requested.emit()
		get_viewport().set_input_as_handled()
