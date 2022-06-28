extends KinematicEnemy

onready var laser := $laser
onready var aim_cast := $laser/aim_cast
onready var awareness := $awareness

export(float) var aim_speed := 1.0
export(float) var aim_speed_windup := 0.1
export(float) var time_to_shoot := 3.0

const TIME_WINDUP := 0.5
const TIME_ATTACK := 1.0
const TIME_DAMAGED := 0.4
const TIME_QUIT := 5.0
var shot_timer := 0.0
var state_timer := 0.0
var quit_timer := 0.0

func _physics_process(delta):
	state_timer += delta
	match ai:
		AI.Idle:
			var bodies = awareness.get_overlapping_bodies()
			if bodies.size() != 0:
				target = bodies[0]
				set_state(AI.Alerted)
		AI.Alerted:
			if !target:
				set_state(AI.Idle)
			elif !awareness.overlaps_body(target):
				quit_timer += delta
				if quit_timer >= TIME_QUIT:
					set_state(AI.Idle)
			else:
				quit_timer = 0
			shot_timer += delta
			if shot_timer >= time_to_shoot:
				set_state(AI.Windup)
			aim(delta, aim_speed)
		AI.Windup:
			if state_timer > TIME_WINDUP:
				set_state(AI.Attacking)
			aim(delta, aim_speed_windup)
		AI.Attacking:
			if state_timer > TIME_ATTACK:
				set_state(AI.Alerted)
		AI.Damaged:
			if state_timer > TIME_DAMAGED:
				set_state(AI.Alerted)
		AI.Dead:
			fall_down(delta)
	aim_cast.update()

func aim(delta: float, speed: float):
	if target:
		var aim_dir: Vector3 = (target.global_transform.origin + 0.75*Vector3.UP - laser.global_transform.origin).normalized()
		if aim_dir.is_normalized():
			var f:Vector3 = laser.global_transform.basis.z
			var angle :float = f.angle_to(aim_dir)
			if abs(angle) > 0.0:
				var axis := f.cross(aim_dir).normalized()
				if axis.is_normalized():
					var rot := sign(angle)*min(abs(angle), aim_speed*delta)
					laser.global_rotate(axis, rot)
	
	
func set_state(new_ai):
	state_timer = 0.0
	ai = new_ai
	if !laser:
		return
	
	var mat_laser: SpatialMaterial = laser.material_override
	mat_laser.albedo_color = Color(3, 0.2, 0.2)
	match ai:
		AI.Idle:
			laser.hide()
		AI.Alerted:
			laser.show()
		AI.Windup:
			laser.show()
			mat_laser.albedo_color = Color(3,3,3)
		AI.Attacking:
			shot_timer = 0.0
			fire()
		AI.Dead:
			laser.hide()

func get_target_ref():
	return $target.global_transform.origin

func fire():
	var c = aim_cast.get_hit_collider()
	if c and c.has_method("take_damage"):
		c.take_damage(attack_damage, laser.global_transform.basis.z)
		var particles := $impact/Particles
		particles.emitting = false
		particles.global_transform.origin = (
			aim_cast.global_transform.origin 
			+ aim_cast.global_transform.basis.z*aim_cast.get_hit_length())
		particles.emitting = true
