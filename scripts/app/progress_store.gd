class_name ProgressStore
extends Node

signal progress_changed

const StoreCatalogScript = preload("res://scripts/app/store_catalog.gd")
const CONFIG_PATH := "user://progress.cfg"
const SAVE_VERSION := 1

var storage_path := CONFIG_PATH
var fragments := 0
var equipped_skin := "signal"
var equipped_power := "none"
var selected_level := 1
var owned_skins: Array[String] = ["signal"]
var owned_powers: Array[String] = ["none"]
var owned_levels: Array[int] = [1]
var completed_levels: Array[int] = []


func _ready() -> void:
	_load_progress()


func owns(category: String, item_id: String) -> bool:
	match category:
		"skins":
			return item_id in owned_skins
		"powers":
			return item_id in owned_powers
		"stages":
			var item := StoreCatalogScript.find_item(category, item_id)
			return not item.is_empty() and int(item.level) in owned_levels
	return false


func purchase(category: String, item_id: String) -> bool:
	var item := StoreCatalogScript.find_item(category, item_id)
	if item.is_empty() or owns(category, item_id):
		return false
	var cost := int(item.cost)
	if fragments < cost:
		return false
	fragments -= cost
	match category:
		"skins":
			owned_skins.append(item_id)
		"powers":
			owned_powers.append(item_id)
		"stages":
			owned_levels.append(int(item.level))
	_equip(category, item)
	_save_and_emit()
	return true


func select_owned(category: String, item_id: String) -> bool:
	if not owns(category, item_id):
		return false
	var item := StoreCatalogScript.find_item(category, item_id)
	if item.is_empty():
		return false
	_equip(category, item)
	_save_and_emit()
	return true


func add_fragments(amount: int) -> void:
	if amount <= 0:
		return
	fragments += amount
	_save_and_emit()


func complete_level(level_number: int) -> bool:
	if level_number in completed_levels:
		return false
	completed_levels.append(level_number)
	_save_progress()
	return true


func is_level_owned(level_number: int) -> bool:
	return level_number in owned_levels


func _equip(category: String, item: Dictionary) -> void:
	match category:
		"skins":
			equipped_skin = item.id
		"powers":
			equipped_power = item.id
		"stages":
			selected_level = int(item.level)


func _load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(storage_path) != OK:
		return
	fragments = maxi(0, int(config.get_value("wallet", "fragments", 0)))
	equipped_skin = str(config.get_value("loadout", "skin", "signal"))
	equipped_power = str(config.get_value("loadout", "power", "none"))
	selected_level = maxi(1, int(config.get_value("loadout", "level", 1)))
	owned_skins = _string_array(config.get_value("inventory", "skins", PackedStringArray(["signal"])))
	owned_powers = _string_array(config.get_value("inventory", "powers", PackedStringArray(["none"])))
	owned_levels = _int_array(config.get_value("inventory", "levels", PackedInt32Array([1])))
	completed_levels = _int_array(config.get_value("progress", "completed_levels", PackedInt32Array()))
	_repair_progress()


func _repair_progress() -> void:
	if "signal" not in owned_skins:
		owned_skins.append("signal")
	if "none" not in owned_powers:
		owned_powers.append("none")
	if 1 not in owned_levels:
		owned_levels.append(1)
	if equipped_skin not in owned_skins:
		equipped_skin = "signal"
	if equipped_power not in owned_powers:
		equipped_power = "none"
	if selected_level not in owned_levels:
		selected_level = 1


func _save_and_emit() -> void:
	_save_progress()
	progress_changed.emit()


func _save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("meta", "version", SAVE_VERSION)
	config.set_value("wallet", "fragments", fragments)
	config.set_value("loadout", "skin", equipped_skin)
	config.set_value("loadout", "power", equipped_power)
	config.set_value("loadout", "level", selected_level)
	config.set_value("inventory", "skins", PackedStringArray(owned_skins))
	config.set_value("inventory", "powers", PackedStringArray(owned_powers))
	config.set_value("inventory", "levels", PackedInt32Array(owned_levels))
	config.set_value("progress", "completed_levels", PackedInt32Array(completed_levels))
	var error := config.save(storage_path)
	if error != OK:
		push_warning("No se pudo guardar el progreso: %s" % error_string(error))


func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	for entry in value:
		result.append(str(entry))
	return result


func _int_array(value: Variant) -> Array[int]:
	var result: Array[int] = []
	for entry in value:
		result.append(int(entry))
	return result
