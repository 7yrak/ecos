class_name World25D
extends SubViewport

const StoreCatalogScript = preload("res://scripts/app/store_catalog.gd")
const PIXELS_PER_UNIT := 90.0
const FINAL_ZOOM := 0.58
const CAMERA_SIZE := 1280.0 / (PIXELS_PER_UNIT * FINAL_ZOOM)
const DISPLAY_SCALE := 1.0 / FINAL_ZOOM
const DESIGN_CENTER := Vector2(360.0, 650.0)
const GROUND_DEPTH_SCALE := 1.104
const CAMERA_HOME := Vector3(0.0, 16.0, 7.5)
const CAMERA_REVEAL := Vector3(0.0, 18.4, 9.2)
const TOUCH_PULSE_INTERVAL := 0.055
const PLAYER_WAKE_DISTANCE := 0.58
const MAX_REACTIVE_PULSES := 18

var _run: RunController
var _world_root: Node3D
var _camera: Camera3D
var _environment: Environment
var _floor: MeshInstance3D
var _frame_root: Node3D
var _platform_root: Node3D
var _architecture_root: Node3D
var _reactive_root: Node3D
var _ambient_particles: GPUParticles3D
var _scanner_strip: MeshInstance3D
var _scanner_light: OmniLight3D
var _player_visual: Node3D
var _player_light: OmniLight3D
var _player_ring: MeshInstance3D
var _trail_particles: GPUParticles3D
var _key_light: DirectionalLight3D
var _rim_light: DirectionalLight3D
var _palette: Dictionary = {}
var _player_color := Color("#55f2bd")
var _stage := 1
var _visual_time := 0.0
var _echo_visuals: Dictionary = {}
var _obstacle_visuals: Dictionary = {}
var _surprise_visuals: Dictionary = {}
var _enabled := false
var _high_quality := true
var _camera_reveal_progress := 0.0
var _camera_reveal_tween: Tween
var _last_touch_pulse_time := -10.0
var _last_player_wake := Vector3(1000.0, 0.0, 1000.0)
var _reactive_pulses: Array[Node3D] = []
var _platform_generation := 0


func _ready() -> void:
	size = Vector2i(720, 1280)
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	handle_input_locally = false
	transparent_bg = false
	if OS.has_feature("headless"):
		render_target_update_mode = SubViewport.UPDATE_DISABLED
		set_process(false)
		return
	_build_world()
	_enabled = true


func attach_run(run: RunController) -> void:
	_run = run


func set_palette(palette: Dictionary) -> void:
	_palette = palette.duplicate(true)
	if not _enabled:
		return
	var void_color: Color = palette.get("void", Color("#030b12"))
	var primary: Color = palette.get("primary", Color("#55f2bd"))
	_environment.background_color = void_color
	_environment.ambient_light_color = primary.lerp(Color.WHITE, 0.2)
	_environment.ambient_light_energy = 0.3
	_environment.fog_light_color = void_color.lightened(0.12)
	_environment.fog_density = 0.022 if _surface_style() == "ice" else 0.028
	_key_light.light_color = primary.lightened(0.34)
	_rim_light.light_color = palette.get("secondary", Color("#ff5b52"))
	_update_floor_material()
	_refresh_reactive_palette()
	_rebuild_player(_player_color)
	_clear_visual_dictionary(_echo_visuals)
	_clear_visual_dictionary(_obstacle_visuals)
	_clear_visual_dictionary(_surprise_visuals)
	_rebuild_architecture()
	_rebuild_platforms(false)
	_rebuild_frame()


func set_arena_stage(stage: int, animate := false) -> void:
	var previous_stage := _stage
	_stage = clampi(stage, 1, 3)
	if _enabled:
		if _stage == 1 and not animate:
			_reset_reactive_surface()
		_rebuild_platforms(animate and _stage > previous_stage, previous_stage)
		_rebuild_architecture()
		_rebuild_frame()
		if animate and _stage > previous_stage:
			_play_camera_reveal()


func set_player_skin(skin_id: String) -> void:
	var colors := StoreCatalogScript.skin_colors(skin_id)
	_player_color = colors.primary
	if _enabled:
		_rebuild_player(_player_color)


func set_high_quality(enabled: bool) -> void:
	_high_quality = enabled
	size = Vector2i(720, 1280) if enabled else Vector2i(540, 960)
	if is_instance_valid(_key_light):
		_key_light.shadow_enabled = enabled
	if is_instance_valid(_trail_particles):
		_trail_particles.amount = 32 if enabled else 16
	if is_instance_valid(_ambient_particles):
		_ambient_particles.amount = 74 if enabled else 34
	for visual in _echo_visuals.values():
		var echo_trail := (visual as Node3D).get_node_or_null("EchoTrail") as GPUParticles3D
		if is_instance_valid(echo_trail):
			echo_trail.amount = 10 if enabled else 5


func react_to_pointer(design_position: Vector2, intensity := 1.0) -> void:
	if not _enabled or _visual_time - _last_touch_pulse_time < TOUCH_PULSE_INTERVAL:
		return
	_last_touch_pulse_time = _visual_time
	_spawn_floor_pulse(
		_to_world(design_position),
		_palette.get("secondary", Color("#32aee8")),
		clampf(intensity, 0.45, 1.8),
		true
	)


func visual_capabilities() -> PackedStringArray:
	return PackedStringArray([
		"deep_3d_arena",
		"physical_stage_expansion",
		"generational_holographic_echoes",
		"animated_obstacle_reveals",
		"reactive_touch_floor",
	])


func display_scale() -> float:
	return DISPLAY_SCALE * 720.0 / float(size.x)


func _process(delta: float) -> void:
	if not _enabled or not is_instance_valid(_run):
		return
	_visual_time = fmod(_visual_time + delta, 1000.0)
	_sync_player()
	_sync_echoes()
	_sync_base_obstacles()
	_sync_surprises()
	_animate_world()


