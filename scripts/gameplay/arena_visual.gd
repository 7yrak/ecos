class_name ArenaVisual
extends Node2D

const PLAY_RECTS := [
	Rect2(48.0, 180.0, 624.0, 940.0),
	Rect2(-76.0, 76.0, 872.0, 1148.0),
	Rect2(-236.0, -72.0, 1192.0, 1444.0),
]
const CAMERA_ZOOMS := [1.0, 0.76, 0.58]
const STAR_COUNT := 28
const ART_WORLD_RECT := Rect2(-236.0, -360.0, 1192.0, 2120.0)

var expansion_stage := 1
var _draw_rect: Rect2 = PLAY_RECTS[0]
var _previous_rect: Rect2 = PLAY_RECTS[0]
var _reveal_strength := 0.0
var _expansion_tween: Tween
var _phase := 0.0
var _palette := {
	"void": Color("#030b12"),
	"arena": Color("#09242a"),
	"primary": Color("#55f2bd"),
	"secondary": Color("#32aee8"),
	"danger": Color("#ff5b52"),
	"warning": Color("#ffc857"),
}


func _ready() -> void:
	queue_redraw()


func _process(delta: float) -> void:
	_phase = fmod(_phase + delta, 1000.0)
	queue_redraw()


func set_palette(palette: Dictionary) -> void:
	for key in palette:
		_palette[key] = palette[key]
	var background_path := str(palette.get("background_path", ""))
	if not background_path.is_empty():
		_palette["background"] = load(background_path)
	queue_redraw()


func set_expansion_stage(stage: int, animate := true) -> void:
	var next_stage := clampi(stage, 1, PLAY_RECTS.size())
	if next_stage == expansion_stage and _draw_rect == PLAY_RECTS[next_stage - 1]:
		return
	if is_instance_valid(_expansion_tween):
		_expansion_tween.kill()
	_previous_rect = _draw_rect
	expansion_stage = next_stage
	var target_rect: Rect2 = PLAY_RECTS[expansion_stage - 1]
	if not animate:
		_draw_rect = target_rect
		_reveal_strength = 0.0
		queue_redraw()
		return

	_reveal_strength = 1.0
	_expansion_tween = create_tween().set_parallel(true)
	_expansion_tween.tween_method(_set_draw_rect, _draw_rect, target_rect, 0.85) \
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	_expansion_tween.tween_method(_set_reveal_strength, 1.0, 0.0, 1.25) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func play_rect_for_stage(stage: int) -> Rect2:
	return PLAY_RECTS[clampi(stage, 1, PLAY_RECTS.size()) - 1]


func camera_zoom_for_stage(stage: int) -> float:
	return CAMERA_ZOOMS[clampi(stage, 1, CAMERA_ZOOMS.size()) - 1]


func _set_draw_rect(value: Rect2) -> void:
	_draw_rect = value
	queue_redraw()


func _set_reveal_strength(value: float) -> void:
	_reveal_strength = value
	queue_redraw()


func _draw() -> void:
	var void_color: Color = _palette.void
	var arena_color: Color = _palette.arena
	var primary: Color = _palette.primary
	var secondary: Color = _palette.secondary
	draw_rect(Rect2(-560.0, -460.0, 1840.0, 2240.0), void_color, true)
	_draw_environment_art()
	_draw_depth_field(primary, secondary)

	for layer in 4:
		var grow := float(34 - layer * 8)
		var alpha := 0.025 + float(layer) * 0.018
		draw_rect(_draw_rect.grow(grow), Color(secondary, alpha), false, 4.0 + float(layer) * 2.0)
	draw_rect(_draw_rect, Color(arena_color, 0.42), true)
	draw_rect(_draw_rect.grow(-5.0), Color(primary, 0.025), true)

	if expansion_stage > 1:
		draw_rect(_previous_rect, Color(void_color.lightened(0.08), 0.58), true)
		var sector_color := Color(secondary, 0.08 + _reveal_strength * 0.15)
		draw_rect(_draw_rect, sector_color, false, 16.0 + _reveal_strength * 22.0)

	_draw_grid(primary, secondary)
	_draw_scanner(secondary)
	_draw_sector_rings(primary)

	var border_color := Color(secondary, 0.92) if expansion_stage > 1 else Color(primary, 0.82)
	draw_rect(_draw_rect.grow(7.0), Color(border_color, 0.12), false, 12.0)
	draw_rect(_draw_rect, border_color, false, 4.0)
	_draw_corner_signals(_draw_rect, border_color)


