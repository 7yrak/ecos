extends SceneTree

const TimelineScript = preload("res://scripts/gameplay/echo_timeline.gd")
const LevelCatalogScript = preload("res://scripts/gameplay/level_catalog.gd")
const StoreCatalogScript = preload("res://scripts/app/store_catalog.gd")
const SurpriseObstacleScript = preload("res://scripts/gameplay/surprise_obstacle.gd")
const RunScene = preload("res://scenes/gameplay/run.tscn")
const AppScene = preload("res://scenes/app/main.tscn")

var _failures := 0
var _checks := 0
var _progress_snapshot: Dictionary


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_ensure_settings_store()
	_ensure_progress_store()
	_prepare_progress_fixture()
	_test_timeline_validation()
	_test_timeline_interpolation()
	_test_level_catalog()
	_test_progress_store()
	await _test_app_navigation()
	await _test_responsive_layout()
	await _test_run_scene()
	await _test_arena_progression()
	await _test_surprise_choreography()
	await _test_world_expansion()
	await _test_level_variants()
	await _test_recursive_echo_chain()
	await _test_level_completion()
	await _test_powers()
	await _test_rift_lifecycle()
	await _test_chain_compression()
	await _test_echo_pressure()
	await _test_physical_collisions()
	await _test_ten_run_cycles()

	if _failures > 0:
		_restore_progress_fixture()
		push_error("Pruebas fallidas: %d de %d" % [_failures, _checks])
		quit(1)
		return

	_restore_progress_fixture()
	print("Pruebas completadas: %d verificaciones" % _checks)
	quit()


func _ensure_settings_store() -> void:
	if root.get_node_or_null("Settings") != null:
		return
	var settings := SettingsStore.new()
	settings.name = "Settings"
	root.add_child(settings)


func _ensure_progress_store() -> void:
	if root.get_node_or_null("Progress") != null:
		return
	var progress := ProgressStore.new()
	progress.name = "Progress"
	root.add_child(progress)


func _prepare_progress_fixture() -> void:
	var progress := root.get_node("Progress") as ProgressStore
	_progress_snapshot = {
		"storage_path": progress.storage_path,
		"fragments": progress.fragments,
		"equipped_skin": progress.equipped_skin,
		"equipped_power": progress.equipped_power,
		"selected_level": progress.selected_level,
		"owned_skins": progress.owned_skins.duplicate(),
		"owned_powers": progress.owned_powers.duplicate(),
		"owned_levels": progress.owned_levels.duplicate(),
		"completed_levels": progress.completed_levels.duplicate(),
	}
	progress.storage_path = "user://progress_test_suite.cfg"
	_reset_progress_fixture()


func _reset_progress_fixture() -> void:
	var progress := root.get_node("Progress") as ProgressStore
	progress.fragments = 0
	progress.equipped_skin = "signal"
	progress.equipped_power = "none"
	progress.selected_level = 1
	progress.owned_skins = ["signal"]
	progress.owned_powers = ["none"]
	progress.owned_levels = [1]
	progress.completed_levels = []
	var test_path := ProjectSettings.globalize_path(progress.storage_path)
	if FileAccess.file_exists(test_path):
		DirAccess.remove_absolute(test_path)


func _restore_progress_fixture() -> void:
	var progress := root.get_node("Progress") as ProgressStore
	var test_path := ProjectSettings.globalize_path(progress.storage_path)
	if FileAccess.file_exists(test_path):
		DirAccess.remove_absolute(test_path)
	progress.storage_path = _progress_snapshot.storage_path
	progress.fragments = _progress_snapshot.fragments
	progress.equipped_skin = _progress_snapshot.equipped_skin
	progress.equipped_power = _progress_snapshot.equipped_power
	progress.selected_level = _progress_snapshot.selected_level
	progress.owned_skins = _progress_snapshot.owned_skins
	progress.owned_powers = _progress_snapshot.owned_powers
	progress.owned_levels = _progress_snapshot.owned_levels
	progress.completed_levels = _progress_snapshot.completed_levels


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


