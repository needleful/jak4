extends Node

onready var player: PlayerBody = get_parent()
onready var yaw : Spatial = $yaw
onready var pitch : Spatial = $yaw/pitch


var mouse_accum := Vector2.ZERO
var mouse_sns := Vector2(0.01, 0.01)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_accum += event.relative


func _physics_process(delta):
	yaw.global_transform.origin = player.global_transform.origin
	
	var mouse_aim = -mouse_accum*mouse_sns
	mouse_accum = Vector2.ZERO
	
	yaw.rotate_y(mouse_aim.x)
	pitch.rotate_x(mouse_aim.y)
