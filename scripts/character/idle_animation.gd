class_name IdleAnimation extends Node

@export var skeleton: Skeleton3D
@export var amplitude := 2.8

var _elapsed_time := 0.0
var _bones: Array[Vector3] = []
var _directions: Array[Vector3] = []

func _ready():
	assert(skeleton is Skeleton3D)
	for i in range(skeleton.get_bone_count()):
		_bones.push_back(skeleton.get_bone_pose_position(i))
		_directions.push_back(skeleton.get_bone_pose_rotation(i) * Vector3.UP)
	
func _process(delta: float) -> void:
	_elapsed_time += delta * 10
	for i in range(skeleton.get_bone_count()):
		var bone := _bones[i]
		var direction := _directions[i]
		var offset := bone.lerp(direction * sin(i + _elapsed_time) * amplitude, delta * 9.0)
		skeleton.set_bone_pose_position(i, offset)