func _test_level_catalog() -> void:
	var level = LevelCatalogScript.get_level(1)
	_expect(level != null, "el catalogo contiene el nivel inicial")
	_expect(level.number == 1 and level.title == "PRIMERA ESTELA" and level.difficulty == "INICIAL", "el nivel declara identidad y dificultad")
	_expect(is_equal_approx(level.duration, 45.0), "el nivel inicial define su tiempo de victoria")
	_expect(is_equal_approx(level.echo_interval, 5.0), "el nivel controla la frecuencia de ecos")
	var level_two = LevelCatalogScript.get_level(2)
	var level_three = LevelCatalogScript.get_level(3)
	_expect(level_two != null and level_two.title == "CONTRACORRIENTE", "el catalogo incorpora una segunda etapa propia")
	_expect(level_three != null and level_three.title == "NUCLEO ROJO", "el catalogo incorpora una tercera etapa avanzada")
	_expect(level_two.duration == 55.0 and level_three.duration == 65.0, "cada etapa aumenta su objetivo temporal")
	_expect(level_two.echo_interval < level.echo_interval and level_three.echo_interval < level_two.echo_interval, "las etapas avanzadas aceleran la aparicion de ecos")
	_expect(level_two.arena_profile.upper_size != level.arena_profile.upper_size, "la segunda etapa cambia la geometria de la arena")
	_expect(level.visual_palette.has_all(["void", "arena", "primary", "secondary", "danger", "warning", "name", "background_path"]), "cada etapa declara una identidad visual completa")
	_expect(level.visual_palette.primary != level_two.visual_palette.primary, "Contracorriente cambia la paleta del mundo")
	_expect(level_two.visual_palette.primary != level_three.visual_palette.primary, "Nucleo Rojo presenta una identidad cromatica propia")
	_expect(ResourceLoader.exists(level.visual_palette.background_path) and ResourceLoader.exists(level_two.visual_palette.background_path) and ResourceLoader.exists(level_three.visual_palette.background_path), "las tres etapas tienen arte ambiental propio")
	_expect(level.surprise_events.size() == 6, "Primera Estela contiene seis sorpresas diseñadas")
	_expect(level_two.surprise_events.size() == 8, "Contracorriente contiene ocho sorpresas diseñadas")
	_expect(level_three.surprise_events.size() == 10, "Nucleo Rojo contiene diez sorpresas diseñadas")
	_expect(level.surprise_events == LevelCatalogScript.get_level(1).surprise_events, "la coreografia se repite sin aleatoriedad")
	for designed_level in [level, level_two, level_three]:
		var previous_time := 0.0
		for event in designed_level.surprise_events:
			_expect(event.time > previous_time and event.time < designed_level.duration, "cada sorpresa tiene un segundo fijo y ordenado")
			_expect(event.warning >= 0.65 and event.obstacles.size() > 0, "cada sorpresa avisa y deja una ruta disenada")
			previous_time = event.time
	_expect(LevelCatalogScript.level_count() == 9, "el catalogo incorpora nueve etapas")
	for level_number in range(4, 10):
		var extended_level = LevelCatalogScript.get_level(level_number)
		_expect(extended_level != null and extended_level.number == level_number, "la etapa %d se puede cargar" % level_number)
		_expect(extended_level.surprise_events.size() == level_number + 5, "la etapa %d agrega una coreografia extensa" % level_number)
		_expect(extended_level.surprise_events == LevelCatalogScript.get_level(level_number).surprise_events, "la etapa %d repite su memoria sin azar" % level_number)
		_expect(ResourceLoader.exists(extended_level.visual_palette.background_path), "la etapa %d tiene textura ambiental" % level_number)
	_expect(LevelCatalogScript.has_level(9) and not LevelCatalogScript.has_level(10), "el catalogo termina en la novena etapa")


