tool
extends KinematicBody

export(bool) var active := true
export(float) var max_rotation_speed := 20.0
export(float) var imparted_velocity := 2.0
export(float) var effective_range := 15.0 setget set_range

onready var particles = $Particles
onready var prop := $fan_body/propeller
onready var hurtbox := $hurtbox
onready var windbox := $windbox

const ACCEL := 2.0
var speed := 0.0

func _ready():
	set_active(active)

func _physics_process(delta):
	if Engine.editor_hint:
		return
	windbox.velocity = imparted_velocity
	speed = lerp(speed, max_rotation_speed if active else 0.0, delta*ACCEL)
	prop.rotate_y(speed*delta)
	var p: ParticlesMaterial = particles.process_material
	p.initial_velocity = imparted_velocity
	particles.lifetime = effective_range/imparted_velocity
	$blockade/CollisionShape.disabled = TimeManagement.time_slowed

func set_active(a):
	active = a
	hurtbox.active = active
	particles.emitting = active
	windbox.set_physics_process(active)

func set_range(r):
	effective_range = r
	var height = r
	var position = r/2
	$windbox/CollisionShape.shape.height = height
	$windbox/CollisionShape.transform.origin.y = position
