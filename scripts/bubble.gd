@tool
extends Node3D

@export_tool_button("Regenerate bodies") var hello_action = _regen_bodies


@onready var _skeleton = $Armature/Skeleton3D
@onready var _core_body = $CoreBody
@onready var _core_shape = $CoreBody/CollisionShape3D

var _bone_bodies = []

func _ready():
	if Engine.is_editor_hint():
		return

	for node in get_children():
		if node is SliderJoint3D:
			_bone_bodies.append(node.get_node(node.node_b))

func _physics_process(_delta: float):
	if Engine.is_editor_hint():
		return

	global_position = _core_body.global_position

	for i in _skeleton.get_bone_count():
		var body = _bone_bodies[i]
		var scale_factor = body.position.length()
		_skeleton.set_bone_pose_scale(i, Vector3.ONE * scale_factor)

func _regen_bodies():
	print('regenerate bodies!')

	for physics_node in get_children():
		if physics_node.is_in_group("physics_nodes"):
			physics_node.queue_free()

	for i in _skeleton.get_bone_count():
		var bone_name = _skeleton.get_bone_name(i)
		var bone_body = _core_body.duplicate()
		var bone_shape = _core_shape.duplicate()
		var xform = _skeleton.get_bone_rest(i)
		var joint = SliderJoint3D.new()

		add_child(bone_body)
		bone_body.add_child(bone_shape)
		add_child(joint)

		bone_body.owner = get_tree().edited_scene_root
		bone_shape.owner = get_tree().edited_scene_root

		bone_body.name = '%sBody' % bone_name
		bone_body.position = xform * Vector3.UP
		bone_shape.position = xform * Vector3.UP * -bone_shape.shape.radius

		joint.owner = get_tree().edited_scene_root
		joint.node_a = '../CoreBody'
		joint.node_b = '../' + bone_body.name
		joint.exclude_nodes_from_collision = false
		joint.set_param(SliderJoint3D.PARAM_LINEAR_LIMIT_LOWER, 0.0)

		bone_body.add_to_group("physics_nodes")
		bone_shape.add_to_group("physics_nodes")
		joint.add_to_group("physics_nodes")
