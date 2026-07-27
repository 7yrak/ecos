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
		"surprise_events": [
			{
				"time": 7.0, "sector": 1, "name": "CORTE FANTASMA",
				"warning": 1.25, "duration": 4.0,
				"obstacles": [
					{"position": Vector2(360.0, 360.0), "size": Vector2(310.0, 28.0), "style": "wall"},
				],
			},
			{
				"time": 13.0, "sector": 1, "name": "TENAZA ESCALONADA",
				"warning": 1.1, "duration": 4.2,
				"obstacles": [
					{"position": Vector2(205.0, 735.0), "size": Vector2(28.0, 270.0), "style": "gate"},
					{"position": Vector2(515.0, 565.0), "size": Vector2(28.0, 270.0), "style": "gate"},
				],
			},
			{
				"time": 19.5, "sector": 2, "name": "BARRIDO AMBAR",
				"warning": 1.15, "duration": 4.8,
				"obstacles": [
					{"position": Vector2(-20.0, 650.0), "size": Vector2(30.0, 245.0), "travel": Vector2(760.0, 0.0), "style": "sweep"},
				],
			},
			{
				"time": 26.0, "sector": 2, "name": "PUERTA PARTIDA",
				"warning": 1.0, "duration": 4.5,
				"obstacles": [
					{"position": Vector2(105.0, 700.0), "size": Vector2(260.0, 28.0), "style": "gate"},
					{"position": Vector2(615.0, 700.0), "size": Vector2(260.0, 28.0), "style": "gate"},
				],
			},
			{
				"time": 35.0, "sector": 3, "name": "CRUZ DE MEMORIA",
				"warning": 1.0, "duration": 4.4,
				"obstacles": [
					{"position": Vector2(225.0, 430.0), "size": Vector2(390.0, 28.0), "rotation": 0.22, "style": "wall"},
					{"position": Vector2(650.0, 810.0), "size": Vector2(28.0, 330.0), "style": "wall"},
				],
			},
			{
				"time": 41.0, "sector": 3, "name": "ULTIMA ONDA",
				"warning": 0.9, "duration": 3.6,
				"obstacles": [
					{"position": Vector2(-120.0, 430.0), "size": Vector2(210.0, 26.0), "travel": Vector2(1030.0, 360.0), "style": "sweep"},
					{"position": Vector2(840.0, 890.0), "size": Vector2(210.0, 26.0), "travel": Vector2(-980.0, -300.0), "style": "sweep"},
				],
			},
		],
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
		"surprise_events": [
			{
				"time": 6.0, "sector": 1, "name": "COMPUERTA NORTE",
				"warning": 1.15, "duration": 4.0,
				"obstacles": [
					{"position": Vector2(360.0, 350.0), "size": Vector2(360.0, 26.0), "style": "gate"},
				],
			},
			{
				"time": 11.0, "sector": 1, "name": "CONTRAGOLPE",
				"warning": 1.0, "duration": 4.2,
				"obstacles": [
					{"position": Vector2(85.0, 650.0), "size": Vector2(28.0, 230.0), "travel": Vector2(520.0, 0.0), "style": "sweep"},
				],
			},
			{
				"time": 18.0, "sector": 2, "name": "CANAL QUEBRADO",
				"warning": 1.0, "duration": 4.8,
				"obstacles": [
					{"position": Vector2(160.0, 515.0), "size": Vector2(250.0, 26.0), "rotation": 0.35, "style": "wall"},
					{"position": Vector2(570.0, 800.0), "size": Vector2(250.0, 26.0), "rotation": 0.35, "style": "wall"},
				],
			},
			{
				"time": 24.5, "sector": 2, "name": "MAREA DOBLE",
				"warning": 0.95, "duration": 4.6,
				"obstacles": [
					{"position": Vector2(-40.0, 420.0), "size": Vector2(28.0, 210.0), "travel": Vector2(760.0, 140.0), "style": "sweep"},
					{"position": Vector2(760.0, 900.0), "size": Vector2(28.0, 210.0), "travel": Vector2(-760.0, -140.0), "style": "sweep"},
				],
			},
			{
				"time": 32.5, "sector": 3, "name": "ESCLUSA CENTRAL",
				"warning": 0.95, "duration": 4.5,
				"obstacles": [
					{"position": Vector2(360.0, 650.0), "size": Vector2(30.0, 430.0), "style": "gate"},
				],
			},
			{
				"time": 39.0, "sector": 3, "name": "DIENTES DE MAREA",
				"warning": 0.9, "duration": 4.5,
				"obstacles": [
					{"position": Vector2(80.0, 355.0), "size": Vector2(250.0, 26.0), "rotation": -0.28, "style": "wall"},
					{"position": Vector2(640.0, 945.0), "size": Vector2(250.0, 26.0), "rotation": -0.28, "style": "wall"},
				],
			},
			{
				"time": 45.5, "sector": 3, "name": "REVERSA",
				"warning": 0.85, "duration": 4.2,
				"obstacles": [
					{"position": Vector2(850.0, 520.0), "size": Vector2(220.0, 28.0), "travel": Vector2(-1040.0, 260.0), "style": "sweep"},
				],
			},
			{
				"time": 51.0, "sector": 3, "name": "CIERRE DE CAUCE",
				"warning": 0.8, "duration": 3.5,
				"obstacles": [
					{"position": Vector2(155.0, 650.0), "size": Vector2(300.0, 28.0), "style": "gate"},
					{"position": Vector2(690.0, 650.0), "size": Vector2(250.0, 28.0), "style": "gate"},
				],
			},
		],
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
		"surprise_events": [
			{
				"time": 5.5, "sector": 1, "name": "FISURA ROJA",
				"warning": 1.0, "duration": 3.8,
				"obstacles": [
					{"position": Vector2(360.0, 365.0), "size": Vector2(330.0, 28.0), "rotation": -0.18, "style": "wall"},
				],
			},
			{
				"time": 10.0, "sector": 1, "name": "AGUJA",
				"warning": 0.9, "duration": 3.8,
				"obstacles": [
					{"position": Vector2(120.0, 930.0), "size": Vector2(28.0, 260.0), "travel": Vector2(460.0, -470.0), "style": "sweep"},
				],
			},
			{
				"time": 16.5, "sector": 2, "name": "MORDAZA",
				"warning": 0.9, "duration": 4.0,
				"obstacles": [
					{"position": Vector2(120.0, 650.0), "size": Vector2(300.0, 28.0), "style": "gate"},
					{"position": Vector2(650.0, 650.0), "size": Vector2(260.0, 28.0), "style": "gate"},
				],
			},
			{
				"time": 21.5, "sector": 2, "name": "CIZALLA",
				"warning": 0.85, "duration": 4.2,
				"obstacles": [
					{"position": Vector2(-50.0, 440.0), "size": Vector2(220.0, 26.0), "travel": Vector2(850.0, 340.0), "style": "sweep"},
					{"position": Vector2(780.0, 870.0), "size": Vector2(220.0, 26.0), "travel": Vector2(-830.0, -300.0), "style": "sweep"},
				],
			},
			{
				"time": 28.5, "sector": 3, "name": "NUCLEO CERRADO",
				"warning": 0.85, "duration": 4.0,
				"obstacles": [
					{"position": Vector2(360.0, 650.0), "size": Vector2(28.0, 440.0), "rotation": 0.32, "style": "gate"},
				],
			},
			{
				"time": 34.0, "sector": 3, "name": "ORBITA PARTIDA",
				"warning": 0.8, "duration": 4.2,
				"obstacles": [
					{"position": Vector2(80.0, 410.0), "size": Vector2(300.0, 26.0), "rotation": 0.45, "style": "wall"},
					{"position": Vector2(650.0, 900.0), "size": Vector2(300.0, 26.0), "rotation": 0.45, "style": "wall"},
				],
			},
			{
				"time": 40.0, "sector": 3, "name": "LATIDO TRIPLE",
				"warning": 0.75, "duration": 4.0,
				"obstacles": [
					{"position": Vector2(40.0, 390.0), "size": Vector2(28.0, 190.0), "travel": Vector2(900.0, 0.0), "style": "sweep"},
					{"position": Vector2(680.0, 650.0), "size": Vector2(28.0, 190.0), "travel": Vector2(-720.0, 0.0), "style": "sweep"},
					{"position": Vector2(40.0, 910.0), "size": Vector2(28.0, 190.0), "travel": Vector2(900.0, 0.0), "style": "sweep"},
				],
			},
			{
				"time": 47.0, "sector": 3, "name": "JAULA INCLINADA",
				"warning": 0.75, "duration": 4.2,
				"obstacles": [
					{"position": Vector2(145.0, 470.0), "size": Vector2(350.0, 26.0), "rotation": -0.5, "style": "wall"},
					{"position": Vector2(590.0, 830.0), "size": Vector2(350.0, 26.0), "rotation": -0.5, "style": "wall"},
				],
			},
			{
				"time": 54.0, "sector": 3, "name": "COLAPSO",
				"warning": 0.7, "duration": 4.0,
				"obstacles": [
					{"position": Vector2(-100.0, 650.0), "size": Vector2(260.0, 30.0), "travel": Vector2(1080.0, 0.0), "style": "sweep"},
					{"position": Vector2(820.0, 650.0), "size": Vector2(260.0, 30.0), "travel": Vector2(-1080.0, 0.0), "style": "sweep"},
				],
			},
			{
				"time": 60.0, "sector": 3, "name": "ULTIMO LATIDO",
				"warning": 0.65, "duration": 4.0,
				"obstacles": [
					{"position": Vector2(360.0, 400.0), "size": Vector2(470.0, 28.0), "rotation": 0.2, "style": "gate"},
					{"position": Vector2(360.0, 900.0), "size": Vector2(470.0, 28.0), "rotation": -0.2, "style": "gate"},
				],
			},
		],
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
