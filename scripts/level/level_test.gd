extends Node3D

## Number of torus segments at one time
@export var pipe_length = 50

## Maximum random offset between segments
@export var max_offset = 0.01

## Movement speed along the path
@export var pipe_speed = 2.5

@onready var torus_template: CSGTorus3D = $CSGTorus3D
@onready var camera_default: Camera3D = $Camera3D

var pipe_path: Path3D
var pipe_segments: Array = []

func _ready():
	if not torus_template:
		push_error("No CSGTorus3D found!")
		return

	# This is done only to make invisible the template torus in the scene
	# It is used to generate new ones as an example one 
	torus_template.visible = false

	pipe_path = Path3D.new()
	add_child(pipe_path)

	generate_initial_pipe()

func generate_offset_vector(z: float) -> Vector3:
	return Vector3(
		randf_range(-max_offset, max_offset),
		randf_range(-max_offset, max_offset),
		z,
	)

func generate_initial_pipe():
	var curve = Curve3D.new()
	var current_pos = Vector3.ZERO
	var segment_distance = (torus_template.outer_radius - torus_template.inner_radius) * 0.05

	for i in range(pipe_length):
		var offset = self.generate_offset_vector(-i * segment_distance)
		curve.add_point(current_pos + offset)
		current_pos += offset

	pipe_path.curve = curve

	for i in range(pipe_length):
		var torus = torus_template.duplicate()
		torus.visible = true
		add_child(torus)
		pipe_segments.append(torus)
		var point_pos = pipe_path.curve.get_point_position(i)
		torus.position = point_pos

func extend_pipe():
	if pipe_segments.size() > 0:
		var oldest_segment = pipe_segments.pop_front()
		oldest_segment.queue_free()

	var curve = pipe_path.curve
	for i in range(curve.point_count - 1):
		curve.set_point_position(i, curve.get_point_position(i+1))

	var last_point = curve.get_point_position(curve.point_count - 1)
	var segment_distance = (torus_template.outer_radius - torus_template.inner_radius) * 0.05
	var new_offset = self.generate_offset_vector(-segment_distance)
	curve.add_point(last_point + new_offset)

	curve.remove_point(0)

	var torus = torus_template.duplicate()
	torus.visible = true
	add_child(torus)

	pipe_segments.append(torus)
	var point_pos = curve.get_point_position(pipe_length - 1)
	torus.position = point_pos

func _process(delta):
	for segment in pipe_segments:
		segment.position.z += pipe_speed * delta

	if pipe_segments[0].position.z >= 0:
		extend_pipe()
