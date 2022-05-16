extends Spatial

export(bool) var active = false setget set_active

func _on_toggled(val: bool):
	set_active(val)

func set_active(a):
	active = a
	if active:
		$AnimationPlayer.play("Loop")
	else:
		$AnimationPlayer.stop()
