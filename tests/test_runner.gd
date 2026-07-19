extends SceneTree

const TimelineScript = preload("res://scripts/gameplay/echo_timeline.gd")
const RunScene = preload("res://scenes/gameplay/run.tscn")
const AppScene = preload("res://scenes/app/main.tscn")

var _failures := 0
var _checks := 0


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_ensure_settings_store()
	_test_timeline_validation()
	_test_timeline_interpolation()
	_test_timeline_copy()
	await _test_app_navigation()
	await _test_responsive_layout()
	await _test_run_scene()
	await _test_arena_progression()
	await _test_echo_cap()
	await _test_rift_lifecycle()
	await _test_echo_pressure()
	await _test_physical_collisions()
	await _test_ten_run_cycles()

	if _failures > 0:
		push_error("Pruebas fallidas: %d de %d" % [_failures, _checks])
		quit(1)
		return

	print("Pruebas completadas: %d verificaciones" % _checks)
	quit()


func _ensure_settings_store() -> void:
	if root.get_node_or_null("Settings") != null:
		return
	var settings := SettingsStore.new()
	settings.name = "Settings"
	root.add_child(settings)


func _test_timeline_validation() -> void:
	var timeline = TimelineScript.new()
	_expect(timeline.sample_count() == 0, "una linea nueva esta vacia")
	_expect(not timeline.is_playable(), "una linea vacia no es reproducible")
	_expect(not timeline.add_sample(-0.1, Vector2.ZERO), "rechaza tiempo negativo")
	_expect(timeline.add_sample(0.0, Vector2.ZERO), "acepta la primera muestra")
	_expect(not timeline.add_sample(0.0, Vector2.ONE), "rechaza tiempo repetido")
	_expect(not timeline.add_sample(-1.0, Vector2.ONE), "rechaza tiempo fuera de orden")
	_expect(timeline.add_sample(1.0, Vector2(10.0, 0.0)), "acepta tiempo creciente")
	_expect(timeline.is_playable(), "dos muestras con duracion son reproducibles")


func _test_timeline_interpolation() -> void:
	var timeline = TimelineScript.new()
	timeline.add_sample(0.0, Vector2(0.0, 10.0))
	timeline.add_sample(1.0, Vector2(10.0, 20.0))
	timeline.add_sample(2.0, Vector2(30.0, 20.0))

	_expect(timeline.sample_at(-1.0).is_equal_approx(Vector2(0.0, 10.0)), "limita antes del inicio")
	_expect(timeline.sample_at(0.5).is_equal_approx(Vector2(5.0, 15.0)), "interpola el primer tramo")
	_expect(timeline.sample_at(1.5).is_equal_approx(Vector2(20.0, 20.0)), "interpola el segundo tramo")
	_expect(timeline.sample_at(3.0).is_equal_approx(Vector2(30.0, 20.0)), "limita despues del final")
	_expect(is_equal_approx(timeline.duration(), 2.0), "informa la duracion")
	_expect(is_equal_approx(timeline.travel_distance(), sqrt(200.0) + 20.0), "calcula la distancia total recorrida")
	var bounds := Rect2(10.0, 10.0, 180.0, 180.0)
	var anchored := timeline.transformed_to_anchor(Vector2(20.0, 20.0), bounds)
	_expect(anchored.sample_at(0.0).is_equal_approx(Vector2(20.0, 20.0)), "transforma la ruta desde una grieta")
	_expect(bounds.has_point(anchored.sample_at(2.0)), "mantiene la ruta transformada dentro de la arena")


func _test_timeline_copy() -> void:
	var original = TimelineScript.new()
	original.add_sample(0.0, Vector2.ZERO)
	original.add_sample(1.0, Vector2.ONE)
	var copy = original.duplicate_timeline()
	original.add_sample(2.0, Vector2(2.0, 2.0))

	_expect(copy.sample_count() == 2, "la copia conserva sus muestras")
	_expect(is_equal_approx(copy.duration(), 1.0), "la copia conserva su duracion")
	_expect(original.sample_count() == 3, "el original puede seguir grabando")