func _build_world() -> void:
	_world_root = Node3D.new()
	_world_root.name = "WorldRoot"
	add_child(_world_root)

	var world_environment := WorldEnvironment.new()
	_environment = Environment.new()
	_environment.background_mode = Environment.BG_COLOR
	_environment.background_color = Color("#030b12")
	_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_environment.ambient_light_color = Color("#55f2bd")
	_environment.ambient_light_energy = 0.2
	_environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	_environment.adjustment_enabled = true
	_environment.adjustment_brightness = 1.06
	_environment.adjustment_contrast = 1.08
	_environment.adjustment_saturation = 1.12
	_environment.fog_enabled = true
	_environment.fog_light_color = Color("#07131d")
	_environment.fog_density = 0.025
	world_environment.environment = _environment
	_world_root.add_child(world_environment)

	_camera = Camera3D.new()
	_camera.name = "Camera"
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = CAMERA_SIZE
	_camera.look_at_from_position(CAMERA_HOME, Vector3.ZERO, Vector3.UP)
	_camera.current = true
	_world_root.add_child(_camera)

	_key_light = DirectionalLight3D.new()
	_key_light.name = "KeyLight"
	_key_light.rotation_degrees = Vector3(-58.0, -28.0, -16.0)
	_key_light.light_color = Color("#b8fff0")
	_key_light.light_energy = 0.78
	_key_light.shadow_enabled = _high_quality
	_world_root.add_child(_key_light)

	_rim_light = DirectionalLight3D.new()
	_rim_light.name = "RimLight"
	_rim_light.rotation_degrees = Vector3(-42.0, 148.0, 12.0)
	_rim_light.light_color = Color("#ff5b52")
	_rim_light.light_energy = 0.48
	_rim_light.shadow_enabled = false
	_world_root.add_child(_rim_light)

	_floor = MeshInstance3D.new()
	_floor.name = "EnvironmentFloor"
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(13.8, 24.6 * GROUND_DEPTH_SCALE)
	floor_mesh.subdivide_width = 1
	floor_mesh.subdivide_depth = 1
	_floor.mesh = floor_mesh
	_floor.position.y = -0.42
	_world_root.add_child(_floor)

	_architecture_root = Node3D.new()
	_architecture_root.name = "DeepArchitecture"
	_world_root.add_child(_architecture_root)

	_platform_root = Node3D.new()
	_platform_root.name = "PhysicalArenaDeck"
	_world_root.add_child(_platform_root)

	_frame_root = Node3D.new()
	_frame_root.name = "ArenaFrame"
	_world_root.add_child(_frame_root)

	_reactive_root = Node3D.new()
	_reactive_root.name = "ReactiveSurface"
	_world_root.add_child(_reactive_root)

	_build_scanner()
	_build_ambient_particles()
	_rebuild_player(Color("#55f2bd"))
	_rebuild_architecture()
	_rebuild_platforms(false)


func _update_floor_material() -> void:
	if not is_instance_valid(_floor):
		return
	var material := StandardMaterial3D.new()
	var background_path := str(_palette.get("background_path", ""))
	if not background_path.is_empty():
		var texture = load(background_path)
		if texture is Texture2D:
			material.albedo_texture = texture
			material.emission_enabled = true
			material.emission_texture = texture
			material.emission = Color(0.24, 0.28, 0.3)
			material.emission_energy_multiplier = 0.12
	material.albedo_color = Color(0.62, 0.66, 0.7)
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	match _surface_style():
		"forge":
			material.metallic = 0.72
			material.roughness = 0.34
		"crystal":
			material.metallic = 0.32
			material.roughness = 0.12
		"ice":
			material.metallic = 0.08
			material.roughness = 0.08
		_:
			material.metallic = 0.18
			material.roughness = 0.62
	_floor.material_override = material


func _rebuild_architecture() -> void:
	if not is_instance_valid(_architecture_root):
		return
	for child in _architecture_root.get_children():
		child.queue_free()
	var primary: Color = _palette.get("primary", Color("#55f2bd"))
	var secondary: Color = _palette.get("secondary", Color("#32aee8"))
	var void_color: Color = _palette.get("void", Color("#030b12"))
	var arena_half_width := 6.1
	var arena_half_depth := 9.1
	if is_instance_valid(_run):
		var active_rect := _run.arena.play_rect_for_stage(_stage)
		arena_half_width = active_rect.size.x / PIXELS_PER_UNIT * 0.5
		arena_half_depth = active_rect.size.y / PIXELS_PER_UNIT * GROUND_DEPTH_SCALE * 0.5

	var undercroft := MeshInstance3D.new()
	undercroft.name = "SuspendedUndercroft"
	var undercroft_mesh := BoxMesh.new()
	undercroft_mesh.size = Vector3(arena_half_width * 2.0 + 0.5, 0.72, arena_half_depth * 2.0 + 0.5)
	undercroft.mesh = undercroft_mesh
	undercroft.position = Vector3(0.0, -0.76, 0.0)
	undercroft.material_override = _solid_material(void_color.lightened(0.16))
	_architecture_root.add_child(undercroft)

	for index in 18:
		var side := -1.0 if index % 2 == 0 else 1.0
		var lane := index / 2
		var z := -arena_half_depth + (float(lane) + 0.5) / 9.0 * arena_half_depth * 2.0
		var distance := arena_half_width + 0.58 + float(index % 3) * 0.38
		var height := 1.8 + float((index * 7) % 5) * 0.55
		var tower := Node3D.new()
		tower.name = "DepthPylon%02d" % index
		tower.position = Vector3(side * distance, -0.52 + height * 0.5, z)
		_architecture_root.add_child(tower)

		var body := MeshInstance3D.new()
		var body_mesh := BoxMesh.new()
		body_mesh.size = Vector3(0.5 + float(index % 2) * 0.16, height, 0.72)
		body.mesh = body_mesh
		body.material_override = _solid_material(primary.darkened(0.3) if index % 3 else secondary.darkened(0.32))
		tower.add_child(body)

		var crown := MeshInstance3D.new()
		var crown_mesh := BoxMesh.new()
		crown_mesh.size = Vector3(0.72, 0.09, 0.84)
		crown.mesh = crown_mesh
		crown.position.y = height * 0.5 + 0.08
		crown.material_override = _energy_material(primary if index % 3 else secondary, 1.4)
		tower.add_child(crown)

	for corner_index in 4:
		var corner_sign: Vector3 = [
			Vector3(-1.0, 0.0, -1.0),
			Vector3(1.0, 0.0, -1.0),
			Vector3(1.0, 0.0, 1.0),
			Vector3(-1.0, 0.0, 1.0),
		][corner_index]
		var anchor := Node3D.new()
		anchor.name = "SuspensionAnchor%d" % corner_index
		anchor.position = Vector3(
			corner_sign.x * (arena_half_width + 0.52),
			-1.38,
			corner_sign.z * (arena_half_depth + 0.52)
		)
		_architecture_root.add_child(anchor)
		var column := MeshInstance3D.new()
		var column_mesh := CylinderMesh.new()
		column_mesh.top_radius = 0.18
		column_mesh.bottom_radius = 0.42
		column_mesh.height = 3.2
		column_mesh.radial_segments = 8
		column.mesh = column_mesh
		column.material_override = _solid_material(secondary)
		anchor.add_child(column)
		var anchor_light := OmniLight3D.new()
		anchor_light.position.y = 1.62
		anchor_light.light_color = secondary
		anchor_light.light_energy = 0.62
		anchor_light.omni_range = 2.6
		anchor_light.shadow_enabled = false
		anchor.add_child(anchor_light)


