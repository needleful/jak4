extends KinematicBody
class_name PlayerBody

const RUN_SPEED := 7.0
const WALKING_SPEED := 1.5
const GRAVITY := Vector3.DOWN*24

const MIN_GROUND_DOT := 0.7
const MIN_SLIDE_DOT := 0.12

const COYOTE_TIME := 0.1
var coyote_timer := 0.0

const BASE_JUMP_TIME := 0.25
const BASE_JUMP_VEL := 10.0
const CROUCH_JUMP_VEL := 12.5
const ROLL_JUMP_VEL := 7.0
const ROLL_JUMP_LURCH := 5.0
var air_timer := 0.0

const MIN_SPEED_ROLL := 2.0

const CROUCH_SPEED := 2.0
const ROLL_SPEED := 15.0
const ROLL_TIME := 0.5
var roll_timer := 0.0

# Accelerating from zero
const ACCEL_START := 50.0
# Accelerating when moving above some speed
const ACCEL := 20.0
# Decelerate against velocity
const DECEL_AGAINST := 60.0
# Decelerate with velocity
const DECEL_WITH := 15.0

onready var cam_yaw := $camera_rig/yaw

var velocity := Vector3.ZERO

enum State {
	Ground,
	Fall,
	Slide,
	BaseJump,
	Crouch,
	Roll,
	CrouchJump,
	RollJump
}

var state: int = State.Ground

func _physics_process(delta):
	var movement := Input.get_vector("mv_left", "mv_right", "mv_up", "mv_down")
	
	var desired_velocity: Vector3 = (
		cam_yaw.global_transform.basis.x * movement.x
		+ cam_yaw.global_transform.basis.z * movement.y)
	
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
			elif best_floor_dot < MIN_SLIDE_DOT:
				coyote_timer += delta
				if coyote_timer > COYOTE_TIME:
					next_state = State.Fall
			elif best_floor_dot < MIN_GROUND_DOT:
				next_state = State.Slide
			else:
				coyote_timer = 0
		State.Slide:
			if best_floor_dot > MIN_GROUND_DOT:
				next_state = State.Ground
			elif best_floor_dot < MIN_SLIDE_DOT:
				coyote_timer += delta
				if coyote_timer > COYOTE_TIME:
					next_state = State.Fall
			else:
				coyote_timer = 0
		State.BaseJump, State.CrouchJump, State.RollJump:
			air_timer += delta
			if air_timer > BASE_JUMP_TIME:
				next_state = State.Fall
		State.Fall:
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
		State.Crouch:
			if Input.is_action_just_pressed("mv_jump"):
				next_state = State.CrouchJump
			elif !Input.is_action_pressed("mv_crouch"):
				next_state = State.Ground
			elif best_floor_dot < MIN_SLIDE_DOT:
				next_state = State.Fall
		State.Roll:
			if Input.is_action_just_pressed("mv_jump"):
				next_state = State.RollJump
			elif best_floor_dot < MIN_SLIDE_DOT:
				coyote_timer += delta
				if coyote_timer > COYOTE_TIME:
					next_state = State.Fall
			else:
				coyote_timer = 0
				roll_timer += delta
				if roll_timer > ROLL_TIME:
					next_state = State.Crouch
	set_state(next_state)
	
	match state:
		State.Ground, State.Fall:
			accel(delta, desired_velocity*RUN_SPEED)
		State.Slide:
			desired_velocity *= RUN_SPEED
			var face_normal = best_normal.slide(Vector3.UP).normalized()
			if face_normal.is_normalized():
				desired_velocity = desired_velocity.slide(best_normal)
			
			accel(delta, desired_velocity)
		State.Crouch:
			accel(delta, desired_velocity * CROUCH_SPEED)
		State.Roll, State.RollJump:
			accel(delta, desired_velocity * ROLL_SPEED, ACCEL, 0, 0)
		State.BaseJump, State.CrouchJump:
			accel(delta, desired_velocity*RUN_SPEED)

func accel(delta: float, desired_velocity: Vector3, accel_normal: float = ACCEL, steer_accel: float = ACCEL, decel_factor: float = 1):
	var hvel := velocity
	hvel.y = 0
	var hdir := hvel.normalized()
	
	var charge_accel = accel_normal
	if hvel.length() > WALKING_SPEED:
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
			+ GRAVITY )
		velocity = move_and_slide(velocity)
	else:
		hvel = hvel.move_toward(desired_velocity, ACCEL_START)
		velocity.x = hvel.x
		velocity.z = hvel.z
		
		velocity = move_and_slide(velocity + delta*GRAVITY)

func set_state(next_state: int):
	if state == next_state:
		return
	coyote_timer = 0
	match next_state:
		State.BaseJump:
			velocity.y = BASE_JUMP_VEL
		State.Ground:
			$standing_mesh.visible = true
			$crouch_mesh.visible = false
		State.Slide:
			pass
		State.Crouch, State.Roll:
			roll_timer = 0.0
			$standing_mesh.visible = false
			$crouch_mesh.visible = true
		State.CrouchJump:
			velocity.y = CROUCH_JUMP_VEL
		State.RollJump:
			velocity.y = ROLL_JUMP_VEL
			velocity += -cam_yaw.global_transform.basis.z*ROLL_JUMP_LURCH
	state = next_state
	$ui/debug/stats/a1.text = "State: %s" % State.keys()[state]
