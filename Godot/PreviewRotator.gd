extends Node3D

@export var enabled: bool = true
@export var speed_deg: float = 18.0

func _process(delta: float) -> void:
    if not enabled:
        return
    rotation_degrees.y += speed_deg * delta
