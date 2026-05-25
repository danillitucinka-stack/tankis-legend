extends CharacterBody3D

@export var speed: float = 6.0

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if input_dir.length() > 0.1:
		input_dir = input_dir.normalized()
		velocity = input_dir * speed
		look_at(global_transform.origin + input_dir, Vector3.UP)
	else:
		velocity = Vector3.ZERO

	move_and_slide()
