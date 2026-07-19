class_name RunController
extends Node2D

signal menu_requested

enum RunState { PLAYING, GAME_OVER }

const EchoTimelineScript = preload("res://scripts/gameplay/echo_timeline.gd")
const ECHO_SCENE := preload("res://scenes/gameplay/echo.tscn")
const RIFT_SCRIPT := preload("res://scripts/gameplay/echo_rift_warning.gd")
const ECHO_INTERVAL := 5.0
const SAMPLE_INTERVAL := 0.05
const MAX_ACTIVE_ECHOES := 4
const MIN_SEGMENT_DISTANCE := 280.0
const ECHO_SPEED_STEP := 0.2
const HUNTER_PLAYER_SPEED_RATIO := 0.8
const RIFT_WARNING_TIME := 0.7
const PATROL_PHASE_TIME := 12.0
const PULSE_PHASE_TIME := 24.0
const START_POSITION := Vector2(360.0, 650.0)
const DESIGN_HEIGHT := 1280.0

@onready var player: PlayerController = $Player
@onready var echoes: Node2D = $Echoes
@onready var rifts: Node2D = $Rifts
@onready var feedback: GameplayFeedback = $Feedback
@onready var upper_obstacle: ArenaObstacle = $Obstacles/Upper
@onready var lower_obstacle: ArenaObstacle = $Obstacles/Lower
@onready var patrol_obstacle: ArenaObstacle = $Obstacles/Patrol
@onready var pulse_obstacle: ArenaObstacle = $Obstacles/Pulse
@onready var time_label: Label = $UI/TopBar/Margin/Stats/Time
@onready var score_label: Label = $UI/TopBar/Margin/Stats/Score
@onready var echo_label: Label = $UI/TopBar/Margin/Stats/Echoes
@onready var phase_label: Label = $UI/TopBar/Margin/Stats/Phase
@onready var phase_banner: Label = $UI/PhaseBanner
@onready var impact_flash: ColorRect = $UI/ImpactFlash
@onready var instruction_label: Label = $UI/Instruction
@onready var game_over_overlay: ColorRect = $UI/GameOver
@onready var result_label: Label = $UI/GameOver/Center/Panel/Content/Result
@onready var restart_button: Button = $UI/GameOver/Center/Panel/Content/Restart
@onready var menu_button: Button = $UI/GameOver/Center/Panel/Content/Menu
@onready var settings_store := get_node("/root/Settings") as SettingsStore

var _state := RunState.PLAYING
var _timeline: EchoTimeline
var _run_time := 0.0
var _segment_time := 0.0
var _sample_accumulator := 0.0
var _echo_count := 0
var _total_echo_count := 0
var _echo_pressure := 0
var _slow_offenses := 0
var _echo_speed_multiplier := 1.0
var _score := 0
var _current_phase := 1
var _phase_banner_time := 0.0
var _flash_tween: Tween
var _run_id := 0


func _ready() -> void:
	_center_world_for_viewport()
	player.danger_hit.connect(_on_player_danger_hit)
	pulse_obstacle.danger_state_changed.connect(_on_pulse_state_changed)
	restart_button.pressed.connect(_restart)
	menu_button.pressed.connect(menu_requested.emit)
	player.set_sensitivity(settings_store.sensitivity)
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
	_update_progression()

	if _segment_time >= ECHO_INTERVAL:
		_spawn_echo()

	_score = int(_run_time * 10.0) + _total_echo_count * 100
	_update_hud()
	_update_phase_banner(delta)
	if _run_time > 3.5:
		instruction_label.modulate.a = move_toward(instruction_label.modulate.a, 0.0, delta * 0.7)


