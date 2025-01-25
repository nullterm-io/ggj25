extends Node3D

## Number of torus segments at one time
@export var pipe_length = 50

## Distance into Z+, after which segments are destroyed
@export var clearance_dist: float = 5

## Distance after which the curvature angle changes
@export var angle_change_dist = 100

## Maximum random offset between segments
@export var max_offset = 0.08

## Movement speed along the path
@export var scroll_speed = 2.5

## Level section template node
@export var section_template: Node3D

@export var obstacle_scenes: Array[PackedScene]

@onready var _outer_radius = section_template.outer_radius
@onready var _inner_radius = section_template.inner_radius

@onready var _segment_length = (section_template.outer_radius - section_template.inner_radius)
@onready var _pipe = $Pipe

var _elapsed_distance := 0.0
var _angle := 0.0
var _target_angle := 0.0
var _segments: Array = []
var _obstacles_gen: ObstaclesGen

func _ready():
	assert(section_template)
	assert(_segment_length > 0)

	_segments.append(section_template.duplicate())
	_pipe.add_child(_segments[-1])

	_obstacles_gen = ObstaclesGen.new(_inner_radius, 5)
	# This is done only to make invisible the template torus in the scene
	# It is used to generate new ones as an example one
	section_template.visible = false

func _physics_process(delta: float) -> void:

	_update_angle(delta)
	_update_sections(delta)

func _process(delta: float) -> void:
	_update_position(delta)
	_angle = lerp(_angle, _target_angle, 0.01)
	if _obstacles_gen.sorted_positions.is_empty():
		_obstacles_gen.try_gen_positions()

func _update_angle(delta: float) -> void:
	_elapsed_distance += scroll_speed * delta
	if _elapsed_distance >= angle_change_dist:
		_target_angle = randf() * TAU
		_elapsed_distance -= angle_change_dist

func _update_sections(delta: float) -> void:
	var segments_to_erase = 0
	var run_length = 0.0

	# Move the segments back
	for seg in _segments:
		seg.position += Vector3.BACK * scroll_speed * delta
		if seg.position.z + _segment_length >= clearance_dist:
			segments_to_erase += 1
			run_length -= _segment_length
		else:
			run_length += _segment_length

	# Add new segments to cover the remaining run length
	while run_length < pipe_length:
		var last_segment = _segments[-1]
		var segment = section_template.duplicate()
		var offset = Vector3(cos(_angle), sin(_angle), 0) * _segment_length * max_offset
		var segment_position = last_segment.position + Vector3.FORWARD * _segment_length + offset

		_pipe.add_child(segment)
		segment.position = segment_position
		segment.visible = true
		run_length += _segment_length

		_segments.append(segment)

	# Erase segments past zero
	while segments_to_erase:
		_segments.pop_front().queue_free()
		segments_to_erase -= 1

func _update_position(_delta: float) -> void:
	var zero_segment_index = int(clearance_dist / _segment_length) + 1
	if zero_segment_index < len(_segments):
		_pipe.position = -_segments[zero_segment_index].position
		_pipe.position.z = 0

func _on_obstacle_spawn_timer_timeout() -> void:
	var scene = obstacle_scenes.pick_random()
	var delay_time = randf_range(2.0, 5.0)
	
	if scene:
		var obstacle = scene.instantiate()
		var segment = _segments[-1]
		var obpos = _obstacles_gen.pop_gen_position()
		var angle = atan2(obpos.y, obpos.x)
		var pos = Vector3(cos(angle), sin(angle), 0) * _outer_radius
		
		segment.add_child(obstacle)

		obstacle.global_position = segment.global_position + pos
		obstacle.global_basis = Basis(Quaternion(Vector3.DOWN, pos.normalized()))
		
	$ObstacleSpawnTimer.start(delay_time)
