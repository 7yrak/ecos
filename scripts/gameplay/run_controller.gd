class_name RunController
extends Node2D

signal menu_requested
signal level_requested(level_number: int)
signal store_requested

enum RunState { PLAYING, GAME_OVER }

const EchoTimelineScript = preload("res://scripts/gameplay/echo_timeline.gd")
const LevelCatalogScript = preload("res://scripts/gameplay/level_catalog.gd")
const SurpriseObstacleScript = preload("res://scripts/gameplay/surprise_obstacle.gd")
const ECHO_SCENE := preload("res://scenes/gameplay/echo.tscn")
const RIFT_SCRIPT := preload("res://scripts/gameplay/echo_rift_warning.gd")
const SAMPLE_INTERVAL := 0.05
const CHAIN_PRESSURE_STEP := 0.2
const ECHO_FOLLOW_DELAY := 1.2
const RIFT_WARNING_TIME := 0.7
const START_POSITION := Vector2(360.0, 650.0)
const DESIGN_HEIGHT := 1280.0
const EXPANSION_THRESHOLDS := [3, 6]
const EXPANSION_DECISION_TIME := 4.0
const MANUAL_EXPANSION_BONUS := 250

@onready var player: PlayerController = $Player
@onready var arena: ArenaVisual = $Arena
@onready var world_25d: World25D = $World25D
@onready var world_camera: Camera2D = $WorldCamera
@onready var boundaries: Node2D = $Boundaries
@onready var surprises: Node2D = $Surprises
@onready var echoes: Node2D = $Echoes
@onready var rifts: Node2D = $Rifts
@onready var feedback: GameplayFeedback = $Feedback
@onready var atmosphere: GameplayOverlay = $UI/Atmosphere
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
@onready var expansion_label: Label = $UI/ExpansionStatus/Content/Label
@onready var expansion_meter: ProgressBar = $UI/ExpansionStatus/Content/Meter
@onready var pattern_memory_label: Label = $UI/ExpansionStatus/Content/PatternMemory
@onready var pattern_warning_label: Label = $UI/PatternWarning
@onready var break_limit_button: Button = $UI/BreakLimitButton
@onready var power_button: Button = $UI/PowerButton
@onready var pause_button: Button = $UI/PauseButton
@onready var pause_overlay: PauseOverlay = $UI/PauseOverlay
@onready var pause_panel: PanelContainer = $UI/PauseOverlay/Center/Panel
@onready var pause_kicker: Label = $UI/PauseOverlay/Center/Panel/Content/Kicker
@onready var pause_title: Label = $UI/PauseOverlay/Center/Panel/Content/Title
@onready var pause_level_label: Label = $UI/PauseOverlay/Center/Panel/Content/Level
@onready var pause_continue_button: Button = $UI/PauseOverlay/Center/Panel/Content/Continue
@onready var pause_restart_button: Button = $UI/PauseOverlay/Center/Panel/Content/Restart
@onready var pause_menu_button: Button = $UI/PauseOverlay/Center/Panel/Content/Menu
@onready var game_over_overlay: ColorRect = $UI/GameOver
@onready var result_panel: PanelContainer = $UI/GameOver/Center/Panel
@onready var result_kicker: Label = $UI/GameOver/Center/Panel/Content/Kicker
@onready var result_title: Label = $UI/GameOver/Center/Panel/Content/Title
@onready var result_label: Label = $UI/GameOver/Center/Panel/Content/Result
@onready var restart_button: Button = $UI/GameOver/Center/Panel/Content/Restart
@onready var menu_button: Button = $UI/GameOver/Center/Panel/Content/Menu
@onready var settings_store := get_node("/root/Settings") as SettingsStore
@onready var progress_store := get_node("/root/Progress") as ProgressStore

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
var _world_stage := 1
var _expansion_offer_time := 0.0
var _expansion_offered := false
var _expansion_bonus := 0
var _next_surprise_event_index := 0
var _discovered_event_count := 0
var _pattern_warning_time := 0.0
var _last_armed_beat := 0
var _phase_banner_time := 0.0
var _flash_tween: Tween
var _camera_tween: Tween
var _camera_zoom_tween: Tween
var _run_id := 0
var _reward_granted := false
var _power_used := false
var _power_invulnerability_time := 0.0


