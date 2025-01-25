class_name AI extends CharacterBody3D

@export var speed := 1.0

var angle := 1.0
var radius := 2.5
var direction := 1.0

func _process(delta: float) -> void:
	angle = angle + direction * speed * delta
	print(angle, Common.to_vec3(Common.point_on_circle(speed, angle)))
	_move(Common.to_vec3(Common.point_on_circle(speed, angle)))

func _move(target_position: Vector3) -> void:
	var dir = (target_position - global_transform.origin).normalized()
	var distance = global_transform.origin.distance_to(target_position)
	var collision = move_and_collide(dir * distance)
	if collision:
		print("Collision")
	global_transform.origin = target_position