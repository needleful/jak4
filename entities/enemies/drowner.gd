extends Spatial

signal drowned

export(float, 1, 30) var DROWN_TIME := 5.0

var submerged := false
var submerged_time := 0.0
var drowned := false
const WATER_LAYER := 8192
onready var space := get_world().direct_space_state
var point_check := 0

func _physics_process(delta):
	if drowned:
		return

	point_check = point_check % get_child_count()
	
	submerged = !space.intersect_point(
		get_child(point_check).global_transform.origin, 1, [], 8192
	).empty()
	point_check += 1
	
	if submerged:
		submerged_time += delta
		if submerged_time > DROWN_TIME:
			emit_signal("drowned")
			print("Drowned: ", get_parent().get_path())
			drowned = true
	else:
		submerged_time = 0
