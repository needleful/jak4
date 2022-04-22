extends Spatial

var on: bool = false

func _on_damaged(damage, dir):
	var switch_on = dir.dot(global_transform.basis.z) > 0.0
	
	$AnimationPlayer.stop()
	
	if switch_on and on:
		$AnimationPlayer.play("AlreadyOn")
	elif !switch_on and !on:
		$AnimationPlayer.play("AlreadyOff")
	elif switch_on:
		$AnimationPlayer.play("SwitchOn")
	else:
		$AnimationPlayer.play("SwitchOff")
	
	on = switch_on
