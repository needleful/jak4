extends Spatial

onready var anim: AnimationPlayer = $AnimationPlayer

const MAX_RADIUS = 8
const MIN_RADIUS = 1
const RADIUS_SEC = 2

const MAX_RECOIL = 15
const MIN_RECOIL = 2
const RECOIL_SEC = 5

var charge_fire := true
var time_firing := 0.5

var charging := false
var charging_time := 0.0
var recoil: Vector3

func _process(delta):
	$Particles.emitting = charging
	if charging:
		charging_time += delta
		assert($Particles.emitting)

func charge():
	charging_time = 0.0
	charging = true
	print("CHARGING")

func fire():
	print("FIRE")
	$Particles.emitting = false
	$damage/area.global_transform.origin = global_transform.origin
	anim.stop()
	anim.play("fire")
	
	var r = clamp(charging_time*RADIUS_SEC, MIN_RADIUS, MAX_RADIUS)
	recoil = Vector3.UP*clamp(charging_time*RECOIL_SEC, MIN_RECOIL, MAX_RECOIL)
	
	$Tween.interpolate_property($damage/area/MeshInstance, "scale", 
		Vector3(0.1, 0.1, 0.1), Vector3(r,r,r), time_firing,
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($damage/area/CollisionShape.shape, "radius",
		0.1, r, time_firing,
		Tween.TRANS_CUBIC, Tween.EASE_OUT)

	$Tween.start()
	charging = false
	return true
