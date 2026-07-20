class_name LevelDefinition
extends RefCounted

var number: int
var title: String
var difficulty: String
var duration: float
var echo_interval: float
var patrol_phase_time: float
var pulse_phase_time: float


func _init(config: Dictionary) -> void:
	number = config.number
	title = config.title
	difficulty = config.difficulty
	duration = config.duration
	echo_interval = config.echo_interval
	patrol_phase_time = config.patrol_phase_time
	pulse_phase_time = config.pulse_phase_time
