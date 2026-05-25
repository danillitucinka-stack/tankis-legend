extends CharacterBody3D
class_name BotAI

@export var player_path: NodePath
@export var speed: float = 4.5
@export var chase_radius: float = 40.0
@export var stopping_distance: float = 2.0

var player: Node3D

func _ready() -> void:
	player = get_node_or_null(player_path) as Node3D
	if player == null:
		for candidate in get_tree().get_nodes_in_group("player"):
			if candidate is Node3D:
				player = candidate
				break

func _physics_process(delta: float) -> void:
	if player == null:
		return

	var target_pos = player.global_transform.origin
	var direction = target_pos - global_transform.origin
	var distance = direction.length()
	if distance > chase_radius:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	if distance <= stopping_distance:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()

	look_at(target_pos, Vector3.UP)
