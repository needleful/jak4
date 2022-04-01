extends Spatial

func _ready():
	var water_up: Vector3 = $circle.global_transform.basis.y
	var axis := water_up.cross(Vector3.UP).normalized()
	if axis.is_normalized():
		var angle := water_up.angle_to(Vector3.UP)
		$circle.global_rotate(axis, angle)
