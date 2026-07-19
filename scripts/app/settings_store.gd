class_name SettingsStore
extends Node

signal settings_changed

const CONFIG_PATH := "user://settings.cfg"
const DEFAULT_VOLUME := 1.0
const DEFAULT_VIBRATION := true
const DEFAULT_SENSITIVITY := 1.0

var master_volume := DEFAULT_VOLUME
var vibration_enabled := DEFAULT_VIBRATION
var sensitivity := DEFAULT_SENSITIVITY


func _ready() -> void:
	_load_settings()
	_apply_volume()


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_volume()
	_save_settings()
	settings_changed.emit()


func set_vibration_enabled(enabled: bool) -> void:
	vibration_enabled = enabled
	_save_settings()
	settings_changed.emit()


func set_sensitivity(value: float) -> void:
	sensitivity = clampf(value, 0.65, 1.35)
	_save_settings()
	settings_changed.emit()


func vibrate(duration_ms: int = 60) -> void:
	if vibration_enabled and OS.has_feature("mobile"):
		Input.vibrate_handheld(duration_ms)


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
	master_volume = clampf(float(config.get_value("audio", "master_volume", DEFAULT_VOLUME)), 0.0, 1.0)
	vibration_enabled = bool(config.get_value("feedback", "vibration", DEFAULT_VIBRATION))
	sensitivity = clampf(float(config.get_value("controls", "sensitivity", DEFAULT_SENSITIVITY)), 0.65, 1.35)


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("feedback", "vibration", vibration_enabled)
	config.set_value("controls", "sensitivity", sensitivity)
	var error := config.save(CONFIG_PATH)
	if error != OK:
		push_warning("No se pudieron guardar los ajustes: %s" % error_string(error))


func _apply_volume() -> void:
	var bus_index := AudioServer.get_bus_index("Master")
	if bus_index < 0:
		return
	var volume_db := -80.0 if master_volume <= 0.001 else linear_to_db(master_volume)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
