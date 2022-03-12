extends KinematicBody
class_name Player

signal pause
signal death
signal act

export(float) var kill_plane := -15.0
export(Material) var material_override setget set_material_override
#constants
const SPEED = 12
const gravity := Vector3.DOWN*10

const accel = 140
const decel_against := 200.0
const decel_with := 10.0

onready var cam_yaw: Spatial = $cam_yaw
onready var cam_pitch: Spatial = $cam_yaw/cam_pitch
onready var camera: Camera = $cam_yaw/cam_pitch/Camera
onready var model: Spatial = $model
onready var neck_attach: Spatial = $model/Armature/Skeleton/neck_attach
onready var action_cast: RayCast = $cam_yaw/cam_pitch/Camera/actionCast

var headbob: bool = false

#variables
var velocity := Vector3(0,0,0)
var can_move := true
var cam_angle := 0.0
var in_air := false

## Camera Controls
#Settings
var sensitivity := Vector2(1,1)
var cam_acceleration := 24.0
var cam_invert := Vector2(-1,1)

#Constants
const analog_sns := Vector2(4, 4)

const mouse_factor := Vector2(0.25, -0.25)
var mouse_sns := Vector2(1,1)

#Aggregate Input
var cam_delta := Vector2(0,0) # Mouse
var cam_velocity := Vector2(0,0) # Analog Stick

#Camera Sway
const cam_speed_base := Vector3(1, 1, 1)
const cam_speed_shift := Vector3(1, 1, 1)
const cam_span_base := 0.1*Vector3(0.03, 0.03, .03) 
const cam_span_shift := 0.1*Vector3(0.02, 0.02, .02)
onready var cam_base: Vector3 = camera.translation

var rnd_cam_speed : Vector3
var rnd_cam_span : Vector3
var rnd_cam_timer := Vector3(0,0,0)

onready var starting_transform = global_transform

# Inventory
var has_flower := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rnd_cam_span = cam_span_base
	rnd_cam_speed = cam_speed_base
	set_process(true)
	set_physics_process(true)

func _input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		cam_delta += event.relative*mouse_factor*mouse_sns
	elif event.is_action_pressed("gm_act"):
		emit_signal("act")
	elif event.is_action_pressed("gm_pause"):
		emit_signal("pause")

func _physics_process(delta) -> void:
	if global_transform.origin.y < kill_plane:
		die()

	var direction := Input.get_vector("mv_forward", "mv_back","mv_left", "mv_right")
	#: apply input
	var b := cam_yaw.global_transform.basis
	var target_dir := (b.z*direction.x + b.x*direction.y)
	var dir := velocity/SPEED
	dir.y = 0
	
	var charge:Vector3
	var steer: Vector3
	var a: float = accel
	if dir.length_squared() >= 0.01 and target_dir != Vector3.ZERO:
		charge = target_dir.project(dir)
		steer = target_dir - charge
		if charge.dot(dir) <= 0.0:
			a = decel_against
		elif charge.length_squared() < dir.length_squared():
			a = decel_with
	else:
		charge = target_dir
		steer = Vector3.ZERO
	
	velocity += delta*( (charge - dir)*a + (steer*accel) + gravity )
	if is_nan(velocity.length()) or velocity.length() == INF:
		print_debug("Velocity is NaN!")
		get_tree().paused = true
	velocity = move_and_slide(velocity)
	# One weird trick to prevent infinite falling velocity on v-shaped geometry
	var average_normal := Vector3.ZERO
	for i in range(get_slide_count()):
		var c := get_slide_collision(i)
		var n := c.normal
		average_normal += n/get_slide_count()
	if average_normal != Vector3.ZERO:
		velocity = velocity.slide(average_normal.normalized())
		$model/debug/box/debug1.text = "Average_normal: (%.2f, %.2f, %.2f)" % [average_normal.x, average_normal.y, average_normal.z]
		$model/debug/box/debug2.text = "Collisions: "+ str(get_slide_count())
	in_air = $ground.get_overlapping_bodies().size() == 0
	
	$model/debug/box/debug.text = "Velocity: (%.2f, %.2f, %.2f)" % [velocity.x, velocity.y, velocity.z]

func _process(delta) -> void:
	look(get_camera_movement(delta))
	if headbob:
		cam_pitch.global_transform.origin = neck_attach.global_transform.origin
	#Random camera movement
	rnd_cam_timer += delta*rnd_cam_speed
	for i in range(3):
		if rnd_cam_timer[i] >= PI*2:
			rnd_cam_timer[i] = 0
			rnd_cam_span[i] = cam_span_base[i] + randf()*cam_span_shift[i]
			rnd_cam_speed[i] = cam_speed_base[i] + randf()*cam_speed_shift[i]
	camera.set_translation(cam_base +
		Vector3(
			sin(rnd_cam_timer.x)*rnd_cam_span.x, 
			sin(rnd_cam_timer.y)*rnd_cam_span.y, 
			sin(rnd_cam_timer.z)*rnd_cam_span.z))
		
	model.animate(delta)
	
	if action_cast.is_colliding():
		var col = action_cast.get_collider().get_parent()
		if "zone_entry" in col and col.zone_entry != "":
			$ui/zone_stats.visible = true
			var zone: String = col.zone_entry
			$ui/zone_stats/name.text = tr("zone_"+zone)
			var stats = Global.get_zone_stats(zone)
			$ui/zone_stats/levels.text = "%d/7 %s" % [
				stats["cleared_levels"],
				tr("zstat_levels")
			]
			$ui/zone_stats/perfect.visible = stats["perfect_clear"]
		else:
			$ui/zone_stats.visible = false
	else:
		$ui/zone_stats.visible = false

func look(movement) -> void:
	cam_yaw.rotate_y(movement.x)
	var rotate = movement.y
	if rotate + cam_angle > PI/2 and rotate > 0:
		rotate = PI/2 - cam_angle
	elif rotate + cam_angle < -PI/2 and rotate < 0:
		rotate = -(PI/2) - cam_angle
	cam_pitch.rotate_x(rotate)
	cam_angle += rotate
	$model/debug/box/debug3.text = "Camera: " + str(cam_angle)


func get_camera_movement(delta) -> Vector2:
	var cam: Vector2 = Input.get_vector( "cam_left", "cam_right","cam_down", "cam_up")
	cam_velocity = cam_velocity.linear_interpolate(cam, min(cam_acceleration*delta, 1.0))
	cam = cam_velocity
	cam *= sensitivity
	cam *= analog_sns
	cam += cam_delta
	cam *= cam_invert
	cam_delta.x = 0
	cam_delta.y = 0
	return cam*delta

func die():
	emit_signal("death")

func set_material_override(mat: Material):
	material_override = mat
	$model/Armature/Skeleton/head.material_override = mat
	$model/Armature/Skeleton/player2.material_override = mat

func show_level_select(zone):
	$ui/level_select.gen_and_show(zone)

func hide_level_select():
	$ui/level_select.exit()
