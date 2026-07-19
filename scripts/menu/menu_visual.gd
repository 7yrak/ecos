class_name MenuVisual
extends Control

var _phase := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _process(delta: float) -> void:
	_phase = fmod(_phase + delta, TAU)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("07131d"))
	_draw_grid()
	_draw_echo_field()
	_draw_route()


func _draw_grid() -> void:
	var grid_color := Color(0.18, 0.82, 0.655, 0.055)
	for x in range(0, int(size.x) + 1, 48):
		draw_line(Vector2(x, 0), Vector2(x, size.y), grid_color, 1.0)
	for y in range(0, int(size.y) + 1, 48):
		draw_line(Vector2(0, y), Vector2(size.x, y), grid_color, 1.0)


func _draw_echo_field() -> void:
	var center := Vector2(size.x * 0.78, size.y * 0.26)
	for index in 7:
		var radius := 46.0 + index * 42.0 + sin(_phase * 1.4 + index) * 5.0
		var alpha := 0.2 - index * 0.018
		draw_arc(center, radius, 0.2, TAU - 0.4, 72, Color(1.0, 0.34, 0.27, alpha), 2.0)

	for index in 12:
		var angle := index * 2.17 + _phase * (0.08 + index * 0.003)
		var distance := 90.0 + float((index * 47) % 230)
		var point := center + Vector2.from_angle(angle) * distance
		draw_circle(point, 2.0 + float(index % 3), Color(0.58, 1.0, 0.8, 0.22))


func _draw_route() -> void:
	var points := PackedVector2Array()
	for index in 18:
		var progress := index / 17.0
		var x := 54.0 + progress * (size.x - 108.0)
		var y := size.y * 0.7 + sin(progress * 8.0 + _phase * 0.7) * 46.0
		points.append(Vector2(x, y))
	draw_polyline(points, Color(0.18, 0.82, 0.655, 0.12), 10.0, true)
	draw_polyline(points, Color(0.58, 1.0, 0.8, 0.68), 2.5, true)
