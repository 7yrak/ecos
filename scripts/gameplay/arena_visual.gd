class_name ArenaVisual
extends Node2D

const PLAY_RECT := Rect2(48.0, 180.0, 624.0, 940.0)
const OBSTACLE_RECTS := [
	Rect2(110.0, 455.0, 200.0, 30.0),
	Rect2(420.0, 805.0, 180.0, 30.0),
]


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, 720.0, 1280.0), Color(0.027, 0.059, 0.09), true)
	draw_rect(PLAY_RECT, Color(0.035, 0.09, 0.115), true)

	for x in range(80, 680, 80):
		draw_line(Vector2(x, PLAY_RECT.position.y), Vector2(x, PLAY_RECT.end.y), Color(0.18, 0.82, 0.655, 0.055), 1.0)
	for y in range(220, 1120, 80):
		draw_line(Vector2(PLAY_RECT.position.x, y), Vector2(PLAY_RECT.end.x, y), Color(0.18, 0.82, 0.655, 0.055), 1.0)

	draw_rect(PLAY_RECT, Color(0.18, 0.82, 0.655, 0.55), false, 3.0)
	for obstacle in OBSTACLE_RECTS:
		draw_rect(obstacle, Color(1.0, 0.38, 0.31, 0.18), true)
		draw_rect(obstacle, Color(1.0, 0.45, 0.36, 0.8), false, 3.0)
