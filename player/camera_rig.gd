extends Node

onready var player: PlayerBody = get_parent()
onready var yaw : Spatial = $yaw
onready var pitch : Spatial = $yaw/pitch
onready var groundCast: RayCast = get_parent().get_node("groundCast")

const MIN_CAMERA_DIFF := -1.0
const MAX_CAMERA_DIFF := 1.0
const CORRECTION_VELOCITY := 4.0
const CORRECTION_VELOCITY_GROUND := 8.0
const MIN_FLOOR_HEIGHT := 0.5
const H_CORRECTION := 24.0
const H_DIFF_BOUND := 1.5

const LEDGE_GRAB_RAISE := 1.0
var raise := 0.0

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
	var target: Vector3 = player.global_transform.origin
	var pos: Vector3 = yaw.global_transform.origin
	
	
	if player.state == player.State.LedgeHang:
		raise = lerp(raise, LEDGE_GRAB_RAISE, 0.1)
	else:
		raise = lerp(raise, 0.0, 0.1)
		if groundCast.is_colliding():
			target.y = max(groundCast.get_collision_point().y + MIN_FLOOR_HEIGHT, target.y)
	
	target.y += raise
	
	if player.is_grounded():
		cv = lerp(cv, CORRECTION_VELOCITY_GROUND, 0.1)
	else:
		cv = lerp(cv, CORRECTION_VELOCITY, 0.1)
		
	var diff := target - pos
	var movement := Vector3(
		diff.x*min(delta*H_CORRECTION, 1),
		diff.y*min(delta*cv, 1),
		diff.z*min(delta*H_CORRECTION, 1)
	)
	
	pos += movement
	
	pos.y = clamp(
		pos.y,
		target.y + MIN_CAMERA_DIFF,
		target.y + MAX_CAMERA_DIFF)
	
	var hT = Vector3(target.x, 0, target.z)
	var hP = Vector3(pos.x, 0, pos.z)
	var hDiff = hP - hT
	if hDiff.length() > H_DIFF_BOUND:
		var dir = H_DIFF_BOUND*hDiff.normalized()
		
		hP = hT + dir
		pos.x = hP.x
		pos.z = hP.z
	yaw.global_transform.origin = pos
	
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
