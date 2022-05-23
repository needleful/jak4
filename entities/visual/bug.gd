extends Spatial

func _on_gravity_stun(stun: bool):
	if stun:
		$AnimationPlayer.play("GravityStun-loop")
	else:
		$AnimationPlayer.play("Idle-loop")
