extends Node3D

@onready var selector: Node = $TankSelector
@onready var label: Label = $UI/Control/Panel/TankLabel
@onready var next_button: Button = $UI/Control/Panel/NextButton
@onready var prev_button: Button = $UI/Control/Panel/PreviousButton
@onready var select_button: Button = $UI/Control/Panel/SelectButton

func _ready() -> void:
    next_button.pressed.connect(Callable(self, "_on_next_pressed"))
    prev_button.pressed.connect(Callable(self, "_on_previous_pressed"))
    select_button.pressed.connect(Callable(self, "_on_select_pressed"))
    selector.connect("selected_tank_changed", Callable(self, "_on_selected_tank_changed"))
    update_ui()

func _on_next_pressed() -> void:
    selector.call("next_tank")
    update_ui()

func _on_previous_pressed() -> void:
    selector.call("previous_tank")
    update_ui()

func _on_select_pressed() -> void:
    selector.call("select_current_tank")
    update_ui()

func _on_selected_tank_changed(selected_id: String) -> void:
    update_ui()

func update_ui() -> void:
    var tank_data = selector.call("get_current_tank_data")
    if typeof(tank_data) == TYPE_DICTIONARY:
        label.text = "Текущий танк: %s" % [tank_data.get("name", "не задан")]
    else:
        label.text = "Танк не найден"
