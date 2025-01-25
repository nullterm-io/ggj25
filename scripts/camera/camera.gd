class_name CameraController extends Camera3D

@export var tracking_player: NodePath

@export var rotation_decay: float = 5.0

func _process(delta: float) -> void:
	var player = get_node(tracking_player)
	var cur_qtr = basis.get_rotation_quaternion()
	var tgt_qtr = Quaternion(Vector3.UP, player.up_direction).normalized()
	if not tgt_qtr.is_equal_approx(cur_qtr):
		basis = Basis(cur_qtr.slerp(tgt_qtr, rotation_decay * delta))
