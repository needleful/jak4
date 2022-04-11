extends Spatial

var queued_pause := false

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
