class_name StoreOverlay
extends ColorRect

signal closed

const StoreCatalogScript = preload("res://scripts/app/store_catalog.gd")
const StoreItemPreviewScript = preload("res://scripts/menu/store_item_preview.gd")
const StoreTouchActionScript = preload("res://scripts/menu/store_touch_action.gd")

@onready var panel: PanelContainer = $Center/Panel
@onready var wallet_label: Label = $Center/Panel/Content/Header/Wallet
@onready var skins_button: Button = $Center/Panel/Content/Tabs/Skins
@onready var stages_button: Button = $Center/Panel/Content/Tabs/Stages
@onready var powers_button: Button = $Center/Panel/Content/Tabs/Powers
@onready var list: ScrollContainer = $Center/Panel/Content/List
@onready var cards: VBoxContainer = $Center/Panel/Content/List/Cards
@onready var status_label: Label = $Center/Panel/Content/Status
@onready var back_button: Button = $Center/Panel/Content/Back
@onready var progress_store := get_node("/root/Progress") as ProgressStore

var _category := "skins"


func _ready() -> void:
	skins_button.pressed.connect(_show_category.bind("skins"))
	stages_button.pressed.connect(_show_category.bind("stages"))
	powers_button.pressed.connect(_show_category.bind("powers"))
	back_button.pressed.connect(close)
	progress_store.progress_changed.connect(_refresh)
	_refresh()


func open(category := "skins") -> void:
	_category = category
	status_label.text = _category_status(category)
	_refresh()
	visible = true
	panel.modulate.a = 0.0
	panel.scale = Vector2.ONE * 0.94
	panel.pivot_offset = panel.size * 0.5
	var tween := create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.22)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	back_button.grab_focus()


func close() -> void:
	visible = false
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _show_category(category: String) -> void:
	_category = category
	status_label.text = _category_status(category)
	list.scroll_vertical = 0
	_refresh()


func _category_status(category: String) -> String:
	if category == "stages":
		return "DESLIZA SOBRE LAS TARJETAS PARA VER MAS ETAPAS"
	return "COMPRA UNA VEZ Y EQUIPA CUANDO QUIERAS"


func _refresh() -> void:
	wallet_label.text = "%d FRAGMENTOS" % progress_store.fragments
	skins_button.disabled = _category == "skins"
	stages_button.disabled = _category == "stages"
	powers_button.disabled = _category == "powers"
	for child in cards.get_children():
		cards.remove_child(child)
		child.queue_free()
	for item in StoreCatalogScript.items_for(_category):
		cards.add_child(_create_card(item))


func _create_card(item: Dictionary) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0.0, 146.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _card_style(_item_color(item)))

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 18)
	panel.add_child(row)

	var preview = StoreItemPreviewScript.new()
	preview.custom_minimum_size = Vector2(104.0, 104.0)
	preview.configure(_category, item)
	row.add_child(preview)

	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	copy.add_theme_constant_override("separation", 7)
	row.add_child(copy)

	var name_label := Label.new()
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.text = str(item.name)
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.add_theme_color_override("font_color", _item_color(item))
	copy.add_child(name_label)

	var description_label := Label.new()
	description_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	description_label.text = str(item.description)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_font_size_override("font_size", 18)
	description_label.add_theme_color_override("font_color", Color(0.68, 0.8, 0.82))
	copy.add_child(description_label)

	var action_wrapper := Control.new()
	action_wrapper.custom_minimum_size = Vector2(178.0, 76.0)
	action_wrapper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(action_wrapper)

	var action := Button.new()
	action.custom_minimum_size = Vector2(178.0, 76.0)
	action.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	action.mouse_filter = Control.MOUSE_FILTER_IGNORE
	action.text = _action_text(item)
	action.add_theme_font_size_override("font_size", 20)
	action.add_theme_color_override("font_color", Color(0.03, 0.08, 0.1))
	action.add_theme_color_override("font_disabled_color", Color(0.55, 0.72, 0.7))
	action.add_theme_stylebox_override("normal", _action_style(Color(0.18, 0.82, 0.655)))
	action.add_theme_stylebox_override("hover", _action_style(Color(0.584, 1.0, 0.796)))
	action.add_theme_stylebox_override("pressed", _action_style(Color(0.42, 0.9, 0.7)))
	action.add_theme_stylebox_override("disabled", _action_style(Color(0.06, 0.15, 0.17)))
	action.disabled = _is_active(item)
	action.pressed.connect(_on_item_pressed.bind(str(item.id)))
	action_wrapper.add_child(action)

	var touch_action = StoreTouchActionScript.new()
	touch_action.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	touch_action.tapped.connect(_on_item_pressed.bind(str(item.id)))
	action_wrapper.add_child(touch_action)
	return panel


func _on_item_pressed(item_id: String) -> void:
	var item := StoreCatalogScript.find_item(_category, item_id)
	if item.is_empty():
		return
	if progress_store.owns(_category, item_id):
		progress_store.select_owned(_category, item_id)
		status_label.text = "%s EQUIPADO" % str(item.name)
	elif progress_store.purchase(_category, item_id):
		status_label.text = "%s DESBLOQUEADO Y EQUIPADO" % str(item.name)
	else:
		var missing := maxi(0, int(item.cost) - progress_store.fragments)
		status_label.text = "FALTAN %d FRAGMENTOS" % missing


func _action_text(item: Dictionary) -> String:
	if _is_active(item):
		return "EQUIPADO" if _category != "stages" else "SELECCIONADA"
	if progress_store.owns(_category, str(item.id)):
		return "EQUIPAR" if _category != "stages" else "SELECCIONAR"
	return "%d FRAG." % int(item.cost)


func _is_active(item: Dictionary) -> bool:
	match _category:
		"skins":
			return progress_store.equipped_skin == item.id
		"powers":
			return progress_store.equipped_power == item.id
		"stages":
			return progress_store.selected_level == int(item.level)
	return false


func _item_color(item: Dictionary) -> Color:
	if _category == "skins":
		return item.primary
	if _category == "powers":
		return Color(0.58, 0.72, 1.0)
	return item.get("accent", Color(1.0, 0.68, 0.25))


func _card_style(accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.018, 0.06, 0.082, 0.98)
	style.border_color = Color(accent, 0.42)
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(accent, 0.09)
	style.shadow_size = 9
	style.content_margin_left = 22.0
	style.content_margin_top = 16.0
	style.content_margin_right = 18.0
	style.content_margin_bottom = 16.0
	return style


func _action_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(14)
	style.shadow_color = Color(color, 0.18)
	style.shadow_size = 8
	return style