func _ready() -> void:
	if _level == null:
		_level = LevelCatalogScript.first_level()
		_level_number = _level.number
	_center_world_for_viewport()
	_setup_25d()
	player.danger_hit.connect(_on_player_danger_hit)
	pulse_obstacle.danger_state_changed.connect(_on_pulse_state_changed)
	break_limit_button.pressed.connect(_on_break_limit_pressed)
	power_button.pressed.connect(_on_power_pressed)
	pause_button.pressed.connect(_show_pause)
	pause_overlay.resume_requested.connect(_hide_pause)
	pause_continue_button.pressed.connect(_hide_pause)
	pause_restart_button.pressed.connect(_restart_from_pause)
	pause_menu_button.pressed.connect(_menu_from_pause)
	restart_button.pressed.connect(_on_primary_action)
	menu_button.pressed.connect(menu_requested.emit)
	player.set_sensitivity(settings_store.sensitivity)
	player.set_skin(progress_store.equipped_skin)
	_start_run()


func configure_level(level_number: int) -> void:
	var configured_level = LevelCatalogScript.get_level(level_number)
	if configured_level == null:
		push_warning("El nivel %d no existe; se usara el primer nivel." % level_number)
		configured_level = LevelCatalogScript.first_level()
	_level = configured_level
	_level_number = _level.number


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _state == RunState.PLAYING:
		_show_pause()
		get_viewport().set_input_as_handled()
		return
	if _state == RunState.PLAYING:
		if event is InputEventScreenTouch and event.pressed:
			world_25d.react_to_pointer(_pointer_to_design(event.position), 1.15)
		elif event is InputEventScreenDrag:
			world_25d.react_to_pointer(_pointer_to_design(event.position), 0.58 + minf(0.72, event.relative.length() / 34.0))
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			world_25d.react_to_pointer(_pointer_to_design(event.position), 1.0)
		elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			world_25d.react_to_pointer(_pointer_to_design(event.position), 0.62)
	if _state != RunState.GAME_OVER:
		return
	if event is InputEventScreenTouch and event.pressed:
		_on_primary_action()
	elif event is InputEventMouseButton and event.pressed:
		_on_primary_action()
	elif event is InputEventKey and event.pressed and not event.echo:
		_on_primary_action()


func _pointer_to_design(viewport_position: Vector2) -> Vector2:
	var world_position := get_viewport().get_canvas_transform().affine_inverse() * viewport_position
	return to_local(world_position)


func _physics_process(delta: float) -> void:
	if _state != RunState.PLAYING:
		return

	if _power_invulnerability_time > 0.0:
		_power_invulnerability_time = maxf(0.0, _power_invulnerability_time - delta)
		player.clear_danger_report()
	_run_time = minf(_run_time + delta, _level.duration)
	_segment_time += delta
	_sample_accumulator += delta
	_record_samples()
	_update_progression()
	_update_surprise_sequence()
	_update_expansion_offer(delta)

	if _segment_time >= _level.echo_interval:
		_spawn_echo()

	_score = int(_run_time * 10.0) + _total_echo_count * 100 + _expansion_bonus
	_update_hud()
	if _run_time >= _level.duration:
		_complete_level()
		return
	_update_phase_banner(delta)
	_update_pattern_warning(delta)
	if _run_time > 3.5:
		instruction_label.modulate.a = move_toward(instruction_label.modulate.a, 0.0, delta * 0.7)


