extends RigidBody

export(float, 0, 10) var delay := 1.0

const time_to_unlock := 1.0

var falling := false
onready var starting_position := global_transform

func _ready():
	var p = Global.get_player()
	if p is PlayerBody:
		p.connect("died", self, "_on_player_died")

func _on_body_entered(_body):
	if !falling:
		falling = true
		$Timer.start(delay)

func _on_timeout():
	if mode == RigidBody.MODE_RIGID:
		axis_lock_angular_x = false
		axis_lock_angular_y = false
		axis_lock_angular_z = false
		axis_lock_linear_x = false
		axis_lock_linear_y = false
		axis_lock_linear_z = false
	else:
		mode = RigidBody.MODE_RIGID
		$Timer.start(time_to_unlock)

func _on_player_died():
	reset()

func reset():
	$Timer.stop()
	mode = RigidBody.MODE_KINEMATIC
	global_transform = starting_position
	falling = false

#TODO: for resetting by button. Make a nice visual effect to teleport them
func visual_reset():
	reset()