func _test_app_navigation() -> void:
	var app := AppScene.instantiate() as AppController
	root.add_child(app)
	await process_frame
	_expect(app.current_screen is MainMenu, "la aplicacion inicia en el menu")

	var menu := app.current_screen as MainMenu
	var tutorial_overlay := menu.get_node("TutorialOverlay") as ColorRect
	(menu.get_node("Content/Layout/Actions/Tutorial") as Button).pressed.emit()
	_expect(tutorial_overlay.visible, "el menu abre el tutorial")
	(menu.get_node("TutorialOverlay/Center/Panel/Content/Back") as Button).pressed.emit()
	_expect(not tutorial_overlay.visible, "el tutorial vuelve al menu")

	var settings_overlay := menu.get_node("SettingsOverlay") as ColorRect
	(menu.get_node("Content/Layout/Actions/Settings") as Button).pressed.emit()
	_expect(settings_overlay.visible, "el menu abre los ajustes")
	var settings_store := root.get_node("Settings") as SettingsStore
	var previous_volume := settings_store.master_volume
	var previous_vibration := settings_store.vibration_enabled
	var previous_sensitivity := settings_store.sensitivity
	var volume_slider := menu.get_node("SettingsOverlay/Center/Panel/Content/VolumeSlider") as HSlider
	var vibration_toggle := menu.get_node("SettingsOverlay/Center/Panel/Content/VibrationRow/Toggle") as CheckButton
	var sensitivity_slider := menu.get_node("SettingsOverlay/Center/Panel/Content/SensitivitySlider") as HSlider
	_expect(is_equal_approx(volume_slider.max_value, 1.0), "volumen usa una escala normalizada")
	volume_slider.value = 0.75
	vibration_toggle.button_pressed = false
	sensitivity_slider.value = 1.2
	_expect(is_equal_approx(settings_store.master_volume, 0.75), "ajustes cambia el volumen")
	_expect(not settings_store.vibration_enabled, "ajustes cambia la vibracion")
	_expect(is_equal_approx(settings_store.sensitivity, 1.2), "ajustes cambia la sensibilidad")
	settings_store.set_master_volume(previous_volume)
	settings_store.set_vibration_enabled(previous_vibration)
	settings_store.set_sensitivity(previous_sensitivity)
	(menu.get_node("SettingsOverlay/Center/Panel/Content/Back") as Button).pressed.emit()
	_expect(not settings_overlay.visible, "ajustes vuelve al menu")

	(menu.get_node("Content/Layout/Actions/Play") as Button).pressed.emit()
	await process_frame
	_expect(app.current_screen is RunController, "jugar abre una partida")

	var run := app.current_screen as RunController
	run._end_run("PRUEBA DE NAVEGACION")
	(run.get_node("UI/GameOver/Center/Panel/Content/Menu") as Button).pressed.emit()
	await process_frame
	_expect(app.current_screen is MainMenu, "el resultado vuelve al menu")
	app.queue_free()
	await process_frame


func _test_responsive_layout() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(720, 1600)
	root.add_child(viewport)
	var run := RunScene.instantiate() as RunController
	viewport.add_child(run)
	await process_frame
	run.set_physics_process(false)
	_expect(is_equal_approx(run.position.y, 160.0), "centra la arena en una pantalla 20:9")
	_expect(is_equal_approx(run.player.global_position.y, 810.0), "centra el inicio sin alterar coordenadas internas")
	var instruction := run.get_node("UI/Instruction") as Label
	_expect(instruction.position.y > 1400.0, "ancla la instruccion al borde inferior")
	run._physics_process(5.1)
	var responsive_echo := await _open_latest_rift(run)
	_expect(run._echo_bounds_global().has_point(responsive_echo.global_position), "la grieta conserva su posicion global en 20:9")
	viewport.queue_free()
	await process_frame


