class_name ObstaclesGen extends Node3D

const RADIUS_OBSTACLE = 0.5
const VISIBLE_DISTANCE = 10
const OBSTACLE_RADIUS = 0.5

var _max_obstacles = 5
var _inner_radius: float
var _randgen: RandomNumberGenerator

var sorted_positions = PackedVector2Array()

func _init(r: float, max_obstacles: int):
	_inner_radius = r
	seed("SomeRandomString".hash())
	
	_max_obstacles = max_obstacles
	_randgen = RandomNumberGenerator.new()
	_randgen.randomize()

func _calc_arc_length_between_points(a: Vector2, b: Vector2) -> float:
	# NOTE: assume that a and b are points both on circle, meaning their magnitude
	# equal to the radius of circle!
	var angle = a.dot(b) / (_inner_radius*_inner_radius)
	var theta = acos(angle)
	var arc_length = theta * _inner_radius
	
	return arc_length

func _rand_point_on_circle() -> Vector2:
	var genangle = _randgen.randf_range(0.0, 2.0 * PI)
	var p_xy = Common.point_on_circle(_inner_radius, genangle)

	var p = Vector2(p_xy.x, p_xy.y)
	
	return p
	
func _get_radius_from_point(p: Vector2, r: float) -> float:
	var angle: float = atan2(p.y, p.x)
	var angle_offset: float = angle / _inner_radius
	angle += angle_offset
	
	var radius_p: Vector2 = Common.point_on_circle(_inner_radius, angle)
	var arc = _calc_arc_length_between_points(p, radius_p)
	
	return arc
	
func _test_positions(a: Vector2, b: Vector2) -> bool:
	var arc_length = _calc_arc_length_between_points(a, b)
	var radius_a = _get_radius_from_point(a, _inner_radius)
	var radius_b = _get_radius_from_point(b, _inner_radius)
	
	if arc_length <= radius_a + radius_b:
		return false
	return true
	
func pop_gen_position() -> Vector2:
	var count = sorted_positions.size()
	if count == 0:
		return Vector2.ZERO
		
	var pos = sorted_positions[count - 1]
	sorted_positions.remove_at(count - 1)
	
	return pos
	
func try_gen_positions() -> void:
	for i in range(0, _max_obstacles):
		var gen_p: Vector2 = _rand_point_on_circle()
		
		if sorted_positions.is_empty():
			sorted_positions.push_back(gen_p)
			continue
			
		var idx = sorted_positions.bsearch(gen_p)
		if idx == 0:
			if _test_positions(Vector2(gen_p.x, gen_p.y), Vector2(sorted_positions[idx].x, sorted_positions[idx].y)):
				sorted_positions.insert(idx, gen_p)
		elif idx == sorted_positions.size() - 1:
			if _test_positions(Vector2(gen_p.x, gen_p.y), Vector2(sorted_positions[idx - 1].x, sorted_positions[idx - 1].y)):
				sorted_positions.insert(idx, gen_p)
		elif sorted_positions.size() > 3 and sorted_positions.size() < _max_obstacles - 1:
			if _test_positions(Vector2(gen_p.x, gen_p.y), Vector2(sorted_positions[idx - 1].x, sorted_positions[idx - 1].y)) and \
				_test_positions(Vector2(gen_p.x, gen_p.y), Vector2(sorted_positions[idx + 1].x, sorted_positions[idx + 1].y)):
				sorted_positions.insert(idx, gen_p)
		else:
			sorted_positions.insert(idx, gen_p)
		
		
	#TODO: add logic to do probing on array and adjust gen_p to fit it somewhere 
	# between neighbour elements instead ? 
