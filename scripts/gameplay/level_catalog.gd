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
		"visual_palette": {
			"void": Color("#030b12"),
			"arena": Color("#09242a"),
			"primary": Color("#55f2bd"),
			"secondary": Color("#32aee8"),
			"danger": Color("#ff5b52"),
			"warning": Color("#ffc857"),
			"name": "MAREA ESMERALDA",
			"background_path": "res://assets/visuals/arena-emerald.png",
		},
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
		"visual_palette": {
			"void": Color("#030817"),
			"arena": Color("#071c38"),
			"primary": Color("#58c8ff"),
			"secondary": Color("#8c7bff"),
			"danger": Color("#ff6f4f"),
			"warning": Color("#ffd35a"),
			"name": "CORRIENTE ELECTRICA",
			"background_path": "res://assets/visuals/arena-electric.png",
		},
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
		"visual_palette": {
			"void": Color("#10030d"),
			"arena": Color("#260b22"),
			"primary": Color("#ff6295"),
			"secondary": Color("#b67cff"),
			"danger": Color("#ff314f"),
			"warning": Color("#ffe36a"),
			"name": "NUCLEO CARMESI",
			"background_path": "res://assets/visuals/arena-crimson.png",
		},
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

const EXTENDED_LEVELS := [
	{
		"number": 4,
		"title": "FORJA ASCENDENTE",
		"difficulty": "EXPERTA",
		"duration": 68.0,
		"echo_interval": 4.2,
		"patrol_phase_time": 9.0,
		"pulse_phase_time": 20.0,
		"follow_delay": 1.08,
		"minimum_segment_distance": 335.0,
		"first_clear_bonus": 60,
		"pattern_count": 9,
		"pattern_names": [
			"YUNQUE SOLAR", "VALVULA ABIERTA", "MARTILLO DOBLE",
			"COLADA LATERAL", "PISON DE COBRE", "HORNO PARTIDO",
			"CHISPA CRUZADA", "TREN DE ESCORIA", "SELLO DE FORJA",
		],
		"visual_palette": {
			"void": Color("#0d0803"),
			"arena": Color("#28170a"),
			"primary": Color("#ffb347"),
			"secondary": Color("#ff6b2c"),
			"danger": Color("#ff3d2e"),
			"warning": Color("#ffe08a"),
			"name": "FORJA AMBAR",
			"surface_style": "forge",
			"background_path": "res://assets/visuals/arena-amber-forge.png",
		},
		"arena_profile": {
			"upper_position": Vector2(190.0, 430.0),
			"upper_size": Vector2(230.0, 30.0),
			"upper_rotation": 0.18,
			"lower_position": Vector2(530.0, 860.0),
			"lower_size": Vector2(230.0, 30.0),
			"lower_rotation": -0.18,
			"patrol_position": Vector2(360.0, 650.0),
			"patrol_size": Vector2(150.0, 28.0),
			"patrol_offset": Vector2(250.0, 120.0),
			"patrol_period": 4.2,
			"pulse_position": Vector2(360.0, 650.0),
			"pulse_size": Vector2(390.0, 30.0),
			"pulse_rotation": 0.18,
			"pulse_warning": 0.62,
			"pulse_active": 2.2,
			"pulse_safe": 0.9,
		},
	},
	{
		"number": 5,
		"title": "ABISMO VIOLETA",
		"difficulty": "EXPERTA",
		"duration": 72.0,
		"echo_interval": 3.9,
		"patrol_phase_time": 8.5,
		"pulse_phase_time": 18.0,
		"follow_delay": 1.0,
		"minimum_segment_distance": 345.0,
		"first_clear_bonus": 75,
		"pattern_count": 10,
		"pattern_names": [
			"UMBRAL INVERSO", "LENTE OSCURA", "ORBITA CAIDA",
			"ARCO DE VACIO", "PRISMA GEMELO", "MAREA ULTRAVIOLETA",
			"NODO IMPOSIBLE", "HORIZONTE CORTADO", "ECLIPSE MOVIL",
			"SINGULARIDAD",
		],
		"visual_palette": {
			"void": Color("#070313"),
			"arena": Color("#170c35"),
			"primary": Color("#c084fc"),
			"secondary": Color("#6d5dfc"),
			"danger": Color("#ff4fa3"),
			"warning": Color("#7ef9ff"),
			"name": "VACIO VIOLETA",
			"surface_style": "crystal",
			"background_path": "res://assets/visuals/arena-violet-abyss.png",
		},
		"arena_profile": {
			"upper_position": Vector2(205.0, 455.0),
			"upper_size": Vector2(210.0, 27.0),
			"upper_rotation": -0.62,
			"lower_position": Vector2(520.0, 835.0),
			"lower_size": Vector2(210.0, 27.0),
			"lower_rotation": 0.62,
			"patrol_position": Vector2(360.0, 650.0),
			"patrol_size": Vector2(28.0, 150.0),
			"patrol_offset": Vector2(220.0, -180.0),
			"patrol_period": 3.9,
			"pulse_position": Vector2(360.0, 650.0),
			"pulse_size": Vector2(30.0, 430.0),
			"pulse_rotation": -0.24,
			"pulse_warning": 0.58,
			"pulse_active": 2.35,
			"pulse_safe": 0.8,
		},
	},
	{
		"number": 6,
		"title": "SANTUARIO GLACIAL",
		"difficulty": "MAESTRA",
		"duration": 76.0,
		"echo_interval": 4.3,
		"patrol_phase_time": 8.0,
		"pulse_phase_time": 17.0,
		"follow_delay": 1.02,
		"minimum_segment_distance": 350.0,
		"first_clear_bonus": 90,
		"pattern_count": 11,
		"pattern_names": [
			"AGUJA DE HIELO", "ESCARCHA DOBLE", "FALLA CRIOGENICA",
			"ALUD LATERAL", "SELLO POLAR", "COLUMNA BLANCA",
			"CRISTAL EN FUGA", "CERO ABSOLUTO", "CASCADA FRIA",
			"CAMARA SELLADA", "DESHIELO FINAL",
		],
		"visual_palette": {
			"void": Color("#020b13"),
			"arena": Color("#09243a"),
			"primary": Color("#80f2ff"),
			"secondary": Color("#4da3ff"),
			"danger": Color("#ff597d"),
			"warning": Color("#e9feff"),
			"name": "SANTUARIO GLACIAL",
			"surface_style": "ice",
			"background_path": "res://assets/visuals/arena-glacial-sanctuary.png",
		},
		"arena_profile": {
			"upper_position": Vector2(220.0, 390.0),
			"upper_size": Vector2(30.0, 250.0),
			"upper_rotation": 0.22,
			"lower_position": Vector2(500.0, 905.0),
			"lower_size": Vector2(30.0, 250.0),
			"lower_rotation": -0.22,
			"patrol_position": Vector2(360.0, 650.0),
			"patrol_size": Vector2(145.0, 26.0),
			"patrol_offset": Vector2(0.0, 280.0),
			"patrol_period": 4.7,
			"pulse_position": Vector2(360.0, 650.0),
			"pulse_size": Vector2(420.0, 28.0),
			"pulse_rotation": 0.0,
			"pulse_warning": 0.68,
			"pulse_active": 2.15,
			"pulse_safe": 0.72,
		},
	},
	{
		"number": 7,
		"title": "MOTOR DEL SOL",
		"difficulty": "MAESTRA",
		"duration": 80.0,
		"echo_interval": 3.8,
		"patrol_phase_time": 7.5,
		"pulse_phase_time": 16.0,
		"follow_delay": 0.95,
		"minimum_segment_distance": 365.0,
		"first_clear_bonus": 110,
		"pattern_count": 12,
		"pattern_names": [
			"IGNICION", "CORONA ABIERTA", "PISTON ROJO", "RAIL DE FUEGO",
			"TURBINA GEMELA", "SOBRECARGA", "EJE INCANDESCENTE",
			"CAMARA DE PRESION", "CHORRO SOLAR", "ANILLO ROTO",
			"FUSION CRITICA", "APAGON TERMICO",
		],
		"visual_palette": {
			"void": Color("#100503"),
			"arena": Color("#321008"),
			"primary": Color("#ffd166"),
			"secondary": Color("#ff7b22"),
			"danger": Color("#ff2442"),
			"warning": Color("#fff0a6"),
			"name": "MOTOR SOLAR",
			"surface_style": "forge",
			"background_path": "res://assets/visuals/arena-amber-forge.png",
		},
		"arena_profile": {
			"upper_position": Vector2(175.0, 420.0),
			"upper_size": Vector2(250.0, 28.0),
			"upper_rotation": 0.42,
			"lower_position": Vector2(545.0, 880.0),
			"lower_size": Vector2(250.0, 28.0),
			"lower_rotation": -0.42,
			"patrol_position": Vector2(360.0, 650.0),
			"patrol_size": Vector2(170.0, 28.0),
			"patrol_offset": Vector2(280.0, 0.0),
			"patrol_period": 3.5,
			"pulse_position": Vector2(360.0, 650.0),
			"pulse_size": Vector2(34.0, 470.0),
			"pulse_rotation": 0.38,
			"pulse_warning": 0.52,
			"pulse_active": 2.5,
			"pulse_safe": 0.7,
		},
	},
	{
		"number": 8,
		"title": "HORIZONTE ROTO",
		"difficulty": "EXTREMA",
		"duration": 84.0,
		"echo_interval": 3.7,
		"patrol_phase_time": 7.0,
		"pulse_phase_time": 15.0,
		"follow_delay": 0.9,
		"minimum_segment_distance": 375.0,
		"first_clear_bonus": 135,
		"pattern_count": 13,
		"pattern_names": [
			"PARALAJE", "GRAVEDAD CERO", "ESPEJO NEGRO", "PORTAL GEMELO",
			"ARISTA COSMICA", "VACIO EN MARCHA", "LENTE PARTIDA",
			"UMBRAL TRIPLE", "CAIDA ORBITAL", "NOCHE INVERTIDA",
			"COLISION DE LUNAS", "BORDE DEL TIEMPO", "FIN DEL HORIZONTE",
		],
		"visual_palette": {
			"void": Color("#05020f"),
			"arena": Color("#210b35"),
			"primary": Color("#f08cff"),
			"secondary": Color("#55d8ff"),
			"danger": Color("#ff387d"),
			"warning": Color("#b7ffef"),
			"name": "HORIZONTE VIOLETA",
			"surface_style": "crystal",
			"background_path": "res://assets/visuals/arena-violet-abyss.png",
		},
		"arena_profile": {
			"upper_position": Vector2(195.0, 445.0),
			"upper_size": Vector2(235.0, 27.0),
			"upper_rotation": -0.78,
			"lower_position": Vector2(525.0, 850.0),
			"lower_size": Vector2(235.0, 27.0),
			"lower_rotation": 0.78,
			"patrol_position": Vector2(360.0, 650.0),
			"patrol_size": Vector2(30.0, 180.0),
			"patrol_offset": Vector2(270.0, 210.0),
			"patrol_period": 3.25,
			"pulse_position": Vector2(360.0, 650.0),
			"pulse_size": Vector2(460.0, 30.0),
			"pulse_rotation": -0.55,
			"pulse_warning": 0.5,
			"pulse_active": 2.55,
			"pulse_safe": 0.65,
		},
	},
	{
		"number": 9,
		"title": "CORAZON DE HIELO",
		"difficulty": "ABISMO",
		"duration": 90.0,
		"echo_interval": 3.6,
		"patrol_phase_time": 6.5,
		"pulse_phase_time": 14.0,
		"follow_delay": 0.88,
		"minimum_segment_distance": 390.0,
		"first_clear_bonus": 165,
		"pattern_count": 14,
		"pattern_names": [
			"PRIMER INVIERNO", "COLMILLO POLAR", "VIDRIO NEGRO",
			"CRIOPULSO", "NIEVE INVERSA", "FRACTURA AZUL",
			"PRISION DE ESCARCHA", "ALUD DOBLE", "AGUJA MOVIL",
			"TEMPERATURA CERO", "TEMPLO QUEBRADO", "NUCLEO CONGELADO",
			"ULTIMO DESHIELO", "SILENCIO BLANCO",
		],
		"visual_palette": {
			"void": Color("#01070d"),
			"arena": Color("#061e31"),
			"primary": Color("#d7fbff"),
			"secondary": Color("#42cfff"),
			"danger": Color("#ff3f72"),
			"warning": Color("#9fffea"),
			"name": "CORAZON GLACIAL",
			"surface_style": "ice",
			"background_path": "res://assets/visuals/arena-glacial-sanctuary.png",
		},
		"arena_profile": {
			"upper_position": Vector2(180.0, 410.0),
			"upper_size": Vector2(255.0, 28.0),
			"upper_rotation": 0.82,
			"lower_position": Vector2(540.0, 890.0),
			"lower_size": Vector2(255.0, 28.0),
			"lower_rotation": -0.82,
			"patrol_position": Vector2(360.0, 650.0),
			"patrol_size": Vector2(180.0, 28.0),
			"patrol_offset": Vector2(0.0, 310.0),
			"patrol_period": 3.1,
			"pulse_position": Vector2(360.0, 650.0),
			"pulse_size": Vector2(34.0, 500.0),
			"pulse_rotation": 0.62,
			"pulse_warning": 0.48,
			"pulse_active": 2.7,
			"pulse_safe": 0.6,
		},
	},
]