func _start_run() -> void:
	_clear_echoes()
	_clear_rifts()
	_clear_surprises()
	_run_id += 1
	if is_instance_valid(_flash_tween):
		_flash_tween.kill()
	if is_instance_valid(_camera_tween):
		_camera_tween.kill()
	if is_instance_valid(_camera_zoom_tween):
		_camera_zoom_tween.kill()
	_state = RunState.PLAYING
	_level_won = false
	_reward_granted = false
	_power_used = false
	_power_invulnerability_time = 0.0
	pause_overlay.visible = false
	pause_button.visible = true
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
	_world_stage = 1
	_expansion_offer_time = 0.0
	_expansion_offered = false
	_expansion_bonus = 0
	_next_surprise_event_index = 0
	_discovered_event_count = 0
	_pattern_warning_time = 0.0
	_last_armed_beat = 0
	_phase_banner_time = 0.0
	_timeline = EchoTimelineScript.new()
	feedback.clear_active()
	_apply_visual_identity()
	arena.set_expansion_stage(1, false)
	world_25d.set_arena_stage(1)
	world_camera.enabled = true
	world_camera.zoom = Vector2.ONE
	world_camera.offset = Vector2.ZERO
	_configure_boundaries(arena.play_rect_for_stage(1))
	_configure_arena_for_level()
	upper_obstacle.reset_for_run(true)
	lower_obstacle.reset_for_run(true)
	patrol_obstacle.reset_for_run(false)
	pulse_obstacle.reset_for_run(false)
	var start_position := to_global(START_POSITION)
	_timeline.add_sample(0.0, start_position)
	player.reset_for_run(start_position)
	player.set_skin(progress_store.equipped_skin)
	world_25d.set_player_skin(progress_store.equipped_skin)
	game_over_overlay.visible = false
	result_title.text = "FIN DEL ECO"
	result_title.add_theme_color_override("font_color", _level.visual_palette.danger)
	result_kicker.text = "REPORTE // %s" % str(_level.visual_palette.name)
	restart_button.text = "REPETIR NIVEL"
	phase_banner.visible = false
	pattern_warning_label.visible = false
	impact_flash.visible = false
	break_limit_button.visible = false
	instruction_label.text = "%s // %d S" % [_level.title, roundi(_level.duration)]
	instruction_label.modulate.a = 1.0
	_configure_power_button()
	_show_banner("NIVEL %d // %s // %d S" % [_level.number, _level.difficulty, roundi(_level.duration)], _level.visual_palette.primary, 2.4)
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
		var pressured: bool = distance < float(_level.minimum_segment_distance)
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
		_level.follow_delay,
		rift.pressured
	)
	echo.set_palette(_level.visual_palette)
	echo.modulate.a = 0.0 if not OS.has_feature("headless") else 1.0
	echo.set_pressure_multiplier(_chain_pressure_multiplier)
	echo.hit_player.connect(_on_echo_hit_player)
	_total_echo_count += 1
	_echo_count = echoes.get_child_count()
	feedback.play_echo(echo.global_position)
	_offer_expansion_if_ready()
	_update_hud()


func _exit_tree() -> void:
	if is_instance_valid(get_tree()) and get_tree().paused:
		get_tree().paused = false


func _show_pause() -> void:
	if _state != RunState.PLAYING or get_tree().paused:
		return
	pause_level_label.text = "NIVEL %02d // %s\nTIEMPO %04.1f / %02d S" % [
		_level.number,
		_level.title,
		_run_time,
		roundi(_level.duration),
	]
	pause_overlay.visible = true
	pause_button.visible = false
	get_tree().paused = true
	pause_continue_button.grab_focus()


func _hide_pause() -> void:
	get_tree().paused = false
	pause_overlay.visible = false
	if _state == RunState.PLAYING:
		pause_button.visible = true
		pause_button.grab_focus()


func _restart_from_pause() -> void:
	_hide_pause()
	_restart()


func _menu_from_pause() -> void:
	_hide_pause()
	menu_requested.emit()


func _on_player_danger_hit(collider: Node) -> void:
	if _ignore_or_absorb_hit(collider):
		return
	_shake_camera(18.0, 0.3)
	_end_run("OBSTACULO")


