class_name StoreCatalog
extends RefCounted

const SKINS := [
	{
		"id": "signal",
		"name": "SENAL",
		"description": "La luz original de ECOS.",
		"cost": 0,
		"primary": Color(0.584, 1.0, 0.796),
		"glow": Color(0.18, 0.82, 0.655),
	},
	{
		"id": "ember",
		"name": "BRASA",
		"description": "Una estela encendida en rojo coral.",
		"cost": 30,
		"primary": Color(1.0, 0.56, 0.32),
		"glow": Color(1.0, 0.24, 0.16),
	},
	{
		"id": "ion",
		"name": "ION",
		"description": "Pulso electrico de alta frecuencia.",
		"cost": 75,
		"primary": Color(0.46, 0.82, 1.0),
		"glow": Color(0.28, 0.42, 1.0),
	},
	{
		"id": "void",
		"name": "VACIO",
		"description": "Materia violeta nacida entre ecos.",
		"cost": 150,
		"primary": Color(0.9, 0.58, 1.0),
		"glow": Color(0.52, 0.18, 0.86),
	},
]

const STAGES := [
	{
		"id": "level_1",
		"level": 1,
		"name": "PRIMERA ESTELA",
		"description": "45 s · cadena base · tres amenazas.",
		"cost": 0,
	},
	{
		"id": "level_2",
		"level": 2,
		"name": "CONTRACORRIENTE",
		"description": "55 s · corredores verticales · ecos mas frecuentes.",
		"cost": 20,
	},
	{
		"id": "level_3",
		"level": 3,
		"name": "NUCLEO ROJO",
		"description": "65 s · arena cruzada · maxima compresion.",
		"cost": 55,
	},
]

const POWERS := [
	{
		"id": "none",
		"name": "SIN PODER",
		"description": "Sobrevive solo con tu movimiento.",
		"cost": 0,
	},
	{
		"id": "pulse",
		"name": "PULSO",
		"description": "Una vez por partida, disipa el eco mas reciente.",
		"cost": 35,
	},
	{
		"id": "stabilizer",
		"name": "ESTABILIZADOR",
		"description": "Una vez por partida, reduce tres niveles de presion.",
		"cost": 75,
	},
	{
		"id": "shield",
		"name": "DESFASE",
		"description": "Absorbe automaticamente el primer impacto.",
		"cost": 150,
	},
]


static func items_for(category: String) -> Array:
	match category:
		"skins":
			return SKINS
		"stages":
			return STAGES
		"powers":
			return POWERS
	return []


static func find_item(category: String, item_id: String) -> Dictionary:
	for item in items_for(category):
		if item.id == item_id:
			return item
	return {}


static func skin_colors(skin_id: String) -> Dictionary:
	var skin := find_item("skins", skin_id)
	if skin.is_empty():
		skin = SKINS[0]
	return {
		"primary": skin.primary,
		"glow": skin.glow,
	}
