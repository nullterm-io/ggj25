class_name AI extends CharacterBody3D

@export var speed := 1.0
@export var radius := 2.5

var angle := 1.0
var direction := 1.0

var _parent: Node3D = null

func _process(delta: float) -> void:
	if _parent == null:
		queue_free()
		return
	angle = angle + direction * speed * delta
	_move(_calc_position())

func reset_position() -> void:
	position = _calc_position()

func _calc_position() -> Vector3:
	var offset := _parent.global_transform.origin
	return Common.to_vec3(Common.point_on_circle(speed, angle)) + offset

func _move(target_position: Vector3) -> void:
	var dir = (target_position - global_transform.origin).normalized()
	var distance = global_transform.origin.distance_to(target_position)
	var collision = move_and_collide(dir * distance)
	if collision:
		print("Collides")
	global_transform.origin = target_position
	
func set_parent(parent: Node3D) -> void:
	_parent = parent
