extends Control

@export var scene: PackedScene

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(scene)

func _on_exit_pressed() -> void:
	get_tree().quit()