func _start_run() -> void:
	_clear_echoes()
	_clear_rifts()
	_run_id += 1
	if is_instance_valid(_flash_tween):
		_flash_tween.kill()
	_state = RunState.PLAYING
	_run_time = 0.0
	_segment_time = 0.0
	_sample_accumulator = 0.0
	_echo_count = 0
	_total_echo_count = 0
	_echo_pressure = 0
	_slow_offenses = 0
	_echo_speed_multiplier = 1.0
	_score = 0
	_current_phase = 1
	_phase_banner_time = 0.0
	_timeline = EchoTimelineScript.new()
	feedback.clear_active()
	upper_obstacle.reset_for_run(true)
	lower_obstacle.reset_for_run(true)
	patrol_obstacle.reset_for_run(false)
	pulse_obstacle.reset_for_run(false)
	var start_position := to_global(START_POSITION)
	_timeline.add_sample(0.0, start_position)
	player.reset_for_run(start_position)
	game_over_overlay.visible = false
	phase_banner.visible = false
	impact_flash.visible = false
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
		var distance := _timeline.travel_distance()
		var hunter := distance < MIN_SEGMENT_DISTANCE
		_update_echo_pressure(distance)
		var segment := _timeline.duplicate_timeline()
		var spawn_position := segment.sample_at(0.0)
		var rift = RIFT_SCRIPT.new()
		rifts.add_child(rift)
		rift.configure(segment, spawn_position, hunter, RIFT_WARNING_TIME, _run_id)
		rift.opened.connect(_on_rift_opened)
		feedback.play_rift(spawn_position, hunter)

	_segment_time = 0.0
	_sample_accumulator = 0.0
	_timeline = EchoTimelineScript.new()
	_timeline.add_sample(0.0, player.global_position)


func _on_rift_opened(rift) -> void:
	if _state != RunState.PLAYING or rift.run_id != _run_id:
		return
	if echoes.get_child_count() >= MAX_ACTIVE_ECHOES:
		_retire_oldest_echo()
	var echo := ECHO_SCENE.instantiate() as EchoPlayback
	echoes.add_child(echo)
	if rift.hunter:
		echo.hunter_base_speed = player.move_speed * HUNTER_PLAYER_SPEED_RATIO
		echo.configure_hunter(rift.global_position, player, _hunter_speed_multiplier())
	else:
		echo.configure_trace(rift.timeline)
	echo.set_playback_speed(_echo_speed_multiplier)
	echo.hit_player.connect(_on_echo_hit_player)
	echo.expired.connect(_on_echo_expired)
	_total_echo_count += 1
	_echo_count = echoes.get_child_count()
	feedback.play_echo(echo.global_position)
	_update_hud()


func _on_echo_expired(_echo: EchoPlayback) -> void:
	_refresh_echo_count.call_deferred()


func _refresh_echo_count() -> void:
	_echo_count = echoes.get_child_count()
	_update_hud()


func _on_player_danger_hit(_collider: Node) -> void:
	_end_run("OBSTACULO")


func _on_echo_hit_player(_echo: EchoPlayback) -> void:
	_end_run("TU ECO TE ALCANZO")


func _end_run(reason: String) -> void:
	if _state == RunState.GAME_OVER:
		return
	_state = RunState.GAME_OVER
	player.set_movement_enabled(false)
	_clear_rifts()
	patrol_obstacle.set_physics_process(false)
	pulse_obstacle.set_physics_process(false)
	for child in echoes.get_children():
		(child as EchoPlayback).stop()
	feedback.play_hit(player.global_position)
	_flash_screen(Color(1.0, 0.2, 0.16), 0.3, 0.42)
	result_label.text = "%s\n\nTIEMPO  %05.1f s\nPUNTOS  %04d\nECOS CREADOS  %02d\nFALTAS LENTAS  %02d / CAZA x%.1f" % [reason, _run_time, _score, _total_echo_count, _slow_offenses, _hunter_speed_multiplier()]
	game_over_overlay.visible = true
	settings_store.vibrate(70)
	restart_button.grab_focus()


func _restart() -> void:
	_start_run()


func _clear_echoes() -> void:
	for child in echoes.get_children():
		(child as EchoPlayback).stop()
		child.queue_free()


func _clear_rifts() -> void:
	for child in rifts.get_children():
		child.queue_free()


func _retire_oldest_echo() -> void:
	var oldest := echoes.get_child(0) as EchoPlayback
	oldest.stop()
	echoes.remove_child(oldest)
	oldest.queue_free()


