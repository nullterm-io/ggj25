extends Node

@onready var _game_over = $UI/GameOver

func _ready() -> void:
	_game_over.visible = false