func _test_run_scene() -> void:
	var run = RunScene.instantiate()
	root.add_child(run)
	await process_frame
	run.set_physics_process(false)

	var player := run.get_node("Player") as CharacterBody2D
	var echoes := run.get_node("Echoes") as Node2D
	var feedback := run.get_node("Feedback") as GameplayFeedback
	var obstacle := run.get_node("Obstacles/Upper") as ArenaObstacle
	_expect(player != null, "la partida contiene al jugador")
	_expect(player.collision_layer == 1 and player.collision_mask == 4, "capas fisicas del jugador")
	_expect(obstacle.is_in_group("danger") and obstacle.collision_layer == 4, "obstaculo peligroso configurado")
	_expect(echoes.get_child_count() == 0, "la partida comienza sin ecos")
	var audio_ready := feedback.stream_data_size(GameplayFeedback.Cue.ECHO) > 0 \
		and feedback.stream_data_size(GameplayFeedback.Cue.RIFT) > 0 \
		and feedback.stream_data_size(GameplayFeedback.Cue.PHASE) > 0 \
		and feedback.stream_data_size(GameplayFeedback.Cue.PULSE) > 0 \
		and feedback.stream_data_size(GameplayFeedback.Cue.PRESSURE) > 0 \
		and feedback.stream_data_size(GameplayFeedback.Cue.HIT) > 0
	_expect(audio_ready, "genera los seis sonidos procedurales")

	run._physics_process(5.1)
	_expect(echoes.get_child_count() == 0 and run.rifts.get_child_count() == 1, "avisa la grieta antes de crear el eco")
	_expect(feedback.last_cue == GameplayFeedback.Cue.RIFT, "la grieta reproduce su sonido")
	var echo := await _open_latest_rift(run)
	_expect(echoes.get_child_count() == 1, "crea un eco al abrir la grieta")
	_expect(echo.collision_layer == 2 and echo.collision_mask == 1, "capas fisicas del eco")
	_expect(is_equal_approx(echo.playback_speed, 1.2), "un segmento inmovil acelera el primer eco")
	_expect(echo.mode == EchoPlayback.Mode.HUNTER, "un segmento inmovil crea un cazador")
	_expect(feedback.last_cue == GameplayFeedback.Cue.ECHO, "crear un eco reproduce su sonido")
	_expect(feedback.active_ring_count() > 0, "crear un eco genera una onda visual")

	run._end_run("PRUEBA")
	_expect(not player.movement_enabled, "el fin bloquea el movimiento")
	_expect(run.get_node("UI/GameOver").visible, "el fin muestra el resultado")
	_expect(feedback.last_cue == GameplayFeedback.Cue.HIT, "el impacto reproduce su sonido")
	_expect(run.get_node("UI/ImpactFlash").visible, "el impacto activa el flash visual")
	run._restart()
	await process_frame
	_expect(player.movement_enabled, "repetir reactiva el movimiento")
	_expect(not run.get_node("UI/GameOver").visible, "repetir oculta el resultado")
	_expect(echoes.get_child_count() == 0, "repetir limpia los ecos")
	_expect(run.rifts.get_child_count() == 0, "repetir limpia las grietas pendientes")
	_expect(feedback.active_ring_count() == 0, "repetir limpia las ondas visuales")
	run._physics_process(5.1)
	var stale_rift = run.rifts.get_child(0)
	stale_rift.set_physics_process(false)
	run._end_run("PRUEBA DE GRIETA")
	stale_rift._physics_process(RunController.RIFT_WARNING_TIME + 0.1)
	_expect(echoes.get_child_count() == 0, "una grieta no abre despues del fin")
	run.queue_free()
	await process_frame


func _test_arena_progression() -> void:
	var run := RunScene.instantiate() as RunController
	root.add_child(run)
	await process_frame
	run.set_physics_process(false)
	var upper := run.get_node("Obstacles/Upper") as ArenaObstacle
	var patrol := run.get_node("Obstacles/Patrol") as ArenaObstacle
	var pulse := run.get_node("Obstacles/Pulse") as ArenaObstacle
	var feedback := run.get_node("Feedback") as GameplayFeedback
	_expect(upper.kind == ArenaObstacle.Kind.STATIC, "la primera etapa usa barreras fijas")
	_expect(patrol.kind == ArenaObstacle.Kind.PATROL, "configura el obstaculo patrulla")
	_expect(pulse.kind == ArenaObstacle.Kind.PULSE, "configura el obstaculo de pulso")
	_expect(not patrol.progression_active and not patrol.visible, "la patrulla comienza inactiva")
	_expect(not pulse.progression_active and not pulse.visible, "el pulso comienza inactivo")

	run._run_time = RunController.PATROL_PHASE_TIME
	run._update_progression()
	_expect(patrol.progression_active and patrol.visible, "la segunda etapa activa la patrulla")
	_expect(not pulse.progression_active, "la segunda etapa mantiene el pulso inactivo")
	_expect(feedback.last_cue == GameplayFeedback.Cue.PHASE, "el cambio de etapa reproduce su sonido")
	_expect(run.get_node("UI/ImpactFlash").visible, "el cambio de etapa activa una transicion visual")
	await process_frame
	_expect(not patrol.collision_shape.disabled, "la patrulla activa su colision")
	run._update_hud()
	_expect((run.get_node("UI/TopBar/Margin/Stats/Phase") as Label).text == "ETAPA 2/3\nECO x1.0", "el HUD informa etapa y ritmo")
	var patrol_start := patrol.position
	patrol.set_physics_process(false)
	patrol._physics_process(1.0)
	_expect(not patrol.position.is_equal_approx(patrol_start), "la patrulla recorre la arena")

	run._run_time = RunController.PULSE_PHASE_TIME
	run._update_progression()
	_expect(pulse.progression_active and pulse.visible, "la tercera etapa activa el pulso")
	pulse.set_physics_process(false)
	pulse._physics_process(pulse.pulse_warning_duration + 0.1)
	_expect(pulse.collision_active, "el pulso se vuelve peligroso despues del aviso")
	_expect(feedback.last_cue == GameplayFeedback.Cue.PULSE, "el pulso peligroso emite una alerta")
	await process_frame
	_expect(not pulse.collision_shape.disabled, "el pulso peligroso activa su colision")
	pulse._physics_process(pulse.pulse_active_duration + 0.1)
	_expect(not pulse.collision_active, "el pulso abre una ventana segura")
	await process_frame
	_expect(pulse.collision_shape.disabled, "la ventana segura desactiva su colision")

	run._restart()
	await process_frame
	_expect(not patrol.progression_active and not pulse.progression_active, "repetir reinicia los obstaculos progresivos")
	_expect((run.get_node("UI/TopBar/Margin/Stats/Phase") as Label).text == "ETAPA 1/3\nECO x1.0", "repetir vuelve a la primera etapa")
	run.queue_free()
	await process_frame


