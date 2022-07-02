extends KinematicBody

export(float) var initial_velocity = 10.0
export(float) var damage_speed := 0.1
export(float) var damage_on_hit := 10.0
export(Vector3) var max_rotation_speed := Vector3(0.3, 0.3, 0.3)

enum State {
	Inactive,
	GravityStunned,
	Falling,
	Planting
}

var state = State.Inactive
var grav_time := 0.0
var velocity := Vector3.ZERO
var axis := Vector3.ZERO
var rotate_speed := 0.0
onready var original_y = global_transform.origin.y
var damaged_bodies = []

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	match state:
		State.GravityStunned:
			velocity *= clamp(1.0 - delta, 0.1, 0.995)
			velocity += Vector3.UP*delta*Global.gravity_stun_velocity
			var col = move_and_collide(velocity*delta, true, true, true)
			if col and !col.collider.is_in_group("push"):
				var _col = move_and_collide(velocity*delta)
			else:
				global_translate(velocity*delta)
			global_rotate(axis, delta*rotate_speed)
			grav_time += delta
			if grav_time > Global.gravity_stun_time:
				state = State.Falling
		State.Falling:
			velocity += Vector3.DOWN*9.8*delta
			global_translate(velocity*delta)
			if global_transform.origin.y < original_y:
				set_physics_process(false)
				velocity = Vector3.ZERO
	
func gravity_stun(_damage):
	var angular_speed: Vector3 = max_rotation_speed*Vector3(randf(),randf(),randf())
	axis = angular_speed.normalized()
	rotate_speed = angular_speed.length()
	damaged_bodies = []
	state = State.GravityStunned
	grav_time = 0.0
	set_physics_process(true)
	velocity = Vector3.UP*initial_velocity

func take_damage(damage, dir, _source: Node):
	velocity += damage*dir*damage_speed

func _on_damage_area_body_exited(body):
	if body in damaged_bodies or !body.has_method("take_damage"):
		return
	var dir = (body.global_transform.origin - global_transform.origin).normalized()
	body.take_damage(damage_on_hit, dir, self)
	take_damage(1, -dir, self)
