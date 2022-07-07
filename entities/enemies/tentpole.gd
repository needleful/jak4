extends KinematicEnemy

export(float) var run_speed = 6.5
export(float) var turn_speed_radians = 8.0

onready var awareness := $awareness
onready var anim := $AnimationTree
onready var playback:AnimationNodeStateMachinePlayback = anim["parameters/StateMachine/playback"]
onready var chopper_hitbox:Area = $Armature/Skeleton/chopper/Area

const TIME_TO_QUIT := 2.0
const TIME_ALERT := 1.0
const TIME_DAMAGED := 0.8
var quit_timer := 0.0
var state_timer := 0.0

func _physics_process(delta):
	state_timer += delta
	match ai:
		AI.Idle:
			for b in $awareness.get_overlapping_bodies():
				if b.is_in_group("player"):
					target = b
					set_state(AI.Chasing)
			fall_down(delta)
		AI.Alerted:
			if !target:
				set_state(AI.Idle)
			elif state_timer > TIME_ALERT:
				set_state(AI.Chasing)
			look_at_target(delta*turn_speed_radians)
		AI.Chasing:
			if !target or target.is_dead():
				set_state(AI.Idle)
			elif !awareness.overlaps_body(target):
				quit_timer += delta
				if quit_timer > TIME_TO_QUIT:
					set_state(AI.Idle)
			else:
				quit_timer = 0
			look_at_target(delta*turn_speed_radians)
			walk(delta, run_speed)
		AI.Damaged:
			if state_timer >= TIME_DAMAGED:
				set_state(AI.Chasing)
			look_at_target(turn_speed_radians*delta)
			fall_down(delta)
		AI.Dead:
			fall_down(delta)
		AI.GravityStun:
			stunned_move(delta)
			if state_timer > Global.gravity_stun_time:
				set_state(AI.Chasing)
		AI.GravityStunDead:
			stunned_move(delta)
			if state_timer > Global.gravity_stun_time:
				set_state(AI.Dead)
			

func take_damage(damage, dir, source):
	if source and source != self:
		return
	else:
		if last_attacker:
			target = last_attacker
		.take_damage(damage, dir, source)

func set_state(new_ai):
	ai = new_ai
	state_timer = 0
	match ai:
		AI.Idle:
			chopper_hitbox.active = false
			playback.travel("Idle-loop")
		AI.Alerted:
			playback.travel("Chase")
		AI.Chasing:
			chopper_hitbox.active = true
			playback.travel("Chase")
		AI.Damaged:
			target = Global.get_player()
			if playback.get_current_node() == "Chase":
				anim["parameters/StateMachine/Chase/Damaged/active"] = true
			else:
				playback.travel("Damaged")
			velocity = move_dir
		AI.Dead:
			chopper_hitbox.active = false
			playback.travel("Death")
			$CollisionShape.disabled = true
			$CollisionShape2.disabled = true
			$Armature/Skeleton/head.queue_free()
		AI.GravityStun:
			chopper_hitbox.active = true
			playback.travel("GravityStun")
		AI.GravityStunDead:
			velocity = move_dir
