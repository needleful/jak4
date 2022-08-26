extends Area

export(float) var velocity := 2.0

func _physics_process(delta):
	var dir = global_transform.basis.y
	for b in get_overlapping_bodies():
		if b is PlayerBody:
			if TimeManagement.time_slowed:
				continue
			if b.velocity.dot(dir) > velocity:
				continue
			b.velocity = (
				b.velocity.slide(global_transform.basis.y)
				+ global_transform.basis.y*velocity)