static func get_level(level_number: int):
	for config in LEVELS:
		if config.number == level_number:
			return LevelDefinitionScript.new(config)
	for blueprint in EXTENDED_LEVELS:
		if blueprint.number == level_number:
			var config: Dictionary = blueprint.duplicate(true)
			config["surprise_events"] = _build_extended_events(config)
			return LevelDefinitionScript.new(config)
	return null


static func has_level(level_number: int) -> bool:
	return get_level(level_number) != null


static func first_level():
	return LevelDefinitionScript.new(LEVELS[0])


static func level_count() -> int:
	return LEVELS.size() + EXTENDED_LEVELS.size()


static func _build_extended_events(config: Dictionary) -> Array:
	var events: Array = []
	var count := int(config.pattern_count)
	var names: Array = config.pattern_names
	var duration := float(config.duration)
	var level_number := int(config.number)
	for index in count:
		var progress := float(index) / float(maxi(1, count - 1))
		var event_time := lerpf(5.0, duration - 5.0, progress)
		var variant := (index + level_number) % 6
		var sector := mini(3, 1 + int(progress * 3.0))
		var warning := maxf(0.62, 1.08 - float(index) * 0.025)
		var active_duration := 3.6 + float((index + level_number) % 3) * 0.35
		var obstacle_seed := level_number * 97 + index * 53
		events.append({
			"time": snappedf(event_time, 0.1),
			"sector": sector,
			"name": str(names[index]),
			"warning": warning,
			"duration": active_duration,
			"obstacles": _pattern_obstacles(variant, obstacle_seed),
		})
	return events


