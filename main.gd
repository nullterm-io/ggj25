extends Node

@onready var _game_over = $UI/GameOver

func _ready() -> void:
	_game_over.visible = false

func game_over() -> void:
	if _game_over:
		_game_over.visible = true
