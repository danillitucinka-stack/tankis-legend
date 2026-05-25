extends Node
class_name TankSelector

signal selected_tank_changed(selected_id: String)

@export var config_path: String = "res://Godot/tank_list.json"
@export var preview_anchor_path: NodePath
@export var save_key: String = "selected_tank"

var tank_list: Array = []
var current_index: int = 0
var current_preview: Node3D
var selected_id: String = ""
const SAVE_FILE: String = "user://selected_tank.cfg"

func _ready() -> void:
	load_tank_data()
	load_saved_tank()
	update_preview()

func load_tank_data() -> void:
	var file = FileAccess.open(config_path, FileAccess.ModeFlags.READ)
	if file == null:
		push_error("TankSelector: не удалось открыть " + config_path)
		return
	var json_text = file.get_as_text()
	file.close()

	var result = JSON.parse_string(json_text)
	if result.error != OK:
		push_error("TankSelector: ошибка JSON " + str(result.error) + " в " + config_path + ": " + str(result.error_string))
		return

	tank_list = result.result if result.result is Array else []

func load_saved_tank() -> void:
	var cfg = ConfigFile.new()
	var err = cfg.load(SAVE_FILE)
	if err == OK:
		selected_id = str(cfg.get_value("tank", save_key, ""))
		if selected_id != "":
			current_index = 0
			for i in range(tank_list.size()):
				var item = tank_list[i]
				if str(item.get("id", "")) == selected_id:
					current_index = i
					break
			if current_index < 0 or current_index >= tank_list.size():
				current_index = 0
	else:
		current_index = 0

func save_selected_tank() -> void:
	if current_index < 0 or current_index >= tank_list.size():
		return
	selected_id = str(tank_list[current_index].get("id", ""))
	var cfg = ConfigFile.new()
	cfg.load(SAVE_FILE)
	cfg.set_value("tank", save_key, selected_id)
	cfg.save(SAVE_FILE)
	emit_signal("selected_tank_changed", selected_id)

func update_preview() -> void:
	if current_preview != null:
		current_preview.queue_free()
		current_preview = null

	if tank_list.empty():
		return

	current_index = clamp(current_index, 0, tank_list.size() - 1)
	var item = tank_list[current_index]
	var scene_path = str(item.get("scene", ""))
	if scene_path == "":
		return

	var anchor = get_node_or_null(preview_anchor_path) as Node3D
	if anchor == null:
		push_error("TankSelector: preview_anchor_path не задан или не Node3D")
		return

	var packed = ResourceLoader.load(scene_path) as PackedScene
	if packed == null:
		push_error("TankSelector: не удалось загрузить сцену танка: " + scene_path)
		return

	current_preview = packed.instantiate() as Node3D
	if current_preview == null:
		push_error("TankSelector: загруженная сцена не Node3D: " + scene_path)
		return

	anchor.add_child(current_preview)
	current_preview.transform = Transform3D.IDENTITY
	current_preview.scale = Vector3.ONE

func next_tank() -> void:
	if tank_list.empty():
		return
	current_index = (current_index + 1) % tank_list.size()
	update_preview()

func previous_tank() -> void:
	if tank_list.empty():
		return
	current_index = (current_index - 1 + tank_list.size()) % tank_list.size()
	update_preview()

func select_current_tank() -> void:
	save_selected_tank()

func get_selected_tank_scene_path() -> String:
	if current_index >= 0 and current_index < tank_list.size():
		return str(tank_list[current_index].get("scene", ""))
	return ""

func get_current_tank_data() -> Dictionary:
	if current_index >= 0 and current_index < tank_list.size():
		return tank_list[current_index]
	return {}
