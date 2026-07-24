class_name LevelCatalog
extends RefCounted

const LevelDefinitionScript = preload("res://scripts/gameplay/level_definition.gd")
const LEVELS := [
	{
		"number": 1,
		"title": "PRIMERA ESTELA",
		"difficulty": "INICIAL",
		"duration": 45.0,
		"echo_interval": 5.0,
		"patrol_phase_time": 12.0,
		"pulse_phase_time": 24.0,
		"follow_delay": 1.2,
		"minimum_segment_distance": 280.0,
		"first_clear_bonus": 20,
		"arena_profile": {
			"upper_position": Vector2(210.0, 470.0),
			"upper_size": Vector2(200.0, 30.0),
			"upper_rotation": 0.0,
			"lower_position": Vector2(510.0, 820.0),
			"lower_size": Vector2(200.0, 30.0),
			"lower_rotation": 0.0,
			"patrol_position": Vector2(570.0, 650.0),
			"patrol_size": Vector2(110.0, 28.0),
			"patrol_offset": Vector2(-420.0, 0.0),
			"patrol_period": 5.4,
			"pulse_position": Vector2(230.0, 650.0),
			"pulse_size": Vector2(250.0, 30.0),
			"pulse_rotation": 0.0,
			"pulse_warning": 0.8,
			"pulse_active": 2.0,
			"pulse_safe": 1.2,
		},
	},
	{
		"number": 2,
		"title": "CONTRACORRIENTE",
		"difficulty": "INTERMEDIA",
		"duration": 55.0,
		"echo_interval": 4.5,
		"patrol_phase_time": 10.0,
		"pulse_phase_time": 22.0,
		"follow_delay": 1.15,
		"minimum_segment_distance": 305.0,
		"first_clear_bonus": 30,
		"arena_profile": {
			"upper_position": Vector2(230.0, 410.0),
			"upper_size": Vector2(34.0, 230.0),
			"upper_rotation": 0.0,
			"lower_position": Vector2(500.0, 880.0),
			"lower_size": Vector2(34.0, 230.0),
			"lower_rotation": 0.0,
			"patrol_position": Vector2(360.0, 650.0),
			"patrol_size": Vector2(130.0, 26.0),
			"patrol_offset": Vector2(230.0, 0.0),
			"patrol_period": 4.4,
			"pulse_position": Vector2(360.0, 650.0),
			"pulse_size": Vector2(32.0, 330.0),
			"pulse_rotation": 0.0,
			"pulse_warning": 0.7,
			"pulse_active": 2.2,
			"pulse_safe": 1.0,
		},
	},
	{
		"number": 3,
		"title": "NUCLEO ROJO",
		"difficulty": "AVANZADA",
		"duration": 65.0,
		"echo_interval": 4.0,
		"patrol_phase_time": 8.0,
		"pulse_phase_time": 18.0,
		"follow_delay": 1.05,
		"minimum_segment_distance": 330.0,
		"first_clear_bonus": 45,
		"arena_profile": {
			"upper_position": Vector2(225.0, 430.0),
			"upper_size": Vector2(190.0, 28.0),
			"upper_rotation": 0.48,
			"lower_position": Vector2(495.0, 860.0),
			"lower_size": Vector2(190.0, 28.0),
			"lower_rotation": -0.48,
			"patrol_position": Vector2(360.0, 650.0),
			"patrol_size": Vector2(110.0, 28.0),
			"patrol_offset": Vector2(0.0, 250.0),
			"patrol_period": 3.8,
			"pulse_position": Vector2(360.0, 650.0),
			"pulse_size": Vector2(360.0, 28.0),
			"pulse_rotation": 0.0,
			"pulse_warning": 0.6,
			"pulse_active": 2.4,
			"pulse_safe": 0.8,
		},
	},
]


static func get_level(level_number: int):
	for config in LEVELS:
		if config.number == level_number:
			return LevelDefinitionScript.new(config)
	return null


static func has_level(level_number: int) -> bool:
	return get_level(level_number) != null


static func first_level():
	return LevelDefinitionScript.new(LEVELS[0])
