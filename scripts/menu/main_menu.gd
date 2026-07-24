class_name MainMenu
extends Control

signal play_requested(level_number: int)

@onready var content: MarginContainer = $Content
@onready var play_button: Button = $Content/Layout/Actions/Play
@onready var tutorial_button: Button = $Content/Layout/Actions/Tutorial
@onready var store_button: Button = $Content/Layout/Actions/Store
@onready var settings_button: Button = $Content/Layout/Actions/Settings
@onready var status_label: Label = $Content/Layout/Top/Status
@onready var footer_label: Label = $Content/Layout/Footer
@onready var tutorial_overlay: ColorRect = $TutorialOverlay
@onready var tutorial_back_button: Button = $TutorialOverlay/Center/Panel/Content/Back
@onready var settings_overlay: ColorRect = $SettingsOverlay
@onready var volume_slider: HSlider = $SettingsOverlay/Center/Panel/Content/VolumeSlider
@onready var volume_value: Label = $SettingsOverlay/Center/Panel/Content/VolumeHeader/Value
@onready var vibration_toggle: CheckButton = $SettingsOverlay/Center/Panel/Content/VibrationRow/Toggle
@onready var sensitivity_slider: HSlider = $SettingsOverlay/Center/Panel/Content/SensitivitySlider
@onready var sensitivity_value: Label = $SettingsOverlay/Center/Panel/Content/SensitivityHeader/Value
@onready var settings_back_button: Button = $SettingsOverlay/Center/Panel/Content/Back
@onready var store_overlay: StoreOverlay = $StoreOverlay
@onready var settings_store := get_node("/root/Settings") as SettingsStore
@onready var progress_store := get_node("/root/Progress") as ProgressStore


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	tutorial_button.pressed.connect(_show_tutorial)
	tutorial_back_button.pressed.connect(_hide_tutorial)
	settings_button.pressed.connect(_show_settings)
	store_button.pressed.connect(open_store)
	store_overlay.closed.connect(_on_store_closed)
	progress_store.progress_changed.connect(_sync_progress)
	settings_back_button.pressed.connect(_hide_settings)
	volume_slider.value_changed.connect(_on_volume_changed)
	vibration_toggle.toggled.connect(_on_vibration_toggled)
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	tutorial_overlay.visible = false
	settings_overlay.visible = false
	_sync_settings()
	_sync_progress()
	_animate_entry()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if store_overlay.visible:
			store_overlay.close()
			get_viewport().set_input_as_handled()
		elif tutorial_overlay.visible:
			_hide_tutorial()
			get_viewport().set_input_as_handled()
		elif settings_overlay.visible:
			_hide_settings()
			get_viewport().set_input_as_handled()


func _on_play_pressed() -> void:
	play_requested.emit(progress_store.selected_level)


func open_store(category := "skins") -> void:
	store_overlay.open(category)


func _on_store_closed() -> void:
	_sync_progress()
	store_button.grab_focus()


func _show_tutorial() -> void:
	tutorial_overlay.visible = true
	tutorial_back_button.grab_focus()


func _hide_tutorial() -> void:
	tutorial_overlay.visible = false
	tutorial_button.grab_focus()


func _show_settings() -> void:
	_sync_settings()
	settings_overlay.visible = true
	settings_back_button.grab_focus()


func _hide_settings() -> void:
	settings_overlay.visible = false
	settings_button.grab_focus()


func _sync_settings() -> void:
	volume_slider.set_value_no_signal(settings_store.master_volume)
	vibration_toggle.set_pressed_no_signal(settings_store.vibration_enabled)
	sensitivity_slider.set_value_no_signal(settings_store.sensitivity)
	_update_setting_labels()


func _on_volume_changed(value: float) -> void:
	settings_store.set_master_volume(value)
	_update_setting_labels()


func _on_vibration_toggled(enabled: bool) -> void:
	settings_store.set_vibration_enabled(enabled)
	_update_setting_labels()


func _on_sensitivity_changed(value: float) -> void:
	settings_store.set_sensitivity(value)
	_update_setting_labels()


func _update_setting_labels() -> void:
	volume_value.text = "%d%%" % roundi(settings_store.master_volume * 100.0)
	sensitivity_value.text = "%.2fx" % settings_store.sensitivity
	vibration_toggle.text = "ACTIVA" if settings_store.vibration_enabled else "INACTIVA"


func _sync_progress() -> void:
	status_label.text = "%d FRAGMENTOS" % progress_store.fragments
	play_button.text = "JUGAR // ETAPA %02d" % progress_store.selected_level
	footer_label.text = "SKIN %s  /  PODER %s" % [
		progress_store.equipped_skin.to_upper(),
		progress_store.equipped_power.to_upper(),
	]


func _animate_entry() -> void:
	content.modulate.a = 0.0
	content.position.y = 28.0
	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(content, "modulate:a", 1.0, 0.55)
	tween.tween_property(content, "position:y", 0.0, 0.7)
