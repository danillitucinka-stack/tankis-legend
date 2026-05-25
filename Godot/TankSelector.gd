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
	if not FileAccess.file_exists(config_path):
		push_error("TankSelector: файл не найден: " + config_path)
		return
		
	var file = FileAccess.open(config_path, FileAccess.ModeFlags.READ)
	var json_text: String = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		push_error("TankSelector: ошибка JSON")
		return

	var data = json.data
	tank_list = data if data is Array else []

func load_saved_tank() -> void:
	var cfg = ConfigFile.new()
	if cfg.load(SAVE_FILE) == OK:
		selected_id = str(cfg.get_value("tank", save_key, ""))
		for i in range(tank_list.size()):
			if str(tank_list[i].get("id", "")) == selected_id:
				current_index = i
				break

	current_index = clamp(current_index, 0, tank_list.size() - 1)

func save_selected_tank() -> void:
	if tank_list.is_empty():
		return
	selected_id = str(tank_list[current_index].get("id", ""))
	var cfg = ConfigFile.new()
	cfg.set_value("tank", save_key, selected_id)
	cfg.save(SAVE_FILE)
	emit_signal("selected_tank_changed", selected_id)

func update_preview() -> void:
	if current_preview != null:
		current_preview.queue_free()
		current_preview = null

	if tank_list.is_empty():
		return

	current_index = clamp(current_index, 0, tank_list.size() - 1)
	var item: Dictionary = tank_list[current_index]
	var scene_path: String = str(item.get("scene", ""))
	
	if scene_path == "":
		return

	var anchor = get_node_or_null(preview_anchor_path) as Node3D
	if anchor == null:
		return

	var packed = ResourceLoader.load(scene_path)
	if packed == null:
		push_error("Не удалось загрузить: " + scene_path)
		return

	current_preview = packed.instantiate() as Node3D
	anchor.add_child(current_preview)
	current_preview.transform = Transform3D.IDENTITY

func next_tank() -> void:
	if tank_list.is_empty(): return
	current_index = (current_index + 1) % tank_list.size()
	update_preview()

func previous_tank() -> void:
	if tank_list.is_empty(): return
	current_index = (current_index - 1 + tank_list.size()) % tank_list.size()
	update_preview()