func _draw_environment_art() -> void:
	var texture = _palette.get("background")
	if not texture is Texture2D:
		return
	var texture_size: Vector2 = texture.get_size()
	var source_position := Vector2(
		(_draw_rect.position.x - ART_WORLD_RECT.position.x) / ART_WORLD_RECT.size.x * texture_size.x,
		(_draw_rect.position.y - ART_WORLD_RECT.position.y) / ART_WORLD_RECT.size.y * texture_size.y
	)
	var source_size := Vector2(
		_draw_rect.size.x / ART_WORLD_RECT.size.x * texture_size.x,
		_draw_rect.size.y / ART_WORLD_RECT.size.y * texture_size.y
	)
	draw_texture_rect_region(
		texture,
		_draw_rect,
		Rect2(source_position, source_size),
		Color(0.86, 0.92, 0.94, 0.8),
		false,
		true
	)


func _draw_depth_field(primary: Color, secondary: Color) -> void:
	for index in STAR_COUNT:
		var seed_x := float((index * 173 + 61) % 1180)
		var seed_y := float((index * 271 + 97) % 1510)
		var drift := sin(_phase * (0.18 + float(index % 4) * 0.03) + index) * 6.0
		var point := Vector2(-230.0 + seed_x, -70.0 + seed_y + drift)
		var color := primary if index % 3 else secondary
		var radius := 1.2 + float(index % 3) * 0.7
		draw_circle(point, radius * 3.0, Color(color, 0.025))
		draw_circle(point, radius, Color(color, 0.16))


func _draw_grid(primary: Color, secondary: Color) -> void:
	var grid_start_x := floori(_draw_rect.position.x / 40.0) * 40
	var grid_end_x := ceili(_draw_rect.end.x / 40.0) * 40
	for x in range(grid_start_x, grid_end_x + 1, 40):
		var major := posmod(x, 160) == 0
		draw_line(
			Vector2(x, _draw_rect.position.y),
			Vector2(x, _draw_rect.end.y),
			Color(secondary if major else primary, 0.09 if major else 0.035),
			1.5 if major else 1.0
		)
	var grid_start_y := floori(_draw_rect.position.y / 40.0) * 40
	var grid_end_y := ceili(_draw_rect.end.y / 40.0) * 40
	for y in range(grid_start_y, grid_end_y + 1, 40):
		var major := posmod(y, 160) == 0
		draw_line(
			Vector2(_draw_rect.position.x, y),
			Vector2(_draw_rect.end.x, y),
			Color(secondary if major else primary, 0.09 if major else 0.035),
			1.5 if major else 1.0
		)


func _draw_scanner(color: Color) -> void:
	var scan_progress := fmod(_phase * 0.075, 1.0)
	var y := lerpf(_draw_rect.position.y, _draw_rect.end.y, scan_progress)
	draw_line(Vector2(_draw_rect.position.x, y), Vector2(_draw_rect.end.x, y), Color(color, 0.035), 24.0)
	draw_line(Vector2(_draw_rect.position.x, y), Vector2(_draw_rect.end.x, y), Color(color, 0.16), 2.0)


func _draw_sector_rings(color: Color) -> void:
	var center := _draw_rect.get_center()
	var base_radius := minf(_draw_rect.size.x, _draw_rect.size.y) * 0.18
	for index in 3:
		var radius := base_radius + float(index) * 86.0 + sin(_phase * 0.6 + index) * 4.0
		var start := _phase * (0.12 + float(index) * 0.02) + float(index)
		draw_arc(center, radius, start, start + PI * 0.72, 40, Color(color, 0.07), 2.0)


func _draw_corner_signals(rect: Rect2, color: Color) -> void:
	var length := 38.0
	var corners := [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]
	var directions := [
		[Vector2.RIGHT, Vector2.DOWN],
		[Vector2.LEFT, Vector2.DOWN],
		[Vector2.LEFT, Vector2.UP],
		[Vector2.RIGHT, Vector2.UP],
	]
	for index in corners.size():
		draw_line(corners[index], corners[index] + directions[index][0] * length, color, 7.0)
		draw_line(corners[index], corners[index] + directions[index][1] * length, color, 7.0)
		var marker: Vector2 = corners[index] + (directions[index][0] + directions[index][1]) * 14.0
		draw_circle(marker, 3.5, Color(color, 0.9))