func _rebuild_platforms(animate: bool, previous_stage := 1) -> void:
	if not is_instance_valid(_platform_root) or not is_instance_valid(_run):
		return
	for child in _platform_root.get_children():
		child.queue_free()
	_platform_generation += 1
	var rect := _run.arena.play_rect_for_stage(_stage)
	var previous_rect := _run.arena.play_rect_for_stage(clampi(previous_stage, 1, 3))
	var center := _to_world(rect.get_center())
	var width := rect.size.x / PIXELS_PER_UNIT
	var depth := rect.size.y / PIXELS_PER_UNIT * GROUND_DEPTH_SCALE
	var columns := 4 + _stage
	var rows := 6 + _stage
	var cell_width := width / float(columns)
	var cell_depth := depth / float(rows)
	var primary: Color = _palette.get("primary", Color("#55f2bd"))
	var secondary: Color = _palette.get("secondary", Color("#32aee8"))
	var arena_color: Color = _palette.get("arena", Color("#09242a"))
	var reveal_tween := create_tween().set_parallel(true) if animate else null
	var reveal_index := 0

	for row in rows:
		for column in columns:
			var normalized := Vector2(
				(float(column) + 0.5) / float(columns),
				(float(row) + 0.5) / float(rows)
			)
			var design_position := rect.position + rect.size * normalized
			var plate := MeshInstance3D.new()
			plate.name = "DeckPlate_%02d_%02d" % [row, column]
			var plate_mesh := BoxMesh.new()
			plate_mesh.size = Vector3(
				maxf(0.12, cell_width - 0.055),
				0.24,
				maxf(0.12, cell_depth - 0.055)
			)
			plate.mesh = plate_mesh
			var accent := primary if (row + column) % 5 else secondary
			var tile_color := arena_color.lerp(accent, 0.12 if (row + column) % 2 else 0.18)
			plate.material_override = _deck_material(tile_color, accent)
			plate.position = Vector3(
				center.x - width * 0.5 + cell_width * (float(column) + 0.5),
				-0.19,
				center.z - depth * 0.5 + cell_depth * (float(row) + 0.5)
			)
			plate.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			_platform_root.add_child(plate)
			if animate and not previous_rect.has_point(design_position):
				var target_y := plate.position.y
				plate.position.y = -2.4 - float((row + column) % 3) * 0.28
				plate.scale.y = 0.18
				var delay := minf(0.48, float(reveal_index) * 0.022)
				reveal_tween.tween_property(plate, "position:y", target_y, 0.72) \
					.set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				reveal_tween.tween_property(plate, "scale:y", 1.0, 0.62) \
					.set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				reveal_index += 1

	_add_expansion_bridges(rect, animate)


func _add_expansion_bridges(rect: Rect2, animate: bool) -> void:
	if _stage <= 1:
		return
	var primary: Color = _palette.get("primary", Color("#55f2bd"))
	var secondary: Color = _palette.get("secondary", Color("#32aee8"))
	var center := _to_world(rect.get_center())
	var width := rect.size.x / PIXELS_PER_UNIT
	var depth := rect.size.y / PIXELS_PER_UNIT * GROUND_DEPTH_SCALE
	var bridge_specs := [
		[Vector3(center.x - width * 0.5, -0.02, center.z), Vector3(0.72, 0.16, 2.2)],
		[Vector3(center.x + width * 0.5, -0.02, center.z), Vector3(0.72, 0.16, 2.2)],
		[Vector3(center.x, -0.02, center.z - depth * 0.5), Vector3(2.2, 0.16, 0.72)],
		[Vector3(center.x, -0.02, center.z + depth * 0.5), Vector3(2.2, 0.16, 0.72)],
	]
	for index in bridge_specs.size():
		var bridge := MeshInstance3D.new()
		bridge.name = "ExpansionBridge%d" % index
		var mesh := BoxMesh.new()
		mesh.size = bridge_specs[index][1]
		bridge.mesh = mesh
		bridge.position = bridge_specs[index][0]
		bridge.material_override = _energy_material(primary if index % 2 == 0 else secondary, 1.45)
		_platform_root.add_child(bridge)
		if animate:
			var target_scale := bridge.scale
			bridge.scale = Vector3(0.12, 0.12, 0.12)
			create_tween().tween_property(bridge, "scale", target_scale, 0.68) \
				.set_delay(0.28 + float(index) * 0.07) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _build_scanner() -> void:
	_scanner_strip = MeshInstance3D.new()
	_scanner_strip.name = "ReactiveScanner"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(7.0, 0.018, 0.075)
	_scanner_strip.mesh = mesh
	_scanner_strip.position.y = -0.045
	_scanner_strip.material_override = _hologram_material(Color("#55f2bd"), 0.32)
	_reactive_root.add_child(_scanner_strip)
	_scanner_light = OmniLight3D.new()
	_scanner_light.name = "ScannerLight"
	_scanner_light.position.y = 0.16
	_scanner_light.light_color = Color("#55f2bd")
	_scanner_light.light_energy = 0.42
	_scanner_light.omni_range = 2.8
	_scanner_light.shadow_enabled = false
	_scanner_strip.add_child(_scanner_light)


