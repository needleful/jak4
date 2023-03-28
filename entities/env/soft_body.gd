extends SoftBody

var queued_pause := false

func _enter_tree():
	if !physics_enabled:
		physics_enabled = true
		queued_pause = true
		call_deferred("disable_on_delay")
	
func disable_on_delay():
	yield(VisualServer, "frame_post_draw")
	yield(get_tree().create_timer(0.05 + 0.1*randf()), "timeout")
	if !queued_pause:
		return
	physics_enabled = false

func process_player_distance(player_origin):
	var l = (player_origin - get_parent().global_transform.origin).length_squared()
	visible = l <= 20000
	physics_enabled = l <= 100

func _exit_tree():
	#physics_enabled = false
	queued_pause = false