func _on_echo_hit_player(echo: EchoPlayback) -> void:
	if _ignore_or_absorb_hit(echo):
		return
	_shake_camera(22.0, 0.34)
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
	pause_button.visible = false
	player.set_movement_enabled(false)
	_clear_rifts()
	_clear_surprises()
	pattern_warning_label.visible = false
	patrol_obstacle.set_physics_process(false)
	pulse_obstacle.set_physics_process(false)
	for child in echoes.get_children():
		(child as EchoPlayback).stop()
	if _level_won:
		result_title.text = "NIVEL SUPERADO"
		result_title.add_theme_color_override("font_color", _level.visual_palette.primary)
		result_kicker.text = "TRANSMISION ESTABLE // %s" % str(_level.visual_palette.name)
		result_panel.add_theme_stylebox_override("panel", _result_panel_style(_level.visual_palette.primary))
		feedback.play_phase(player.global_position)
		_flash_screen(Color(0.18, 0.82, 0.655), 0.2, 0.45)
		var next_level := _level_number + 1
		if LevelCatalogScript.has_level(next_level) and progress_store.is_level_owned(next_level):
			restart_button.text = "SIGUIENTE NIVEL"
		elif LevelCatalogScript.has_level(next_level):
			restart_button.text = "DESBLOQUEAR EN TIENDA"
		else:
			restart_button.text = "REPETIR NIVEL"
	else:
		result_title.text = "FIN DEL ECO"
		result_title.add_theme_color_override("font_color", _level.visual_palette.danger)
		result_kicker.text = "SENAL INTERRUMPIDA // %s" % str(_level.visual_palette.name)
		result_panel.add_theme_stylebox_override("panel", _result_panel_style(_level.visual_palette.danger))
		feedback.play_hit(player.global_position)
		_flash_screen(Color(1.0, 0.2, 0.16), 0.3, 0.42)
		restart_button.text = "REINTENTAR NIVEL"
	var reward := _grant_run_reward()
	result_label.text = "NIVEL %02d // %s\n%s\n\nTIEMPO  %05.1f / %05.1f s\nPUNTOS  %04d\nECOS CREADOS  %02d\nSECTORES ABIERTOS  %d / 3\nPATRONES DESCUBIERTOS  %02d / %02d\nFALTAS LENTAS  %02d / CADENA x%.1f\n\n+%d FRAGMENTOS  //  SALDO %d" % [_level.number, _level.difficulty, reason, _run_time, _level.duration, _score, _total_echo_count, _world_stage, _discovered_event_count, _level.surprise_events.size(), _slow_offenses, _chain_pressure_multiplier, reward, progress_store.fragments]
	game_over_overlay.visible = true
	result_panel.modulate.a = 0.0
	result_panel.scale = Vector2.ONE * 0.9
	result_panel.pivot_offset = result_panel.size * 0.5
	create_tween().set_parallel(true) \
		.tween_property(result_panel, "modulate:a", 1.0, 0.28) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	create_tween().tween_property(result_panel, "scale", Vector2.ONE, 0.38) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	settings_store.vibrate(70)
	restart_button.grab_focus()


func _restart() -> void:
	_start_run()


func _on_primary_action() -> void:
	if _level_won:
		var next_level := _level_number + 1
		if LevelCatalogScript.has_level(next_level) and progress_store.is_level_owned(next_level):
			level_requested.emit(next_level)
			return
		if LevelCatalogScript.has_level(next_level):
			store_requested.emit()
			return
	_restart()


func _clear_echoes() -> void:
	for child in echoes.get_children():
		(child as EchoPlayback).stop()
		child.queue_free()


func _clear_rifts() -> void:
	for child in rifts.get_children():
		child.queue_free()


func _clear_surprises() -> void:
	for child in surprises.get_children():
		child.stop()
		child.queue_free()


func _recursive_predecessor() -> Node2D:
	if echoes.get_child_count() > 0:
		return echoes.get_child(echoes.get_child_count() - 1) as Node2D
	return player


