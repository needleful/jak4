extends KinematicBody

export(int) var damage := 10
export(float) var speed := 10.0
export(float) var turn_speed := 2.0
export(Vector3) var offset := Vector3.ZERO

var target: Spatial

var velocity := Vector3.ZERO

func fire(p_target: Spatial, p_offset := Vector3.ZERO):
	offset = p_offset
	target = p_target
	if target:
		var direction = (
			target.global_transform.origin + offset
			 - global_transform.origin).normalized()
		velocity = speed*direction

func _physics_process(delta):
	if target:
		var dir = (
			target.global_transform.origin + offset
			 - global_transform.origin)
		var axis = velocity.cross(dir).normalized()
		if axis.is_normalized():
			var theta = velocity.angle_to(dir)
			var angle = sign(theta)*min(theta, turn_speed*delta)
			velocity = velocity.rotated(axis, angle)
		
	var c := move_and_collide(velocity*delta)
	if c:
		dir_damage(c.collider)
		queue_free()

func take_damage(_damage, _dir):
	queue_free()

func gravity_stun(_damage):
	velocity *= 0.25
	velocity.y += 3.0
	turn_speed *= 0.25

func dir_damage(body):
	if !body.has_method("take_damage"):
		return
	var dir :Vector3 = velocity.normalized()
	body.take_damage(damage, dir)

func _on_deletion_timer_timeout():
	queue_free()
