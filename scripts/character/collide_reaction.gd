class_name CollideReaction extends Node


func _on_area_3d_area_entered(area: Area3D) -> void:
	print("CollideReaction: area entered", area.name)
