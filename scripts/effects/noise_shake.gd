@tool
extends Node

@export var noise_speed: float = 90.0
@export var noise_strength_factor: float = 8.0
@export var decay_ray: float = 3.0

@onready var _camera: Camera3D
@onready var _noise: FastNoiseLite = FastNoiseLite.new()

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _strength: float = 0.0
var noise_i: float = 0.0

func _enter_tree():
	if Engine.is_editor_hint():
		_ready()

func _ready() -> void:
	var camera = get_parent()
	
	if camera is Camera3D:
		_camera = camera
	else:
		_camera = null

	if Engine.is_editor_hint():
		update_configuration_warnings()
		return
	
	_rng.randomize()
	_noise.seed = _rng.randi()
	
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		# print("NoiseShake is active in the editor.")
		return
	_strength = lerp(_strength, 0.0, decay_ray * delta)
	var offset = _get_noise_offset(delta, noise_speed, _strength)
	_camera.h_offset = offset.x
	_camera.v_offset = offset.y

func apply_shake() -> void:
	_strength = noise_strength_factor

func _get_noise_offset(delta: float, speed: float, strength: float) -> Vector2:
	noise_i += delta * speed
	return Vector2(
		_noise.get_noise_2d(1, noise_i) * strength,
		_noise.get_noise_2d(100, noise_i) * strength
	)

func _get_configuration_warnings() -> PackedStringArray:
	if _camera is not Camera3D:
		return ["NoiseShake should be a child of a Camera3D node."]
	return []
