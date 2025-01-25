extends Node3D

const RADIUS_CIRCLE = 5
const VISIBLE_DISTANCE = 10

var randgen: RandomNumberGenerator

var positions = Array()

func _ready() -> void:
	seed("SomRandomString".hash())
	
	randgen = RandomNumberGenerator.new()
	randgen.randomize()
	
	
func _process(_delta: float) -> void:
	# logic will be done here
	pass
