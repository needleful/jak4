extends SoftBody

func process_player_distance(player_origin):
	var l = (player_origin - get_parent().global_transform.origin).length_squared()
	visible = l <= 20000
	physics_enabled = l <= 100