func _test_echo_cap() -> void:
	var run := RunScene.instantiate() as RunController
	root.add_child(run)
	await process_frame
	run.set_physics_process(false)
	for _cycle in 6:
		run._physics_process(5.1)
		await _open_latest_rift(run)
	var echoes := run.get_node("Echoes") as Node2D
	_expect(echoes.get_child_count() == RunController.MAX_ACTIVE_ECHOES, "limita los ecos activos a cuatro")
	_expect((run.get_node("UI/TopBar/Margin/Stats/Echoes") as Label).text == "ECOS\n04/04", "el HUD muestra el limite de ecos")
	run._end_run("PRUEBA DE LIMITE")
	var result := (run.get_node("UI/GameOver/Center/Panel/Content/Result") as Label).text
	_expect(result.contains("ECOS CREADOS  06"), "el resultado conserva los ecos creados")
	run.queue_free()
	await process_frame


func _test_rift_lifecycle() -> void:
	var run := RunScene.instantiate() as RunController
	root.add_child(run)
	await process_frame
	run.set_physics_process(false)
	var origin := run.player.global_position
	run.player.global_position = origin + Vector2(320.0, 0.0)
	run._physics_process(5.1)
	var first_rift = run.rifts.get_child(0)
	var first_anchor: Vector2 = first_rift.global_position
	_expect(not first_rift.hunter, "un recorrido activo crea una grieta de trayectoria")
	_expect(not first_anchor.is_equal_approx(origin), "la grieta aparece lejos del origen del jugador")
	var trace := await _open_latest_rift(run)
	_expect(trace.mode == EchoPlayback.Mode.TRACE, "la grieta activa reproduce el recorrido")
	trace.set_physics_process(false)
	trace._physics_process(20.0)
	var trace_endpoint := trace.global_position
	_expect(trace.mode == EchoPlayback.Mode.RESONANCE, "la trayectoria termina como resonancia")
	trace._physics_process(0.5)
	_expect(trace.global_position.is_equal_approx(trace_endpoint), "la resonancia no vuelve al inicio")
	trace._physics_process(trace.resonance_duration)
	await process_frame
	await process_frame
	_expect(run.echoes.get_child_count() == 0, "la resonancia desaparece al terminar")

	run.player.global_position = origin + Vector2(-320.0, 0.0)
	run._physics_process(5.1)
	var second_rift = run.rifts.get_child(0)
	_expect(not second_rift.global_position.is_equal_approx(first_anchor), "las grietas no repiten el ancla anterior")
	run.queue_free()
	await process_frame


