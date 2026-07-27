class_name MenuVisual
extends Control

const PRIMARY := Color("#55f2bd")
const SECONDARY := Color("#32aee8")
const DANGER := Color("#ff5b52")

var _phase := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _process(delta: float) -> void:
	_phase = fmod(_phase + delta, 1000.0)
	queue_redraw()


func _draw() -> void:
	_draw_grid()
	_draw_constellation()
	_draw_scanlines()
	_draw_frame()


func _draw_grid() -> void:
	for x in range(0, int(size.x) + 1, 48):
		var major := x % 192 == 0
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color(PRIMARY, 0.048 if major else 0.017), 1.0)
	for y in range(0, int(size.y) + 1, 48):
		var major := y % 192 == 0
		draw_line(Vector2(0, y), Vector2(size.x, y), Color(PRIMARY, 0.048 if major else 0.017), 1.0)


func _draw_constellation() -> void:
	for index in 20:
		var x := float((index * 137 + 83) % 690) + sin(_phase * 0.17 + index) * 3.0
		var y := float((index * 223 + 41) % 1180) + 40.0
		var color := SECONDARY if index % 4 == 0 else PRIMARY
		draw_circle(Vector2(x, y), 1.4 + float(index % 3) * 0.65, Color(color, 0.2))


func _draw_scanlines() -> void:
	for y in range(0, int(size.y), 9):
		draw_line(Vector2(0.0, y), Vector2(size.x, y), Color(PRIMARY, 0.012), 1.0)
	var scan_y := fmod(_phase * 48.0, maxf(1.0, size.y))
	draw_line(Vector2(0.0, scan_y), Vector2(size.x, scan_y), Color(SECONDARY, 0.055), 2.0)


func _draw_frame() -> void:
	var margin := 20.0
	var corner := 44.0
	var color := Color(PRIMARY, 0.28)
	draw_line(Vector2(margin, margin), Vector2(margin + corner, margin), color, 2.0)
	draw_line(Vector2(margin, margin), Vector2(margin, margin + corner), color, 2.0)
	draw_line(Vector2(size.x - margin, margin), Vector2(size.x - margin - corner, margin), color, 2.0)
	draw_line(Vector2(size.x - margin, margin), Vector2(size.x - margin, margin + corner), color, 2.0)
	draw_line(Vector2(margin, size.y - margin), Vector2(margin + corner, size.y - margin), color, 2.0)
	draw_line(Vector2(margin, size.y - margin), Vector2(margin, size.y - margin - corner), color, 2.0)
	draw_line(Vector2(size.x - margin, size.y - margin), Vector2(size.x - margin - corner, size.y - margin), color, 2.0)
	draw_line(Vector2(size.x - margin, size.y - margin), Vector2(size.x - margin, size.y - margin - corner), color, 2.0)
