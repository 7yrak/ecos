class_name GameplayOverlay
extends Control

var _phase := 0.0
var _primary := Color("#55f2bd")
var _secondary := Color("#32aee8")
var _resonance_strength := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _process(delta: float) -> void:
	_phase = fmod(_phase + delta, 1000.0)
	queue_redraw()


func set_palette(palette: Dictionary) -> void:
	_primary = palette.get("primary", _primary)
	_secondary = palette.get("secondary", _secondary)
	queue_redraw()


func set_resonance_strength(strength: float) -> void:
	_resonance_strength = clampf(strength, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	var edge := 34.0
	draw_rect(Rect2(0.0, 0.0, size.x, edge), Color(0.0, 0.0, 0.0, 0.22))
	draw_rect(Rect2(0.0, size.y - edge, size.x, edge), Color(0.0, 0.0, 0.0, 0.28))
	draw_rect(Rect2(0.0, 0.0, edge, size.y), Color(0.0, 0.0, 0.0, 0.2))
	draw_rect(Rect2(size.x - edge, 0.0, edge, size.y), Color(0.0, 0.0, 0.0, 0.2))
	for y in range(0, int(size.y), 8):
		draw_line(Vector2(0.0, y), Vector2(size.x, y), Color(_primary, 0.012), 1.0)
	var scan_y := fmod(_phase * 72.0, maxf(1.0, size.y))
	draw_line(Vector2(0.0, scan_y), Vector2(size.x, scan_y), Color(_secondary, 0.055), 2.0)
	_draw_bracket(Vector2(24.0, 286.0), Vector2.RIGHT, Vector2.DOWN)
	_draw_bracket(Vector2(size.x - 24.0, 286.0), Vector2.LEFT, Vector2.DOWN)
	_draw_bracket(Vector2(24.0, size.y - 34.0), Vector2.RIGHT, Vector2.UP)
	_draw_bracket(Vector2(size.x - 24.0, size.y - 34.0), Vector2.LEFT, Vector2.UP)
	if _resonance_strength > 0.001:
		var pulse := 0.68 + sin(_phase * 8.0) * 0.18
		var resonance_color := _primary.lerp(_secondary, 0.5 + sin(_phase * 2.4) * 0.22)
		draw_rect(
			Rect2(10.0, 10.0, size.x - 20.0, size.y - 20.0),
			Color(resonance_color, _resonance_strength * pulse * 0.3),
			false,
			10.0 + _resonance_strength * 8.0
		)
		for index in 3:
			var inset := 18.0 + float(index) * 11.0
			draw_rect(
				Rect2(inset, inset, size.x - inset * 2.0, size.y - inset * 2.0),
				Color(resonance_color, _resonance_strength * (0.035 - float(index) * 0.008)),
				false,
				2.0
			)


func _draw_bracket(origin: Vector2, horizontal: Vector2, vertical: Vector2) -> void:
	draw_line(origin, origin + horizontal * 24.0, Color(_primary, 0.34), 2.0)
	draw_line(origin, origin + vertical * 24.0, Color(_primary, 0.34), 2.0)
