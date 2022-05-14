extends KinematicBody

var velocity: Vector3

func _physics_process(delta):
	var v = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var dv = global_transform.basis.x*v.x + global_transform.basis.z*v.y
	dv *= 6
	velocity.y -= 9.8*delta
	velocity = velocity.move_toward(Vector3(dv.x, velocity.y, dv.z), 20)
	
	velocity = move_and_slide_with_snap(velocity, Vector3.DOWN*0.1, Vector3.UP)
	$ColorRect.visible = is_on_floor()
	var gv = get_floor_velocity()
	$ColorRect/Label.text = "%f, %f, %f" % [gv.x, gv.y, gv.z]