func _build_ambient_particles() -> void:
	_ambient_particles = GPUParticles3D.new()
	_ambient_particles.name = "DepthParticles"
	_ambient_particles.amount = 74 if _high_quality else 34
	_ambient_particles.lifetime = 4.8
	_ambient_particles.preprocess = 4.8
	_ambient_particles.visibility_aabb = AABB(Vector3(-12.0, -3.0, -15.0), Vector3(24.0, 9.0, 30.0))
	var particle_mesh := SphereMesh.new()
	particle_mesh.radius = 0.025
	particle_mesh.height = 0.05
	particle_mesh.material = _hologram_material(Color("#55f2bd"), 0.48)
	_ambient_particles.draw_pass_1 = particle_mesh
	var process_material := ParticleProcessMaterial.new()
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_material.emission_box_extents = Vector3(8.2, 0.5, 11.8)
	process_material.direction = Vector3(0.0, 1.0, 0.0)
	process_material.spread = 24.0
	process_material.gravity = Vector3(0.0, 0.08, 0.0)
	process_material.initial_velocity_min = 0.05
	process_material.initial_velocity_max = 0.24
	process_material.scale_min = 0.45
	process_material.scale_max = 1.35
	_ambient_particles.process_material = process_material
	_world_root.add_child(_ambient_particles)


func _rebuild_player(color: Color) -> void:
	if is_instance_valid(_player_visual):
		_player_visual.queue_free()
	_player_visual = Node3D.new()
	_player_visual.name = "PlayerSignal"
	_world_root.add_child(_player_visual)

	var core := MeshInstance3D.new()
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.24
	core_mesh.height = 0.48
	core_mesh.radial_segments = 24
	core_mesh.rings = 12
	core.mesh = core_mesh
	core.material_override = _energy_material(color, 1.8)
	_player_visual.add_child(core)

	var shell := MeshInstance3D.new()
	var shell_mesh := SphereMesh.new()
	shell_mesh.radius = 0.34
	shell_mesh.height = 0.68
	shell_mesh.radial_segments = 24
	shell_mesh.rings = 12
	shell.mesh = shell_mesh
	shell.material_override = _hologram_material(color, 0.1)
	_player_visual.add_child(shell)

	_player_ring = MeshInstance3D.new()
	_player_ring.mesh = _torus_mesh(0.34, 0.405)
	_player_ring.material_override = _energy_material(color.lightened(0.12), 1.5)
	_player_visual.add_child(_player_ring)

	_player_light = OmniLight3D.new()
	_player_light.light_color = color
	_player_light.light_energy = 1.2
	_player_light.omni_range = 3.2
	_player_light.shadow_enabled = false
	_player_visual.add_child(_player_light)

	_trail_particles = GPUParticles3D.new()
	_trail_particles.name = "SignalTrail"
	_trail_particles.amount = 32 if _high_quality else 16
	_trail_particles.lifetime = 0.58
	_trail_particles.preprocess = 0.58
	_trail_particles.local_coords = false
	_trail_particles.visibility_aabb = AABB(Vector3(-20.0, -2.0, -20.0), Vector3(40.0, 4.0, 40.0))
	var particle_mesh := SphereMesh.new()
	particle_mesh.radius = 0.045
	particle_mesh.height = 0.09
	particle_mesh.material = _energy_material(color, 1.2)
	_trail_particles.draw_pass_1 = particle_mesh
	var process_material := ParticleProcessMaterial.new()
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process_material.emission_sphere_radius = 0.07
	process_material.gravity = Vector3.ZERO
	process_material.initial_velocity_min = 0.0
	process_material.initial_velocity_max = 0.0
	process_material.scale_min = 0.35
	process_material.scale_max = 1.0
	process_material.color = Color(color, 0.72)
	_trail_particles.process_material = process_material
	_player_visual.add_child(_trail_particles)


func _sync_player() -> void:
	if not is_instance_valid(_run.player) or not is_instance_valid(_player_visual):
		return
	var design_position := _run.player.position
	var world_position := _to_world(design_position)
	_player_visual.position = world_position
	_player_visual.position.y = 0.34 + sin(_visual_time * 5.5) * 0.055
	if _last_player_wake.distance_to(world_position) >= PLAYER_WAKE_DISTANCE:
		_last_player_wake = world_position
		_spawn_floor_pulse(world_position, _player_color, 0.58, false)
	if is_instance_valid(_scanner_light):
		var scanner_local := _scanner_light.global_position
		_scanner_light.global_position = Vector3(
			lerpf(scanner_local.x, world_position.x, 0.12),
			0.16,
			lerpf(scanner_local.z, world_position.z, 0.12)
		)


func _sync_echoes() -> void:
	var active_ids := {}
	for child in _run.echoes.get_children():
		if not child is EchoPlayback:
			continue
		var echo := child as EchoPlayback
		var id := echo.get_instance_id()
		active_ids[id] = true
		if not _echo_visuals.has(id):
			_echo_visuals[id] = _create_echo_visual(echo)
		var visual := _echo_visuals[id] as Node3D
		visual.position = _to_world(_run.to_local(echo.global_position))
		visual.position.y = 0.25 + sin(_visual_time * 5.0 + echo.generation) * 0.035
		visual.rotation.y = _visual_time * (0.7 + echo.generation * 0.04)
		var pulse := 1.0 + sin(_visual_time * 6.4 + float(echo.generation) * 0.8) * 0.08
		visual.scale = Vector3(pulse, 0.92 + pulse * 0.08, pulse)
	_remove_missing_visuals(_echo_visuals, active_ids)


func _create_echo_visual(echo: EchoPlayback) -> Node3D:
	var color := _echo_generation_color(echo.generation, echo.pressured)
	var root := Node3D.new()
	root.name = "Echo%02d" % echo.generation
	root.set_meta("generation", echo.generation)
	_world_root.add_child(root)
	var core := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.17
	sphere.height = 0.34
	sphere.radial_segments = 18
	sphere.rings = 9
	core.mesh = sphere
	core.material_override = _energy_material(color, 2.2)
	root.add_child(core)
	var shell := MeshInstance3D.new()
	var shell_mesh := SphereMesh.new()
	shell_mesh.radius = 0.27
	shell_mesh.height = 0.54
	shell_mesh.radial_segments = 18
	shell_mesh.rings = 9
	shell.mesh = shell_mesh
	shell.material_override = _hologram_material(color, 0.16)
	root.add_child(shell)
	for index in 3:
		var ring := MeshInstance3D.new()
		ring.name = "GenerationRing%d" % index
		ring.mesh = _torus_mesh(0.25 + index * 0.075, 0.29 + index * 0.075)
		ring.material_override = _hologram_material(color, 0.68 - index * 0.16)
		ring.rotation.x = float(index) * 0.62
		root.add_child(ring)
	var beam := MeshInstance3D.new()
	beam.name = "MemoryBeam"
	var beam_mesh := CylinderMesh.new()
	beam_mesh.top_radius = 0.018
	beam_mesh.bottom_radius = 0.055
	beam_mesh.height = 1.05
	beam_mesh.radial_segments = 8
	beam.mesh = beam_mesh
	beam.position.y = 0.36
	beam.material_override = _hologram_material(color, 0.22)
	root.add_child(beam)
	var echo_trail := _create_memory_trail(color)
	root.add_child(echo_trail)
	if echo.generation <= 8:
		var echo_light := OmniLight3D.new()
		echo_light.name = "EchoLight"
		echo_light.light_color = color
		echo_light.light_energy = 0.48
		echo_light.omni_range = 1.65
		echo_light.shadow_enabled = false
		root.add_child(echo_light)
	return root


