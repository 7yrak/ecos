class_name TutorialVisual
extends Control

var _phase := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _process(delta: float) -> void:
	_phase += delta
	queue_redraw()


func _draw() -> void:
	var route := PackedVector2Array([
		Vector2(28.0, 73.0),
		Vector2(118.0, 36.0),
		Vector2(215.0, 70.0),
		Vector2(315.0, 31.0),
		Vector2(425.0, 67.0),
	])
	draw_polyline(route, Color(0.33, 0.95, 0.74, 0.18), 12.0, true)
	draw_polyline(route, Color(0.33, 0.95, 0.74, 0.75), 2.5, true)
	for index in 3:
		var point := route[maxi(0, 3 - index)]
		var echo_color := Color(1.0, 0.36, 0.32, 0.7 - index * 0.16)
		draw_arc(point, 13.0 + sin(_phase * 5.0 + index) * 2.0, 0.0, TAU, 24, echo_color, 2.5)
	var player_position := route[4]
	draw_circle(player_position, 25.0, Color(0.2, 0.88, 0.68, 0.08))
	draw_circle(player_position, 13.0, Color("#55f2bd"))
	var hazard_rect := Rect2(478.0, 20.0, 28.0, 72.0)
	draw_rect(hazard_rect.grow(7.0), Color(1.0, 0.33, 0.3, 0.08), true)
	draw_rect(hazard_rect, Color(1.0, 0.33, 0.3, 0.82), false, 3.0)
	for y in range(28, 88, 14):
		draw_line(Vector2(480.0, y + 7.0), Vector2(504.0, y - 7.0), Color(1.0, 0.48, 0.38, 0.6), 2.0)