func _update_echo_pressure(segment_distance: float) -> void:
	var previous_pressure := _echo_pressure
	if segment_distance < _level.minimum_segment_distance:
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
	var next_phase := _world_stage
	if _run_time >= _level.pulse_phase_time:
		next_phase = maxi(next_phase, 3)
	elif _run_time >= _level.patrol_phase_time:
		next_phase = maxi(next_phase, 2)
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


func _update_surprise_sequence() -> void:
	while _next_surprise_event_index < _level.surprise_events.size():
		var event: Dictionary = _level.surprise_events[_next_surprise_event_index]
		if _run_time < float(event.time):
			return
		_spawn_surprise_event(event, _next_surprise_event_index + 1)
		_next_surprise_event_index += 1


func _spawn_surprise_event(event: Dictionary, event_index: int) -> void:
	var event_name := str(event.name)
	var warning := float(event.get("warning", 1.0))
	var duration := float(event.get("duration", 4.0))
	for obstacle_config in event.obstacles:
		var obstacle = SurpriseObstacleScript.new()
		obstacle.configure(obstacle_config, warning, duration, event_index, event_name)
		obstacle.set_palette(_level.visual_palette)
		obstacle.modulate.a = 0.42 if not OS.has_feature("headless") else 1.0
		surprises.add_child(obstacle)
		obstacle.armed.connect(_on_surprise_armed)
	_discovered_event_count = event_index
	_pattern_warning_time = warning
	pattern_warning_label.text = "MEMORIZA %02d/%02d // %s // %.1f S" % [event_index, _level.surprise_events.size(), event_name, warning]
	pattern_warning_label.add_theme_color_override("font_color", _level.visual_palette.warning)
	pattern_warning_label.modulate.a = 1.0
	pattern_warning_label.scale = Vector2.ONE * 0.88
	pattern_warning_label.pivot_offset = pattern_warning_label.size * 0.5
	pattern_warning_label.visible = true
	create_tween().tween_property(pattern_warning_label, "scale", Vector2.ONE, 0.18) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	feedback.play_hazard(player.global_position)
	_flash_screen(Color(1.0, 0.72, 0.18), 0.08, 0.22)
	_update_hud()


func _on_surprise_armed(obstacle) -> void:
	if _state != RunState.PLAYING or obstacle.beat_index == _last_armed_beat:
		return
	_last_armed_beat = obstacle.beat_index
	_pattern_warning_time = 0.75
	pattern_warning_label.text = "¡AHORA! // %02d // %s" % [obstacle.beat_index, obstacle.pattern_name]
	pattern_warning_label.add_theme_color_override("font_color", _level.visual_palette.danger)
	pattern_warning_label.modulate.a = 1.0
	pattern_warning_label.visible = true
	feedback.play_pulse(obstacle.global_position)
	_shake_camera(9.0, 0.22)
	_flash_screen(Color(1.0, 0.2, 0.16), 0.1, 0.2)
	settings_store.vibrate(45)


func _update_pattern_warning(delta: float) -> void:
	if _pattern_warning_time <= 0.0:
		return
	_pattern_warning_time = maxf(0.0, _pattern_warning_time - delta)
	if _pattern_warning_time < 0.35:
		pattern_warning_label.modulate.a = _pattern_warning_time / 0.35
	if _pattern_warning_time <= 0.0:
		pattern_warning_label.visible = false


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
	phase_label.text = "N%d S%d/3\nF%d CAD x%.1f" % [_level.number, _world_stage, _slow_offenses, _chain_pressure_multiplier]
	pattern_memory_label.text = "MEMORIA DEL NIVEL %02d/%02d" % [_discovered_event_count, _level.surprise_events.size()]
	_update_expansion_hud()


