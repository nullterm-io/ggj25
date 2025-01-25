extends Node3D

const RADIUS_CIRCLE = 5.0
const VISIBLE_DISTANCE = 10

var randgen: RandomNumberGenerator

var positions = PackedVector3Array()
const MAX_OBSTACLES = 5

func _rand_point_on_circle() -> Vector3:
	var genangle = randgen.randf_range(0.0, 2.0 * PI)
	var gen_z = randgen.randf_range(1.0, VISIBLE_DISTANCE)
	var xy = Common.point_on_circle(RADIUS_CIRCLE, genangle)
	var p = Vector3(xy.x, xy.y, gen_z)
	return p
	
func _try_gen_position() -> void:
	var gen_p: Vector3 = _rand_point_on_circle()
	
	#TODO: add logic to do probing on array and adjust gen_p to fit it somewhere 
	# between neighbour elements instead ? 
	if not positions.has(gen_p):
		positions.append(gen_p)
		
func _ready() -> void:
	seed("SomeRandomString".hash())
	
	randgen = RandomNumberGenerator.new()
	randgen.randomize()
	
	for i in range(MAX_OBSTACLES):
		_try_gen_position()
	
func _process(_delta: float) -> void:
	# logic will be done here
	pass
