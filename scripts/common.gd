extends Node

func point_on_circle(radius: float, rad: float) -> Vector2:
	var x = radius * cos(rad)
	var y = radius * sin(rad)
	return Vector2(x, y)
