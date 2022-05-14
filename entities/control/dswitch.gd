extends Spatial

signal activated
signal toggled(on)

var on: bool = false
export(float) var time_deactivate := 0.0

func _on_damaged(damage, dir):
	var switch_on = dir.dot(global_transform.basis.z) > 0.0
	
	set_on(switch_on)

func set_on(switch_on):
	$AnimationPlayer.stop()
	
	if switch_on and on:
		$AnimationPlayer.play("AlreadyOn")
	elif !switch_on and !on:
		$AnimationPlayer.play("AlreadyOff")
	elif switch_on:
		emit_signal("activated")
		emit_signal("toggled", true)
		$AnimationPlayer.play("SwitchOn")
		if time_deactivate > 0:
			$deactivate_timer.start(time_deactivate)
	else:
		emit_signal("toggled", false)
		$AnimationPlayer.play("SwitchOff")
	
	on = switch_on

func _on_deactivate_timer_timeout():
	set_on(false)
