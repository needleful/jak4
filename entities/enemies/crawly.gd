extends KinematicEnemy

export(float) var run_speed = 7.5
export(float) var lunge_speed = 15.0
export(float) var turn_speed_radians = 15.0
export(float) var turn_speed_windup = 5.0
export(float) var turn_speed_attacking = 1.0

onready var anim := $crawly/AnimationPlayer

var WINDUP_TIME := .5
var ATTACK_TIME := 0.75
var ALERT_TIME := 2.0
var DAMAGED_TIME := 1.0
var COOLDOWN_TIME := 2.0
var EXTRA_CHASE_TIME := 4.0
var state_timer := 0.0
var cooldown_timer := 0.0
var give_up_timer := 0.0


func _ready():
	if coat:
		$crawly/Armature/Skeleton/crawly.material_override = coat.generate_material()

func _physics_process(delta):
	state_timer += delta
	if cooldown_timer > 0:
		cooldown_timer -= delta
	var next = ai
	match ai:
		AI.Idle:
			for b in $awareness.get_overlapping_bodies():
				target = b
				next = AI.Alerted
		AI.Alerted:
			if state_timer > ALERT_TIME:
				next = AI.Chasing
		AI.Chasing:
			if !target:
				next = AI.Idle
			elif !$awareness.overlaps_body(target):
				give_up_timer += delta
				if give_up_timer > EXTRA_CHASE_TIME:
					next = AI.Idle
			elif cooldown_timer <= 0 and $attack_range.overlaps_body(target):
				next = AI.Windup
			else:
				give_up_timer = 0.0
		AI.Windup:
			if state_timer > WINDUP_TIME:
				next = AI.Attacking
		AI.Attacking:
			if state_timer > ATTACK_TIME:
				next = AI.Chasing
		AI.Damaged:
			if state_timer > DAMAGED_TIME:
				next = AI.Chasing
	set_state(next)
	
	match ai:
		AI.Attacking:
			look_at_target(turn_speed_attacking*delta)
			walk(delta, lunge_speed)
			damage_direction($hurtbox, global_transform.basis.z)
		AI.Chasing:
			look_at_target(turn_speed_radians*delta)
			walk(delta, run_speed)
		AI.Damaged:
			look_at_target(turn_speed_radians*delta)
			velocity.x = move_dir.x
			velocity.z = move_dir.z
			velocity = move_and_slide(velocity + GRAVITY*delta)
		AI.Dead:
			var best_normal = Vector3.ZERO
			for c in get_slide_count():
				var n = get_slide_collision(c).normal
				if n.y > best_normal.y:
					best_normal = n
			var gravity := GRAVITY
			if best_normal != Vector3.ZERO:
				gravity = GRAVITY.project(best_normal)
				
			velocity.x = move_dir.x
			velocity.z = move_dir.z
			move_dir *= 0.9
			velocity = move_and_slide(velocity + gravity*delta)
		AI.Idle:
			walk(delta, 0)
		AI.Windup, AI.Alerted:
			look_at_target(turn_speed_windup*delta)
			walk(delta, 0)

func set_state(new_ai):
	if ai == new_ai:
		return
	if ai == AI.Attacking:
		cooldown_timer = COOLDOWN_TIME
	else:
		cooldown_timer = 0
	ai = new_ai
	state_timer = 0
	damaged = []
	match ai:
		AI.Alerted:
			anim.play("Alert")
		AI.Chasing:
			anim.play("Run-loop")
		AI.Damaged:
			anim.play("Damaged")
		AI.Dead:
			collision_layer = 0
			die()
			anim.play("Die")
			anim.queue("Dead-loop")
		AI.Idle:
			anim.play("Idle-loop")
		AI.Windup:
			anim.play("Attack")
