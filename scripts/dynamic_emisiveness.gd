extends MeshInstance3D

@export var minEmissionEnergy: float = 15
@export var maxEmissionEnergy: float = 5000
@export var minDistance: float = 0
@export var maxDistance: float = 20

@export var interpolationCurve: Curve = preload("res://assets/curves/emissiveness_dist_curve.tres")

func _process(_delta: float) -> void:
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return
		
	var distToCamera = transform.origin.distance_to(camera.transform.origin)
	var interpolationArg = (distToCamera - minDistance) / maxDistance
	interpolationArg = clamp(interpolationArg, 0, 1)
	
	var energy = minEmissionEnergy + interpolationCurve.sample_baked(interpolationArg) * maxEmissionEnergy
	var material = get_active_material(0) as StandardMaterial3D
	material.emission_energy_multiplier = energy