func _sync_base_obstacles() -> void:
	for obstacle in [
		_run.upper_obstacle,
		_run.lower_obstacle,
		_run.patrol_obstacle,
		_run.pulse_obstacle,
	]:
		var id: int = obstacle.get_instance_id()
		if not _obstacle_visuals.has(id):
			_obstacle_visuals[id] = _create_obstacle_visual(obstacle)
		var visual := _obstacle_visuals[id] as Node3D
		var should_show: bool = obstacle.progression_active and obstacle.visible
		visual.visible = should_show
		if not visual.visible:
			visual.set_meta("was_visible", false)
			continue
		if not bool(visual.get_meta("was_visible", false)):
			visual.set_meta("reveal_time", _visual_time)
			visual.set_meta("was_visible", true)
		var reveal_age := maxf(0.0, _visual_time - float(visual.get_meta("reveal_time", _visual_time)))
		var reveal := smoothstep(0.0, 0.7, reveal_age)
		visual.position = _to_world(obstacle.position)
		visual.position.y = lerpf(-0.78, 0.35, reveal)
		visual.scale = Vector3(0.82 + reveal * 0.18, 0.12 + reveal * 0.88, 0.82 + reveal * 0.18)
		visual.rotation.y = -obstacle.rotation
		_update_box_geometry(visual, obstacle.obstacle_size, 0.7)
		var target_color: Color = _palette.get("danger", Color("#ff5b52"))
		if obstacle.kind == ArenaObstacle.Kind.PATROL:
			target_color = _palette.get("warning", Color("#ffc857"))
		elif obstacle.kind == ArenaObstacle.Kind.PULSE and not obstacle.collision_active:
			target_color = _palette.get("secondary", Color("#32aee8"))
		_set_visual_color(visual, target_color, 2.0 if obstacle.collision_active else 1.15)


func _create_obstacle_visual(obstacle: ArenaObstacle) -> Node3D:
	var root := _create_energy_box(_palette.get("danger", Color("#ff5b52")))
	root.name = "BaseObstacle%d" % obstacle.get_instance_id()
	_world_root.add_child(root)
	return root


func _sync_surprises() -> void:
	var active_ids := {}
	for child in _run.surprises.get_children():
		if not child is SurpriseObstacle:
			continue
		var obstacle := child as SurpriseObstacle
		var id := obstacle.get_instance_id()
		active_ids[id] = true
		if not _surprise_visuals.has(id):
			_surprise_visuals[id] = _create_surprise_visual(obstacle)
		var visual := _surprise_visuals[id] as Node3D
		visual.position = _to_world(obstacle.position)
		visual.rotation.y = -obstacle.rotation
		_update_box_geometry(visual, obstacle.obstacle_size, 0.85)
		var color: Color = _palette.get("warning", Color("#ffc857"))
		var energy := 1.15
		var previous_state := int(visual.get_meta("obstacle_state", -1))
		if previous_state != obstacle.state:
			visual.set_meta("obstacle_state", obstacle.state)
			visual.set_meta("state_change_time", _visual_time)
		if obstacle.state == SurpriseObstacle.State.ACTIVE:
			color = _palette.get("secondary", Color("#32aee8")) if obstacle.style == "gate" else _palette.get("danger", Color("#ff5b52"))
			energy = 2.8
		elif obstacle.state == SurpriseObstacle.State.RETRACTING:
			energy = 0.45
		_set_visual_color(visual, color, energy)
		if obstacle.state == SurpriseObstacle.State.WARNING:
			var warning_reveal := smoothstep(0.0, 1.0, obstacle.warning_progress())
			visual.position.y = lerpf(-0.92, 0.425, warning_reveal)
			visual.scale = Vector3(
				0.68 + warning_reveal * 0.32,
				0.08 + warning_reveal * 0.92,
				0.68 + warning_reveal * 0.32
			)
		elif obstacle.state == SurpriseObstacle.State.ACTIVE:
			var active_age := maxf(0.0, _visual_time - float(visual.get_meta("state_change_time", _visual_time)))
			var slam := exp(-active_age * 5.0) * sin(active_age * 20.0) * 0.22
			visual.position.y = 0.425 + maxf(0.0, slam) * 0.24
			visual.scale = Vector3(1.0 + slam, 1.0 - slam * 0.35, 1.0 + slam)
		else:
			var retract_age := maxf(0.0, _visual_time - float(visual.get_meta("state_change_time", _visual_time)))
			var retract := clampf(retract_age / SurpriseObstacle.RETRACT_DURATION, 0.0, 1.0)
			visual.position.y = lerpf(0.425, -0.72, retract)
			visual.scale = Vector3.ONE * (1.0 - retract * 0.35)
		_remove_missing_visuals(_surprise_visuals, active_ids)


func _create_surprise_visual(obstacle: SurpriseObstacle) -> Node3D:
	var root := _create_energy_box(_palette.get("warning", Color("#ffc857")))
	root.name = "Surprise%02d" % obstacle.beat_index
	root.set_meta("style", obstacle.style)
	_add_obstacle_details(root, obstacle.style)
	_world_root.add_child(root)
	return root


