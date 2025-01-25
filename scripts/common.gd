extends Node

func point_on_circle(radius: float, rad: float) -> Vector2:
	var x = radius * cos(rad)
	var y = radius * sin(rad)
	return Vector2(x, y)

func to_vec2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.y)

func to_vec3(vec2: Vector2, z: float = 0) -> Vector3:
	return Vector3(vec2.x, vec2.y, z)

enum ObstacleType {
	ENEMY,
	OBSTACLE
}