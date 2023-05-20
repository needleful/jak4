extends KinematicBody
# For now this is just the plane

var player: PlayerBody
var velocity: Vector3
var start_speed := 10.0
var lift_factor := 0.75
var gravity := Vector3.DOWN*9.8
var drag_factor := 0.01

func _ready():
	set_physics_process(false)

func activate():
	var t := global_transform
	var new_p = get_tree().current_scene
	get_parent().remove_child(self)
	new_p.add_child(self)
	global_transform = t
	
	player = Global.get_player()
	player.disable_collision()
	player.get_parent().remove_child(player)
	add_child(player)
	player.set_state(PlayerBody.State.Vehicle)
	player.transform = Transform()
	player.mesh.transform = Transform()
	
	set_physics_process(true)
	velocity = global_transform.basis.z*start_speed

func _physics_process(delta: float):
	var pitch := Input.get_axis("mv_down", "mv_up")
	var roll := Input.get_axis("mv_left", "mv_right")
	
	var pitch_speed := 1.5
	var roll_speed := 1.5
	
	var total_pitch := delta*pitch*pitch_speed
	var total_roll := delta*roll*roll_speed
	
	global_rotate(global_transform.basis.x, total_pitch)
	global_rotate(global_transform.basis.z, total_roll)
	
	velocity = velocity.rotated(
		global_transform.basis.x, total_pitch).rotated(
			global_transform.basis.z, total_roll)

	var lift := clamp(
		lift_factor * velocity.dot(global_transform.basis.z),
		-15, 15
	) * global_transform.basis.y
	var drag := -drag_factor*(velocity.length()*velocity)
	velocity += (gravity + lift + drag)*delta
	velocity = move_and_slide(velocity)