func _test_progress_store() -> void:
	var progress := root.get_node("Progress") as ProgressStore
	_expect(StoreCatalogScript.SKINS.size() == 4, "la tienda ofrece cuatro skins")
	_expect(StoreCatalogScript.STAGES.size() == 9, "la tienda ofrece nueve etapas")
	_expect(StoreCatalogScript.POWERS.size() == 4, "la tienda ofrece tres poderes y la opcion sin poder")
	_expect(progress.owns("skins", "signal") and progress.owns("stages", "level_1"), "el progreso comienza con skin y etapa iniciales")
	progress.add_fragments(30)
	_expect(progress.purchase("skins", "ember"), "permite comprar una skin con Fragmentos")
	_expect(progress.equipped_skin == "ember" and progress.fragments == 0, "la compra equipa la skin y descuenta su costo")
	_expect(not progress.purchase("stages", "level_2"), "impide comprar contenido sin saldo suficiente")
	progress.add_fragments(20)
	_expect(progress.purchase("stages", "level_2"), "permite desbloquear la segunda etapa")
	_expect(progress.selected_level == 2 and progress.is_level_owned(2), "una etapa comprada queda seleccionada")
	progress.add_fragments(35)
	_expect(progress.purchase("powers", "pulse"), "permite comprar un poder permanente")
	_expect(progress.equipped_power == "pulse" and progress.owns("powers", "pulse"), "el poder comprado queda equipado")
	var saved := ConfigFile.new()
	_expect(saved.load(progress.storage_path) == OK, "el progreso se guarda en disco")
	_expect(saved.get_value("loadout", "skin") == "ember" and saved.get_value("loadout", "level") == 2, "el guardado conserva equipamiento y etapa")
	_reset_progress_fixture()


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

	var store_overlay := menu.get_node("StoreOverlay") as StoreOverlay
	(menu.get_node("Content/Layout/Actions/Store") as Button).pressed.emit()
	await process_frame
	_expect(store_overlay.visible, "el menu abre la tienda")
	_expect((store_overlay.get_node("Center/Panel/Content/List/Cards") as VBoxContainer).get_child_count() == 4, "la tienda muestra el catalogo de skins")
	(store_overlay.get_node("Center/Panel/Content/Tabs/Stages") as Button).pressed.emit()
	await process_frame
	_expect((store_overlay.get_node("Center/Panel/Content/List/Cards") as VBoxContainer).get_child_count() == 9, "la tienda cambia al catalogo de nueve etapas")
	var stage_list := store_overlay.get_node("Center/Panel/Content/List") as ScrollContainer
	var stage_cards := store_overlay.get_node("Center/Panel/Content/List/Cards") as VBoxContainer
	var first_stage_action_wrapper := stage_cards.get_child(0).get_child(0).get_child(2) as Control
	var first_stage_action := first_stage_action_wrapper.get_child(0) as Button
	var first_stage_touch_action = first_stage_action_wrapper.get_child(1)
	_expect(stage_list.scroll_deadzone == 8 and stage_cards.mouse_filter == Control.MOUSE_FILTER_IGNORE, "la lista acepta arrastre tactil sobre las tarjetas")
	_expect(first_stage_action.mouse_filter == Control.MOUSE_FILTER_IGNORE and first_stage_touch_action.mouse_filter == Control.MOUSE_FILTER_PASS, "los botones permiten deslizar sin bloquear la lista")
	var tapped_count := [0]
	first_stage_touch_action.tapped.connect(func(): tapped_count[0] += 1)
	var touch_press := InputEventScreenTouch.new()
	touch_press.index = 4
	touch_press.pressed = true
	touch_press.position = Vector2(80.0, 40.0)
	first_stage_touch_action._gui_input(touch_press)
	var touch_drag := InputEventScreenDrag.new()
	touch_drag.index = 4
	touch_drag.position = Vector2(80.0, 5.0)
	first_stage_touch_action._gui_input(touch_drag)
	var touch_release := InputEventScreenTouch.new()
	touch_release.index = 4
	touch_release.pressed = false
	touch_release.position = Vector2(80.0, 5.0)
	first_stage_touch_action._gui_input(touch_release)
	_expect(tapped_count[0] == 0, "arrastrar sobre un boton no compra ni selecciona accidentalmente")
	var tap_press := InputEventScreenTouch.new()
	tap_press.index = 5
	tap_press.pressed = true
	tap_press.position = Vector2(80.0, 40.0)
	first_stage_touch_action._gui_input(tap_press)
	var tap_release := InputEventScreenTouch.new()
	tap_release.index = 5
	tap_release.pressed = false
	tap_release.position = Vector2(82.0, 42.0)
	first_stage_touch_action._gui_input(tap_release)
	_expect(tapped_count[0] == 1, "un toque corto conserva la accion de comprar o seleccionar")
	(store_overlay.get_node("Center/Panel/Content/Tabs/Powers") as Button).pressed.emit()
	await process_frame
	_expect((store_overlay.get_node("Center/Panel/Content/List/Cards") as VBoxContainer).get_child_count() == 4, "la tienda cambia al catalogo de poderes")
	(store_overlay.get_node("Center/Panel/Content/Back") as Button).pressed.emit()
	_expect(not store_overlay.visible, "la tienda vuelve al menu")

	var settings_overlay := menu.get_node("SettingsOverlay") as ColorRect
	(menu.get_node("Content/Layout/Actions/Settings") as Button).pressed.emit()
	_expect(settings_overlay.visible, "el menu abre los ajustes")
	var settings_store := root.get_node("Settings") as SettingsStore
	var previous_volume := settings_store.master_volume
	var previous_vibration := settings_store.vibration_enabled
	var previous_sensitivity := settings_store.sensitivity
	var previous_quality := settings_store.high_quality_25d
	var volume_slider := menu.get_node("SettingsOverlay/Center/Panel/Content/VolumeSlider") as HSlider
	var vibration_toggle := menu.get_node("SettingsOverlay/Center/Panel/Content/VibrationRow/Toggle") as CheckButton
	var sensitivity_slider := menu.get_node("SettingsOverlay/Center/Panel/Content/SensitivitySlider") as HSlider
	var quality_toggle := menu.get_node("SettingsOverlay/Center/Panel/Content/QualityRow/Toggle") as CheckButton
	_expect(is_equal_approx(volume_slider.max_value, 1.0), "volumen usa una escala normalizada")
	volume_slider.value = 0.75
	vibration_toggle.button_pressed = false
	sensitivity_slider.value = 1.2
	quality_toggle.button_pressed = false
	_expect(is_equal_approx(settings_store.master_volume, 0.75), "ajustes cambia el volumen")
	_expect(not settings_store.vibration_enabled, "ajustes cambia la vibracion")
	_expect(is_equal_approx(settings_store.sensitivity, 1.2), "ajustes cambia la sensibilidad")
	_expect(not settings_store.high_quality_25d, "ajustes cambia la calidad 2.5D")
	settings_store.set_master_volume(previous_volume)
	settings_store.set_vibration_enabled(previous_vibration)
	settings_store.set_sensitivity(previous_sensitivity)
	settings_store.set_high_quality_25d(previous_quality)
	(menu.get_node("SettingsOverlay/Center/Panel/Content/Back") as Button).pressed.emit()
	_expect(not settings_overlay.visible, "ajustes vuelve al menu")

	(menu.get_node("Content/Layout/Actions/Play") as Button).pressed.emit()
	await process_frame
	_expect(app.current_screen is RunController, "jugar abre una partida")

	var active_run := app.current_screen as RunController
	active_run.pause_button.pressed.emit()
	_expect(paused and active_run.pause_overlay.visible, "pausar detiene la partida y abre sus opciones")
	active_run.pause_continue_button.pressed.emit()
	_expect(not paused and not active_run.pause_overlay.visible, "continuar reanuda la partida")
	active_run.pause_button.pressed.emit()
	active_run.pause_menu_button.pressed.emit()
	await process_frame
	_expect(app.current_screen is MainMenu and not paused, "la pausa permite salir al menu sin perder")
	menu = app.current_screen as MainMenu
	menu.play_button.pressed.emit()
	await process_frame

	var run := app.current_screen as RunController
	run.set_physics_process(false)
	run._run_time = run._level.duration - 0.1
	run._physics_process(0.2)
	(run.restart_button as Button).pressed.emit()
	await process_frame
	_expect(app.current_screen is MainMenu and (app.current_screen as MainMenu).store_overlay.visible, "un nivel bloqueado abre la tienda desde el resultado")
	_expect(((app.current_screen as MainMenu).store_overlay.stages_button as Button).disabled, "el acceso desde el resultado abre la categoria de etapas")
	(app.current_screen as MainMenu).store_overlay.close()
	((app.current_screen as MainMenu).play_button as Button).pressed.emit()
	await process_frame
	run = app.current_screen as RunController
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
	_expect(responsive_echo.global_position.is_equal_approx(run.to_global(RunController.START_POSITION)), "el eco conserva el origen real en 20:9")
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
	var world_25d := run.get_node("World25D") as World25D
	_expect(player != null, "la partida contiene al jugador")
	_expect(world_25d != null and world_25d.size == Vector2i(720, 1280), "la partida incorpora el mundo 2.5D sincronizado")
	_expect(is_equal_approx(world_25d.display_scale(), 1.0 / World25D.FINAL_ZOOM), "el mundo 2.5D conserva la escala de expansion")
	var visual_capabilities := world_25d.visual_capabilities()
	_expect(visual_capabilities.has("deep_3d_arena"), "la arena declara arquitectura 3D profunda")
	_expect(visual_capabilities.has("physical_stage_expansion"), "la expansion levanta placas y puentes fisicos")
	_expect(visual_capabilities.has("generational_holographic_echoes"), "los ecos usan hologramas por generacion")
	_expect(visual_capabilities.has("animated_obstacle_reveals"), "los obstaculos tienen apariciones tridimensionales")
	_expect(visual_capabilities.has("reactive_touch_floor"), "el suelo responde al tacto y al movimiento")
	world_25d.set_high_quality(false)
	_expect(world_25d.size == Vector2i(540, 960), "el modo rendimiento reduce la resolucion 3D")
	_expect(is_equal_approx(world_25d.display_scale(), (1.0 / World25D.FINAL_ZOOM) * 4.0 / 3.0), "el modo rendimiento conserva el encuadre")
	world_25d.set_high_quality(true)
	run.pause_button.pressed.emit()
	_expect(paused and run.pause_overlay.visible, "el boton de pausa esta disponible durante el intento")
	run.pause_restart_button.pressed.emit()
	_expect(not paused and is_zero_approx(run._run_time), "reiniciar desde pausa comienza la etapa de nuevo")
	_expect(player.collision_layer == 1 and player.collision_mask == 4, "capas fisicas del jugador")
	_expect(obstacle.is_in_group("danger") and obstacle.collision_layer == 4, "obstaculo peligroso configurado")
	_expect(echoes.get_child_count() == 0, "la partida comienza sin ecos")
	var audio_ready := feedback.stream_data_size(GameplayFeedback.Cue.ECHO) > 0 \
		and feedback.stream_data_size(GameplayFeedback.Cue.RIFT) > 0 \
		and feedback.stream_data_size(GameplayFeedback.Cue.PHASE) > 0 \
		and feedback.stream_data_size(GameplayFeedback.Cue.PULSE) > 0 \
		and feedback.stream_data_size(GameplayFeedback.Cue.PRESSURE) > 0 \
		and feedback.stream_data_size(GameplayFeedback.Cue.HIT) > 0 \
		and feedback.stream_data_size(GameplayFeedback.Cue.HAZARD) > 0
	_expect(audio_ready, "genera los siete sonidos procedurales")

	run._physics_process(5.1)
	_expect(echoes.get_child_count() == 0 and run.rifts.get_child_count() == 1, "avisa la grieta antes de crear el eco")
	_expect(run.rifts.get_child(0).global_position.is_equal_approx(player.global_position), "avisa en el origen real del segmento")
	_expect(feedback.last_cue == GameplayFeedback.Cue.RIFT, "la grieta reproduce su sonido")
	var echo := await _open_latest_rift(run)
	_expect(echoes.get_child_count() == 1, "crea un eco al abrir la grieta")
	_expect(echo.collision_layer == 2 and echo.collision_mask == 1, "capas fisicas del eco")
	_expect(is_equal_approx(echo.pressure_multiplier, 1.2), "un segmento inmovil comprime el retraso del primer eco")
	_expect(echo.mode == EchoPlayback.Mode.FOLLOWER, "todos los ecos usan seguimiento retardado")
	_expect(echo.follow_target() == player, "el primer eco sigue al jugador")
	_expect(echo.pressured, "un segmento inmovil marca el eco como presionado")
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

	run._run_time = run._level.patrol_phase_time
	run._update_progression()
	_expect(patrol.progression_active and patrol.visible, "la segunda etapa activa la patrulla")
	_expect(not pulse.progression_active, "la segunda etapa mantiene el pulso inactivo")
	_expect(feedback.last_cue == GameplayFeedback.Cue.PHASE, "el cambio de etapa reproduce su sonido")
	_expect(run.get_node("UI/ImpactFlash").visible, "el cambio de etapa activa una transicion visual")
	await process_frame
	_expect(not patrol.collision_shape.disabled, "la patrulla activa su colision")
	run._update_hud()
	_expect((run.get_node("UI/TopBar/Margin/Stats/Phase") as Label).text == "N1 S1/3\nF0 CAD x1.0", "el HUD informa nivel, sector, faltas y ritmo")
	var patrol_start := patrol.position
	patrol.set_physics_process(false)
	patrol._physics_process(1.0)
	_expect(not patrol.position.is_equal_approx(patrol_start), "la patrulla recorre la arena")

	run._run_time = run._level.pulse_phase_time
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
	_expect((run.get_node("UI/TopBar/Margin/Stats/Phase") as Label).text == "N1 S1/3\nF0 CAD x1.0", "repetir limpia sectores y faltas de ritmo")
	run.queue_free()
	await process_frame


