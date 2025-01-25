extends Node3D

## Number of torus segments at one time
@export var pipe_length = 50

## Maximum random offset between segments
@export var max_offset = 0.01

## Movement speed along the path
@export var scroll_speed = 2.5

## Level section template node
@export var section_template: Node3D

@onready var _segment_length = (section_template.outer_radius - section_template.inner_radius)

var _segments: Array = []

func _ready():
	assert(section_template)

	_segments.append(section_template.duplicate())
	add_child(_segments[-1])

	# This is done only to make invisible the template torus in the scene
	# It is used to generate new ones as an example one
	section_template.visible = false

func _physics_process(delta: float) -> void:
	var segments_to_erase = 0
	var run_length = 0.0

	# Move the segments back
	for seg in _segments:
		seg.position += Vector3.BACK * scroll_speed * delta
		if seg.position.z + _segment_length > 0:
			segments_to_erase += 1
			run_length -= _segment_length
		else:
			run_length += _segment_length

	# Add new segments to cover the remaining run length
	while run_length < pipe_length:
		var segment = _segments[-1].duplicate()
		_segments.append(segment)
		add_child(segment)
		segment.position += Vector3.FORWARD * _segment_length
		run_length += _segment_length

	# Erase segments past zero
	while segments_to_erase:
		_segments.pop_front().queue_free()
		segments_to_erase -= 1

func generate_offset_vector(z: float) -> Vector3:
	return Vector3(
		randf_range(-max_offset, max_offset),
		randf_range(-max_offset, max_offset),
		z,
	)
