extends Spatial

func _ready():
	$Particles.restart()
	$Particles.emitting = true
	$AudioStreamPlayer3D.play(0.0)
	wait_for_delete()

func wait_for_delete():
	yield(get_tree().create_timer(1.5), "timeout")
	get_parent().remove_child(self)
	$Particles.emitting = false
	$AudioStreamPlayer3D.stop()
	ObjectPool.call_deferred("put", "orb_explosion", self)
