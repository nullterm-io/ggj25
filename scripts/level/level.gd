extends Node3D

## Number of torus segments at one time
@export var pipe_length = 50

## Distance into Z+, after which segments are destroyed
@export var clearance_dist: float = 5

## Distance after which the curvature angle changes
@export var angle_change_dist = 100

## Distance after which obstacle sections are generated
@export var obstacle_section_dist: float = 100

## Normal deviation factor for obstacle sections distance
@export var obstacle_section_dist_dev: float = 0.5

## Maximum random offset between segments
@export var max_offset = 0.08

## Movement speed along the path
@export var scroll_speed = 2.5

## How much the scroll speed increases over a second
@export var scroll_speed_increase_per_s = 0.05

## Maximum scroll speed which we don't go past
@export var max_scroll_speed = 8.0

## Level section template node
@export var section_template: Node3D

@export var obstacle_section_template: Node3D

@export var obstacle_scenes: Array[PackedScene]
@export var enemies_scenes: Array[PackedScene]

@onready var _outer_radius = section_template.outer_radius
@onready var _inner_radius = section_template.inner_radius

@onready var _segment_length = (section_template.outer_radius - section_template.inner_radius)
@onready var _pipe = $Pipe

var _dist_to_obstacle_section := 0.0
var _angle_change_distance := 0.0
var _angle := 0.0
var _target_angle := 0.0
var _segments: Array[Node] = []
var _obstacles_gen: ObstaclesGen
var _directions: Array[int] = [1, -1]


var _obstacle_types: Array[Common.ObstacleType] = [
	Common.ObstacleType.ENEMY,
	Common.ObstacleType.OBSTACLE,
]

func _ready():
	assert(section_template)
	assert(obstacle_section_template)
	assert(_segment_length > 0)

	_segments.append(section_template.duplicate())
	_pipe.add_child(_segments[-1])

	_obstacles_gen = ObstaclesGen.new(_inner_radius, 5)

	section_template.visible = false

	# Hide and disable the obstacle section template node, for not interfering
	# with the boundary node
	obstacle_section_template.visible = false
	obstacle_section_template.use_collision = false

	_reset_obstacle_section_distance()

func _physics_process(delta: float) -> void:
	_update_angle(delta)
	_update_sections(delta)
	_update_obstacle_sections(delta)

func _process(delta: float) -> void:
	_update_position(delta)
	_angle = lerp(_angle, _target_angle, 0.01)
	if _obstacles_gen.sorted_positions.is_empty():
		_obstacles_gen.try_gen_positions()
		
	scroll_speed += scroll_speed_increase_per_s * delta
	scroll_speed = min(scroll_speed, max_scroll_speed)

func _update_angle(delta: float) -> void:
	_angle_change_distance += scroll_speed * delta
	if _angle_change_distance >= angle_change_dist:
		_target_angle = randf() * TAU
		_angle_change_distance -= angle_change_dist

func _update_sections(delta: float) -> void:
	var segments_to_erase := 0
	var run_length := 0.0

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
		var last_segment := _segments[-1]
		var segment := section_template.duplicate()
		var offset: Vector3 = Vector3(cos(_angle), sin(_angle), 0) * _segment_length * max_offset
		var segment_position: Vector3 = last_segment.position + Vector3.FORWARD * _segment_length + offset

		_pipe.add_child(segment)
		segment.position = segment_position
		segment.visible = true
		run_length += _segment_length

		_segments.append(segment)

	# Erase segments past zero
	while segments_to_erase:
		_segments.pop_front().queue_free()
		segments_to_erase -= 1

func _update_obstacle_sections(_delta: float):
	_dist_to_obstacle_section -= _segment_length
	if _dist_to_obstacle_section <= 0:
		_spawn_obstacle_section()
		_reset_obstacle_section_distance()

func _update_position(_delta: float) -> void:
	var zero_segment_index := int(clearance_dist / _segment_length) + 1
	if zero_segment_index < len(_segments):
		_pipe.position = -_segments[zero_segment_index].position
		_pipe.position.z = 0

func _on_obstacle_spawn_timer_timeout() -> void:
	var delay_time = randf_range(0.5, 2.0)

	match _obstacle_types.pick_random():
		Common.ObstacleType.ENEMY:
			_spawn_enemy()
		Common.ObstacleType.OBSTACLE:
			_spawn_obstacle()

	$ObstacleSpawnTimer.start(delay_time)

func _spawn_obstacle() -> void:
	var scene: PackedScene = obstacle_scenes.pick_random()
	var obstacle := scene.instantiate()
	var segment := _segments[-1]
	var obpos := _obstacles_gen.pop_gen_position()
	var angle := atan2(obpos.y, obpos.x)
	var pos: Vector3 = Vector3(cos(angle), sin(angle), 0) * _outer_radius
	segment.add_child(obstacle)

	obstacle.global_position = segment.global_position + pos
	obstacle.global_basis = Basis(Quaternion(Vector3.DOWN, pos.normalized()))

func _spawn_enemy() -> void:
	assert(enemies_scenes.size() > 0)
	assert(_segments.size() > 0)
	var segment := _segments[-1]
	var dir: int = _directions.pick_random()
	var enemy: AI = enemies_scenes.pick_random().instantiate()
	enemy.direction = dir
	enemy.set_parent(segment)
	enemy.reset_position()
	add_child(enemy)


func _spawn_obstacle_section() -> void:
	var section = obstacle_section_template.duplicate()
	var segment = _segments[-1]
	segment.add_child(section)
	section.basis = Basis().rotated(Vector3.RIGHT, PI / 2)
	section.visible = true
	section.use_collision = true

func _reset_obstacle_section_distance() -> void:
	_dist_to_obstacle_section = randfn(obstacle_section_dist, obstacle_section_dist_dev)
	print('Next obstacle section in %.1fm' % _dist_to_obstacle_section)
