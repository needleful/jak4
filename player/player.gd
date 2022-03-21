extends KinematicBody
class_name PlayerBody

const RUN_SPEED := 7.0
const WALKING_SPEED := 1.5
const GRAVITY := Vector3.DOWN*24

const MIN_GROUND_DOT := 0.7
const MIN_SLIDE_DOT := 0.12

const COYOTE_TIME := 0.1
var coyote_timer := 0.0

const BASE_JUMP_VEL := 8.0
const CROUCH_JUMP_VEL := 12.5
const LEDGE_JUMP_VEL := 9.0
const ROLL_JUMP_VEL := 7.0
const ROLL_JUMP_LURCH := 15.0

const BASE_JUMP_TIME := 0.25
const ROLL_JUMP_STEER := 2.5
const CROUCH_JUMP_TIME := 0.5
var state_timer := 0.0

const MIN_SPEED_ROLL := 2.0

const CROUCH_SPEED := 2.0
const ROLL_SPEED := 15.0
const ROLL_TIME := 0.5
const ROLL_MIN_TIME_JUMP := 0.3
const BONK_SPEED := 5.0

const CLIMB_STAMINA_DRAIN := 25.0
const MIN_CLIMB_STAMINA := 10.0

# Accelerating from zero
const ACCEL_START := 50.0
# Accelerating when moving above some speed
const ACCEL := 20.0
const ACCEL_SLIDE := 10.0
const ACCEL_ROLL := 0.5
# Decelerate against velocity
const DECEL_AGAINST := 45.0
# Decelerate with velocity
const DECEL_WITH := 15.0

const TIME_LEDGE_FALL := 0.5
const LEDGE_MIN_Y := 0.6

# Combat

const LUNGE_KICK_TIME := 0.6
const SPIN_KICK_TIME := 0.7
const UPPERCUT_WINDUP_TIME := 0.25
const UPPERCUT_MIN_TIME := 0.4
const UPPERCUT_MAX_TIME := 0.8
const DIVE_WINDUP_TIME := 0.2
const DIVE_END_TIME := 0.75

const LUNGE_KICK_VEL := 25.0
const AIR_SPIN_VEL := 5.0
const UPPERCUT_VEL := 10.0
const UPPERCUT_EXTRA_GRAVITY := 0.2
const DIVE_WINDUP_VEL := 4.0
const DIVE_EXTRA_GRAVITY := 0.5

const STEER_KICK := 5.0
const DECEL_KICK := 75.0

const DIVE_START_DAMGE := 15
const DIVE_END_DAMAGE := 25
const UPPERCUT_DAMAGE := 20
const LUNGE_DAMAGE := 15
const SPIN_DAMAGE := 10
const ROLL_JUMP_DAMAGE := 5

const VEL_H_DAMAGED := 5
const VEL_V_DAMAGED := 6
const TIME_DAMAGED := 0.75

var max_health := 50
var health := max_health
var damaged_objects: Array = []

var max_stamina := 20.0
var stamina_recover := 8.0
var stamina := max_stamina

var move_speed := 1.0
var jump_height := 1.0

onready var cam_yaw := $camera_rig/yaw
onready var mesh := $jackie
onready var crouch_head := $crouchHeadArea
onready var intention := $intention

onready var ledgeCastLeft := $jackie/leftHandCast
onready var ledgeCastRight := $jackie/rightHandCast
onready var ledgeCastCenter := $jackie/centerCast
onready var ledgeCastCeiling := $jackie/ceilingCast
onready var ledgeCastWall := $jackie/wallCast
onready var ledgeRef := $jackie/reference

onready var lunge_hitbox := $jackie/attack_lunge
onready var spin_hitbox := $jackie/attack_spin
onready var roll_hitbox := $jackie/attack_roll
onready var uppercut_hitbox := $jackie/attack_uppercut
onready var dive_start_hitbox := $jackie/attack_dive_start
onready var dive_end_hitbox := $jackie/attack_dive_end

var velocity := Vector3.ZERO

