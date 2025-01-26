extends AudioStreamPlayer

const BUS_NAME := "HeartBeat"
const EFFECT_INDEX := 0
const MAX_PITCH := 2.0
@export var _pitch = 0.5
@export var max_db: float = -5
@export var min_db: float = -20

# TODO: Maybe use went distance?
var _elapsed_time := 0.0

func _ready() -> void:
	_update_pitch()

func _update_pitch() -> void:
	var effect: AudioEffectPitchShift = AudioServer.get_bus_effect(AudioServer.get_bus_index(BUS_NAME), EFFECT_INDEX)
	effect.pitch_scale = min(1, 1 / _pitch)
	pitch_scale = _pitch

func set_pitch(value: float) -> void:
	value = clamp(value, 0.5, MAX_PITCH)
	if _pitch == value:
		return
	# print("Setting pitch to: ", value)
	_pitch = value
	_update_pitch()

const STEP := 0.15
func _process(delta: float) -> void:
	_elapsed_time += delta
	var pitch: float = round(_elapsed_time / 30.0 / STEP) * STEP
	var percent: float = min(1, pitch / MAX_PITCH)

	volume_db = min_db + (max_db - min_db) * percent
	set_pitch(pitch)