func _update_echo_pressure(segment_distance: float) -> void:
	var previous_pressure := _echo_pressure
	if segment_distance < MIN_SEGMENT_DISTANCE:
		_echo_pressure += 1
		_slow_offenses += 1
	else:
		_echo_pressure = maxi(0, _echo_pressure - 1)
	_echo_speed_multiplier = 1.0 + float(_echo_pressure) * ECHO_SPEED_STEP
	_apply_echo_speed()
	if _echo_pressure == previous_pressure:
		return

	if _echo_pressure > previous_pressure:
		feedback.play_pressure(player.global_position)
		_show_banner("FALTA LENTA %d // CAZADOR x%.1f" % [_slow_offenses, _hunter_speed_multiplier()], Color(1.0, 0.48, 0.24), 2.0)
		_flash_screen(Color(1.0, 0.34, 0.18), 0.1, 0.24)
	else:
		_show_banner("RITMO RECUPERADO // ECOS x%.1f" % _echo_speed_multiplier, Color(0.45, 1.0, 0.72), 1.5)
		_flash_screen(Color(0.18, 0.82, 0.655), 0.07, 0.2)


func _apply_echo_speed() -> void:
	for child in echoes.get_children():
		(child as EchoPlayback).set_playback_speed(_echo_speed_multiplier)


func _hunter_speed_multiplier() -> float:
	return 1.0 + float(_slow_offenses) * ECHO_SPEED_STEP


func _update_progression() -> void:
	var next_phase := 1
	if _run_time >= PULSE_PHASE_TIME:
		next_phase = 3
	elif _run_time >= PATROL_PHASE_TIME:
		next_phase = 2
	if next_phase == _current_phase:
		return

	_current_phase = next_phase
	patrol_obstacle.set_progression_active(_current_phase >= 2)
	pulse_obstacle.set_progression_active(_current_phase >= 3)
	var phase_name := "PATRULLA ACTIVADA" if _current_phase == 2 else "PULSO ACTIVADO"
	_show_banner("ETAPA %d // %s" % [_current_phase, phase_name], Color(1.0, 0.78, 0.38), 2.4)
	feedback.play_phase(player.global_position)
	_flash_screen(Color(1.0, 0.68, 0.25), 0.12, 0.3)


func _show_banner(text: String, color: Color, duration: float) -> void:
	phase_banner.text = text
	phase_banner.add_theme_color_override("font_color", color)
	phase_banner.modulate.a = 1.0
	phase_banner.pivot_offset = phase_banner.size * 0.5
	phase_banner.scale = Vector2.ONE * 0.82
	phase_banner.visible = true
	_phase_banner_time = duration
	create_tween().tween_property(phase_banner, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _update_phase_banner(delta: float) -> void:
	if _phase_banner_time <= 0.0:
		return
	_phase_banner_time = maxf(0.0, _phase_banner_time - delta)
	if _phase_banner_time < 0.6:
		phase_banner.modulate.a = _phase_banner_time / 0.6
	if _phase_banner_time <= 0.0:
		phase_banner.visible = false


func _on_pulse_state_changed(active: bool) -> void:
	if not active or _state != RunState.PLAYING:
		return
	feedback.play_pulse(pulse_obstacle.global_position)
	_flash_screen(Color(1.0, 0.3, 0.22), 0.07, 0.18)


func _flash_screen(color: Color, peak_alpha: float, duration: float) -> void:
	if is_instance_valid(_flash_tween):
		_flash_tween.kill()
	impact_flash.color = Color(color, peak_alpha)
	impact_flash.visible = true
	_flash_tween = create_tween()
	_flash_tween.tween_property(impact_flash, "color:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_flash_tween.tween_callback(func() -> void: impact_flash.visible = false)


func _center_world_for_viewport() -> void:
	position.y = maxf(0.0, (get_viewport_rect().size.y - DESIGN_HEIGHT) * 0.5)


func _update_hud() -> void:
	time_label.text = "TIEMPO\n%05.1f" % _run_time
	score_label.text = "PUNTOS\n%04d" % _score
	echo_label.text = "ECOS\n%02d/%02d" % [_echo_count, MAX_ACTIVE_ECHOES]
	phase_label.text = "ETAPA %d/3\nF%d CAZA x%.1f" % [_current_phase, _slow_offenses, _hunter_speed_multiplier()]
