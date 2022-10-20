extends Node

onready var player: PlayerBody = get_parent()
onready var yaw : Spatial = $yaw
onready var pitch : Spatial = $yaw/pitch
onready var spring : SpringArm = $yaw/pitch/SpringArm
onready var camera := $yaw/pitch/Camera
onready var tween := $cam_tween

const MIN_CAMERA_DIFF := -1.0
const MAX_CAMERA_DIFF := 1.0
const CORRECTION_VELOCITY := 4.0
const CORRECTION_VELOCITY_GROUND := 8.0
const MIN_FLOOR_HEIGHT := 0.5
const H_CORRECTION := 30.0
const H_SLOW_CORRECTION := 15.0
const H_DIFF_BOUND := 2.5

const LEDGE_GRAB_RAISE := 1.0
var raise := 0.0

const SPRING_DEFAULT := 2.5
const SPRING_AIM := 1.5
const SPRING_DIALOG := 1.5
const SPRING_WARDROBE := 1.0
const ANGLE_DEFAULT := Vector3(-15, 0, 0)
const ANGLE_AIM := Vector3(-10, -20, 0)
const ANGLE_DIALOG := Vector3(-10, 20, 0)

const TWEEN_TIME_AIM := 0.4
const TWEEN_TIME_AIM_RESET := 0.6
const TWEEN_TIME_DIALOG := 2.0
const TWEEN_TIME_WARDROBE := 1.5

var mouse_accum := Vector2.ZERO
var mouse_sns := Vector2(0.01, 0.01)
var analog_sns := Vector2(-0.1, 0.1)

var cv := CORRECTION_VELOCITY
var hv := H_CORRECTION
var aiming := false
var locked := false

onready var cam_basis = camera.transform.basis

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_accum += event.relative

func _physics_process(delta):
	if locked:
		# Look at player, return
		camera.global_transform = camera.global_transform.looking_at(player.global_transform.origin, Vector3.UP)
		return
	var floor_v: Vector3
	if player.is_on_floor():
		floor_v = player.get_floor_velocity()
	else:
		floor_v = player.applied_ground_velocity
	yaw.global_translate(delta*floor_v*0.8)
	#Camera Movement
	var target: Vector3 = player.global_transform.origin
	var pos: Vector3 = yaw.global_transform.origin
	
	if player.should_raise_camera():
		raise = lerp(raise, LEDGE_GRAB_RAISE, 0.05)
	else:
		raise = lerp(raise, 0.0, 0.05)
	target.y += raise
	
	if player.is_grounded():
		cv = lerp(cv, CORRECTION_VELOCITY_GROUND, 0.1)
	else:
		cv = lerp(cv, CORRECTION_VELOCITY, 0.1)
	
	
	if player.should_slow_follow():
		hv = lerp(hv, H_SLOW_CORRECTION, 0.1)
	else:
		hv = lerp(hv, H_CORRECTION, 0.1)
	
	var diff := target - pos
	var movement := Vector3(
		diff.x*min(delta*hv, 1),
		diff.y*min(delta*cv, 1),
		diff.z*min(delta*hv, 1)
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

func _process(delta):
	# Camera Rotation
	var mouse_aim = -mouse_accum*mouse_sns
	mouse_accum = Vector2.ZERO
	
	var analog_aim = Input.get_vector("cam_left", "cam_right", "cam_down", "cam_up")
	analog_aim *= analog_sns
	
	var aim : Vector2 = delta*60*player.sensitivity*(mouse_aim + analog_aim)
	if player.invert_x:
		aim.x *= -1
	if player.invert_y:
		aim.y *= -1
	
	yaw.rotate_y(aim.x)
	pitch.rotate_x(aim.y)
	if pitch.rotation_degrees.x > 80:
		pitch.rotation_degrees.x = 80
	elif pitch.rotation_degrees.x < -80:
		pitch.rotation_degrees.x = -80

func reset():
	camera.transform.basis = cam_basis
	locked = false
	set_aiming(false)

func lock_follow():
	locked = true

func set_aiming(aim: bool):
	if aiming == aim:
		return
	aiming = aim
	if aiming:
		tween_to(ANGLE_AIM, SPRING_AIM, TWEEN_TIME_AIM)
	else:
		tween_to(ANGLE_DEFAULT, SPRING_DEFAULT, TWEEN_TIME_AIM_RESET)

func start_dialog():
	tween_to(ANGLE_DIALOG, SPRING_DIALOG, TWEEN_TIME_DIALOG)

func end_dialog():
	tween_to(ANGLE_DEFAULT, SPRING_DEFAULT, TWEEN_TIME_DIALOG)

func start_wardrobe():
	tween_to(ANGLE_AIM, SPRING_WARDROBE, TWEEN_TIME_WARDROBE)

func end_wardrobe():
	tween_to(ANGLE_DEFAULT, SPRING_DEFAULT, TWEEN_TIME_WARDROBE)

func tween_to(angle: Vector3, distance: float, time: float):
		tween.remove_all()
		tween.interpolate_property(spring, "rotation_degrees",
			spring.rotation_degrees, angle,
			time,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property(spring, "spring_length",
			spring.spring_length, distance,
			time,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		#tween.interpolate_property(camera, "rotation_degrees",
		#	camera.rotation_degrees, -angle,
		#	time,
		#	Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
