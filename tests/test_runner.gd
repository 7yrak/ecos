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
	viewport.queue_free()
	await process_frame


func _test_run_scene() -> void:
	var run = RunScene.instantiate()
	root.add_child(run)
	await process_frame
	run.set_physics_process(false)

	var player := run.get_node("Player") as CharacterBody2D
	var echoes := run.get_node("Echoes") as Node2D
	var obstacle := run.get_node("Obstacles/Upper") as StaticBody2D
	_expect(player != null, "la partida contiene al jugador")
	_expect(player.collision_layer == 1 and player.collision_mask == 4, "capas fisicas del jugador")
	_expect(obstacle.is_in_group("danger") and obstacle.collision_layer == 4, "obstaculo peligroso configurado")
	_expect(echoes.get_child_count() == 0, "la partida comienza sin ecos")

	run._physics_process(5.1)
	_expect(echoes.get_child_count() == 1, "crea un eco al completar el intervalo")
	var echo := echoes.get_child(0) as Area2D
	_expect(echo.collision_layer == 2 and echo.collision_mask == 1, "capas fisicas del eco")

	run._end_run("PRUEBA")
	_expect(not player.movement_enabled, "el fin bloquea el movimiento")
	_expect(run.get_node("UI/GameOver").visible, "el fin muestra el resultado")
	run._restart()
	await process_frame
	_expect(player.movement_enabled, "repetir reactiva el movimiento")
	_expect(not run.get_node("UI/GameOver").visible, "repetir oculta el resultado")
	_expect(echoes.get_child_count() == 0, "repetir limpia los ecos")
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
		if run.get_node("Echoes").get_child_count() == 1:
			run._end_run("CICLO %d" % cycle)
			if run.get_node("UI/GameOver").visible:
				completed_cycles += 1
		run.queue_free()
		await process_frame
	_expect(completed_cycles == 10, "completa diez ciclos tecnicos consecutivos")


func _expect(condition: bool, description: String) -> void:
	_checks += 1
	if condition:
		print("[OK] %s" % description)
		return

	_failures += 1
	printerr("[FALLO] %s" % description)
