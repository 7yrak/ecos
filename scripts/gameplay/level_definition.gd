class_name LevelDefinition
extends RefCounted

var number: int
var title: String
var difficulty: String
var duration: float
var echo_interval: float
var patrol_phase_time: float
var pulse_phase_time: float
var follow_delay: float
var minimum_segment_distance: float
var first_clear_bonus: int
var arena_profile: Dictionary


func _init(config: Dictionary) -> void:
	number = config.number
	title = config.title
	difficulty = config.difficulty
	duration = config.duration
	echo_interval = config.echo_interval
	patrol_phase_time = config.patrol_phase_time
	pulse_phase_time = config.pulse_phase_time
	follow_delay = config.follow_delay
	minimum_segment_distance = config.minimum_segment_distance
	first_clear_bonus = config.first_clear_bonus
	arena_profile = config.arena_profile