func _test_world_expansion() -> void:
	var run := RunScene.instantiate() as RunController
	root.add_child(run)
	await process_frame
	run.set_physics_process(false)
	var initial_rect: Rect2 = run.arena.play_rect_for_stage(1)
	var initial_right := run.boundaries.get_node("Right") as StaticBody2D

	for _cycle in 3:
		run._physics_process(run._level.echo_interval + 0.1)
		await _open_latest_rift(run, true)
	_expect(run._expansion_offered, "tres ecos saturan el primer sector")
	_expect(run.break_limit_button.visible, "la saturacion ofrece romper el limite")
	_expect((run.expansion_label as Label).text.contains("LIMITE LISTO"), "el HUD convierte la saturacion en una decision")
	(run.break_limit_button as Button).pressed.emit()
	await process_frame
	_expect(run._world_stage == 2, "romper el limite abre el segundo sector")
	_expect(run.world_camera.enabled and run.world_camera.zoom.x < 1.0, "la expansion aleja la camara")
	_expect(initial_right.position.x > initial_rect.end.x and initial_right.position.x > 800.0, "los limites fisicos se desplazan y crean espacio real")
	_expect(run.patrol_obstacle.progression_active, "el nuevo sector libera una patrulla")
	_expect(run._expansion_bonus == RunController.MANUAL_EXPANSION_BONUS, "decidir a tiempo entrega una recompensa")

	for _cycle in 3:
		run._physics_process(run._level.echo_interval + 0.1)
		await _open_latest_rift(run, true)
	_expect(run._expansion_offered, "seis ecos saturan el segundo sector")
	run._expand_world(false)
	_expect(run._world_stage == 3, "la saturacion termina abriendo automaticamente el mundo completo")
	_expect(run.pulse_obstacle.progression_active, "el sector final libera la tormenta de pulso")
	_expect((run.expansion_label as Label).text.contains("MUNDO AL MAXIMO"), "el HUD celebra la expansion total")
	run._restart()
	await process_frame
	_expect(run._world_stage == 1 and run.world_camera.enabled and is_equal_approx(run.world_camera.zoom.x, 1.0), "repetir restaura el mundo inicial")
	run.queue_free()
	await process_frame


