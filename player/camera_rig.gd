extends Node

onready var player: PlayerBody = get_parent()
onready var yaw : Spatial = $yaw
onready var pitch : Spatial = $yaw/pitch
onready var groundCast: RayCast = get_parent().get_node("groundCast")

const MIN_CAMERA_DIFF := -1.0
const MAX_CAMERA_DIFF := 0.8
const CORRECTION_VELOCITY := 2.0
const CORRECTION_VELOCITY_GROUND := 4.0
const MIN_FLOOR_HEIGHT := 0.5

var mouse_accum := Vector2.ZERO
var mouse_sns := Vector2(0.01, 0.01)
var analog_sns := Vector2(-0.1, 0.1)

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
		cv = lerp(cv, CORRECTION_VELOCITY_GROUND, 0.1)
	else:
		cv = lerp(cv, CORRECTION_VELOCITY, 0.1)

	if difference < MIN_CAMERA_DIFF:
		target_y += difference - MIN_CAMERA_DIFF
		difference = MIN_CAMERA_DIFF
	elif difference > MAX_CAMERA_DIFF:
		target_y += difference - MAX_CAMERA_DIFF
		difference = MAX_CAMERA_DIFF
	
	target_y += (difference*cv*delta)
	if groundCast.is_colliding():
		target_y = max(groundCast.get_collision_point().y + MIN_FLOOR_HEIGHT, target_y)
	
	yaw.global_transform.origin = Vector3(
		target_origin.x,
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
