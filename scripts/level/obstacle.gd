class_name Obstacle extends Area3D


func _on_body_entered(body:Node3D) -> void:
	if body.is_in_group("players"):
		Game.game_over.emit()
