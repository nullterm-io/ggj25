class_name CharacterController extends CharacterBody3D

@export var max_radius: float = 3
@export var slide_acceleration: float = 1.0
@export var slide_velocity: float = 3
@export var shape_radius: float = 1
@export var jump_curve: Curve
@export var jump_velocity: float = 1
@export var jump_slide_velocity: float = 0.0

var _gravity: Vector3
var _jumping := false

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_apply_jump(delta)
	_apply_slide(delta)
	move_and_slide()

func _apply_gravity(delta: float):
	var grav_accel = PhysicsServer3D.area_get_param(get_viewport().find_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY)

	# Recompute gravity only when not jumping
	if _gravity.is_zero_approx() or is_on_floor() or is_on_ceiling():
		_gravity = global_position.normalized()

	up_direction = -_gravity

	if not is_on_floor():
		velocity += _gravity * grav_accel * delta
	else:
		apply_floor_snap()
		velocity = Vector3.ZERO
		_jumping = false

func _apply_jump(_delta: float):
	if (is_on_floor() or is_on_ceiling()) and Input.is_action_just_pressed("jump"):
		velocity += -_gravity * jump_velocity
		_jumping = true

func _apply_slide(_delta: float):
	var slide_vel = slide_velocity if (is_on_floor() and not _jumping) else jump_slide_velocity
	var move = Input.get_action_strength("left") - Input.get_action_strength("right")
	var right = _gravity.cross(Vector3.BACK)
	velocity += right * move * slide_vel

# func _move_left(delta: float) -> void:
# 	angle += speed * delta

# func _move_right(delta: float) -> void:
# 	angle -= speed * delta

# func _movement(delta: float) -> void:
# 	var move = Input.get_action_strength("left") - Input.get_action_strength("right")
# 	if move < 0:
# 		_move_left(delta)
# 	elif move > 0:
# 		_move_right(delta)

# 	if Input.is_action_just_pressed("jump"):
# 		jump.do()

# func _gravity() -> void:
# 	var radius = max_radius - jump.get_force() - shape_radius
# 	var pos = Common.point_on_circle(radius, angle)
# 	position.x = pos.x
# 	position.y = pos.y
