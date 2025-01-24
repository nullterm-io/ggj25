extends Control

func _ready() -> void:
	_load_readme()

func _load_readme():
	$ReadMe.display_file("res://README.md")
