extends Spatial

export(Material) var flag_material

var queued_pause := false

func _ready():
	if flag_material:
		$pole.material_override = flag_material
	
func process_player_distance(player_origin):
	var l = (player_origin - global_transform.origin).length_squared()
	var enabled = l <= 100
	if !enabled:
		if queued_pause:
			$SoftBody.physics_enabled = false
		else:
			queued_pause = true
	else:
		$SoftBody.physics_enabled = true
	return INF