func _test_echo_pressure() -> void:
	var run := RunScene.instantiate() as RunController
	root.add_child(run)
	await process_frame
	run.set_physics_process(false)
	var feedback := run.get_node("Feedback") as GameplayFeedback
	run._update_echo_pressure(0.0)
	_expect(run._echo_pressure == 1, "un recorrido corto aumenta la presion")
	_expect(feedback.last_cue == GameplayFeedback.Cue.PRESSURE, "la presion reproduce una alerta")
	_expect((run.get_node("UI/PhaseBanner") as Label).text.contains("ECOS x1.2"), "la alerta explica la aceleracion")
	for _level in 5:
		run._update_echo_pressure(0.0)
	_expect(run._echo_pressure == 6, "la presion supera el antiguo limite")
	_expect(is_equal_approx(run._echo_speed_multiplier, 2.2), "la velocidad aumenta sin tope configurado")

	run._physics_process(5.1)
	var pending_rift = run.rifts.get_child(0)
	_expect(pending_rift.hunter, "el recorrido lento prepara un cazador")
	var echo := await _open_latest_rift(run)
	_expect(is_equal_approx(echo.playback_speed, 2.4), "el eco nuevo recibe toda la presion acumulada")
	var hunter_distance := echo.global_position.distance_to(run.player.global_position)
	echo.set_physics_process(false)
	echo._physics_process(0.25)
	_expect(echo.global_position.distance_to(run.player.global_position) < hunter_distance, "el cazador persigue al jugador")
	run._update_echo_pressure(500.0)
	_expect(run._echo_pressure == 6 and is_equal_approx(echo.playback_speed, 2.2), "moverse reduce la presion de ecos existentes")
	_expect((run.get_node("UI/PhaseBanner") as Label).text.contains("RITMO RECUPERADO"), "la recuperacion se comunica al jugador")
	for _level in 6:
		run._update_echo_pressure(500.0)
	_expect(run._echo_pressure == 0 and is_equal_approx(echo.playback_speed, 1.0), "la actividad recupera el ritmo normal")

	run._update_echo_pressure(0.0)
	run._restart()
	await process_frame
	_expect(run._echo_pressure == 0 and is_equal_approx(run._echo_speed_multiplier, 1.0), "repetir reinicia la presion")
	run.queue_free()
	await process_frame


func _test_physical_collisions() -> void:
	var danger_run = RunScene.instantiate()
	root.add_child(danger_run)
	await physics_frame
	danger_run.set_physics_process(false)
	var danger_player = danger_run.get_node("Player")
	danger_player.set_target(Vector2(210.0, 470.0))
	for _frame in 120:
		await physics_frame
		if danger_run.get_node("UI/GameOver").visible:
			break
	_expect(danger_run.get_node("UI/GameOver").visible, "chocar con un obstaculo termina la partida")
	_expect(danger_run.get_node("UI/GameOver/Center/Panel/Content/Result").text.begins_with("OBSTACULO"), "informa la causa obstaculo")
	danger_run.queue_free()
	await process_frame

	var boundary_run = RunScene.instantiate()
	root.add_child(boundary_run)
	await physics_frame
	boundary_run.set_physics_process(false)
	var boundary_player = boundary_run.get_node("Player")
	boundary_player.set_target(Vector2(-200.0, 650.0))
	for _frame in 120:
		await physics_frame
	_expect(boundary_player.global_position.x >= 69.0, "el limite izquierdo contiene al jugador")
	_expect(not boundary_run.get_node("UI/GameOver").visible, "tocar un limite no termina la partida")
	boundary_run.queue_free()
	await process_frame


func _test_ten_run_cycles() -> void:
	var completed_cycles := 0
	for cycle in 10:
		var run = RunScene.instantiate()
		root.add_child(run)
		await process_frame
		run.set_physics_process(false)
		run._physics_process(5.1)
		await _open_latest_rift(run)
		if run.get_node("Echoes").get_child_count() == 1:
			run._end_run("CICLO %d" % cycle)
			if run.get_node("UI/GameOver").visible:
				completed_cycles += 1
		run.queue_free()
		await process_frame
	_expect(completed_cycles == 10, "completa diez ciclos tecnicos consecutivos")


func _open_latest_rift(run: RunController) -> EchoPlayback:
	var rift = run.rifts.get_child(run.rifts.get_child_count() - 1)
	rift.set_physics_process(false)
	rift._physics_process(RunController.RIFT_WARNING_TIME + 0.1)
	await process_frame
	return run.echoes.get_child(run.echoes.get_child_count() - 1) as EchoPlayback


func _expect(condition: bool, description: String) -> void:
	_checks += 1
	if condition:
		print("[OK] %s" % description)
		return

	_failures += 1
	printerr("[FALLO] %s" % description)
