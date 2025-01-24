class_name Jump


var _max_force: float
var _curve: Curve
var _time: float

var _elapsed_time: float = 0
var _force: float

func _init(force: float, curve: Curve, time: float) -> void:
	_max_force = force
	_curve = curve
	_time = time

func do() -> void:
	if is_active():
		return
	_elapsed_time = 0.01

func tick(delta: float) -> void:
	if !is_active():
		return

	_elapsed_time += delta
	if _elapsed_time >= _time:
		_elapsed_time = 0
	
	_force = _curve.sample_baked(_elapsed_time) * _max_force

func is_active() -> bool:
	return _elapsed_time != 0

func get_force() -> float:
	return _force
