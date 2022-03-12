extends Node

onready var player: PlayerBody = get_parent()
onready var yaw : Spatial = $yaw
onready var pitch : Spatial = $yaw/pitch

const MIN_CAMERA_DIFF = -1
const MAX_CAMERA_DIFF = 1.5
const MIN_CAMERA_DIFF_GROUND = -1
const CORRECTION_VELOCITY = 2

var mouse_accum := Vector2.ZERO
var mouse_sns := Vector2(0.01, 0.01)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_accum += event.relative


func _physics_process(delta):
	var target_origin: Vector3 = player.global_transform.origin
	var difference = target_origin.y - yaw.global_transform.origin.y
	
	var target_y = yaw.global_transform.origin.y
	
	var bound_low = MIN_CAMERA_DIFF
	var bound_high = MAX_CAMERA_DIFF
	if player.state == player.State.Ground or player.state == player.State.Slide:
		bound_low = MIN_CAMERA_DIFF_GROUND

	if difference < bound_low:
		target_y += difference - bound_low
		difference = bound_low
	elif difference > bound_high:
		target_y += difference - bound_high
		difference = bound_high
	
	target_y += difference*CORRECTION_VELOCITY*delta
	
	yaw.global_transform.origin = Vector3(
		target_origin.x,
		# something for y
		target_y,
		target_origin.z
	)
	
	var mouse_aim = -mouse_accum*mouse_sns
	mouse_accum = Vector2.ZERO
	
	yaw.rotate_y(mouse_aim.x)
	pitch.rotate_x(mouse_aim.y)
