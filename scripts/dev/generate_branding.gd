extends SceneTree

const SOURCE_PATH := "res://assets/branding/icon.svg"
const TARGET_PATH := "res://assets/branding/icon.png"


func _init() -> void:
	var texture := load(SOURCE_PATH) as Texture2D
	if texture == null:
		push_error("No se pudo cargar %s" % SOURCE_PATH)
		quit(1)
		return
	var image := texture.get_image()

	var error := image.save_png(TARGET_PATH)
	if error != OK:
		push_error("No se pudo generar %s: error %d" % [TARGET_PATH, error])
		quit(1)
		return

	quit()