func _test_surprise_choreography() -> void:
	var run := RunScene.instantiate() as RunController
	root.add_child(run)
	await process_frame
	run.set_physics_process(false)
	var first_event: Dictionary = run._level.surprise_events[0]
	_expect(run.surprises.get_child_count() == 0, "la secuencia comienza sin sorpresas adelantadas")
	run._run_time = first_event.time - 0.1
	run._update_surprise_sequence()
	_expect(run.surprises.get_child_count() == 0, "el obstaculo no aparece antes de su segundo fijo")
	run._run_time = first_event.time
	run._update_surprise_sequence()
	_expect(run.surprises.get_child_count() == first_event.obstacles.size(), "el segundo exacto revela la composicion disenada")
	var obstacle = run.surprises.get_child(0)
	obstacle.set_physics_process(false)
	_expect(obstacle.state == 0 and not obstacle.collision_active, "la sorpresa comienza como aviso no letal")
	_expect(obstacle.is_in_group("danger") and obstacle.collision_layer == 4, "el obstaculo usa las capas fisicas de peligro")
	_expect(run.pattern_warning_label.visible and run.pattern_warning_label.text.contains("CORTE FANTASMA"), "el HUD nombra el patron que debe memorizarse")
	_expect(run.feedback.last_cue == GameplayFeedback.Cue.HAZARD, "el aviso tiene una alerta sonora propia")
	_expect(run.pattern_memory_label.text.contains("01/06"), "el HUD registra el patron descubierto")

	obstacle._physics_process(obstacle.warning_duration + 0.05)
	await process_frame
	_expect(obstacle.state == 1 and obstacle.collision_active, "el obstaculo se arma solo despues del aviso")
	_expect(not (obstacle.get_node("Collision") as CollisionShape2D).disabled, "la colision se activa al terminar la cuenta regresiva")
	_expect(run.pattern_warning_label.text.contains("¡AHORA!"), "la activacion comunica el momento que debe recordarse")
	obstacle._physics_process(obstacle.active_duration + 0.05)
	await process_frame
	_expect(obstacle.state == 2 and not obstacle.collision_active, "el patron se retira despues de su duracion fija")
	obstacle._physics_process(0.5)
	await process_frame
	_expect(not is_instance_valid(obstacle), "la sorpresa desaparece al completar su coreografia")

	var sweep_event: Dictionary = run._level.surprise_events[2]
	var sweep = SurpriseObstacleScript.new()
	sweep.configure(sweep_event.obstacles[0], sweep_event.warning, sweep_event.duration, 3, sweep_event.name)
	run.surprises.add_child(sweep)
	await process_frame
	sweep.set_physics_process(false)
	var sweep_origin: Vector2 = sweep.position
	sweep._physics_process(sweep.warning_duration + 0.01)
	sweep._physics_process(sweep.active_duration * 0.5)
	_expect(not sweep.position.is_equal_approx(sweep_origin), "los barridos recorren siempre la trayectoria declarada")

	run._restart()
	await process_frame
	_expect(run.surprises.get_child_count() == 0 and run._next_surprise_event_index == 0, "repetir reinicia la secuencia desde el primer descubrimiento")
	_expect(run.pattern_memory_label.text.contains("00/06"), "repetir limpia la memoria visible del nivel")
	run.queue_free()
	await process_frame


