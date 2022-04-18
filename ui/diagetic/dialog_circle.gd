extends Spatial

const vis_distance := 10.0
const sq_distance_visible := vis_distance*vis_distance

onready var mat: ShaderMaterial = $Circle.get_active_material(0)

func process_player_distance(origin: Vector3):
	var sq_dist = (origin - global_transform.origin).length_squared()
	var vis = sq_dist < sq_distance_visible
	if visible != vis:
		visible = vis
	return INF

func _process(_delta):
	mat.set_shader_param("world_player", Global.get_player().global_transform.origin)
