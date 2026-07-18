extends Control

const RING_COLOR := Color(0.18, 0.82, 0.655, 0.16)
const RING_COUNT := 6
const RING_GAP := 92.0

var pulse := 0.0


func _process(delta: float) -> void:
	pulse = fmod(pulse + delta * 36.0, RING_GAP)
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	for index in RING_COUNT:
		var radius := pulse + index * RING_GAP
		draw_arc(center, radius, 0.0, TAU, 96, RING_COLOR, 3.0, true)
