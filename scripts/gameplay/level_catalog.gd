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
