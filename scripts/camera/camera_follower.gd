extends Node3D

@export var followOffset = Vector3(0, 0, -10)

func _process(delta: float) -> void:
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return
		
	self.transform.origin = camera.transform.origin
