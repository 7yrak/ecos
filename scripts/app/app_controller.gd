class_name AppController
extends Node

const MENU_SCENE := preload("res://scenes/menu/main_menu.tscn")
const RUN_SCENE := preload("res://scenes/gameplay/run.tscn")

var current_screen: Node


func _ready() -> void:
	show_menu()


func show_menu() -> void:
	var menu := MENU_SCENE.instantiate() as MainMenu
	menu.play_requested.connect(start_game)
	_replace_screen(menu)


func start_game() -> void:
	_start_level(1)


func _start_level(level_number: int) -> void:
	var run := RUN_SCENE.instantiate() as RunController
	run.configure_level(level_number)
	run.menu_requested.connect(show_menu)
	run.level_requested.connect(_start_level)
	_replace_screen(run)


func _replace_screen(next_screen: Node) -> void:
	if is_instance_valid(current_screen):
		remove_child(current_screen)
		current_screen.queue_free()
	current_screen = next_screen
	add_child(current_screen)
