class_name CharacterController extends Node3D

@export var max_radius: float = 3
@export var max_speed: float = 5
@export var shape_radius: float = 1
@export var jump_curve: Curve
@export var jump_force: float = 1

var speed: float = 1
var angle: float = deg_to_rad(-90) # in radians

var jump: Jump

func _ready() -> void:
	jump = Jump.new(jump_force, jump_curve, 1)
	speed = max_speed

func _physics_process(delta: float) -> void:
	_movement(delta)
	jump.tick(delta)
	_gravity()


func _move_left(delta: float) -> void:
	angle += speed * delta

func _move_right(delta: float) -> void:
	angle -= speed * delta

func _movement(delta: float) -> void:
	var move = Input.get_action_strength("left") - Input.get_action_strength("right")
	if move < 0:
		_move_left(delta)
	elif move > 0:
		_move_right(delta)
	
	if Input.is_action_just_pressed("jump"):
		jump.do()
  
func _gravity() -> void:
	var radius = max_radius - jump.get_force() - shape_radius
	var pos = _point_on_circle(radius, angle)
	position.x = pos.x
	position.y = pos.y
  
func _point_on_circle(radius: float, rad: float) -> Vector2:
	var x = radius * cos(rad)
	var y = radius * sin(rad)
	return Vector2(x, y)
