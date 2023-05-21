extends KinematicBody
# For now this is just the plane

var player: PlayerBody
var velocity: Vector3
var start_speed := 10.0
var lift_factor := 0.25
var gravity := Vector3.DOWN*9.8
var drag_factor := 0.004
var drag_y_factor := 0.5

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
	player.set_state(PlayerBody.State.Vehicle)
	player.transform = Transform()
	player.mesh.transform = Transform()
	player.mesh.start_hover(false)
	var _x = player.connect("died", self, "exit", [], CONNECT_ONESHOT)
	
	set_physics_process(true)
	velocity = global_transform.basis.z*start_speed

func exit():
	if !player:
		return
	if player.is_connected("died", self, "exit"):
		player.disconnect("died", self, "exit")
	player.enable_collision()
	player = null
	set_physics_process(false)

func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED and player:
		player.set_saved_transform(global_transform)

func _physics_process(delta: float):
	if !player:
		set_physics_process(false)
		return
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

	var hvel := velocity.slide(global_transform.basis.y)
	var yvel := velocity.project(global_transform.basis.y)
	var drag := -drag_factor*(hvel.length()*hvel)
	var drag_y := -drag_y_factor*(yvel.length()*yvel)
	
	velocity += (gravity + lift + drag + drag_y)*delta
	velocity = move_and_slide(velocity)
	player.mesh.hover_lean(Vector2(
		-2*global_transform.basis.x.y,
		+2*global_transform.basis.z.y),
	delta)
