extends KinematicEnemy

export(float) var bounce_damage := 5.0
export(float) var aim_speed := 0.6
export(float) var aim_speed_windup := 0.35
export(float) var time_to_shoot := 3.0
export(float) var move_speed := 8.0
export(float) var flee_radius := 5.0
export(float) var safe_radius := 10.0
export(float) var bounce_velocity := 8.0
export(float) var flee_acceleration := 40.0

export(Color) var laser_color := Color(3, 0.2, 0.2)

const TIME_WINDUP := 0.5
const TIME_ATTACK := 1.0
const TIME_DAMAGED := 0.4
const TIME_QUIT := 5.0

const BOUNCE_WINDUP_TIME := 0.75
const BOUNCE_TIME_TO_HITBOX := 0.1
const BOUNCE_MIN_TIME := 0.25
const BOUNCE_TURN_SPEED := 5.0
const DEFAULT_DISTANCE := 20.0

const GRAV_STUN_TURN_SPEED := 1.0

var shot_timer := 0.0
var state_timer := 0.0
var quit_timer := 0.0
var bounce_timer := 0.0

var grounded := true

onready var laser := $laser
onready var aim_cast := $laser/aim_cast
onready var awareness := $awareness
onready var groundArea := $ground_area
onready var clawHitbox := $claw_hitbox
onready var anim:AnimationNodeStateMachinePlayback = $AnimationTree["parameters/StateMachine/playback"]
onready var anim_tree := $AnimationTree

func _ready():
	aim_cast.add_excluded_object(self.get_rid())

func _physics_process(delta):
	state_timer += delta
	var dist: Vector3
	if target:
		dist = target.global_transform.origin - global_transform.origin
	
	match ai:
		AI.Idle:
			for b in $awareness.get_overlapping_bodies():
				if b.is_in_group("player"):
					target = b
					set_state(AI.Chasing)
			fall_down(delta)
		AI.Chasing:
			shot_timer += delta
			if !target or target.is_dead():
				set_state(AI.Idle)
			else:
				if !awareness.overlaps_body(target):
					quit_timer += delta
				else:
					quit_timer = 0.0
				
				if quit_timer >= TIME_QUIT:
					set_state(AI.Idle)
				elif shot_timer >= time_to_shoot:
					set_state(AI.Windup)
				elif dist.length_squared() < flee_radius*flee_radius:
					if !shielded or dist.normalized().dot(global_transform.basis.z) < min_dot_shielded_damage + 0.5:
						set_state(AI.Flee)
			var f := DEFAULT_DISTANCE/(1 + dist.length())
			aim(delta, f*aim_speed)
			fall_down(delta)
		AI.Windup:
			if state_timer > TIME_WINDUP:
				set_state(AI.Attacking)
			var f := DEFAULT_DISTANCE/(1 + dist.length())
			aim(delta, f*aim_speed_windup)
			fall_down(delta)
		AI.Attacking:
			if state_timer > TIME_ATTACK:
				set_state(AI.Chasing)
			fall_down(delta)
		AI.Damaged:
			if state_timer > TIME_DAMAGED:
				set_state(AI.Chasing)
			fall_down(delta)
		AI.Flee:
			if !target or target.is_dead():
				set_state(AI.Idle)
			else:
				bounce_timer += delta
				dist.y = 0
				var dir := -dist.normalized()
				var safe_dist := dist.length_squared() > safe_radius*safe_radius
				var safe_angle := dist.normalized().dot(global_transform.basis.z) > 0.2
				if grounded:
					if safe_angle and safe_dist:
						set_state(AI.Chasing)
						
					fall_down(delta)

					if bounce_timer > BOUNCE_WINDUP_TIME:
						if safe_dist:
							dir = Vector3.ZERO
						velocity = Vector3.UP*bounce_velocity + dir*move_speed
						grounded = false
						bounce_timer = 0
						damaged = []
					elif !groundArea.get_overlapping_bodies().size() > 0:
						grounded = false
				else:
					look_at_target(BOUNCE_TURN_SPEED*delta)
					velocity = move_and_slide(velocity + GRAVITY*delta, Vector3.UP)
					if bounce_timer > BOUNCE_MIN_TIME and is_on_floor():
						anim.travel("Flee_Windup")
						grounded = true
						bounce_timer = 0
					if bounce_timer > BOUNCE_TIME_TO_HITBOX:
						damage_direction(clawHitbox, -dir, bounce_damage)
		AI.GravityStun:
			look_at_target(GRAV_STUN_TURN_SPEED*delta)
			stunned_move(delta)
			if state_timer > Global.gravity_stun_time:
				set_state(AI.Chasing)
		AI.Dead:
			fall_down(delta)
	aim_cast.update()

func aim(delta: float, speed: float):
	if target:
		var aim_dir: Vector3 = (target.global_transform.origin + 0.75*Vector3.UP - laser.global_transform.origin).normalized()
		if aim_dir.is_normalized():
			if aim_dir.dot(global_transform.basis.z) < 0:
				set_state(AI.Flee)
			var f:Vector3 = laser.global_transform.basis.z
			var angle :float = f.angle_to(aim_dir)
			if abs(angle) > 0.0:
				var axis := f.cross(aim_dir).normalized()
				if axis.is_normalized():
					var rot := sign(angle)*min(abs(angle), speed*delta)
					laser.global_rotate(axis, rot)
		var aim_up :float = laser.global_transform.basis.z.dot(global_transform.basis.y)
		var aim_right :float = laser.global_transform.basis.z.dot(-global_transform.basis.x)
		anim_tree["parameters/StateMachine/Aim/blend_position"] = Vector2(aim_right, aim_up)

func get_shield():
	if is_inside_tree():
		return $debug_shield
	else:
		return null

func get_target_ref():
	return $target.global_transform.origin

func fire():
	damaged = []
	var c = aim_cast.get_hit_collider()
	if !c:
		return
	if c.has_method("take_damage"):
		c.take_damage(attack_damage, laser.global_transform.basis.z, self)
	var particles := $impact/Particles
	particles.emitting = false
	particles.global_transform.origin = (
		aim_cast.global_transform.origin 
		+ aim_cast.global_transform.basis.z*aim_cast.get_hit_length())
	particles.emitting = true

func set_state(new_ai):
	grounded = true
	state_timer = 0.0
	ai = new_ai
	if !laser:
		return
	
	var mat_laser: SpatialMaterial = laser.material_override
	match ai:
		AI.Idle:
			anim.travel("Idle")
			laser.hide()
		AI.Chasing:
			shot_timer = 0.0
			anim.travel("Aim")
			mat_laser.albedo_color = laser_color
			laser.show()
		AI.Windup:
			laser.show()
			mat_laser.albedo_color = Color(3,3,3)
		AI.Attacking:
			shot_timer = 0.0
			fire()
		AI.Flee:
			anim.travel("Flee_Windup")
			laser.hide()
		AI.Dead:
			anim.travel("Death")
			laser.hide()
			$CollisionShape.disabled = true
			$CollisionShape2.disabled = true
			$CollisionShape3.disabled = false
		AI.Damaged:
			if last_attacker:
				target = last_attacker
			anim.travel("Damaged")
			if grounded:
				velocity.y += move_dir.y
			else:
				velocity += move_dir
		AI.GravityStun:
			anim.travel("GravityStun")
