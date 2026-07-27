class_name StoreItemPreview
extends Control

var category := "skins"
var item: Dictionary = {}
var _phase := 0.0


func configure(new_category: String, new_item: Dictionary) -> void:
	category = new_category
	item = new_item
	queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _process(delta: float) -> void:
	_phase += delta
	queue_redraw()


func _draw() -> void:
	draw_circle(size * 0.5, 45.0, Color(0.03, 0.08, 0.11, 0.9))
	if category == "skins":
		_draw_skin()
	elif category == "stages":
		_draw_stage()
	else:
		_draw_power()


func _draw_skin() -> void:
	var center := size * 0.5
	var primary: Color = item.get("primary", Color("#55f2bd"))
	var glow: Color = item.get("glow", primary)
	var pulse := 1.0 + sin(_phase * 5.0) * 0.08
	draw_circle(center, 38.0 * pulse, Color(glow, 0.1))
	draw_arc(center, 34.0, _phase, _phase + PI * 1.25, 28, Color(glow, 0.65), 3.0)
	draw_circle(center, 21.0, primary)
	draw_circle(center - Vector2(6.0, 7.0), 5.0, Color(1.0, 1.0, 1.0, 0.85))


func _draw_stage() -> void:
	var level := int(item.get("level", 1))
	var colors := [Color("#55f2bd"), Color("#58c8ff"), Color("#ff6295")]
	var accent: Color = colors[clampi(level - 1, 0, 2)]
	var arena := Rect2(14.0, 20.0, size.x - 28.0, size.y - 40.0)
	draw_rect(arena, Color(accent, 0.07), true)
	draw_rect(arena, Color(accent, 0.7), false, 2.0)
	for index in level + 1:
		var x := arena.position.x + 17.0 + float(index) * 20.0
		draw_line(Vector2(x, arena.position.y + 10.0), Vector2(x + 17.0, arena.end.y - 10.0), Color(accent, 0.46), 4.0)
	draw_circle(arena.get_center() + Vector2(sin(_phase) * 15.0, 0.0), 6.0, accent)


func _draw_power() -> void:
	var center := size * 0.5
	var power_id := str(item.get("id", "none"))
	var color := Color("#8ca9ff")
	draw_arc(center, 31.0, -_phase, -_phase + PI * 1.45, 28, Color(color, 0.7), 3.0)
	if power_id == "pulse":
		for radius in [10.0, 19.0, 28.0]:
			draw_arc(center, radius, 0.0, TAU, 28, Color(color, 0.35 + radius * 0.01), 2.0)
	elif power_id == "stabilizer":
		draw_line(center - Vector2(23.0, 0.0), center + Vector2(23.0, 0.0), color, 5.0)
		draw_line(center - Vector2(0.0, 23.0), center + Vector2(0.0, 23.0), color, 5.0)
		draw_circle(center, 8.0, Color("#55f2bd"))
	elif power_id == "shield":
		var shield := PackedVector2Array([
			center + Vector2(0.0, -27.0),
			center + Vector2(24.0, -15.0),
			center + Vector2(18.0, 17.0),
			center + Vector2(0.0, 31.0),
			center + Vector2(-18.0, 17.0),
			center + Vector2(-24.0, -15.0),
			center + Vector2(0.0, -27.0),
		])
		draw_polyline(shield, color, 4.0, true)
	else:
		draw_line(center - Vector2(18.0, 18.0), center + Vector2(18.0, 18.0), Color(color, 0.65), 4.0)
