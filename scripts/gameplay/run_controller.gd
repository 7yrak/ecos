class_name RunController
extends Node2D

signal menu_requested

enum RunState { PLAYING, GAME_OVER }

const EchoTimelineScript = preload("res://scripts/gameplay/echo_timeline.gd")
const ECHO_SCENE := preload("res://scenes/gameplay/echo.tscn")
const ECHO_INTERVAL := 5.0
const SAMPLE_INTERVAL := 0.05
const START_POSITION := Vector2(360.0, 650.0)

@onready var player: PlayerController = $Player
@onready var echoes: Node2D = $Echoes
@onready var time_label: Label = $UI/TopBar/Margin/Stats/Time
@onready var score_label: Label = $UI/TopBar/Margin/Stats/Score
@onready var echo_label: Label = $UI/TopBar/Margin/Stats/Echoes
@onready var instruction_label: Label = $UI/Instruction
@onready var game_over_overlay: ColorRect = $UI/GameOver
@onready var result_label: Label = $UI/GameOver/Center/Panel/Content/Result
@onready var restart_button: Button = $UI/GameOver/Center/Panel/Content/Restart
@onready var menu_button: Button = $UI/GameOver/Center/Panel/Content/Menu

var _state := RunState.PLAYING
var _timeline: EchoTimeline
var _run_time := 0.0
var _segment_time := 0.0
var _sample_accumulator := 0.0
var _echo_count := 0
var _score := 0


func _ready() -> void:
	player.danger_hit.connect(_on_player_danger_hit)
	restart_button.pressed.connect(_restart)
	menu_button.pressed.connect(menu_requested.emit)
	_start_run()


func _unhandled_input(event: InputEvent) -> void:
	if _state != RunState.GAME_OVER:
		return
	if event is InputEventScreenTouch and event.pressed:
		_restart()
	elif event is InputEventMouseButton and event.pressed:
		_restart()
	elif event is InputEventKey and event.pressed and not event.echo:
		_restart()


func _physics_process(delta: float) -> void:
	if _state != RunState.PLAYING:
		return

	_run_time += delta
	_segment_time += delta
	_sample_accumulator += delta
	_record_samples()

	if _segment_time >= ECHO_INTERVAL:
		_spawn_echo()

	_score = int(_run_time * 10.0) + _echo_count * 100
	_update_hud()
	if _run_time > 3.5:
		instruction_label.modulate.a = move_toward(instruction_label.modulate.a, 0.0, delta * 0.7)


func _start_run() -> void:
	_clear_echoes()
	_state = RunState.PLAYING
	_run_time = 0.0
	_segment_time = 0.0
	_sample_accumulator = 0.0
	_echo_count = 0
	_score = 0
	_timeline = EchoTimelineScript.new()
	_timeline.add_sample(0.0, START_POSITION)
	player.reset_for_run(START_POSITION)
	game_over_overlay.visible = false
	instruction_label.modulate.a = 1.0
	_update_hud()


func _record_samples() -> void:
	while _sample_accumulator >= SAMPLE_INTERVAL:
		_sample_accumulator -= SAMPLE_INTERVAL
		var sample_time := _segment_time - _sample_accumulator
		_timeline.add_sample(sample_time, player.global_position)


func _spawn_echo() -> void:
	_timeline.add_sample(_segment_time, player.global_position)
	if _timeline.is_playable():
		var echo := ECHO_SCENE.instantiate() as EchoPlayback
		echo.configure(_timeline)
		echo.hit_player.connect(_on_echo_hit_player)
		echoes.add_child(echo)
		_echo_count += 1

	_segment_time = 0.0
	_sample_accumulator = 0.0
	_timeline = EchoTimelineScript.new()
	_timeline.add_sample(0.0, player.global_position)


func _on_player_danger_hit(_collider: Node) -> void:
	_end_run("OBSTACULO")


func _on_echo_hit_player(_echo: EchoPlayback) -> void:
	_end_run("TU ECO TE ALCANZO")


func _end_run(reason: String) -> void:
	if _state == RunState.GAME_OVER:
		return
	_state = RunState.GAME_OVER
	player.set_movement_enabled(false)
	for child in echoes.get_children():
		(child as EchoPlayback).stop()
	result_label.text = "%s\n\nTIEMPO  %05.1f s\nPUNTOS  %04d\nECOS  %02d" % [reason, _run_time, _score, _echo_count]
	game_over_overlay.visible = true
	restart_button.grab_focus()


func _restart() -> void:
	_start_run()


func _clear_echoes() -> void:
	for child in echoes.get_children():
		(child as EchoPlayback).stop()
		child.queue_free()


func _update_hud() -> void:
	time_label.text = "TIEMPO\n%05.1f" % _run_time
	score_label.text = "PUNTOS\n%04d" % _score
	echo_label.text = "ECOS\n%02d" % _echo_count