func _configure_arena_for_level() -> void:
	var profile: Dictionary = _level.arena_profile
	upper_obstacle.configure_geometry(profile.upper_position, profile.upper_size, profile.upper_rotation)
	lower_obstacle.configure_geometry(profile.lower_position, profile.lower_size, profile.lower_rotation)
	patrol_obstacle.configure_geometry(profile.patrol_position, profile.patrol_size)
	patrol_obstacle.movement_offset = profile.patrol_offset
	patrol_obstacle.movement_period = profile.patrol_period
	pulse_obstacle.configure_geometry(profile.pulse_position, profile.pulse_size, profile.pulse_rotation)
	pulse_obstacle.pulse_warning_duration = profile.pulse_warning
	pulse_obstacle.pulse_active_duration = profile.pulse_active
	pulse_obstacle.pulse_safe_duration = profile.pulse_safe


func _apply_visual_identity() -> void:
	var palette: Dictionary = _level.visual_palette
	arena.set_palette(palette)
	world_25d.set_palette(palette)
	atmosphere.set_palette(palette)
	feedback.set_palette(palette)
	for obstacle in [upper_obstacle, lower_obstacle, patrol_obstacle, pulse_obstacle]:
		(obstacle as ArenaObstacle).set_palette(palette)
	($UI/TopBar as ColorRect).color = Color(palette.void, 0.96)
	($UI/ExpansionStatus as ColorRect).color = Color(palette.void, 0.91)
	($UI/TopBar/Margin/Stats/Brand as Label).add_theme_color_override("font_color", palette.primary)
	time_label.add_theme_color_override("font_color", palette.primary.lightened(0.48))
	score_label.add_theme_color_override("font_color", palette.primary.lightened(0.48))
	echo_label.add_theme_color_override("font_color", palette.danger)
	phase_label.add_theme_color_override("font_color", palette.warning)
	expansion_label.add_theme_color_override("font_color", palette.secondary)
	pattern_memory_label.add_theme_color_override("font_color", palette.warning)
	result_kicker.add_theme_color_override("font_color", palette.secondary)
	pause_panel.add_theme_stylebox_override("panel", _result_panel_style(palette.secondary))
	pause_kicker.add_theme_color_override("font_color", palette.secondary)
	pause_title.add_theme_color_override("font_color", palette.primary.lightened(0.38))


func _setup_25d() -> void:
	world_25d.attach_run(self)
	if OS.has_feature("headless"):
		return
	world_25d.set_high_quality(settings_store.high_quality_25d)
	var display := Sprite2D.new()
	display.name = "World25DDisplay"
	display.texture = world_25d.get_texture()
	display.position = START_POSITION
	display.scale = Vector2.ONE * world_25d.display_scale()
	display.z_index = -30
	add_child(display)
	move_child(display, 0)
	arena.set_25d_enabled(true)
	player.modulate.a = 0.0
	for obstacle in [upper_obstacle, lower_obstacle, patrol_obstacle, pulse_obstacle]:
		(obstacle as ArenaObstacle).modulate.a = 0.0
		(obstacle as ArenaObstacle).set_process(false)


