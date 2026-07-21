class_name RunController
extends Node2D

signal menu_requested
signal level_requested(level_number: int)

enum RunState { PLAYING, GAME_OVER }

const EchoTimelineScript = preload("res://scripts/gameplay/echo_timeline.gd")
const LevelCatalogScript = preload("res://scripts/gameplay/level_catalog.gd")
const ECHO_SCENE := preload("res://scenes/gameplay/echo.tscn")
const RIFT_SCRIPT := preload("res://scripts/gameplay/echo_rift_warning.gd")
const SAMPLE_INTERVAL := 0.05
const MIN_SEGMENT_DISTANCE := 280.0
const CHAIN_PRESSURE_STEP := 0.2
const ECHO_FOLLOW_DELAY := 1.2
const RIFT_WARNING_TIME := 0.7
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
@onready var result_title: Label = $UI/GameOver/Center/Panel/Content/Title
@onready var result_label: Label = $UI/GameOver/Center/Panel/Content/Result
@onready var restart_button: Button = $UI/GameOver/Center/Panel/Content/Restart
@onready var menu_button: Button = $UI/GameOver/Center/Panel/Content/Menu
@onready var settings_store := get_node("/root/Settings") as SettingsStore

var _state := RunState.PLAYING
var _level
var _level_number := 1
var _level_won := false
var _timeline: EchoTimeline
var _run_time := 0.0
var _segment_time := 0.0
var _sample_accumulator := 0.0
var _echo_count := 0
var _total_echo_count := 0
var _echo_pressure := 0
var _slow_offenses := 0
var _chain_pressure_multiplier := 1.0
var _score := 0
var _current_phase := 1
var _phase_banner_time := 0.0
var _flash_tween: Tween
var _run_id := 0


func _ready() -> void:
	if _level == null:
		_level = LevelCatalogScript.first_level()
		_level_number = _level.number
	_center_world_for_viewport()
	player.danger_hit.connect(_on_player_danger_hit)
	pulse_obstacle.danger_state_changed.connect(_on_pulse_state_changed)
	restart_button.pressed.connect(_on_primary_action)
	menu_button.pressed.connect(menu_requested.emit)
	player.set_sensitivity(settings_store.sensitivity)
	_start_run()


func configure_level(level_number: int) -> void:
	var configured_level = LevelCatalogScript.get_level(level_number)
	if configured_level == null:
		push_warning("El nivel %d no existe; se usara el primer nivel." % level_number)
		configured_level = LevelCatalogScript.first_level()
	_level = configured_level
	_level_number = _level.number


func _unhandled_input(event: InputEvent) -> void:
	if _state != RunState.GAME_OVER:
		return
	if event is InputEventScreenTouch and event.pressed:
		_on_primary_action()
	elif event is InputEventMouseButton and event.pressed:
		_on_primary_action()
	elif event is InputEventKey and event.pressed and not event.echo:
		_on_primary_action()


func _physics_process(delta: float) -> void:
	if _state != RunState.PLAYING:
		return

	_run_time = minf(_run_time + delta, _level.duration)
	_segment_time += delta
	_sample_accumulator += delta
	_record_samples()
	_update_progression()

	if _segment_time >= _level.echo_interval:
		_spawn_echo()

	_score = int(_run_time * 10.0) + _total_echo_count * 100
	_update_hud()
	if _run_time >= _level.duration:
		_complete_level()
		return
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
	_level_won = false
	_run_time = 0.0
	_segment_time = 0.0
	_sample_accumulator = 0.0
	_echo_count = 0
	_total_echo_count = 0
	_echo_pressure = 0
	_slow_offenses = 0
	_chain_pressure_multiplier = 1.0
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
	result_title.text = "FIN DEL ECO"
	result_title.add_theme_color_override("font_color", Color(1.0, 0.45, 0.36))
	restart_button.text = "REPETIR NIVEL"
	phase_banner.visible = false
	impact_flash.visible = false
	instruction_label.text = "%d S // LOS ECOS SIGUEN TU ESTELA" % roundi(_level.duration)
	instruction_label.modulate.a = 1.0
	_show_banner("NIVEL %d // %s // %d S" % [_level.number, _level.difficulty, roundi(_level.duration)], Color(0.584, 1.0, 0.796), 2.4)
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
		var pressured := distance < MIN_SEGMENT_DISTANCE
		_update_echo_pressure(distance)
		var predecessor := _recursive_predecessor()
		var rift = RIFT_SCRIPT.new()
		rifts.add_child(rift)
		rift.configure(
			predecessor,
			pressured,
			RIFT_WARNING_TIME,
			_run_id,
			_total_echo_count + rifts.get_child_count()
		)
		rift.opened.connect(_on_rift_opened)
		feedback.play_rift(rift.global_position, pressured)

	_segment_time = 0.0
	_sample_accumulator = 0.0
	_timeline = EchoTimelineScript.new()
	_timeline.add_sample(0.0, player.global_position)


