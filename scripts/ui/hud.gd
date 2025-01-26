class_name HUD extends Control

@onready var label: Label = $Box/Score

var _active := false
var _score := 0.0

func _ready() -> void:
	_start()
	Game.game_over.connect(_stop)

func _start() -> void:
	label.text = "000"
	_active = true
	visible = true
	_score = 0
	
func _stop() -> void:
	_active = false
	visible = false
	
func _process(delta: float) -> void:
	if not _active:
		return
	_score += delta * 2.0 ** 1.35
	label.text = str(int(round(_score))).pad_zeros(3)