func _create_energy_box(color: Color) -> Node3D:
	var root := Node3D.new()
	var body := MeshInstance3D.new()
	body.name = "Body"
	body.mesh = BoxMesh.new()
	body.material_override = _solid_material(color)
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	root.add_child(body)
	var core := MeshInstance3D.new()
	core.name = "Core"
	core.mesh = BoxMesh.new()
	core.material_override = _energy_material(color, 2.0)
	core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(core)
	var halo := MeshInstance3D.new()
	halo.name = "Halo"
	halo.mesh = BoxMesh.new()
	halo.material_override = _hologram_material(color, 0.16)
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(halo)
	var projection := MeshInstance3D.new()
	projection.name = "WarningProjection"
	projection.mesh = BoxMesh.new()
	projection.position.y = -0.37
	projection.material_override = _hologram_material(color, 0.16)
	projection.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(projection)
	return root


func _update_box_geometry(root: Node3D, pixel_size: Vector2, height: float) -> void:
	var size_3d := Vector3(pixel_size.x / PIXELS_PER_UNIT, height, pixel_size.y / PIXELS_PER_UNIT * GROUND_DEPTH_SCALE)
	var previous_size: Vector3 = root.get_meta("box_size", Vector3.ZERO)
	if previous_size.is_equal_approx(size_3d):
		return
	root.set_meta("box_size", size_3d)
	var body := root.get_node("Body") as MeshInstance3D
	var core := root.get_node("Core") as MeshInstance3D
	var halo := root.get_node("Halo") as MeshInstance3D
	var projection := root.get_node("WarningProjection") as MeshInstance3D
	var body_mesh := BoxMesh.new()
	body_mesh.size = size_3d
	body.mesh = body_mesh
	var core_mesh := BoxMesh.new()
	core_mesh.size = Vector3(
		maxf(0.08, size_3d.x * 0.86),
		0.055,
		maxf(0.08, size_3d.z * 0.56)
	)
	core.mesh = core_mesh
	core.position.y = size_3d.y * 0.5 + 0.035
	var halo_mesh := BoxMesh.new()
	halo_mesh.size = size_3d + Vector3(0.14, 0.12, 0.14)
	halo.mesh = halo_mesh
	var projection_mesh := BoxMesh.new()
	projection_mesh.size = Vector3(size_3d.x + 0.38, 0.018, size_3d.z + 0.38)
	projection.mesh = projection_mesh
	projection.position.y = -size_3d.y * 0.5 + 0.02
	var details := root.get_node_or_null("Details")
	if is_instance_valid(details):
		var style := str(root.get_meta("style", "wall"))
		var horizontal := size_3d.x >= size_3d.z
		for index in details.get_child_count():
			var detail := details.get_child(index) as MeshInstance3D
			var detail_mesh := BoxMesh.new()
			if style == "gate":
				detail_mesh.size = Vector3(0.12, size_3d.y * 1.65, 0.12)
				var offset := lerpf(-0.38, 0.38, float(index) / 2.0)
				detail.position = Vector3(
					offset * size_3d.x if horizontal else 0.0,
					size_3d.y * 0.38,
					0.0 if horizontal else offset * size_3d.z
				)
			elif style == "sweep":
				detail_mesh.size = Vector3(
					0.34 if horizontal else 0.08,
					size_3d.y * (0.62 + float(index) * 0.15),
					0.08 if horizontal else 0.34
				)
				var sweep_offset := (float(index) - 1.0) * 0.28
				detail.position = Vector3(
					sweep_offset * size_3d.x if horizontal else 0.0,
					size_3d.y * 0.46,
					0.0 if horizontal else sweep_offset * size_3d.z
				)
				detail.rotation.y = 0.46 * (float(index) - 1.0)
			else:
				detail_mesh.size = Vector3(
					0.1 if horizontal else 0.22,
					size_3d.y * 0.9,
					0.22 if horizontal else 0.1
				)
				var wall_offset := (float(index) - 1.0) * 0.32
				detail.position = Vector3(
					wall_offset * size_3d.x if horizontal else 0.0,
					size_3d.y * 0.62,
					0.0 if horizontal else wall_offset * size_3d.z
				)
			detail.mesh = detail_mesh


func _set_visual_color(root: Node3D, color: Color, energy: float) -> void:
	var cache_key := "%s:%.2f" % [color.to_html(), energy]
	if root.get_meta("material_key", "") == cache_key:
		return
	root.set_meta("material_key", cache_key)
	(root.get_node("Body") as MeshInstance3D).material_override = _solid_material(color)
	(root.get_node("Core") as MeshInstance3D).material_override = _energy_material(color, energy)
	(root.get_node("Halo") as MeshInstance3D).material_override = _hologram_material(color, 0.08 + energy * 0.045)
	(root.get_node("WarningProjection") as MeshInstance3D).material_override = _hologram_material(color, 0.08 + energy * 0.025)
	var details := root.get_node_or_null("Details")
	if is_instance_valid(details):
		for detail in details.get_children():
			(detail as MeshInstance3D).material_override = _energy_material(color, energy * 0.72)


func _rebuild_frame() -> void:
	if not is_instance_valid(_frame_root) or not is_instance_valid(_run):
		return
	for child in _frame_root.get_children():
		child.queue_free()
	var rect := _run.arena.play_rect_for_stage(_stage)
	var primary: Color = _palette.get("primary", Color("#55f2bd"))
	var secondary: Color = _palette.get("secondary", Color("#32aee8"))
	var center := _to_world(rect.get_center())
	var width := rect.size.x / PIXELS_PER_UNIT
	var depth := rect.size.y / PIXELS_PER_UNIT * GROUND_DEPTH_SCALE
	var thickness := 0.075
	_add_frame_rail(Vector3(center.x, 0.05, center.z - depth * 0.5), Vector3(width, 0.1, thickness), primary)
	_add_frame_rail(Vector3(center.x, 0.05, center.z + depth * 0.5), Vector3(width, 0.1, thickness), primary)
	_add_frame_rail(Vector3(center.x - width * 0.5, 0.05, center.z), Vector3(thickness, 0.1, depth), secondary)
	_add_frame_rail(Vector3(center.x + width * 0.5, 0.05, center.z), Vector3(thickness, 0.1, depth), secondary)
	for corner in [
		Vector3(center.x - width * 0.5, 0.18, center.z - depth * 0.5),
		Vector3(center.x + width * 0.5, 0.18, center.z - depth * 0.5),
		Vector3(center.x + width * 0.5, 0.18, center.z + depth * 0.5),
		Vector3(center.x - width * 0.5, 0.18, center.z + depth * 0.5),
	]:
		var beacon := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 0.09
		cylinder.bottom_radius = 0.13
		cylinder.height = 0.36
		beacon.mesh = cylinder
		beacon.position = corner
		beacon.material_override = _energy_material(primary, 2.4)
		_frame_root.add_child(beacon)


