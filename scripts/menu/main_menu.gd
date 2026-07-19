class_name MainMenu
extends Control

signal play_requested

@onready var content: MarginContainer = $Content
@onready var play_button: Button = $Content/Layout/Actions/Play
@onready var tutorial_button: Button = $Content/Layout/Actions/Tutorial
@onready var tutorial_overlay: ColorRect = $TutorialOverlay
@onready var tutorial_back_button: Button = $TutorialOverlay/Center/Panel/Content/Back


func _ready() -> void:
	play_button.pressed.connect(play_requested.emit)
	tutorial_button.pressed.connect(_show_tutorial)
	tutorial_back_button.pressed.connect(_hide_tutorial)
	tutorial_overlay.visible = false
	_animate_entry()


func _unhandled_input(event: InputEvent) -> void:
	if not tutorial_overlay.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_hide_tutorial()
		get_viewport().set_input_as_handled()


func _show_tutorial() -> void:
	tutorial_overlay.visible = true
	tutorial_back_button.grab_focus()


func _hide_tutorial() -> void:
	tutorial_overlay.visible = false
	tutorial_button.grab_focus()


func _animate_entry() -> void:
	content.modulate.a = 0.0
	content.position.y = 28.0
	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(content, "modulate:a", 1.0, 0.55)
	tween.tween_property(content, "position:y", 0.0, 0.7)