func _test_level_variants() -> void:
	var level_two_run := RunScene.instantiate() as RunController
	level_two_run.configure_level(2)
	root.add_child(level_two_run)
	await process_frame
	level_two_run.set_physics_process(false)
	_expect(level_two_run._level_number == 2 and level_two_run._level.title == "CONTRACORRIENTE", "la partida carga la segunda etapa solicitada")
	_expect(level_two_run.upper_obstacle.obstacle_size == Vector2(34.0, 230.0), "Contracorriente usa corredores verticales")
	_expect(level_two_run.patrol_obstacle.movement_offset == Vector2(230.0, 0.0), "Contracorriente mueve la patrulla en horizontal")
	_expect(level_two_run.pulse_obstacle.obstacle_size == Vector2(32.0, 330.0), "Contracorriente activa una compuerta de pulso vertical")
	level_two_run._run_time = level_two_run._level.patrol_phase_time
	level_two_run._update_progression()
	level_two_run._update_hud()
	_expect((level_two_run.phase_label as Label).text.begins_with("N2 S1/3"), "el HUD identifica el nivel y su sector actual")
	level_two_run.queue_free()
	await process_frame

	var level_three_run := RunScene.instantiate() as RunController
	level_three_run.configure_level(3)
	root.add_child(level_three_run)
	await process_frame
	level_three_run.set_physics_process(false)
	_expect(level_three_run._level_number == 3 and level_three_run._level.difficulty == "AVANZADA", "la partida carga la tercera etapa avanzada")
	_expect(not is_zero_approx(level_three_run.upper_obstacle.rotation), "Nucleo Rojo inclina sus barreras fijas")
	_expect(level_three_run.patrol_obstacle.movement_offset == Vector2(0.0, 250.0), "Nucleo Rojo cambia la patrulla al eje vertical")
	_expect(level_three_run._level.echo_interval == 4.0 and level_three_run._level.follow_delay == 1.05, "Nucleo Rojo comprime ritmo y retraso de ecos")
	level_three_run.queue_free()
	await process_frame

	for level_number in range(4, 10):
		var extended_run := RunScene.instantiate() as RunController
		extended_run.configure_level(level_number)
		root.add_child(extended_run)
		await process_frame
		extended_run.set_physics_process(false)
		_expect(extended_run._level_number == level_number, "la partida carga la etapa %d" % level_number)
		_expect(extended_run._level.visual_palette.has("surface_style"), "la etapa %d define materiales 2.5D" % level_number)
		var first_extended_event: Dictionary = extended_run._level.surprise_events[0]
		extended_run._run_time = float(first_extended_event.time) + 0.01
		extended_run._update_surprise_sequence()
		_expect(extended_run.surprises.get_child_count() > 0, "la etapa %d ejecuta su primera sorpresa" % level_number)
		extended_run.queue_free()
		await process_frame


func _test_recursive_echo_chain() -> void:
	var run := RunScene.instantiate() as RunController
	root.add_child(run)
	await process_frame
	run.set_physics_process(false)
	var predecessor: Node2D = run.player
	for cycle in 6:
		run._physics_process(5.1)
		var rift = run.rifts.get_child(run.rifts.get_child_count() - 1)
		_expect(rift.predecessor == predecessor, "la grieta %d nace del ultimo miembro de la cadena" % (cycle + 1))
		var spawn_position: Vector2 = predecessor.global_position
		var echo := await _open_latest_rift(run, true)
		_expect(echo.global_position.is_equal_approx(spawn_position), "el eco %d aparece donde estaba su predecesor" % (cycle + 1))
		_expect(echo.generation == cycle + 1, "la cadena conserva el orden generacional")
		_expect(echo.mode == EchoPlayback.Mode.FOLLOWER, "cada generacion permanece en seguimiento")
		_expect(echo.follow_target() == predecessor, "cada eco sigue directamente a su predecesor")
		predecessor = echo
	var echoes := run.get_node("Echoes") as Node2D
	_expect(echoes.get_child_count() == 6, "la cantidad de ecos activos supera el antiguo limite")
	_expect((run.get_node("UI/TopBar/Margin/Stats/Echoes") as Label).text == "ECOS\n06", "el HUD muestra la cadena sin un maximo")
	run._end_run("PRUEBA DE CADENA")
	var result := (run.get_node("UI/GameOver/Center/Panel/Content/Result") as Label).text
	_expect(result.contains("ECOS CREADOS  06"), "el resultado conserva los ecos creados")
	run.queue_free()
	await process_frame


