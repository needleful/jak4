extends Node

onready var player: PlayerBody = get_parent()
onready var yaw : Spatial = $yaw
onready var pitch : Spatial = $yaw/pitch

const MIN_CAMERA_DIFF := -1.0
const MAX_CAMERA_DIFF := 10.0
const MAX_CAMERA_DIFF_GROUND := 1.25
const MIN_CAMERA_DIFF_GROUND := -1
const CORRECTION_VELOCITY := 2.0
const CORRECTION_VELOCITY_GROUND := 4.0

var mouse_accum := Vector2.ZERO
var mouse_sns := Vector2(0.01, 0.01)
var analog_sns := Vector2(-0.1, 0.1)

var bound_high := MAX_CAMERA_DIFF
var bound_low := MIN_CAMERA_DIFF
var cv := CORRECTION_VELOCITY

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_accum += event.relative

func _physics_process(delta):
	#Camera Movement
	var target_origin: Vector3 = player.global_transform.origin
	var difference = target_origin.y - yaw.global_transform.origin.y
	
	var target_y = yaw.global_transform.origin.y
	
	if player.is_grounded():
		bound_low = lerp(bound_low, MIN_CAMERA_DIFF_GROUND, 0.1)
		bound_high = lerp(bound_high, MAX_CAMERA_DIFF_GROUND, 0.1)
		cv = lerp(cv, CORRECTION_VELOCITY_GROUND, 0.1)
	else:
		bound_low = lerp(bound_low, MIN_CAMERA_DIFF, 0.1)
		bound_high = lerp(bound_high, MAX_CAMERA_DIFF, 0.1)
		cv = lerp(cv, CORRECTION_VELOCITY, 0.1)

	if difference < bound_low:
		target_y += difference - bound_low
		difference = bound_low
	elif difference > bound_high:
		target_y += difference - bound_high
		difference = bound_high
	
	target_y += (difference*cv*delta)
	
	yaw.global_transform.origin = Vector3(
		target_origin.x,
		# something for y
		target_y,
		target_origin.z
	)
	
	# Camera Rotation
	var mouse_aim = -mouse_accum*mouse_sns
	mouse_accum = Vector2.ZERO
	
	var analog_aim = Input.get_vector("cam_left", "cam_right", "cam_down", "cam_up")
	analog_aim *= analog_sns
	
	yaw.rotate_y(mouse_aim.x + analog_aim.x)
	pitch.rotate_x(mouse_aim.y + analog_aim.y)
	if pitch.rotation_degrees.x > 80:
		pitch.rotation_degrees.x = 80
	elif pitch.rotation_degrees.x < -80:
		pitch.rotation_degrees.x = -80