func _add_frame_rail(position_3d: Vector3, size_3d: Vector3, color: Color) -> void:
	var rail_root := Node3D.new()
	rail_root.position = position_3d
	_frame_root.add_child(rail_root)
	var wall := MeshInstance3D.new()
	var wall_mesh := BoxMesh.new()
	wall_mesh.size = Vector3(size_3d.x, 0.52, size_3d.z)
	wall.mesh = wall_mesh
	wall.position.y = -0.22
	wall.material_override = _solid_material(color.darkened(0.34))
	wall.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	rail_root.add_child(wall)
	var rail := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size_3d
	rail.mesh = mesh
	rail.material_override = _energy_material(color, 2.2)
	rail_root.add_child(rail)
	var lower_glow := MeshInstance3D.new()
	var lower_mesh := BoxMesh.new()
	lower_mesh.size = Vector3(
		maxf(0.08, size_3d.x * 0.94),
		0.035,
		maxf(0.08, size_3d.z * 0.94)
	)
	lower_glow.mesh = lower_mesh
	lower_glow.position.y = -0.46
	lower_glow.material_override = _hologram_material(color, 0.32)
	rail_root.add_child(lower_glow)


func _animate_world() -> void:
	if is_instance_valid(_player_ring):
		_player_ring.rotation.y = _visual_time * 1.8
		_player_ring.rotation.x = sin(_visual_time * 0.9) * 0.24
	if is_instance_valid(_player_light):
		_player_light.light_energy = 1.2 + sin(_visual_time * 6.0) * 0.18
	if is_instance_valid(_scanner_strip) and is_instance_valid(_run):
		var rect := _run.arena.play_rect_for_stage(_stage)
		var center := _to_world(rect.get_center())
		var depth := rect.size.y / PIXELS_PER_UNIT * GROUND_DEPTH_SCALE
		var width := rect.size.x / PIXELS_PER_UNIT
		var scan_progress := fmod(_visual_time * 0.105, 1.0)
		_scanner_strip.position = Vector3(center.x, -0.045, center.z - depth * 0.5 + depth * scan_progress)
		_scanner_strip.scale.x = width / 7.0
		_scanner_strip.visible = true
		_scanner_light.light_energy = 0.32 + sin(_visual_time * 5.0) * 0.08
	for visual in _echo_visuals.values():
		var echo_visual := visual as Node3D
		var generation := int(echo_visual.get_meta("generation", 1))
		for ring_index in 3:
			var ring := echo_visual.get_node_or_null("GenerationRing%d" % ring_index) as MeshInstance3D
			if is_instance_valid(ring):
				ring.rotation.x = _visual_time * (0.38 + float(ring_index) * 0.13) * (-1.0 if ring_index % 2 else 1.0)
				ring.rotation.z = _visual_time * (0.24 + float(generation) * 0.012) + float(ring_index)
	for visual in _surprise_visuals.values():
		var obstacle_visual := visual as Node3D
		var details := obstacle_visual.get_node_or_null("Details")
		if is_instance_valid(details):
			details.rotation.y = sin(_visual_time * 6.0 + float(obstacle_visual.get_instance_id() % 7)) * 0.055


func _play_camera_reveal() -> void:
	if not is_instance_valid(_camera):
		return
	if is_instance_valid(_camera_reveal_tween):
		_camera_reveal_tween.kill()
	_set_camera_reveal_progress(0.0)
	_camera_reveal_tween = create_tween()
	_camera_reveal_tween.tween_method(_set_camera_reveal_progress, 0.0, 1.0, 1.28) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_camera_reveal_tween.tween_callback(_finish_camera_reveal)


func _set_camera_reveal_progress(progress: float) -> void:
	_camera_reveal_progress = progress
	var lift := sin(progress * PI)
	var lateral := sin(progress * TAU) * 0.36
	var camera_position := CAMERA_HOME.lerp(CAMERA_REVEAL, lift) + Vector3(lateral, 0.0, 0.0)
	_camera.size = CAMERA_SIZE * (1.0 + lift * 0.085)
	_camera.look_at_from_position(camera_position, Vector3(0.0, -0.1, -lift * 0.42), Vector3.UP)


func _finish_camera_reveal() -> void:
	_camera_reveal_progress = 0.0
	_camera.size = CAMERA_SIZE
	_camera.look_at_from_position(CAMERA_HOME, Vector3.ZERO, Vector3.UP)


func _spawn_floor_pulse(world_position: Vector3, color: Color, intensity: float, touch_driven: bool) -> void:
	if not is_instance_valid(_reactive_root):
		return
	while _reactive_pulses.size() >= MAX_REACTIVE_PULSES:
		var oldest: Node3D = _reactive_pulses.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()
	var pulse := Node3D.new()
	pulse.name = "TouchPulse" if touch_driven else "MovementWake"
	pulse.position = Vector3(world_position.x, 0.015, world_position.z)
	pulse.scale = Vector3.ONE * 0.16
	_reactive_root.add_child(pulse)
	_reactive_pulses.append(pulse)

	var outer_ring := MeshInstance3D.new()
	outer_ring.mesh = _torus_mesh(0.34, 0.385)
	outer_ring.material_override = _hologram_material(color, 0.72 if touch_driven else 0.38)
	pulse.add_child(outer_ring)
	var inner_ring := MeshInstance3D.new()
	inner_ring.mesh = _torus_mesh(0.16, 0.19)
	inner_ring.material_override = _energy_material(color, 1.2)
	pulse.add_child(inner_ring)

	if touch_driven:
		var touch_light := OmniLight3D.new()
		touch_light.name = "TouchLight"
		touch_light.position.y = 0.16
		touch_light.light_color = color
		touch_light.light_energy = 1.1 * intensity
		touch_light.omni_range = 2.2 * intensity
		touch_light.shadow_enabled = false
		pulse.add_child(touch_light)
		pulse.create_tween().tween_property(touch_light, "light_energy", 0.0, 0.52)

	var duration := 0.62 if touch_driven else 0.42
	var target_scale := Vector3.ONE * (2.7 * intensity if touch_driven else 1.35)
	var tween := pulse.create_tween().set_parallel(true)
	tween.tween_property(pulse, "scale", target_scale, duration) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(pulse, "position:y", -0.045, duration)
	tween.chain().tween_callback(_release_reactive_pulse.bind(pulse))