func _test_level_completion() -> void:
	_reset_progress_fixture()
	var run := RunScene.instantiate() as RunController
	root.add_child(run)
	await process_frame
	run.set_physics_process(false)
	run._run_time = run._level.duration - 0.1
	run._physics_process(0.2)
	_expect(run._state == RunController.RunState.GAME_OVER and run._level_won, "alcanzar el tiempo objetivo completa el nivel")
	_expect((run.result_title as Label).text == "NIVEL SUPERADO", "la victoria tiene un resultado diferente a la colision")
	_expect((run.result_label as Label).text.contains("OBJETIVO DE TIEMPO CUMPLIDO"), "el resultado explica la condicion de victoria")
	_expect((run.restart_button as Button).text == "DESBLOQUEAR EN TIENDA", "una etapa siguiente bloqueada dirige a la tienda")
	_expect((run.result_label as Label).text.contains("+22 FRAGMENTOS"), "la primera victoria suma recompensa base, etapa y bono")
	_expect((root.get_node("Progress") as ProgressStore).fragments == 22, "la recompensa queda en la billetera local")
	run._restart()
	await process_frame
	_expect(run._state == RunController.RunState.PLAYING and is_zero_approx(run._run_time), "repetir reinicia el mismo nivel")
	run.queue_free()
	await process_frame
	_reset_progress_fixture()


func _test_powers() -> void:
	var progress := root.get_node("Progress") as ProgressStore
	progress.equipped_power = "pulse"
	var run := RunScene.instantiate() as RunController
	root.add_child(run)
	await process_frame
	run.set_physics_process(false)
	run._physics_process(5.1)
	await _open_latest_rift(run)
	(run.power_button as Button).pressed.emit()
	await process_frame
	_expect(run._power_used and run.echoes.get_child_count() == 0, "Pulso disipa el eco mas reciente una vez por partida")
	_expect((run.power_button as Button).disabled, "Pulso queda agotado despues de usarlo")

	progress.equipped_power = "stabilizer"
	run._restart()
	await process_frame
	run._update_echo_pressure(0.0)
	run._update_echo_pressure(0.0)
	(run.power_button as Button).pressed.emit()
	_expect(run._power_used and run._echo_pressure == 0, "Estabilizador reduce hasta tres niveles de presion")
	_expect(is_equal_approx(run._chain_pressure_multiplier, 1.0), "Estabilizador vuelve a abrir la cadena")

	progress.equipped_power = "shield"
	run._restart()
	await process_frame
	run._on_player_danger_hit(run.upper_obstacle)
	_expect(run._state == RunController.RunState.PLAYING and run._power_used, "Desfase absorbe automaticamente el primer impacto")
	run._power_invulnerability_time = 0.0
	run._on_player_danger_hit(run.upper_obstacle)
	_expect(run._state == RunController.RunState.GAME_OVER, "Desfase no absorbe un segundo impacto")
	run.queue_free()
	await process_frame
	_reset_progress_fixture()


func _test_rift_lifecycle() -> void:
	var run := RunScene.instantiate() as RunController
	root.add_child(run)
	await process_frame
	run.set_physics_process(false)
	var origin := run.player.global_position
	var endpoint := origin + Vector2(120.0, 0.0)
	var midpoint := origin + Vector2(60.0, -180.0)
	run._timeline.add_sample(2.5, midpoint)
	run._timeline.add_sample(5.0, endpoint)
	run.player.global_position = endpoint
	run._segment_time = 5.0
	run._spawn_echo()
	var first_rift = run.rifts.get_child(0)
	_expect(not first_rift.pressured, "un recorrido activo conserva la distancia normal")
	_expect(first_rift.predecessor == run.player, "el jugador inicia la primera generacion")
	_expect(first_rift.global_position.is_equal_approx(endpoint), "la primera grieta sigue la posicion actual del jugador")
	var first := await _open_latest_rift(run, true)
	_expect(first.mode == EchoPlayback.Mode.FOLLOWER, "la grieta crea un perseguidor con memoria")
	_expect(first.follow_target() == run.player, "la primera generacion sigue al jugador")
	_expect(first.global_position.is_equal_approx(endpoint), "el primer eco nace donde se encuentra el jugador")

	var player_step_one := endpoint + Vector2(140.0, -80.0)
	run.player.global_position = player_step_one
	first._physics_process(0.6)
	_expect(first.global_position.is_equal_approx(endpoint), "el eco espera su retraso antes de perseguir")
	var player_step_two := endpoint + Vector2(-120.0, -40.0)
	run.player.global_position = player_step_two
	first._physics_process(0.7)
	_expect(not first.global_position.is_equal_approx(endpoint), "el eco comienza a recorrer la memoria del jugador")
	_expect(not first.global_position.is_equal_approx(player_step_two), "el seguimiento mantiene distancia temporal")
	var player_step_three := endpoint + Vector2(80.0, 160.0)
	run.player.global_position = player_step_three
	first._physics_process(1.2)
	_expect(first.global_position.is_equal_approx(player_step_two), "el eco alcanza una posicion pasada exacta del jugador")

	run._timeline.add_sample(2.5, endpoint - Vector2(150.0, 80.0))
	run._timeline.add_sample(5.0, endpoint - Vector2(300.0, 0.0))
	run._segment_time = 5.0
	run._spawn_echo()
	var second_rift = run.rifts.get_child(0)
	_expect(second_rift.predecessor == first, "la segunda grieta desciende del ultimo eco")
	var predecessor_start: Vector2 = first.global_position
	run.player.global_position = endpoint + Vector2(-100.0, 220.0)
	first._physics_process(0.6)
	second_rift._physics_process(0.2)
	_expect(not first.global_position.is_equal_approx(predecessor_start), "el eco predecesor continua siguiendo al jugador")
	_expect(second_rift.global_position.is_equal_approx(first.global_position), "la grieta sigue al ultimo eco mientras se mueve")
	var second_origin: Vector2 = first.global_position
	var second := await _open_latest_rift(run, true)
	_expect(second.global_position.is_equal_approx(second_origin), "la segunda generacion nace desde la primera")
	_expect(second.generation == 2, "la segunda generacion queda identificada")
	_expect(second.follow_target() == first, "la segunda generacion sigue a la primera")
	run.player.global_position = endpoint + Vector2(180.0, 180.0)
	first._physics_process(1.2)
	var first_past_position := first.global_position
	second._physics_process(1.2)
	run.player.global_position = endpoint + Vector2(220.0, -120.0)
	first._physics_process(1.2)
	second._physics_process(1.2)
	_expect(second.global_position.is_equal_approx(first_past_position), "la segunda generacion recorre la memoria de la primera")
	_expect(run.echoes.get_child_count() == 2, "las generaciones permanecen activas durante el nivel")
	run.queue_free()
	await process_frame


