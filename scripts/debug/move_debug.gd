extends Node

@export var speed: float = 1
@export var direction: Vector3 = Vector3(0, 0, 0)
@export var target: Node3D

func _physics_process(delta: float) -> void:
	if target is not Node3D:
		return

	target.position += direction * speed * delta