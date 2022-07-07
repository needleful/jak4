extends KinematicEnemy

export(float) var orb_speed := 9.0
export(float) var orb_seeking := 2.0
export(float) var gun_cooldown := 1.0
export(float) var gravity_stun_speed := 5.0

const time_damaged := 2.0
var state_timer := 0.0

var cooldown: PoolRealArray = [0.0, 0.0, 0.0, 0.0]

onready var guns = [$gun0, $gun1, $gun2, $gun3]

func _init():
	damaged_speed = 0.1

func _ready():
	if coat:
		$turtle.set_surface_material(0, coat.generate_material())

func _physics_process(delta):
	state_timer += delta
	match ai:
		AI.Idle:
			for b in $awareness.get_overlapping_bodies():
				if b.is_in_group("player"):
					target = b
					set_state(AI.Chasing)
			fall_down(delta)
		AI.Chasing:
			for i in range(cooldown.size()):
				cooldown[i] -= delta
				if cooldown[i] < 0:
					cooldown[i] = 0
			if !target or target.is_dead():
				set_state(AI.Idle)
			for i in range(guns.size()):
				var gun = guns[i]
				var a:Area = gun.get_node("awareness")
				if a.overlaps_body(target) and cooldown[i] <= 0:
					fire_orb(gun.global_transform.origin, orb_speed, orb_seeking)
					cooldown[i] = gun_cooldown
			fall_down(delta)
		AI.Damaged:
			if state_timer > time_damaged:
				set_state(AI.Chasing)
			fall_down(delta)
		AI.GravityStun:
			print(velocity)
			stunned_move(delta)
			if state_timer > Global.gravity_stun_time:
				set_state(AI.Chasing)
		AI.GravityStunDead:
			stunned_move(delta)
			if state_timer > Global.gravity_stun_time:
				set_state(AI.Dead)
		AI.Dead:
			fall_down(delta)

func set_state(new_ai):
	state_timer = 0.0
	ai = new_ai
	match ai:
		AI.Chasing:
			for i in range(cooldown.size()):
				cooldown[i] = 0
		AI.GravityStun:
			velocity += Vector3.UP*gravity_stun_speed
		AI.Damaged:
			velocity += move_dir
		AI.GravityStunDead:
			velocity += Vector3.UP*gravity_stun_speed

func take_damage(damage, dir, source):
	if source and source != self:
		return
	else:
		if last_attacker:
			target = last_attacker
		.take_damage(damage, dir, source)
