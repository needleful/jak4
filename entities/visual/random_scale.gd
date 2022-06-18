extends MeshInstance

export(float, 0, 3) var min_scale := 0.8
export(float, 0, 3) var max_scale := 1.2

func _ready():
	if min_scale < max_scale:
		var t = max_scale
		max_scale = min_scale
		min_scale = t
	scale = Vector3(
		rand_range(min_scale, max_scale),
		rand_range(min_scale, max_scale),
		rand_range(min_scale, max_scale))