static func _pattern_obstacles(variant: int, seed: int) -> Array:
	var x_shift := float((seed % 5) - 2) * 34.0
	var y_shift := float((int(seed / 5) % 5) - 2) * 38.0
	match variant:
		0:
			return [{
				"position": Vector2(360.0 + x_shift, 390.0 + y_shift),
				"size": Vector2(320.0, 28.0),
				"rotation": 0.18 if seed % 2 == 0 else -0.18,
				"style": "wall",
			}]
		1:
			return [
				{"position": Vector2(175.0 + x_shift * 0.25, 530.0), "size": Vector2(28.0, 250.0), "style": "gate"},
				{"position": Vector2(545.0 - x_shift * 0.25, 780.0), "size": Vector2(28.0, 250.0), "style": "gate"},
			]
		2:
			return [{
				"position": Vector2(-90.0, 470.0 + y_shift),
				"size": Vector2(210.0, 28.0),
				"travel": Vector2(990.0, 250.0 if seed % 2 == 0 else -250.0),
				"style": "sweep",
			}]
		3:
			return [
				{"position": Vector2(190.0, 430.0 + y_shift * 0.4), "size": Vector2(270.0, 26.0), "rotation": 0.48, "style": "wall"},
				{"position": Vector2(535.0, 860.0 - y_shift * 0.4), "size": Vector2(270.0, 26.0), "rotation": -0.48, "style": "wall"},
			]
		4:
			return [{
				"position": Vector2(180.0 + x_shift, 70.0),
				"size": Vector2(28.0, 220.0),
				"travel": Vector2(360.0, 1080.0),
				"style": "sweep",
			}]
		_:
			return [
				{"position": Vector2(360.0, 410.0 + y_shift * 0.35), "size": Vector2(360.0, 27.0), "style": "gate"},
				{"position": Vector2(360.0 + x_shift * 0.35, 820.0), "size": Vector2(30.0, 300.0), "style": "gate"},
			]
