extends Node

func _ready() -> void:
	$UI/GameOver.visible = false
	get_tree().paused = false
	Game.game_over.connect(_game_over)

func _game_over() -> void:
	get_tree().paused = true
	$UI/GameOver.visible = true