func _on_rift_opened(rift) -> void:
	if _state != RunState.PLAYING or rift.run_id != _run_id:
		return
	var echo := ECHO_SCENE.instantiate() as EchoPlayback
	echoes.add_child(echo)
	echo.generation = rift.generation
	echo.configure_follower(
		rift.global_position,
		rift.predecessor,
		ECHO_FOLLOW_DELAY,
		rift.pressured
	)
	echo.set_pressure_multiplier(_chain_pressure_multiplier)
	echo.hit_player.connect(_on_echo_hit_player)
	_total_echo_count += 1
	_echo_count = echoes.get_child_count()
	feedback.play_echo(echo.global_position)
	_update_hud()


func _on_player_danger_hit(_collider: Node) -> void:
	_end_run("OBSTACULO")


func _on_echo_hit_player(_echo: EchoPlayback) -> void:
	_end_run("TU ECO TE ALCANZO")


func _end_run(reason: String) -> void:
	if _state == RunState.GAME_OVER:
		return
	_level_won = false
	_show_result(reason)


func _complete_level() -> void:
	if _state == RunState.GAME_OVER:
		return
	_run_time = _level.duration
	_level_won = true
	_show_result("OBJETIVO DE TIEMPO CUMPLIDO")


func _show_result(reason: String) -> void:
	_state = RunState.GAME_OVER
	player.set_movement_enabled(false)
	_clear_rifts()
	patrol_obstacle.set_physics_process(false)
	pulse_obstacle.set_physics_process(false)
	for child in echoes.get_children():
		(child as EchoPlayback).stop()
	if _level_won:
		result_title.text = "NIVEL SUPERADO"
		result_title.add_theme_color_override("font_color", Color(0.584, 1.0, 0.796))
		feedback.play_phase(player.global_position)
		_flash_screen(Color(0.18, 0.82, 0.655), 0.2, 0.45)
		restart_button.text = "SIGUIENTE NIVEL" if LevelCatalogScript.has_level(_level_number + 1) else "REPETIR NIVEL"
	else:
		result_title.text = "FIN DEL ECO"
		result_title.add_theme_color_override("font_color", Color(1.0, 0.45, 0.36))
		feedback.play_hit(player.global_position)
		_flash_screen(Color(1.0, 0.2, 0.16), 0.3, 0.42)
		restart_button.text = "REINTENTAR NIVEL"
	result_label.text = "NIVEL %02d // %s\n%s\n\nTIEMPO  %05.1f / %05.1f s\nPUNTOS  %04d\nECOS CREADOS  %02d\nFALTAS LENTAS  %02d / CADENA x%.1f" % [_level.number, _level.difficulty, reason, _run_time, _level.duration, _score, _total_echo_count, _slow_offenses, _chain_pressure_multiplier]
	game_over_overlay.visible = true
	settings_store.vibrate(70)
	restart_button.grab_focus()


func _restart() -> void:
	_start_run()


func _on_primary_action() -> void:
	if _level_won and LevelCatalogScript.has_level(_level_number + 1):
		level_requested.emit(_level_number + 1)
		return
	_restart()


func _clear_echoes() -> void:
	for child in echoes.get_children():
		(child as EchoPlayback).stop()
		child.queue_free()


func _clear_rifts() -> void:
	for child in rifts.get_children():
		child.queue_free()


func _recursive_predecessor() -> Node2D:
	if echoes.get_child_count() > 0:
		return echoes.get_child(echoes.get_child_count() - 1) as Node2D
	return player


func _update_echo_pressure(segment_distance: float) -> void:
	var previous_pressure := _echo_pressure
	if segment_distance < MIN_SEGMENT_DISTANCE:
		_echo_pressure += 1
		_slow_offenses += 1
	else:
		_echo_pressure = maxi(0, _echo_pressure - 1)
	_chain_pressure_multiplier = 1.0 + float(_echo_pressure) * CHAIN_PRESSURE_STEP
	_apply_chain_pressure()
	if _echo_pressure == previous_pressure:
		return

	if _echo_pressure > previous_pressure:
		feedback.play_pressure(player.global_position)
		_show_banner("FALTA LENTA %d // CADENA x%.1f" % [_slow_offenses, _chain_pressure_multiplier], Color(1.0, 0.48, 0.24), 2.0)
		_flash_screen(Color(1.0, 0.34, 0.18), 0.1, 0.24)
	else:
		_show_banner("DISTANCIA RECUPERADA // CADENA x%.1f" % _chain_pressure_multiplier, Color(0.45, 1.0, 0.72), 1.5)
		_flash_screen(Color(0.18, 0.82, 0.655), 0.07, 0.2)


func _apply_chain_pressure() -> void:
	for child in echoes.get_children():
		(child as EchoPlayback).set_pressure_multiplier(_chain_pressure_multiplier)


func _update_progression() -> void:
	var next_phase := 1
	if _run_time >= _level.pulse_phase_time:
		next_phase = 3
	elif _run_time >= _level.patrol_phase_time:
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
	time_label.text = "TIEMPO\n%04.1f/%02d" % [_run_time, roundi(_level.duration)]
	score_label.text = "PUNTOS\n%04d" % _score
	echo_label.text = "ECOS\n%02d" % _echo_count
	phase_label.text = "N%d E%d/3\nF%d CAD x%.1f" % [_level.number, _current_phase, _slow_offenses, _chain_pressure_multiplier]