func _result_panel_style(accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(_level.visual_palette.void.lightened(0.08), 0.985)
	style.border_color = Color(accent, 0.88)
	style.set_border_width_all(3)
	style.set_corner_radius_all(26)
	style.content_margin_left = 42.0
	style.content_margin_top = 36.0
	style.content_margin_right = 42.0
	style.content_margin_bottom = 36.0
	style.shadow_color = Color(accent, 0.18)
	style.shadow_size = 22
	return style


func _shake_camera(intensity: float, duration: float) -> void:
	if is_instance_valid(_camera_tween):
		_camera_tween.kill()
	world_camera.offset = Vector2.ZERO
	_camera_tween = create_tween()
	var slice := duration / 5.0
	for target in [
		Vector2(intensity, -intensity * 0.45),
		Vector2(-intensity * 0.7, intensity * 0.55),
		Vector2(intensity * 0.4, -intensity * 0.3),
		Vector2(-intensity * 0.2, intensity * 0.18),
		Vector2.ZERO,
	]:
		_camera_tween.tween_property(world_camera, "offset", target, slice) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _grant_run_reward() -> int:
	if _reward_granted:
		return 0
	_reward_granted = true
	if _run_time < 10.0:
		return 0
	var reward := 1 + int(_score / 1000)
	if _current_phase >= 3:
		reward += 1
	reward += _world_stage - 1
	if _level_won and progress_store.complete_level(_level_number):
		reward += _level.first_clear_bonus
	progress_store.add_fragments(reward)
	return reward


func _configure_power_button() -> void:
	var power_id := progress_store.equipped_power
	power_button.visible = power_id != "none"
	power_button.disabled = power_id == "shield"
	match power_id:
		"pulse":
			power_button.text = "PULSO\nLISTO"
		"stabilizer":
			power_button.text = "ESTABILIZAR\nLISTO"
		"shield":
			power_button.text = "DESFASE\nAUTOMATICO"
		_:
			power_button.text = ""


func _on_power_pressed() -> void:
	if _state != RunState.PLAYING or _power_used:
		return
	match progress_store.equipped_power:
		"pulse":
			if echoes.get_child_count() == 0:
				_show_banner("PULSO // AUN NO HAY ECOS", Color(0.45, 0.8, 1.0), 1.2)
				return
			var echo := echoes.get_child(echoes.get_child_count() - 1) as EchoPlayback
			echo.stop()
			echo.queue_free()
			_echo_count = maxi(0, _echo_count - 1)
			_power_used = true
			_show_banner("PULSO // ECO DISIPADO", Color(0.45, 0.8, 1.0), 1.8)
		"stabilizer":
			if _echo_pressure == 0:
				_show_banner("ESTABILIZADOR // CADENA ESTABLE", Color(0.45, 0.8, 1.0), 1.2)
				return
			_echo_pressure = maxi(0, _echo_pressure - 3)
			_chain_pressure_multiplier = 1.0 + float(_echo_pressure) * CHAIN_PRESSURE_STEP
			_apply_chain_pressure()
			_power_used = true
			_show_banner("ESTABILIZADOR // CADENA x%.1f" % _chain_pressure_multiplier, Color(0.45, 1.0, 0.72), 1.8)
	if _power_used:
		power_button.disabled = true
		power_button.text = "PODER\nAGOTADO"
		feedback.play_phase(player.global_position)
		_flash_screen(Color(0.35, 0.72, 1.0), 0.1, 0.24)
		_update_hud()


func _ignore_or_absorb_hit(_source: Node) -> bool:
	if _power_invulnerability_time > 0.0:
		player.clear_danger_report()
		return true
	if progress_store.equipped_power != "shield" or _power_used:
		return false
	_power_used = true
	_power_invulnerability_time = 1.5
	player.clear_danger_report()
	power_button.text = "DESFASE\nAGOTADO"
	_show_banner("DESFASE // IMPACTO ABSORBIDO", Color(0.58, 0.72, 1.0), 2.0)
	feedback.play_phase(player.global_position)
	_flash_screen(Color(0.42, 0.58, 1.0), 0.14, 0.3)
	_update_hud()
	return true


func _offer_expansion_if_ready() -> void:
	if _world_stage >= 3 or _expansion_offered:
		return
	var threshold: int = EXPANSION_THRESHOLDS[_world_stage - 1]
	if _total_echo_count < threshold:
		return
	_expansion_offered = true
	_expansion_offer_time = EXPANSION_DECISION_TIME
	break_limit_button.visible = true
	break_limit_button.disabled = false
	_show_banner("SATURACION CRITICA // ROMPE EL LIMITE", Color(0.35, 0.72, 1.0), 2.6)
	_flash_screen(Color(0.25, 0.55, 1.0), 0.1, 0.35)


func _update_expansion_offer(delta: float) -> void:
	if not _expansion_offered:
		return
	_expansion_offer_time = maxf(0.0, _expansion_offer_time - delta)
	if _expansion_offer_time <= 0.0:
		_expand_world(false)


func _on_break_limit_pressed() -> void:
	if _state != RunState.PLAYING or not _expansion_offered:
		return
	_expand_world(true)


func _expand_world(manual: bool) -> void:
	if _world_stage >= 3:
		return
	_expansion_offered = false
	_expansion_offer_time = 0.0
	break_limit_button.visible = false
	_world_stage += 1
	if manual:
		_expansion_bonus += MANUAL_EXPANSION_BONUS

	var next_rect := arena.play_rect_for_stage(_world_stage)
	arena.set_expansion_stage(_world_stage)
	world_25d.set_arena_stage(_world_stage, true)
	_configure_boundaries(next_rect)
	world_camera.enabled = true
	var target_zoom := Vector2.ONE * arena.camera_zoom_for_stage(_world_stage)
	if is_instance_valid(_camera_zoom_tween):
		_camera_zoom_tween.kill()
	_camera_zoom_tween = create_tween()
	_camera_zoom_tween.tween_property(world_camera, "zoom", target_zoom, 0.9) \
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

	if _current_phase < _world_stage:
		_current_phase = _world_stage
		patrol_obstacle.set_progression_active(_current_phase >= 2)
		pulse_obstacle.set_progression_active(_current_phase >= 3)
	var danger_name := "PATRULLA LIBERADA" if _world_stage == 2 else "TORMENTA DE PULSO"
	var bonus_text := " // +%d" % MANUAL_EXPANSION_BONUS if manual else ""
	_show_banner("SECTOR %d ABIERTO // %s%s" % [_world_stage, danger_name, bonus_text], Color(0.45, 0.82, 1.0), 3.0)
	feedback.play_phase(player.global_position)
	_shake_camera(14.0, 0.46)
	_flash_screen(Color(0.25, 0.62, 1.0), 0.22, 0.7)
	settings_store.vibrate(110)
	_update_hud()


func _configure_boundaries(play_rect: Rect2) -> void:
	var thickness := 32.0
	var left := boundaries.get_node("Left") as StaticBody2D
	var right := boundaries.get_node("Right") as StaticBody2D
	var top := boundaries.get_node("Top") as StaticBody2D
	var bottom := boundaries.get_node("Bottom") as StaticBody2D
	left.position = Vector2(play_rect.position.x - thickness * 0.5, play_rect.get_center().y)
	right.position = Vector2(play_rect.end.x + thickness * 0.5, play_rect.get_center().y)
	top.position = Vector2(play_rect.get_center().x, play_rect.position.y - thickness * 0.5)
	bottom.position = Vector2(play_rect.get_center().x, play_rect.end.y + thickness * 0.5)
	(left.get_node("Collision") as CollisionShape2D).shape.size = Vector2(thickness, play_rect.size.y + thickness * 2.0)
	(right.get_node("Collision") as CollisionShape2D).shape.size = Vector2(thickness, play_rect.size.y + thickness * 2.0)
	(top.get_node("Collision") as CollisionShape2D).shape.size = Vector2(play_rect.size.x + thickness * 2.0, thickness)
	(bottom.get_node("Collision") as CollisionShape2D).shape.size = Vector2(play_rect.size.x + thickness * 2.0, thickness)


func _update_expansion_hud() -> void:
	if _world_stage >= 3:
		expansion_label.text = "MUNDO AL MAXIMO // SOBREVIVE A LA TORMENTA"
		expansion_meter.max_value = 1.0
		expansion_meter.value = 1.0
		return
	var threshold: int = EXPANSION_THRESHOLDS[_world_stage - 1]
	expansion_meter.max_value = threshold
	expansion_meter.value = mini(_total_echo_count, threshold)
	if _expansion_offered:
		expansion_label.text = "LIMITE LISTO // ABRIR EN %.1f S" % _expansion_offer_time
		break_limit_button.text = "ROMPER EL LIMITE  //  +%d PTS\nNUEVO SECTOR + NUEVO PELIGRO" % MANUAL_EXPANSION_BONUS
	else:
		expansion_label.text = "SECTOR %d // SATURACION %d/%d ECOS" % [_world_stage, _total_echo_count, threshold]