func _release_reactive_pulse(pulse) -> void:
	_reactive_pulses.erase(pulse)
	if is_instance_valid(pulse):
		pulse.queue_free()


func _reset_reactive_surface() -> void:
	_last_player_wake = Vector3(1000.0, 0.0, 1000.0)
	_last_touch_pulse_time = -10.0
	for pulse in _reactive_pulses:
		if is_instance_valid(pulse):
			pulse.queue_free()
	_reactive_pulses.clear()
	if is_instance_valid(_camera_reveal_tween):
		_camera_reveal_tween.kill()
	if is_instance_valid(_camera):
		_finish_camera_reveal()


func _create_memory_trail(color: Color) -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "EchoTrail"
	particles.amount = 10 if _high_quality else 5
	particles.lifetime = 0.88
	particles.local_coords = false
	particles.visibility_aabb = AABB(Vector3(-20.0, -2.0, -20.0), Vector3(40.0, 4.0, 40.0))
	var particle_mesh := SphereMesh.new()
	particle_mesh.radius = 0.035
	particle_mesh.height = 0.07
	particle_mesh.material = _hologram_material(color, 0.58)
	particles.draw_pass_1 = particle_mesh
	var process_material := ParticleProcessMaterial.new()
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process_material.emission_sphere_radius = 0.08
	process_material.gravity = Vector3(0.0, 0.05, 0.0)
	process_material.initial_velocity_min = 0.0
	process_material.initial_velocity_max = 0.04
	process_material.scale_min = 0.4
	process_material.scale_max = 1.0
	particles.process_material = process_material
	return particles


func _echo_generation_color(generation: int, pressured: bool) -> Color:
	if pressured:
		return _palette.get("warning", Color("#ffc857"))
	var colors := [
		_palette.get("danger", Color("#ff5b52")),
		_palette.get("secondary", Color("#32aee8")),
		_palette.get("warning", Color("#ffc857")),
		_palette.get("primary", Color("#55f2bd")),
	]
	var base: Color = colors[posmod(generation - 1, colors.size())]
	var next: Color = colors[posmod(generation, colors.size())]
	var blend := float(posmod(generation - 1, 4)) * 0.12
	return base.lerp(next, blend).lightened(minf(0.16, float(generation - 1) * 0.012))


func _add_obstacle_details(root: Node3D, style: String) -> void:
	var details := Node3D.new()
	details.name = "Details"
	root.add_child(details)
	for index in 3:
		var detail := MeshInstance3D.new()
		detail.name = "Detail%d" % index
		detail.mesh = BoxMesh.new()
		detail.material_override = _energy_material(_palette.get("warning", Color("#ffc857")), 1.3)
		details.add_child(detail)
	root.set_meta("style", style)


func _refresh_reactive_palette() -> void:
	var primary: Color = _palette.get("primary", Color("#55f2bd"))
	var secondary: Color = _palette.get("secondary", Color("#32aee8"))
	if is_instance_valid(_scanner_strip):
		_scanner_strip.material_override = _hologram_material(secondary, 0.32)
	if is_instance_valid(_scanner_light):
		_scanner_light.light_color = secondary
	if is_instance_valid(_ambient_particles):
		var particle_mesh := _ambient_particles.draw_pass_1 as SphereMesh
		if is_instance_valid(particle_mesh):
			particle_mesh.material = _hologram_material(primary, 0.48)


func _energy_material(color: Color, energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color.darkened(0.48)
	match _surface_style():
		"forge":
			material.metallic = 0.92
			material.roughness = 0.22
		"crystal":
			material.metallic = 0.38
			material.roughness = 0.08
		"ice":
			material.metallic = 0.12
			material.roughness = 0.06
		_:
			material.metallic = 0.58
			material.roughness = 0.28
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 0.32 + energy * 0.26
	return material


func _deck_material(base_color: Color, accent: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = base_color.darkened(0.34)
	material.metallic = 0.78 if _surface_style() != "ice" else 0.18
	material.roughness = 0.26
	if _surface_style() == "crystal":
		material.metallic = 0.32
		material.roughness = 0.08
	elif _surface_style() == "ice":
		material.roughness = 0.07
	elif _surface_style() == "forge":
		material.metallic = 0.94
		material.roughness = 0.31
	material.emission_enabled = true
	material.emission = accent.darkened(0.56)
	material.emission_energy_multiplier = 0.18
	return material


func _solid_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color.darkened(0.54)
	match _surface_style():
		"forge":
			material.metallic = 0.94
			material.roughness = 0.3
		"crystal":
			material.metallic = 0.3
			material.roughness = 0.1
		"ice":
			material.metallic = 0.08
			material.roughness = 0.07
		_:
			material.metallic = 0.78
			material.roughness = 0.24
	material.emission_enabled = true
	material.emission = color.darkened(0.55)
	material.emission_energy_multiplier = 0.12
	return material


func _hologram_material(color: Color, alpha: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(color, alpha)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 0.28
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


func _torus_mesh(inner: float, outer: float) -> TorusMesh:
	var mesh := TorusMesh.new()
	mesh.inner_radius = inner
	mesh.outer_radius = outer
	mesh.rings = 32
	mesh.ring_segments = 10
	return mesh


func _to_world(point: Vector2) -> Vector3:
	return Vector3(
		(point.x - DESIGN_CENTER.x) / PIXELS_PER_UNIT,
		0.0,
		(point.y - DESIGN_CENTER.y) / PIXELS_PER_UNIT * GROUND_DEPTH_SCALE
	)


func _surface_style() -> String:
	return str(_palette.get("surface_style", "signal"))


func _remove_missing_visuals(visuals: Dictionary, active_ids: Dictionary) -> void:
	for id in visuals.keys():
		if active_ids.has(id):
			continue
		var visual = visuals[id]
		if is_instance_valid(visual):
			visual.queue_free()
		visuals.erase(id)


func _clear_visual_dictionary(visuals: Dictionary) -> void:
	for visual in visuals.values():
		if is_instance_valid(visual):
			visual.queue_free()
	visuals.clear()
