extends Spatial

const MAX_RADIUS = 8
const MIN_RADIUS = 1
const RADIUS_SEC = 2

const MAX_RECOIL = 15
const MIN_RECOIL = 2
const RECOIL_SEC = 5

var charge_fire := true
var time_firing := 0.4

var charging := false
var charging_time := 0.0
var time_since_fired := INF
var recoil: Vector3

var active_bubble := 0
var bubble_count := 2

func _process(delta):
	$Particles.emitting = charging
	time_since_fired += delta
	if charging:
		charging_time += delta
		assert($Particles.emitting)

func can_charge():
	return time_since_fired > time_firing

func charge():
	charging_time = 0.0
	charging = true

func fire():
	time_since_fired = 0
	$Particles.emitting = false
	var bubble = get_node("damage/area%d" % (active_bubble + 1))
	active_bubble = (active_bubble + 1) % bubble_count
	bubble.global_transform.origin = global_transform.origin
	
	var anim = bubble.get_node("AnimationPlayer")
	anim.stop()
	anim.play("fire")
	
	var r = clamp(charging_time*RADIUS_SEC, MIN_RADIUS, MAX_RADIUS)
	recoil = Vector3.UP*clamp(charging_time*RECOIL_SEC, MIN_RECOIL, MAX_RECOIL)
	
	
	$Tween.interpolate_property(bubble.get_node("MeshInstance"), "scale", 
		Vector3(0.1, 0.1, 0.1), Vector3(r,r,r), time_firing,
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(bubble.get_node("CollisionShape").shape, "radius",
		0.1, r, time_firing,
		Tween.TRANS_CUBIC, Tween.EASE_OUT)

	$Tween.start()
	charging = false
	return true
