class_name World25D
extends SubViewport

const StoreCatalogScript = preload("res://scripts/app/store_catalog.gd")
const PIXELS_PER_UNIT := 90.0
const FINAL_ZOOM := 0.58
const CAMERA_SIZE := 1280.0 / (PIXELS_PER_UNIT * FINAL_ZOOM)
const DISPLAY_SCALE := 1.0 / FINAL_ZOOM
const DESIGN_CENTER := Vector2(360.0, 650.0)
const GROUND_DEPTH_SCALE := 1.104

var _run: RunController
var _world_root: Node3D
var _camera: Camera3D
var _environment: Environment
var _floor: MeshInstance3D
var _frame_root: Node3D
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
	_rebuild_player(_player_color)
	_clear_visual_dictionary(_echo_visuals)
	_clear_visual_dictionary(_obstacle_visuals)
	_clear_visual_dictionary(_surprise_visuals)
	_rebuild_frame()


func set_arena_stage(stage: int) -> void:
	_stage = clampi(stage, 1, 3)
	if _enabled:
		_rebuild_frame()


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
	_environment.fog_enabled = true
	_environment.fog_light_color = Color("#07131d")
	_environment.fog_density = 0.025
	world_environment.environment = _environment
	_world_root.add_child(world_environment)

	_camera = Camera3D.new()
	_camera.name = "Camera"
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = CAMERA_SIZE
	_camera.look_at_from_position(Vector3(0.0, 16.0, 7.5), Vector3.ZERO, Vector3.UP)
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
	_floor.position.y = -0.08
	_world_root.add_child(_floor)

	_frame_root = Node3D.new()
	_frame_root.name = "ArenaFrame"
	_world_root.add_child(_frame_root)
	_rebuild_player(Color("#55f2bd"))


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
	_player_visual.position = _to_world(design_position)
	_player_visual.position.y = 0.34 + sin(_visual_time * 5.5) * 0.055


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
	_remove_missing_visuals(_echo_visuals, active_ids)


func _create_echo_visual(echo: EchoPlayback) -> Node3D:
	var color: Color = _palette.get("warning", Color("#ffc857")) if echo.pressured else _palette.get("danger", Color("#ff5b52"))
	var root := Node3D.new()
	root.name = "Echo%02d" % echo.generation
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
	for index in 2:
		var ring := MeshInstance3D.new()
		ring.mesh = _torus_mesh(0.25 + index * 0.08, 0.29 + index * 0.08)
		ring.material_override = _hologram_material(color, 0.64 - index * 0.18)
		ring.rotation.x = float(index) * 0.7
		root.add_child(ring)
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
		visual.visible = obstacle.progression_active and obstacle.visible
		if not visual.visible:
			continue
		visual.position = _to_world(obstacle.position)
		visual.position.y = 0.35
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
		visual.position.y = 0.425
		visual.rotation.y = -obstacle.rotation
		_update_box_geometry(visual, obstacle.obstacle_size, 0.85)
		var color: Color = _palette.get("warning", Color("#ffc857"))
		var energy := 1.15
		if obstacle.state == SurpriseObstacle.State.ACTIVE:
			color = _palette.get("secondary", Color("#32aee8")) if obstacle.style == "gate" else _palette.get("danger", Color("#ff5b52"))
			energy = 2.8
		elif obstacle.state == SurpriseObstacle.State.RETRACTING:
			energy = 0.45
		_set_visual_color(visual, color, energy)
		visual.scale.y = 0.2 + obstacle.warning_progress() * 0.8 if obstacle.state == SurpriseObstacle.State.WARNING else 1.0
	_remove_missing_visuals(_surprise_visuals, active_ids)


func _create_surprise_visual(obstacle: SurpriseObstacle) -> Node3D:
	var root := _create_energy_box(_palette.get("warning", Color("#ffc857")))
	root.name = "Surprise%02d" % obstacle.beat_index
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


func _set_visual_color(root: Node3D, color: Color, energy: float) -> void:
	var cache_key := "%s:%.2f" % [color.to_html(), energy]
	if root.get_meta("material_key", "") == cache_key:
		return
	root.set_meta("material_key", cache_key)
	(root.get_node("Body") as MeshInstance3D).material_override = _solid_material(color)
	(root.get_node("Core") as MeshInstance3D).material_override = _energy_material(color, energy)
	(root.get_node("Halo") as MeshInstance3D).material_override = _hologram_material(color, 0.08 + energy * 0.045)


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
	var rail := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size_3d
	rail.mesh = mesh
	rail.position = position_3d
	rail.material_override = _energy_material(color, 2.2)
	_frame_root.add_child(rail)


func _animate_world() -> void:
	if is_instance_valid(_player_ring):
		_player_ring.rotation.y = _visual_time * 1.8
		_player_ring.rotation.x = sin(_visual_time * 0.9) * 0.24
	if is_instance_valid(_player_light):
		_player_light.light_energy = 1.2 + sin(_visual_time * 6.0) * 0.18
	for visual in _surprise_visuals.values():
		(visual as Node3D).rotation.x = sin(_visual_time * 8.0) * 0.025


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