enum State {
	Ground,
	Fall,
	Slide,
	BaseJump,
	Crouch,
	Roll,
	Climb,
	CrouchJump,
	RollJump,
	RollFall,
	LedgeHang,
	LedgeFall,
	LedgeJump,
	BonkFall,
	LungeKick,
	SpinKick,
	AirSpinKick,
	UppercutWindup,
	Uppercut,
	DiveWindup,
	DiveStart,
	DiveEnd,
	Damaged
}

var state: int = State.Fall
var ground_normal:Vector3 = Vector3.UP

var current_coat: Coat

func _ready():
	set_state(State.Ground)
	if Global.valid_game_state:
		global_transform = Global.game_state.player_transform
		set_current_coat(Global.game_state.current_coat)
	else:
		# Generate a random Common coat
		var i = (1 << 56) + (randi() & 0xFFFFFFFFFFF)
		var coat = Global.get_coat(i)
		set_current_coat(coat)
		Global.add_coat(coat)
	var _x = Global.connect("inventory_changed", self, "redraw_inventory")
	redraw_inventory()
	update_health()

func _input(event):
	if event.is_action_pressed("debug_randomize_coat"):
		var coat = Global.get_coat(randi())
		set_current_coat(coat)
		Global.add_coat(coat)
		
func prepare_save():
	Global.game_state.player_transform = global_transform
	Global.game_state.current_coat = current_coat
	assert(Global.game_state.player_transform == global_transform)
	$ui/saveStats/AnimationPlayer.play("save_start")

func complete_save():
	$ui/saveStats/AnimationPlayer.queue("save_complete")

func redraw_inventory():
	var state_viewer: Control = $ui/debug/game_state
	for c in state_viewer.get_children():
		state_viewer.remove_child(c)
	add_label(state_viewer, "Stats:")
	for s in Global.game_state.stats:
		add_label(state_viewer, "\t%s: %d" % [s, Global.stat(s)])
	add_label(state_viewer, "Inventory:")
	for i in Global.game_state.inventory:
		add_label(state_viewer, "\t%s: %d" % [i, Global.count(i)])

func add_label(box: Control, text: String):
	var l := Label.new()
	l.text = text
	box.add_child(l)

func set_current_coat(coat: Coat):
	current_coat = coat
	mesh.show_coat(coat)

