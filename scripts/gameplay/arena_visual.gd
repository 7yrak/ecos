class_name ArenaVisual
extends Node2D

const PLAY_RECTS := [
	Rect2(48.0, 180.0, 624.0, 940.0),
	Rect2(-76.0, 76.0, 872.0, 1148.0),
	Rect2(-236.0, -72.0, 1192.0, 1444.0),
]
const CAMERA_ZOOMS := [1.0, 0.76, 0.58]

var expansion_stage := 1
var _draw_rect: Rect2 = PLAY_RECTS[0]
var _previous_rect: Rect2 = PLAY_RECTS[0]
var _reveal_strength := 0.0
var _expansion_tween: Tween


func _ready() -> void:
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
	draw_rect(Rect2(-520.0, -420.0, 1760.0, 2160.0), Color(0.018, 0.043, 0.063), true)
	draw_rect(_draw_rect, Color(0.035, 0.09, 0.115), true)

	if expansion_stage > 1:
		draw_rect(_previous_rect, Color(0.027, 0.065, 0.09, 0.72), true)
		var sector_color := Color(0.22, 0.68, 1.0, 0.08 + _reveal_strength * 0.14)
		draw_rect(_draw_rect, sector_color, false, 18.0 + _reveal_strength * 18.0)

	var grid_start_x := floori(_draw_rect.position.x / 80.0) * 80
	var grid_end_x := ceili(_draw_rect.end.x / 80.0) * 80
	for x in range(grid_start_x, grid_end_x + 1, 80):
		draw_line(Vector2(x, _draw_rect.position.y), Vector2(x, _draw_rect.end.y), Color(0.18, 0.82, 0.655, 0.07), 1.0)
	var grid_start_y := floori(_draw_rect.position.y / 80.0) * 80
	var grid_end_y := ceili(_draw_rect.end.y / 80.0) * 80
	for y in range(grid_start_y, grid_end_y + 1, 80):
		draw_line(Vector2(_draw_rect.position.x, y), Vector2(_draw_rect.end.x, y), Color(0.18, 0.82, 0.655, 0.07), 1.0)

	var border_color := Color(0.35, 0.72, 1.0, 0.82) if expansion_stage > 1 else Color(0.18, 0.82, 0.655, 0.65)
	draw_rect(_draw_rect, border_color, false, 4.0)
	_draw_corner_signals(_draw_rect, border_color)


func _draw_corner_signals(rect: Rect2, color: Color) -> void:
	var length := 34.0
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
