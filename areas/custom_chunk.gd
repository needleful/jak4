extends MeshInstance

var real_aabb: AABB

func _ready():
	real_aabb = .get_aabb()
	#print_debug(get_path(), " size: ", real_aabb.size)
	if !Engine.editor_hint:
		mesh = null

func get_aabb():
	return real_aabb
