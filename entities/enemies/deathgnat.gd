tool
extends KinematicEnemy
class_name DeathGnat

export(PackedScene) var projectile: PackedScene 
export(float) var speed = 5.0
export(float) var turn_speed = 10.0
export(float) var orb_cooldown := 2.0
export(float) var orb_speed := 5.0
export(float) var orb_seeking := 2.0
export(float) var time_to_quit = 10.0
export(float) var minimum_radius = 5.0
export(float) var maximum_radius = 10.0
export(float) var desired_height = 3.0
export(float) var acceleration = 10.0

const TIME_FLINCH := 0.75
var state_timer := 0.0
var quit_timer := 0.0
var orb_timer := 0.0

func _init():
	can_fly = true

func _ready():
	if coat:
		$Armature/Skeleton/bug.set_surface_material(0, coat.generate_material())

func set_active(active):
	if active:
		$AnimationPlayer.play("Idle-loop", -1, 0.5)
	else:
		$AnimationPlayer.stop()

func _physics_process(delta):
	state_timer += delta
	if orb_timer > 0:
		orb_timer = max(orb_timer - delta, 0)
	var next_state = ai
	match ai:
		AI.Idle:
			var seen = $awareness.get_overlapping_bodies()
			if seen.size() > 0:
				target = seen[0]
				next_state = AI.Chasing
		AI.Chasing:
			if $awareness.get_overlapping_bodies().size() == 0:
				quit_timer += delta
				if quit_timer > time_to_quit:
					print("I Quit!")
					next_state = AI.Idle
			else:
				quit_timer = 0
		AI.Windup:
			pass
		AI.Attacking:
			pass
		AI.Damaged:
			if state_timer > TIME_FLINCH:
				next_state = AI.Chasing
		AI.GravityStun:
			if state_timer > Global.gravity_stun_time:
				next_state = AI.Chasing
		AI.Dead:
			pass
	set_state(next_state)
	
	match ai:
		AI.Idle:
			pass
		AI.Chasing:
			look_at_target(delta*turn_speed)
			fly(delta)
			if orb_timer <= 0:
				fire_orb()
		AI.Damaged:
			look_at_target(delta*turn_speed)
			velocity = move_and_slide(velocity + GRAVITY*delta)
		AI.Dead:
			fall_down(delta)
		AI.GravityStun:
			stunned_move(delta)

func fire_orb():
	var orb = projectile.instance()
	get_parent().add_child(orb)
	orb.damage = attack_damage
	orb.speed = orb_speed
	orb.turn_speed = orb_seeking
	orb.global_transform.origin = $orb_spawner.global_transform.origin
	orb.fire(target, Vector3.UP)
	orb_timer = orb_cooldown

func fly(delta: float):
	if !target:
		target = Global.get_player()
	var dir := target.global_transform.origin - global_transform.origin
	var change_y := dir.y
	dir.y = 0
	var l = dir.length()
	if l < minimum_radius:
		dir = -dir
	elif l < maximum_radius:
		dir = Vector3.ZERO
	
	dir.y = change_y + desired_height
	dir /= 5
	if dir.length() > 1:
		dir = dir.normalized()
	velocity = velocity.move_toward(speed*dir, delta*acceleration)
	velocity = move_and_slide(velocity)

func play_damage_sfx():
	# TODO
	pass


func get_shield():
	if is_inside_tree():
		return $debug_shield
	else:
		return null

func set_state(new_state):
	if ai == new_state:
		return
	ai = new_state
	state_timer = 0
	match ai:
		AI.Chasing:
			$AnimationPlayer.play("Idle-loop")
			quit_timer = 0
			orb_timer = orb_cooldown
		AI.Dead:
			$AnimationPlayer.stop()
			collision_layer = 0
		AI.Damaged:
			$AnimationPlayer.stop()
			velocity = move_dir
			velocity.y = min(velocity.y, 10)
		AI.GravityStun:
			$AnimationPlayer.stop()
			velocity = move_dir
			$AnimationPlayer.play("GravityStun-loop")
		_:
			$AnimationPlayer.play("Idle-loop")