func _physics_process(delta):
	if global_transform.origin.y < -1000:
		global_transform.origin.y = 1000
	state_timer += delta
	if state != State.Climb:
		stamina += stamina_recover*delta
	stamina = clamp(stamina, 0.0, max_stamina)
	
	var movement := Input.get_vector("mv_left", "mv_right", "mv_up", "mv_down")
	var desired_velocity: Vector3 = move_speed*(
		cam_yaw.global_transform.basis.x * movement.x
		+ cam_yaw.global_transform.basis.z * movement.y)
	
	rotate_intention(desired_velocity)
	
	var best_floor_dot := -1.0
	var best_normal := Vector3.ZERO
	for c in range(get_slide_count()):
		var col := get_slide_collision(c)
		var normal := col.normal
		var dot := normal.dot(Vector3.UP)
		if dot > best_floor_dot:
			best_floor_dot = dot
			best_normal = normal
	$ui/debug/stats/a2.text = "Floor Dot: %f" % best_floor_dot
	
	var next_state := state
	match state:
		State.Ground:
			if Input.is_action_just_pressed("mv_jump"):
				next_state = State.BaseJump
			elif Input.is_action_pressed("mv_crouch"):
				if velocity.length() > MIN_SPEED_ROLL:
					next_state = State.Roll
				else:
					next_state = State.Crouch
			elif Input.is_action_just_released("combat_lunge"):
				next_state = State.LungeKick
			elif Input.is_action_just_pressed("combat_spin"):
				next_state = State.SpinKick
			elif $groundArea.get_overlapping_bodies().size() == 0:
				coyote_timer += delta
				if coyote_timer > COYOTE_TIME:
					next_state = State.Fall
			elif best_normal != Vector3.ZERO and best_floor_dot < MIN_GROUND_DOT:
				next_state = State.Slide
			else:
				coyote_timer = 0
		State.Slide:
			if Input.is_action_just_pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif stamina > MIN_CLIMB_STAMINA and Input.is_action_pressed("mv_crouch"):
				next_state = State.Climb
			elif best_floor_dot > MIN_GROUND_DOT:
				next_state = State.Ground
			elif best_floor_dot < MIN_SLIDE_DOT:
				coyote_timer += delta
				if coyote_timer > COYOTE_TIME:
					next_state = State.Fall
			else:
				coyote_timer = 0
		State.BaseJump, State.LedgeJump:
			if Input.is_action_just_pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif Input.is_action_just_pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif state_timer > BASE_JUMP_TIME:
				next_state = State.Fall
		State.Crouch:
			if Input.is_action_just_pressed("mv_jump"):
				next_state = State.CrouchJump
			elif Input.is_action_just_released("combat_lunge"):
				# TODO: HighKick
				next_state = State.UppercutWindup
			elif !Input.is_action_pressed("mv_crouch") and (
				crouch_head.get_overlapping_bodies().size() == 0
			):
				next_state = State.Ground
			elif best_floor_dot < MIN_SLIDE_DOT:
				next_state = State.Fall
			elif best_floor_dot < MIN_GROUND_DOT:
				if stamina > MIN_CLIMB_STAMINA:
					next_state = State.Climb
				else:
					next_state = State.Slide
		State.CrouchJump:
			if Input.is_action_just_pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif state_timer > CROUCH_JUMP_TIME:
				next_state = State.Fall
		State.Climb:
			stamina -= CLIMB_STAMINA_DRAIN*delta*(1.0-best_floor_dot)
			if best_floor_dot > MIN_GROUND_DOT:
				next_state = State.Crouch
			elif best_floor_dot < MIN_SLIDE_DOT:
				next_state = State.Fall
			elif stamina <= 0 or !Input.is_action_pressed("mv_crouch"):
				next_state = State.Slide
		State.Roll:
			if (state_timer > ROLL_MIN_TIME_JUMP 
				and Input.is_action_just_pressed("mv_jump")
			):
				next_state = State.RollJump
			elif best_floor_dot < MIN_SLIDE_DOT:
				if best_normal != Vector3.ZERO:
					next_state = State.BonkFall
				else:
					coyote_timer += delta
					if coyote_timer > COYOTE_TIME:
						next_state = State.Fall
			else:
				coyote_timer = 0
				if state_timer > ROLL_TIME:
					next_state = State.Crouch
		State.RollJump:
			if Input.is_action_just_pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif (best_normal != Vector3.ZERO
				and best_floor_dot < MIN_SLIDE_DOT
			):
				ground_normal = best_normal
				next_state = State.BonkFall
			elif state_timer > CROUCH_JUMP_TIME:
				if best_floor_dot > MIN_GROUND_DOT:
					next_state = State.Ground
				elif best_floor_dot > MIN_SLIDE_DOT:
					next_state = State.Slide
				else:
					next_state = State.RollFall
		State.RollFall:
			if Input.is_action_just_pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif best_floor_dot > MIN_GROUND_DOT:
				if Input.is_action_pressed("mv_crouch"):
					next_state = State.Crouch
				elif crouch_head.get_overlapping_bodies().size() == 0:
					next_state = State.Ground
			elif best_floor_dot > MIN_SLIDE_DOT:
				if Input.is_action_pressed("mv_crouch"):
					next_state = State.Crouch
				elif crouch_head.get_overlapping_bodies().size() == 0:
					next_state = State.Slide
			elif best_normal != Vector3.ZERO:
					ground_normal = best_normal
					next_state = State.BonkFall
		State.Fall:
			if Input.is_action_just_pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif Input.is_action_just_pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif best_floor_dot > MIN_GROUND_DOT:
				if Input.is_action_pressed("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Ground
			elif best_floor_dot > MIN_SLIDE_DOT:
				if Input.is_action_pressed("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Slide
			elif can_ledge_grab():
				next_state = State.LedgeHang
		State.LedgeHang:
			var intent_dot = mesh.global_transform.basis.z.dot(desired_velocity)
			if Input.is_action_just_pressed("mv_jump"):
				next_state = State.LedgeJump
			elif Input.is_action_just_pressed("mv_crouch") or intent_dot < 0:
				next_state = State.LedgeFall
		State.LedgeFall, State.BonkFall:
			if best_floor_dot > MIN_GROUND_DOT:
				if Input.is_action_pressed("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Ground
			elif best_floor_dot > MIN_SLIDE_DOT:
				if Input.is_action_pressed("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Slide
			else:
				if state_timer >= TIME_LEDGE_FALL:
					next_state = State.Fall
		State.LungeKick:
			if Input.is_action_just_pressed("mv_jump"):
				next_state = State.UppercutWindup
			elif state_timer >= LUNGE_KICK_TIME:
				next_state = State.Ground
		State.SpinKick:
			if state_timer >= SPIN_KICK_TIME:
				next_state = State.Ground
		State.AirSpinKick:
			if best_floor_dot > MIN_GROUND_DOT:
				if Input.is_action_pressed("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Ground
			elif can_ledge_grab():
				next_state = State.LedgeHang
			else:
				if state_timer >= SPIN_KICK_TIME:
					next_state = State.Fall
		State.UppercutWindup:
			if state_timer > UPPERCUT_WINDUP_TIME:
				next_state = State.Uppercut
		State.Uppercut:
			if state_timer > UPPERCUT_MIN_TIME and best_floor_dot > MIN_GROUND_DOT:
				if Input.is_action_pressed("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Ground
			elif state_timer > UPPERCUT_MAX_TIME:
				next_state = State.Fall
		State.DiveWindup:
			if state_timer > DIVE_WINDUP_TIME:
				next_state = State.DiveStart
		State.DiveStart:
			if best_floor_dot > MIN_SLIDE_DOT:
				next_state = State.DiveEnd
		State.DiveEnd:
			if state_timer > DIVE_END_TIME:
				next_state = State.Ground
		State.Damaged:
			if Input.is_action_just_released("combat_lunge"):
				next_state = State.LungeKick
			elif Input.is_action_just_pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif state_timer > TIME_DAMAGED:
				next_state = State.Fall
	set_state(next_state)
	
	match state:
		State.Ground:
			ground_normal = best_normal
			accel(delta, desired_velocity*RUN_SPEED)
		State.Fall, State.LedgeFall:
			accel_air(delta, desired_velocity*RUN_SPEED, ACCEL)
		State.Slide:
			if best_normal != Vector3.ZERO:
				ground_normal = best_normal
			accel_slide(delta, desired_velocity*RUN_SPEED, best_normal)
		State.BaseJump:
			accel_air(delta, desired_velocity*RUN_SPEED, ACCEL_START)
		State.Roll:
			ground_normal = best_normal
			accel(delta, desired_velocity * ROLL_SPEED, ACCEL, ROLL_JUMP_STEER, 0.0)
		State.RollJump, State.RollFall:
			accel_air(delta, desired_velocity * ROLL_SPEED, ACCEL_ROLL, true)
			damage_point(roll_hitbox, ROLL_JUMP_DAMAGE, global_transform.origin)
		State.BonkFall, State.Damaged:
			accel_air(delta, desired_velocity*CROUCH_SPEED, ACCEL_ROLL)
		State.Crouch, State.Climb:
			ground_normal = best_normal
			accel(delta, desired_velocity*CROUCH_SPEED)
		State.CrouchJump, State.LedgeJump:
			accel_air(delta, desired_velocity*CROUCH_SPEED, ACCEL)
		State.LedgeHang:
			desired_velocity = Vector3.ZERO
		State.LungeKick:
			rotate_intention(velocity.normalized())
			accel_lunge(delta, desired_velocity*LUNGE_KICK_VEL)
			damage_directed(lunge_hitbox, LUNGE_DAMAGE, get_visual_forward())
		State.SpinKick:
			accel(delta, desired_velocity*RUN_SPEED)
			damage_point(spin_hitbox, SPIN_DAMAGE, global_transform.origin)
		State.AirSpinKick:
			accel_low_gravity(delta, desired_velocity*RUN_SPEED, 0.75)
			damage_point(spin_hitbox, SPIN_DAMAGE, global_transform.origin)
		State.UppercutWindup:
			accel(delta, 0.5*desired_velocity*CROUCH_SPEED)
		State.Uppercut:
			velocity += delta*GRAVITY*UPPERCUT_EXTRA_GRAVITY
			accel_air(delta, desired_velocity*RUN_SPEED, ACCEL)
			damage_directed(uppercut_hitbox, UPPERCUT_DAMAGE, Vector3.UP)
		State.DiveWindup:
			accel_air(delta, desired_velocity*CROUCH_SPEED, ACCEL)
		State.DiveStart:
			velocity += delta*GRAVITY*DIVE_EXTRA_GRAVITY
			accel_air(delta, desired_velocity*CROUCH_SPEED, ACCEL)
			damage_point(dive_start_hitbox, DIVE_START_DAMGE, global_transform.origin)
		State.DiveEnd:
			accel(delta, desired_velocity*RUN_SPEED)
			damage_point(dive_end_hitbox, DIVE_END_DAMAGE, global_transform.origin)
	update_visuals(desired_velocity)

func _process(_delta):
	update_stamina()

func update_health():
	$ui/stats/health.max_value = max_health
	$ui/stats/health.value = health

func update_stamina():
	$ui/stats/stamina.max_value = max_stamina
	$ui/stats/stamina.value = stamina

func get_visual_forward():
	return mesh.global_transform.basis.z

func accel(delta: float, desired_velocity: Vector3, accel_normal: float = ACCEL, steer_accel: float = ACCEL, decel_factor: float = 1):
	var hvel := velocity
	hvel.y = 0
	var hdir := hvel.normalized()
	
	$ui/debug/stats/a3.text = "DV: (%f, %f, %f)" % [
		desired_velocity.x,
		desired_velocity.y,
		desired_velocity.z
	]
	var gravity = GRAVITY
	if ground_normal != Vector3.ZERO:
		gravity = gravity.project(ground_normal.normalized())

	if hvel.length() > WALKING_SPEED and desired_velocity != Vector3.ZERO:
		var charge_accel = accel_normal
		# Direction parellel to current (horizontal) velocity
		var charge := desired_velocity.project(hdir)
		# Direction perpendicular to (horizontal) velocity
		var steer := desired_velocity.slide(hdir)
		if charge.dot(hvel) > 0:
			# Moving in the same direction
			if charge.length() < velocity.length():
				# Decelerating
				charge_accel = DECEL_WITH*decel_factor
			else:
				charge_accel = accel_normal
		else:
			charge_accel = DECEL_AGAINST*decel_factor
		velocity += delta*(
			(charge - hvel)/RUN_SPEED*charge_accel 
			+ (steer*steer_accel) 
			+ gravity )
	else:
		if desired_velocity.length_squared() < 0.05:
			hvel = hvel.move_toward(desired_velocity, DECEL_AGAINST*decel_factor)
		else:
			hvel = hvel.move_toward(desired_velocity, ACCEL_START)
		velocity.x = hvel.x
		velocity.z = hvel.z
		velocity += delta*gravity
	
	velocity = move_and_slide_with_snap(
		velocity,Vector3.DOWN*0.125,Vector3.UP)

func accel_air(delta: float, desired_velocity: Vector3, accel: float, ignore_slide := false):
	var hvel := Vector3(velocity.x, 0, velocity.z).move_toward(desired_velocity, accel*delta)
	velocity.x = hvel.x
	velocity.z = hvel.z
	velocity += GRAVITY*delta
	var pre_slide_vel := velocity
	velocity = move_and_slide(velocity)
	if pre_slide_vel.y <= 0:
		velocity.y = clamp(velocity.y, pre_slide_vel.y, 0.0)
	else:
		velocity.y = max(velocity.y, pre_slide_vel.y)
	if ignore_slide:
		velocity = pre_slide_vel

func accel_low_gravity(delta, desired_velocity, gravity_factor):
	var hvel := Vector3(velocity.x, 0, velocity.z).move_toward(desired_velocity, ACCEL*delta)
	velocity.x = hvel.x
	velocity.z = hvel.z
	velocity += gravity_factor*GRAVITY*delta
	var pre_slide_vel := velocity
	velocity = move_and_slide(velocity)
	velocity.y = min(pre_slide_vel.y, velocity.y)

func accel_slide(delta: float, desired_velocity: Vector3, wall_normal: Vector3):
	if desired_velocity.dot(wall_normal) < 0:
		desired_velocity = desired_velocity.slide(wall_normal)
	var angle = Vector3.UP.angle_to(wall_normal)
	var axis = Vector3.UP.cross(wall_normal).normalized()
	if axis != Vector3.ZERO:
		desired_velocity = desired_velocity.rotated(axis, angle)
	desired_velocity.y = -1
	
	var hvel := velocity
	hvel = hvel.move_toward(desired_velocity, ACCEL_SLIDE*delta)
	
	velocity = Vector3(
		hvel.x,
		min(hvel.y, velocity.y),
		hvel.z)
	velocity = move_and_slide(velocity + delta*GRAVITY)

func accel_lunge(delta, desired_velocity):
	var hvel = velocity
	hvel.y = 0
	desired_velocity.y = 0
	hvel = hvel.move_toward(desired_velocity, STEER_KICK*delta)
	var v2 := move_and_slide(velocity + GRAVITY*delta)
	velocity = velocity.move_toward(Vector3.ZERO, DECEL_KICK*delta)
	velocity.y = min(velocity.y, v2.y)

func is_grounded():
	return ( state == State.Ground
		or state == State.Slide
		or state == State.Roll
		or state == State.Crouch)

func can_ledge_grab() -> bool:
	if ((ledgeCastCeiling.is_colliding() 
		and ledgeCastCeiling.get_collision_normal().y < 0)
		or ( 
			ledgeCastWall.is_colliding()
			and ledgeCastWall.get_collision_normal().y < LEDGE_MIN_Y
	)):
		return false
	var left:bool = (
		ledgeCastLeft.is_colliding()
		and ledgeCastLeft.get_collision_normal().y > LEDGE_MIN_Y)
	var right:bool = (
		ledgeCastRight.is_colliding()
		and ledgeCastRight.get_collision_normal().y > LEDGE_MIN_Y)
	var center:bool = (
		ledgeCastCenter.is_colliding()
		and ledgeCastCenter.get_collision_normal().y > LEDGE_MIN_Y)
	return center and (left or right) 

func snap_to_ledge():
	var change = ledgeCastCenter.get_collision_point() - ledgeRef.global_transform.origin
	global_translate(change)

func should_slow_follow():
	return state == State.LungeKick or state == State.RollJump

func update_visuals(input_dir: Vector3, var flip = false):
	var crouching = state == State.Crouch or state == State.Climb
	var climbing = state == State.Climb
	var vs = velocity/(CROUCH_SPEED if crouching else RUN_SPEED)
	var vis_vel = lerp(
		vs,
		input_dir,
		0.5)
	if flip:
		vis_vel = -vis_vel
		
	mesh.set_movement_animation(
		vs.length(), 
		crouching, climbing)
	
	if abs(vis_vel.x) + abs(vis_vel.z) > 0.1 and input_dir != Vector3.ZERO:
		rotate_mesh(Vector3(vis_vel.x, 0, vis_vel.z).normalized())

func rotate_mesh(target: Vector3):
	var forward = mesh.global_transform.basis.z
	var axis = forward.cross(target).normalized()
	if axis.is_normalized():
		var angle = forward.angle_to(target)
		mesh.global_rotate(axis, angle)

func rotate_intention(dir: Vector3):
	dir.y = 0
	dir = dir.normalized()
	if dir != Vector3.ZERO:
		intention.global_transform = intention.global_transform.looking_at(
			intention.global_transform.origin + dir,
			Vector3.UP
		)

func damage_point(area: Area, damage: int, point: Vector3):
	for g in area.get_overlapping_bodies():
		var damage_dir = g.global_transform.origin - point
		damage_dir = damage_dir.normalized()
		damage(g, damage, damage_dir)

func damage_directed(area: Area, damage: int, damage_dir: Vector3):
	for g in area.get_overlapping_bodies():
		damage(g, damage, damage_dir)

func damage(node: Node, damage: int, dir: Vector3):
	if node in damaged_objects:
		return
	damaged_objects.append(node)
	if node.has_method("take_damage"):
		node.take_damage(damage, dir)

func take_damage(damage: int, direction: Vector3):
	health -= damage
	update_health()
	print("Health: ", health)
	if health <= 0:
		Global.load_sync()
		return
	velocity = VEL_H_DAMAGED*direction
	set_state(State.Damaged)

func set_state(next_state: int):
	if state == next_state:
		return
	coyote_timer = 0.0
	state_timer = 0.0
	$crouching_col.disabled = true
	$standing_col.disabled = false
	
	match next_state:
		State.Fall, State.LedgeFall:
			mesh.transition_to("Fall")
		State.BaseJump:
			velocity.y = jump_height*BASE_JUMP_VEL
			mesh.transition_to("BaseJump")
		State.Ground:
			mesh.transition_to("Ground")
		State.Slide:
			pass
		State.Crouch, State.Climb:
			$crouching_col.disabled = false
			$standing_col.disabled = true
			mesh.transition_to("Ground")
		State.CrouchJump:
			velocity.y = jump_height*CROUCH_JUMP_VEL
			mesh.transition_to("BaseJump")
		State.LedgeHang:
			mesh.transition_to("LedgeGrab")
			snap_to_ledge()
			velocity = Vector3.ZERO
		State.LedgeJump:
			velocity.y += jump_height*LEDGE_JUMP_VEL
			mesh.transition_to("BaseJump")
		State.Roll:
			$crouching_col.disabled = false
			$standing_col.disabled = true
			mesh.transition_to("Roll")
		State.RollJump:
			$crouching_col.disabled = false
			$standing_col.disabled = true
			var dir = mesh.global_transform.basis.z
			velocity = move_speed*dir*ROLL_JUMP_LURCH
			velocity.y = jump_height*ROLL_JUMP_VEL
			
			mesh.transition_to("RollJump")
		State.BonkFall:
			mesh.transition_to("Fall")
			var dir = ground_normal
			dir.y = 0.1
			dir = dir.normalized()
			velocity = move_speed*dir*BONK_SPEED
		State.LungeKick:
			damaged_objects = []
			var dir = get_visual_forward()
			velocity = move_speed*dir*LUNGE_KICK_VEL
			mesh.transition_to("LungeKickRight")
		State.SpinKick, State.AirSpinKick:
			damaged_objects = []
			velocity.y = jump_height*AIR_SPIN_VEL
			mesh.transition_to("SpinKickLeft")
		State.UppercutWindup:
			mesh.transition_to("Uppercut")
		State.Uppercut:
			damaged_objects = []
			velocity.y = jump_height*UPPERCUT_VEL
		State.DiveWindup:
			velocity.y = DIVE_WINDUP_VEL
			mesh.transition_to("DiveStart")
		State.DiveStart:
			damaged_objects = []
		State.DiveEnd:
			damaged_objects = []
			mesh.transition_to("DiveEnd")
		State.Damaged:
			velocity.y = move_speed*VEL_V_DAMAGED
			mesh.transition_to("Fall")
	state = next_state
	$ui/debug/stats/a1.text = "State: %s" % State.keys()[state]