func _test_chain_compression() -> void:
	var run := RunScene.instantiate() as RunController
	root.add_child(run)
	await process_frame
	run.set_physics_process(false)
	run._physics_process(5.1)
	var first := await _open_latest_rift(run)
	var first_delay := first.effective_follow_delay()
	_expect(first_delay < RunController.ECHO_FOLLOW_DELAY, "la primera falta acerca el eco a su predecesor")
	_expect((run.phase_banner as Label).text.contains("FALTA LENTA 1"), "el primer castigo muestra su nivel")
	run._physics_process(5.1)
	var second := await _open_latest_rift(run)
	_expect(second.effective_follow_delay() < first_delay, "una segunda falta comprime aun mas la cadena")
	_expect(is_equal_approx(first.effective_follow_delay(), second.effective_follow_delay()), "la presion afecta todas las generaciones")
	_expect((run.phase_banner as Label).text.contains("FALTA LENTA 2"), "el segundo castigo muestra reincidencia")
	var compressed_delay := first.effective_follow_delay()
	run._update_echo_pressure(500.0)
	_expect(run._echo_pressure == 1 and run._slow_offenses == 2, "recuperarse conserva las faltas registradas")
	_expect(first.effective_follow_delay() > compressed_delay, "recuperarse vuelve a abrir la cadena")
	run._update_echo_pressure(500.0)
	_expect(run._echo_pressure == 0 and is_equal_approx(first.effective_follow_delay(), RunController.ECHO_FOLLOW_DELAY), "la distancia activa restaura el retraso normal")
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
	_expect((run.get_node("UI/PhaseBanner") as Label).text.contains("CADENA x1.2"), "la alerta explica la compresion")
	for _level in 5:
		run._update_echo_pressure(0.0)
	_expect(run._echo_pressure == 6, "la presion supera el antiguo limite")
	_expect(is_equal_approx(run._chain_pressure_multiplier, 2.2), "la compresion aumenta sin tope configurado")

	run._physics_process(5.1)
	var pending_rift = run.rifts.get_child(0)
	_expect(pending_rift.pressured, "el recorrido lento prepara un eco comprimido")
	var echo := await _open_latest_rift(run)
	_expect(is_equal_approx(echo.pressure_multiplier, 2.4), "el eco nuevo recibe toda la presion acumulada")
	_expect(echo.effective_follow_delay() < RunController.ECHO_FOLLOW_DELAY, "la presion reduce el retraso de seguimiento")
	var echo_origin := echo.global_position
	run.player.global_position += Vector2(120.0, 0.0)
	echo.set_physics_process(false)
	echo._physics_process(0.25)
	_expect(echo.global_position.is_equal_approx(echo_origin), "el eco conserva memoria incluso bajo presion")
	run.player.global_position += Vector2(120.0, 0.0)
	echo._physics_process(0.3)
	_expect(not echo.global_position.is_equal_approx(echo_origin), "el eco sigue una posicion pasada del jugador")
	run._update_echo_pressure(500.0)
	_expect(run._echo_pressure == 6 and is_equal_approx(run._chain_pressure_multiplier, 2.2), "moverse reduce la presion temporal")
	_expect(is_equal_approx(echo.pressure_multiplier, 2.2), "recuperarse abre tambien los ecos existentes")
	_expect((run.get_node("UI/PhaseBanner") as Label).text.contains("DISTANCIA RECUPERADA"), "la recuperacion se comunica al jugador")
	for _level in 6:
		run._update_echo_pressure(500.0)
	_expect(run._echo_pressure == 0 and is_equal_approx(run._chain_pressure_multiplier, 1.0), "la actividad recupera el ritmo normal")

	run._update_echo_pressure(0.0)
	run._restart()
	await process_frame
	_expect(run._echo_pressure == 0 and run._slow_offenses == 0 and is_equal_approx(run._chain_pressure_multiplier, 1.0), "repetir reinicia presion y faltas")
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
	_expect(danger_run.get_node("UI/GameOver/Center/Panel/Content/Result").text.contains("OBSTACULO"), "informa la causa obstaculo")
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


func _open_latest_rift(run: RunController, pause_echo := false) -> EchoPlayback:
	var rift = run.rifts.get_child(run.rifts.get_child_count() - 1)
	rift.set_physics_process(false)
	rift._physics_process(RunController.RIFT_WARNING_TIME + 0.1)
	var echo := run.echoes.get_child(run.echoes.get_child_count() - 1) as EchoPlayback
	if pause_echo:
		echo.set_physics_process(false)
	await process_frame
	return echo


func _expect(condition: bool, description: String) -> void:
	_checks += 1
	if condition:
		print("[OK] %s" % description)
		return

	_failures += 1
	printerr("[FALLO] %s" % description)
