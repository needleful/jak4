extends KinematicBody
class_name PlayerBody

signal jumped
signal died
signal show_stats
signal damaged

const GRAVITY := Vector3.DOWN*24.0

# Movement
const SPEED_WALK := 1.5
const SPEED_RUN := 7.0
const SPEED_CROUCH := 3.0

const SPEED_CLIMB := 5.0
const SPEED_ROLL := 15.0
const SPEED_BONK := 5.0

const SPEED_DASH := 15.0
const SPEED_DASH_V := 2.0

const SPEED_WADE := 4.0

const MIN_DOT_GROUND := 0.7
const MIN_DOT_SLIDE := 0.12
const MIN_DOT_CLIMB := -0.4
const MIN_DOT_CLIMB_MOVEMENT := -0.4
const MIN_DOT_CLIMB_AIR := 0.1
const MIN_DOT_SLIDE_ROLL := 0.5
const MIN_DOT_LEDGE := 0.4
const MIN_DOT_LEDGE_SLIDE := 0.7
const MIN_DOT_CEILING := -0.7

const ROLL_MAX_VELOCITY_V := 4.0

const TIME_COYOTE := 0.1
const TIME_LEDGE_FALL := 0.5
const TIME_CROUCH_JUMP := 0.5
const TIME_JUMP_MIN := 0.2
const TIME_BASE_JUMP := 0.25

const JUMP_VEL_BASE := 8.0
const JUMP_VEL_CROUCH := 12.5
const JUMP_VEL_LEDGE := 9.0
const JUMP_VEL_ROLL := 7.0
const JUMP_VEL_ROLL_FORWARD := 16.5
const JUMP_VEL_HIGH := 15.0
const JUMP_VEL_WALL := 5.0
const JUMP_VEL_WALL_V := 8.0
const JUMP_VEL_WATER := 5.0

const MIN_SPEED_ROLL := 5.0

const TIME_ROLL_MIN := 0.25
const TIME_ROLL_MAX := 0.5
const TIME_ROLL_MIN_JUMP := 0.3
const TIME_ROLL_INVINCIBILITY := 0.1

# Accelerating from zero
const ACCEL_START := 50.0
# Accelerating when moving above some speed
const ACCEL := 20.0
const ACCEL_SLIDE := 10.0
const ACCEL_ROLL := 0.5
const ACCEL_ROLL_AIR := 10.0
const ACCEL_ROLL_WAVE_JUMP := 50.0
const ACCEL_WADING := 15.0
# Decelerate against velocity
const DECEL_AGAINST := 45.0
# Decelerate with velocity
const DECEL_WITH := 15.0

const DECEL_DASH := 25.0
const DECEL_APPLIED_GROUND := 0.005

const ACCEL_CLIMB := 45.0
const DECEL_CLIMB := 45.0
const ACCEL_STEER_ROLL := 2.5
const ACCEL_DIVE_WINDUP := 75.0

const ACCEL_GRAVITY_STUN := 17.0

const WATER_GRAVITY := 0.6

const STAMINA_DRAIN_HANG := 0.0
const STAMINA_DRAIN_CLIMB := 25.0
const STAMINA_DRAIN_CLIMB_START := 1.0
const STAMINA_DRAIN_MIN := 0.05
const STAMINA_DRAIN_WALLJUMP := 15.0
const MIN_CLIMB_STAMINA := 1.0
const TIME_STOP_CLIMB := 0.0
const MIN_STAMINA_LEDGE_HANG := 0.0
const MAX_TIME_WALL_CLING := 1.0
const WALL_CLING_GRAVITY := 0.2
# Combat

const TIME_LUNGE_MAX := 0.6
const TIME_LUNGE_MIN := 0.4
const TIME_LUNGE_MIN_UPPERCUT := 0.2
const TIME_LUNGE_PARTICLES := 0.4
const TIME_LUNGE_COMBO := 0.15

const TIME_SPIN_MAX := 0.7
const TIME_SPIN_MIN := 0.2

const TIME_UPPERCUT_WINDUP := 0.25
const TIME_UPPERCUT_MIN := 0.4
const TIME_UPPERCUT_MAX := 0.8

const TIME_DIVE_WINDUP := 0.2
const TIME_DIVE_END_MIN := 0.4
const TIME_DIVE_END_MAX := 0.5
const TIME_DIVE_UPPERCUT := 0.1
const TIME_DIVE_HIGHJUMP := 0.1

const SPEED_LUNGE := 25.0
const VEL_REDUCTION_WATER := 0.78

const VEL_AIR_SPIN := 3.0
const VEL_UPPERCUT := 10.0
const VEL_DIVE_WINDUP := 4.0

const GRAVITY_BOOST_UPPERCUT := 0.2
const GRAVITY_BOOST_DIVE := 0.5

const STEER_KICK := 5.0
const DECEL_KICK := 75.0
const DECEL_FACTOR_WATER := 1.2

const DAMGE_DIVE_START := 15
const DAMAGE_DIVE_END := 25
const DAMAGE_UPPERCUT := 20
const DAMAGE_LUNGE := 15
const DAMAGE_SPIN := 10
const DAMAGE_ROLL_JUMP := 5

const TIME_DAMAGED := 0.25
const VEL_DAMAGED_H := 5
const VEL_DAMAGED_V := 6

const TERMINAL_VELOCITY := -300

# Hover board
const SPEED_HOVER := SPEED_RUN*3.2
const ACCEL_HOVER := 8.0
const DECEL_HOVER := 0.01
const ACCEL_STEER_HOVER := 2.75

const HOVER_DESIRED_HEIGHT := 0.6
const HOVER_CORRECTION_HEIGHT := 50.0
const HOVER_CORRECTION_VELOCITY := 1.0
const HOVER_CORRECTION_SLOPE := 1.0
const HOVER_AIR_DRAG := 0.01
const HOVER_EXTRA_GRAVITY := 1.0

var hover_normal := Vector3.UP
var hover_speed_factor := 1.0
const HOVER_SPEED_BOOST := 0.5

const DEPTH_CROUCH := 0.1
const DEPTH_CRUSH := 0.4
var crush_skip := 0

# Broad things

var velocity := Vector3.ZERO
var falling_velocity := Vector3.ZERO

const DEFAULT_MAX_HEALTH := 50
const HEALTH_UP_BOOST := 0.5
var max_health := DEFAULT_MAX_HEALTH
var health := max_health

const ARMOR_BOOST := 20.0
var armor := 0
var extra_health := 0.0

const DEFAULT_MAX_STAMINA := 40.0
const STAMINA_UP_BOOST := 0.5
var max_stamina := DEFAULT_MAX_STAMINA
var stamina := max_stamina

const EXTRA_STAMINA_BOOST := 15.0
var energy := 0
var extra_stamina := 0.0

const MAX_DAMAGE_UP := 10
const DAMAGE_UP_BOOST := 0.4
var damage_factor := 1.0
var max_damage := false
var damaged_objects: Array = []

const JUMP_UP_BOOST := 0.5
var jump_factor := 1.0

const SPEED_UP_BOOST := .5
var speed_factor := 1.0

const SPEED_STAMINA_BOOST := 0.04
var stamina_drain_factor := 1.0

var can_air_spin := true
var can_slide_lunge := true
var wall_cling := true

const TIME_LEDGE_LEAVE := 0.1

const TIME_PLACE_FLAG := 0.5
const TIME_GET_ITEM := 0.9
const MIN_TIME_LOCKED := 0.2

const TIME_FALLING_DEATH := 2.0

const TIME_GRAVITY_STUN := 2
const TIME_WAVE_JUMP_ROLL := 0.1

const TIME_TO_SIT := 2.5

const TIME_TO_DASH := 0.05
const TIME_DASH := 0.5

const FALL_DIST_DEATH = 50.0
const FALL_DIST_HIGH = 30.0
const FALL_DIST_MIN = 15.0
const FALL_VEL_DEATH = 0.0
const FALL_VEL_HIGH = 0.0
const FALL_VEL_MIN = 0.0
const FALL_DAM_HIGH = 25
const FALL_DAM_MIN = 8

# Ledge being held onto
var ledge: Spatial
# Position of player relative to ledge at start of ledge grab
var ledge_local_position : Vector3
# Global transform
var ledge_last_transform : Transform

onready var equipped_item : Usable
# enemies don't attack you
var do_not_disturb := false

enum State {
	None,
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
	SlideLungeKick,
	SpinKick,
	AirSpinKick,
	UppercutWindup,
	Uppercut,
	DiveWindup,
	DiveStart,
	DiveEnd,
	Damaged,
	Dead,
	Locked,
	LockedWaiting,
	PlaceFlag,
	GetItem,
	FallingDeath,
	GravityStun,
	Hover,
	WaveJump,
	WaveJumpRoll,
	Sitting,
	Dash,
	HighJump,
	WallCling,
	WallJump,
	Wading,
	WadingJump,
	WadingFall,
	NoClip,
	Vehicle
}

const ground_states = [
	State.Ground, State.Crouch, State.Climb, State.Slide,
	State.Sitting, State.Roll, 
	State.GetItem, State.Locked, State.LockedWaiting,
	State.LungeKick, State.SpinKick, State.SlideLungeKick,
	State.DiveEnd, State.DiveWindup, State.UppercutWindup
]

var state: int = State.Fall
var ground_normal:Vector3 = Vector3.UP
var best_floor : Node
var dash_charges := 0
var can_use_hover_scooter := true

var jump_time := TIME_BASE_JUMP
var jump_time_min := TIME_JUMP_MIN

var current_coat: Coat

var current_weapon : String

const INFINITE_INERTIA := false

const DEPTH_WATER_WADE := 0.3
const DEPTH_WATER_DRY := 0.2
const DEPTH_WATER_DROWN := 1.8
var water_depth := 0.0

# Nodes
onready var cam_rig := $camera_rig
onready var cam_yaw := $camera_rig/yaw
onready var mesh := $base_mesh
onready var crouch_head := $crouchHeadArea
onready var intention := $intention

onready var ground_area := $groundArea
onready var floor_cast := $emergency_floor_raycast
onready var climb_area := $climbArea

onready var ledgeCastLeft := $base_mesh/leftHandCast
onready var ledgeCastRight := $base_mesh/rightHandCast
onready var ledgeCastCenter := $base_mesh/centerCast
onready var ledgeCastCeiling := $base_mesh/ceilingCast
onready var ledgeCastHeadFloor := $base_mesh/headFloorCast
onready var wallCheck := $base_mesh/wall_check
onready var ledge_area := $base_mesh/ledge_area
onready var ledgeRef := $base_mesh/reference

onready var lunge_hitbox := $base_mesh/attack_lunge
onready var spin_hitbox := $base_mesh/attack_spin
onready var roll_hitbox := $base_mesh/attack_roll
onready var uppercut_hitbox := $base_mesh/attack_uppercut
onready var dive_start_hitbox := $base_mesh/attack_dive_start
onready var dive_end_hitbox := $base_mesh/attack_dive_end

onready var hover_floor_finder := $hover_floor_finder
onready var hover_cast := $hover_cast
onready var hover_area := $hover_area

onready var water_cast := $base_mesh/water_cast

onready var ui := $ui
onready var game_ui:Control = ui.game.get_node("custom_game")

onready var sleep_zone := $base_mesh/the_sleep_zone
onready var coat_zone := $base_mesh/the_coat_zone
onready var gun := $base_mesh/Armature/Skeleton/gun
onready var lantern := $base_mesh/Armature/Skeleton/coat_tails/lantern
export(PackedScene) var flag : PackedScene

onready var eyes := $base_mesh/Armature/Skeleton/head/eye_contact

var held_item
const TIME_ITEM_CHOOSE := 0.25
var timers := PoolRealArray()
var applied_ground_velocity := Vector3.ZERO

var last_ground_origin := Vector3.ZERO
var normal_layer := collision_layer
var normal_mask := collision_mask
var running_ground := PoolVector3Array()
var ground_index := 0
var dialog_ready := false

const TIMERS_MAX := 3

onready var debug = ui.game.get_node("debug")

func _ready():
	if Global.valid_game_state:
		set_saved_transform(Global.game_state.checkpoint_position)
		set_current_coat(Global.game_state.current_coat, false)
		if Global.stat("player_sleeping"):
			_slow_wake()
		else:
			set_state(State.Ground)
	else:
		Global.game_state.checkpoint_position = global_transform
		# Generate three random Common coats
		for _x in 3:
			var coat = Coat.new(true, Coat.Rarity.Common, Coat.Rarity.Common)
			Global.add_coat(coat)
		set_current_coat(Global.game_state.all_coats[0], false)
		# default coat shape
		var _x = Global.add_item("double-breasted")
		set_state(State.Ground)
	gun.camera = cam_rig.camera
	last_ground_origin = global_transform.origin
	running_ground = [Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO]
	ui.activate()
	health = max_health
	stamina = max_stamina
	dialog_ready = false
	$dialog_timer.start()

func _input(event):
	if can_talk() and event.is_action_pressed("dialog_item") and !empty(coat_zone):
		var c = coat_zone.get_overlapping_bodies()
		var best_trade = c[0]
		for b in c :
			var current_dist = (best_trade.global_transform.origin
				- global_transform.origin).length_squared()
			var new_dist = (b.global_transform.origin
				- global_transform.origin).length_squared()
			if new_dist < current_dist:
				best_trade = b
		best_trade.start_coat_trade(self)
	elif !ui.choosing_item and event.is_action_released("use_item"):
		if equipped_item and equipped_item.can_use():
			equipped_item.use()
	elif event.is_action_pressed("show_inventory"):
		emit_signal("show_stats")
	elif state == State.Sitting and event.is_action("mv_crouch"):
		var reset_bar = ui.game.get_node("reset_bar")
		if event.is_action_pressed("mv_crouch"):
			reset_bar.sleep = true
		elif event.is_action_released("mv_crouch"):
			reset_bar.sleep = false
	elif ui.choosing_item:
		if event.is_action_pressed("ui_up"):
			ui.equip_previous()
		elif event.is_action_pressed("ui_down"):
			ui.equip_next()

func _physics_process(delta):
	if velocity.y < TERMINAL_VELOCITY:
		velocity.y = TERMINAL_VELOCITY
	if !is_instance_valid(best_floor):
		best_floor = null
	for i in timers.size():
		timers[i] += delta
	stamina = clamp(stamina, 0.0, max_stamina)
	
	var movement := Input.get_vector("mv_left", "mv_right", "mv_up", "mv_down")
	var desired_velocity: Vector3 = speed_factor*(
		cam_yaw.global_transform.basis.x * movement.x
		+ cam_yaw.global_transform.basis.z * movement.y)
	
	if desired_velocity.length() > 1.0 or (
		desired_velocity.dot(velocity) > 0
	):
		rotate_intention(desired_velocity)

	running_ground[ground_index] = Vector3.ZERO
	var best_dot := -INF
	var max_depth := 0.0
	for c in range(get_slide_count()):
		var col := get_slide_collision(c)
		var normal := col.normal
		if col.collision_depth > max_depth:
			max_depth = col.collision_depth
		if normal.y > best_dot:
			best_dot = normal.y
			running_ground[ground_index] = normal
			best_floor = col.collider as Node
	ground_index += 1
	ground_index = ground_index % running_ground.size()
	
	var current_normal := running_ground[ground_index] 
	var average_normal := Vector3.ZERO
	for v in running_ground:
		average_normal += v/running_ground.size()
	average_normal = average_normal.normalized()

	if max_depth > DEPTH_CRUSH:
		for c in get_slide_count():
			var n := get_slide_collision(c).collider
			if !n or n.is_in_group("no_crush"):
				crush_skip = 10
				break
		if crush_skip <= 0:
			crush_skip = 0
			crushing_death()
		else:
			crush_skip -= 1
		
	var best_floor_dot = max(average_normal.y, current_normal.y)
	if current_normal.y > MIN_DOT_GROUND:
		ground_normal = current_normal
	elif average_normal.y > MIN_DOT_GROUND:
		ground_normal = average_normal
	debug.get_node("stats/a11").text = str(average_normal)
	debug.get_node("stats/a2").text = "Floor: " + (
			"null" if !best_floor else best_floor.name)
	
	if water_cast.is_colliding():
		water_depth = water_cast.get_collision_point().y - global_transform.origin.y
		if water_depth > DEPTH_WATER_DROWN and !is_dead() and state != State.NoClip:
			fall_to_death()
		elif water_depth > DEPTH_WATER_WADE:
			debug.get_node("stats/a8").text = "Wading"
		else:
			debug.get_node("stats/a8").text = "Splashing"

		var wpart : Particles = water_cast.get_node("standing_ripple")
		var mpart : Particles = water_cast.get_node("running_ripple")
		wpart.emitting = true
		var emit_please_god := velocity.length_squared() > 4
		mpart.visible = true
		mpart.emitting = emit_please_god
		debug.get_node("stats/a9").text = "Ripples: " + str(emit_please_god)
		
		var ripple_color := Color.white
		if water_cast.get_collider().has_method("get_ripple_color"):
			ripple_color = water_cast.get_collider().get_ripple_color()
		wpart.process_material.color = ripple_color
		mpart.process_material.color = ripple_color
		
		var ripple_pos = water_cast.get_collision_point() + Vector3.UP*0.01
		wpart.global_transform.origin = ripple_pos
		mpart.global_transform.origin = ripple_pos
	else:
		debug.get_node("stats/a8").text = "Dry"
		water_depth = 0
		water_cast.get_node("standing_ripple").emitting = false
		water_cast.get_node("running_ripple").emitting = false
	
	var next_state = State.None
	var speed:float = (velocity).slide(ground_normal).length()
	match state:
		State.Ground:
			if pressed("mv_jump"):
				next_state = State.BaseJump
			elif should_hover():
				next_state = State.Hover
			elif holding("mv_crouch"):
				if speed > MIN_SPEED_ROLL or movement.length_squared() >= 0.8:
					next_state = State.Roll
				elif speed < 0.2 and !empty(sleep_zone):
					next_state = State.Sitting
					var g = sleep_zone.get_overlapping_bodies()[0]
					global_transform.origin = g.global_transform.origin
					rotate_mesh(g.global_transform.basis.z)
				else:
					next_state = State.Crouch
			elif max_depth > DEPTH_CROUCH:
				next_state = State.Crouch
			elif !empty(crouch_head) and $standing_col.disabled:
				next_state = State.Crouch
			elif pressed("combat_lunge"):
				next_state = State.LungeKick
			elif pressed("combat_spin"):
				next_state = State.SpinKick
			elif after(TIME_COYOTE, empty(ground_area), 1):
				next_state = State.Fall
			elif water_depth > DEPTH_WATER_WADE:
				next_state = State.Wading
			elif after(TIME_COYOTE, best_floor_dot < MIN_DOT_GROUND, 2) or (
				best_floor and best_floor.is_in_group("dont_stand")
			):
				if (!floor_cast.is_colliding()
					or floor_cast.get_collider().is_in_group("dont_stand")
					or floor_cast.get_collision_normal().y < MIN_DOT_GROUND
				):
					next_state = State.Slide
		State.Slide:
			if pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif total_stamina() > 0 and pressed("mv_jump"):
				drain_stamina(STAMINA_DRAIN_WALLJUMP)
				next_state = State.BaseJump
			elif should_hover():
				next_state = State.Hover
			elif can_slide_lunge and pressed("combat_lunge"):
				next_state = State.SlideLungeKick
			elif pressed("mv_crouch") and desired_velocity.dot(average_normal) > MIN_DOT_SLIDE_ROLL:
				next_state = State.Roll
				# TODO: maybe a neat little slide animation if you hold crouch while sliding down-hill
			elif can_climb(best_floor_dot):
				next_state = State.Climb
			elif water_depth > DEPTH_WATER_WADE:
				next_state = State.WadingFall
			elif best_floor_dot > MIN_DOT_GROUND and !best_floor.is_in_group("dont_stand"):
				next_state = State.Ground
			elif after(TIME_COYOTE, empty(climb_area) or best_floor_dot < MIN_DOT_CLIMB, 1):
				next_state = State.Fall
			elif can_ledge_grab(MIN_DOT_LEDGE_SLIDE):
				next_state = State.LedgeHang
		State.Dash:
			if pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif can_dash() and pressed("mv_jump"):
				next_state = State.Dash
			elif best_floor_dot > MIN_DOT_GROUND:
				if holding("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Ground
			elif can_climb(current_normal.y, MIN_DOT_CLIMB_AIR):
				next_state = State.Climb
			elif can_wall_cling(current_normal):
				next_state = State.WallCling
			elif best_floor_dot > MIN_DOT_SLIDE:
				if holding("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Slide
			elif after(TIME_DASH):
				next_state = State.Fall
		State.BaseJump, State.LedgeJump, State.HighJump, State.WallJump, State.WaveJump, State.CrouchJump:
			if after(jump_time_min) and pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif after(jump_time_min) and pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif after(TIME_TO_DASH) and can_dash() and pressed("mv_jump"):
				next_state = State.Dash
			elif after(jump_time):
				next_state = State.Fall
			elif after(jump_time_min):
				if best_floor_dot > MIN_DOT_GROUND:
					next_state = State.Ground
				elif best_floor_dot > MIN_DOT_SLIDE:
					next_state = State.Slide
		State.Crouch:
			if pressed("mv_jump"):
				next_state = State.CrouchJump
			elif pressed("combat_lunge"):
				next_state = State.UppercutWindup
			elif best_floor and best_floor.is_in_group("dont_stand"):
				next_state = State.Fall
			elif (best_floor_dot < MIN_DOT_GROUND
				and can_climb(best_floor_dot)
			):
				if (desired_velocity.dot(average_normal) > MIN_DOT_CLIMB_MOVEMENT
					and floor_cast.is_colliding()
					and floor_cast.get_collision_normal().y > MIN_DOT_GROUND
				):
					next_state = State.Crouch
				else:
					next_state = State.Climb
			elif water_depth > DEPTH_WATER_WADE:
				next_state = State.Wading
			elif pressed("mv_crouch") and speed < 0.2 and !empty(sleep_zone):
				next_state = State.Sitting
				var g = sleep_zone.get_overlapping_bodies()[0]
				global_transform.origin = g.global_transform.origin
				rotate_mesh(g.global_transform.basis.z)
			elif !holding("mv_crouch") and empty(crouch_head):
				next_state = State.Ground
			elif after(TIME_COYOTE, empty(ground_area), 1):
				next_state = State.Fall
			elif after(TIME_COYOTE, best_floor_dot < MIN_DOT_GROUND, 1):
				if can_climb(best_floor_dot):
					next_state = State.Climb
				else:
					next_state = State.Slide
			else:
				if after(TIME_TO_SIT, desired_velocity.length() < 0.001, 2):
					next_state = State.Sitting
		State.Climb:
			if best_floor and best_floor.is_in_group("ladder"):
				stamina = max_stamina
			else:
				drain_stamina(
					(desired_velocity.length() + STAMINA_DRAIN_MIN)
					* STAMINA_DRAIN_CLIMB
					* delta
					* (1.0-sqrt(max(current_normal.y, 0)))
				)
			if total_stamina() >= 0 and pressed("mv_jump"):
				drain_stamina(STAMINA_DRAIN_WALLJUMP)
				if current_normal == Vector3.ZERO:
					current_normal = ground_normal
				velocity = JUMP_VEL_WALL*current_normal
				velocity.y = JUMP_VEL_WALL_V
				next_state = State.WallJump
			elif after(TIME_STOP_CLIMB) and best_floor_dot > MIN_DOT_GROUND:
				next_state = State.Crouch
			elif empty(climb_area) or best_floor_dot < MIN_DOT_CLIMB:
				debug.get_node("stats/a6").text = "!!!"
				next_state = State.Fall
			elif total_stamina() <= 0 or !holding("mv_crouch"):
				if best_floor_dot < MIN_DOT_CLIMB_AIR:
					next_state = State.Fall
				else:
					next_state = State.Slide
			else:
				debug.get_node("stats/a6").text = "all good"
		State.Roll:
			if after(TIME_ROLL_MIN_JUMP) and pressed("mv_jump"):
				next_state = State.RollJump
			elif after(TIME_ROLL_MIN) and pressed("combat_lunge"):
				next_state = State.UppercutWindup
			elif after(TIME_ROLL_MIN) and after(TIME_COYOTE, empty(ground_area), 1):
				next_state = State.Fall
			else:
				if after(TIME_ROLL_MAX):
					if empty(ground_area):
						next_state = State.Fall
					elif best_floor_dot < MIN_DOT_GROUND:
						next_state = State.Slide
					elif holding("mv_crouch"):
						next_state = State.Crouch
					else:
						next_state = State.Ground
		State.RollJump:
			if pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif after(TIME_TO_DASH) and can_dash() and pressed("mv_jump"):
				next_state = State.Dash
			elif can_ledge_grab():
				next_state = State.LedgeHang
			elif (current_normal != Vector3.ZERO
				and current_normal.y < MIN_DOT_SLIDE
			):
				next_state = State.BonkFall
			elif after(TIME_CROUCH_JUMP):
				if best_floor_dot > MIN_DOT_GROUND:
					next_state = State.Ground
				elif best_floor_dot > MIN_DOT_SLIDE:
					next_state = State.Slide
				else:
					next_state = State.RollFall
		State.RollFall:
			if pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif can_dash() and pressed("mv_jump"):
				next_state = State.Dash
			elif can_ledge_grab():
				next_state = State.LedgeHang
			elif current_normal.y > MIN_DOT_GROUND:
				if pressed("mv_crouch"):
					next_state = State.Crouch
				elif empty(crouch_head):
					next_state = State.Ground
			elif can_climb(current_normal.y, MIN_DOT_CLIMB_AIR):
				next_state = State.Climb
			elif can_wall_cling(current_normal):
				next_state = State.WallCling
			elif current_normal.y > MIN_DOT_SLIDE and empty(crouch_head):
				next_state = State.Slide
			elif current_normal != Vector3.ZERO:
				next_state = State.BonkFall
		State.Fall, State.BonkFall:
			if can_air_spin and pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif can_dash() and pressed("mv_jump"):
				next_state = State.Dash
			elif should_hover():
				next_state = State.Hover
			elif best_floor_dot > MIN_DOT_GROUND:
				if holding("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Ground
			elif can_ledge_grab():
				next_state = State.LedgeHang
			elif can_climb(best_floor_dot, MIN_DOT_CLIMB_AIR):
				next_state = State.Climb
			elif can_wall_cling(current_normal):
				next_state = State.WallCling
			elif best_floor_dot > MIN_DOT_SLIDE:
				next_state = State.Slide
			elif water_depth > DEPTH_WATER_WADE:
				next_state = State.WadingFall
		State.LedgeHang:
			drain_stamina(STAMINA_DRAIN_HANG*delta)
			var intent_dot = mesh.global_transform.basis.z.dot(desired_velocity)
			if pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif pressed("mv_jump"):
				next_state = State.LedgeJump
			elif best_floor_dot > MIN_DOT_GROUND:
				next_state = State.Ground
			elif (!is_instance_valid(ledge)
				or total_stamina() < MIN_STAMINA_LEDGE_HANG
				or after(TIME_LEDGE_LEAVE, intent_dot < 0)
				or after(TIME_LEDGE_LEAVE, empty(ledge_area), 1)
			):
				next_state = State.LedgeFall
		State.LedgeFall:
			if can_air_spin and pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif can_dash() and pressed("mv_jump"):
				next_state = State.Dash
			elif should_hover():
				next_state = State.Hover
			elif best_floor_dot > MIN_DOT_GROUND:
				if holding("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Ground
			elif can_climb(current_normal.y, MIN_DOT_CLIMB_AIR):
				next_state = State.Climb
			elif can_wall_cling(current_normal):
				next_state = State.WallCling
			elif best_floor_dot > MIN_DOT_SLIDE:
				next_state = State.Slide
			elif after(TIME_LEDGE_FALL):
				next_state = State.Fall
		State.LungeKick:
			if after(TIME_LUNGE_MAX):
				if best_floor_dot > MIN_DOT_GROUND:
					next_state = State.Ground
				else:
					next_state = State.Fall
			elif after(TIME_LUNGE_MIN) and pressed("combat_spin"):
				next_state = State.SpinKick
			elif after(TIME_LUNGE_MIN_UPPERCUT) and pressed("mv_jump"):
				next_state = State.UppercutWindup
		State.SlideLungeKick:
			if after(TIME_LUNGE_MAX):
				next_state = State.Slide
			elif after(TIME_LUNGE_MIN) and pressed("combat_spin"):
				next_state = State.AirSpinKick
		State.SpinKick:
			if after(TIME_SPIN_MAX):
				if best_floor_dot > MIN_DOT_GROUND:
					next_state = State.Ground
				elif best_floor_dot > MIN_DOT_SLIDE:
					next_state = State.Slide
				else:
					next_state = State.Fall
			elif after(TIME_SPIN_MIN):
				if pressed("combat_lunge"):
					next_state = State.LungeKick
				elif best_floor_dot > MIN_DOT_SLIDE and holding("mv_crouch"):
					if velocity.length_squared() > MIN_SPEED_ROLL*MIN_SPEED_ROLL:
						next_state = State.Roll
					else:
						next_state = State.Crouch
		State.AirSpinKick:
			if can_dash() and pressed("mv_jump"):
				next_state = State.Dash
			elif best_floor_dot > MIN_DOT_GROUND:
				if holding("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Ground
			elif can_ledge_grab():
				next_state = State.LedgeHang
			else:
				if after(TIME_SPIN_MAX):
					next_state = State.Fall
				elif after(TIME_SPIN_MIN) and pressed("combat_lunge"):
					next_state = State.DiveWindup
		State.UppercutWindup:
			if after(TIME_UPPERCUT_WINDUP):
				next_state = State.Uppercut
		State.Uppercut:
			if pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif released("combat_spin"):
				next_state = State.AirSpinKick
			elif can_dash() and pressed("mv_jump"):
				next_state = State.Dash
			elif after(TIME_UPPERCUT_MIN) and best_floor_dot > MIN_DOT_GROUND:
				if holding("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Ground
			elif after(TIME_UPPERCUT_MAX):
				next_state = State.Fall
		State.DiveWindup:
			if after(TIME_DIVE_WINDUP):
				next_state = State.DiveStart
		State.DiveStart:
			if can_dash() and pressed("mv_jump"):
				next_state = State.Dash
			elif best_floor_dot > MIN_DOT_SLIDE:
				next_state = State.DiveEnd
			elif velocity.y > 0:
				next_state = State.Fall
		State.DiveEnd:
			if after(TIME_DIVE_END_MAX):
				next_state = State.Ground
			elif after(TIME_DIVE_END_MIN):
				if pressed("combat_lunge"):
					next_state = State.LungeKick
				elif pressed("combat_spin"):
					next_state = State.AirSpinKick
			elif after(TIME_DIVE_UPPERCUT) and best_floor_dot > MIN_DOT_GROUND and pressed("combat_lunge"):
				next_state = State.UppercutWindup
			elif !after(TIME_DIVE_HIGHJUMP) and pressed("mv_jump"):
				next_state = State.HighJump
		State.Damaged:
			if pressed("combat_lunge"):
				next_state = State.LungeKick
			elif pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif after(TIME_DAMAGED):
				next_state = State.Fall
		State.FallingDeath:
			if after(TIME_FALLING_DEATH):
				die()
		State.GravityStun:
			if after(TIME_GRAVITY_STUN):
				next_state = State.Fall
		State.Hover:
			if pressed("hover_toggle"):
				next_state = State.Fall
		State.WaveJumpRoll:
			if can_dash() and pressed("mv_jump"):
				next_state = State.Dash
			elif after(TIME_WAVE_JUMP_ROLL):
				next_state = State.RollFall
		State.Sitting:
			if pressed("mv_jump"):
				next_state = State.BaseJump
			elif after(TIME_COYOTE, empty(ground_area)):
				next_state = State.Fall
			elif desired_velocity.length() > 0.05:
				next_state = State.Ground
		State.Wading:
			if pressed("mv_jump"):
				next_state = State.WadingJump
			elif pressed("combat_lunge"):
				next_state = State.LungeKick
			elif pressed("combat_spin"):
				next_state = State.SpinKick
			elif best_floor_dot < MIN_DOT_GROUND and can_climb(best_floor_dot):
				next_state = State.Climb
			elif water_depth < DEPTH_WATER_DRY:
				next_state = State.Ground
			elif after(TIME_COYOTE, empty(ground_area)):
				next_state = State.WadingFall
		State.WadingJump:
			if after(TIME_BASE_JUMP):
				next_state = State.WadingFall
		State.WadingFall:
			if can_ledge_grab():
				next_state = State.LedgeHang
			elif best_floor_dot > MIN_DOT_GROUND:
				next_state = State.Wading
			elif water_depth < DEPTH_WATER_DRY:
				next_state = State.Fall
		State.WallCling:
			drain_stamina(
				(STAMINA_DRAIN_MIN)
				* STAMINA_DRAIN_CLIMB
				* delta
				* (1.0-sqrt(max(current_normal.y, 0)))
			)
			var on_wall := true
			if best_floor and current_normal.y < MIN_DOT_CLIMB:
				on_wall = false
			elif empty(climb_area):
				on_wall = false
			if can_ledge_grab():
				next_state = State.LedgeHang
			elif stamina >= 0 and pressed("mv_jump"):
				drain_stamina(STAMINA_DRAIN_WALLJUMP)
				if current_normal == Vector3.ZERO:
					current_normal = ground_normal
				velocity = JUMP_VEL_WALL*current_normal
				velocity.y = JUMP_VEL_WALL_V
				next_state = State.WallJump
			elif current_normal.y >= MIN_DOT_GROUND:
				if holding("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Ground
			elif current_normal.y >= MIN_DOT_CLIMB_AIR:
				next_state = State.Climb
			elif ( total_stamina() <= 0 
				or after(MAX_TIME_WALL_CLING)
				or !on_wall
				or !holding("mv_crouch")
			):
				next_state = State.Fall
		State.LockedWaiting, State.GetItem:
			if after(MIN_TIME_LOCKED) and mesh.body.get_current_node() == "Walk":
				next_state = State.Ground
		State.PlaceFlag:
			if after(TIME_PLACE_FLAG, true, 1) and held_item:
				place_flag()
			elif after(MIN_TIME_LOCKED) and mesh.body.get_current_node() == "Walk":
				next_state = State.Ground
	if next_state != State.None:
		set_state(next_state)
	
	var av: Vector3 = Vector3.ZERO
	if is_on_floor():
		av = Vector3.ZERO
		applied_ground_velocity = get_floor_velocity()
	else:
		applied_ground_velocity *= (1 - DECEL_APPLIED_GROUND)
		av = Engine.time_scale*applied_ground_velocity
	
	if global_transform.origin.y > last_ground_origin.y:
		last_ground_origin = global_transform.origin
	
	match state:
		State.Ground:
			last_ground_origin = global_transform.origin
			accel(delta, desired_velocity*SPEED_RUN)
			mesh.blend_run_animation((velocity - av)/SPEED_RUN)
			rotate_to_velocity(desired_velocity)
		State.Fall, State.LedgeFall:
			accel_air(delta, desired_velocity*SPEED_RUN, ACCEL)
			rotate_to_velocity(desired_velocity)
		State.Slide:
			last_ground_origin = global_transform.origin
			accel_slide(delta, desired_velocity*SPEED_RUN, av, average_normal)
			mesh.blend_run_animation((velocity - av)/SPEED_RUN)
			rotate_to_velocity(desired_velocity)
		State.BaseJump, State.HighJump, State.WaveJump:
			accel_air(delta, desired_velocity*SPEED_RUN, ACCEL_START)
			rotate_to_velocity(desired_velocity)
		State.Roll:
			last_ground_origin = global_transform.origin
			accel(delta, desired_velocity * SPEED_ROLL, ACCEL, ACCEL_STEER_ROLL, 0.0)
			rotate_to_velocity(desired_velocity)
		State.RollJump:
			accel_air(delta, desired_velocity*SPEED_ROLL, ACCEL_ROLL_AIR)
			damage_directed(roll_hitbox, DAMAGE_ROLL_JUMP, velocity.normalized(), "movement")
			rotate_to_velocity(desired_velocity)
		State.RollFall, State.WallJump:
			accel_air(delta, desired_velocity*SPEED_ROLL, ACCEL_ROLL_AIR)
			rotate_to_velocity(desired_velocity)
		State.BonkFall, State.Damaged:
			accel_air(delta, desired_velocity*SPEED_CROUCH, ACCEL_ROLL)
			rotate_to_velocity(desired_velocity)
		State.Crouch:
			last_ground_origin = global_transform.origin
			accel(delta, desired_velocity*SPEED_CROUCH)
			mesh.blend_run_animation((velocity - av)/SPEED_CROUCH)
			rotate_to_velocity(desired_velocity)
		State.Climb:
			last_ground_origin = global_transform.origin
			if average_normal != Vector3.ZERO:
				ground_normal = average_normal
			accel_climb(delta, desired_velocity*SPEED_CLIMB, av, ground_normal)
			mesh.blend_climb_animation(velocity/SPEED_CLIMB, average_normal)
			rotate_mesh(-average_normal)
		State.CrouchJump, State.LedgeJump:
			accel_air(delta, desired_velocity*SPEED_CROUCH, ACCEL)
			rotate_to_velocity(desired_velocity)
		State.LedgeHang:
			last_ground_origin = global_transform.origin
			$ledge_ref/mesh.global_transform.origin = ledge_last_transform*ledge_local_position
			if ledge.global_transform != ledge_last_transform:
				var new_transform := ledge.global_transform
				var old_position := ledge_last_transform*ledge_local_position
				var new_position := new_transform*ledge_local_position
				var _x = move_and_collide(new_position - old_position)
				ledge_last_transform = new_transform
		State.Dash:
			rotate_intention(velocity.normalized())
			accel_lunge(delta, av, DECEL_DASH)
			damage_directed(roll_hitbox, DAMAGE_ROLL_JUMP, get_visual_forward(), "dash")
			rotate_to_velocity(desired_velocity)
		State.LungeKick, State.SlideLungeKick:
			last_ground_origin = global_transform.origin
			if after(TIME_LUNGE_PARTICLES):
				mesh.stop_particles()
			if (after(TIME_LUNGE_COMBO)
				and !gun.in_combo()
				and damaged_objects.size() > 0
			):
				gun.start_combo()
			rotate_intention(velocity.normalized())
			accel_lunge(delta, av)
			damage_directed(lunge_hitbox, DAMAGE_LUNGE, get_visual_forward(), "lunge")
			rotate_to_velocity(desired_velocity)
		State.SpinKick:
			last_ground_origin = global_transform.origin
			if average_normal.dot(Vector3.UP) > MIN_DOT_SLIDE:
				ground_normal = average_normal
			accel(delta, desired_velocity*SPEED_RUN)
			damage_point(spin_hitbox, DAMAGE_SPIN, global_transform.origin, "movement")
		State.AirSpinKick:
			accel_low_gravity(delta, desired_velocity*SPEED_RUN, 0.75)
			damage_point(spin_hitbox, DAMAGE_SPIN, global_transform.origin, "movement")
		State.UppercutWindup:
			accel(delta, 0.5*desired_velocity*SPEED_CROUCH)
			rotate_to_velocity(desired_velocity)
		State.Uppercut:
			velocity += delta*GRAVITY*GRAVITY_BOOST_UPPERCUT
			accel_air(delta, desired_velocity*SPEED_RUN, ACCEL)
			damage_point(uppercut_hitbox, DAMAGE_UPPERCUT, global_transform.origin)
			rotate_to_velocity(desired_velocity)
		State.DiveWindup:
			accel_air(delta, desired_velocity*SPEED_CROUCH, ACCEL_DIVE_WINDUP)
			rotate_to_velocity(desired_velocity)
		State.DiveStart:
			velocity += damage_factor*delta*GRAVITY*GRAVITY_BOOST_DIVE
			accel_air(delta, desired_velocity*SPEED_CROUCH, ACCEL)
			damage_point(dive_start_hitbox, DAMGE_DIVE_START, global_transform.origin)
			rotate_to_velocity(desired_velocity)
		State.DiveEnd:
			last_ground_origin = global_transform.origin
			if !gun.in_combo() and damaged_objects.size() > 0:
				gun.start_combo()
			accel_slide(delta, desired_velocity*SPEED_RUN, av, average_normal)
			damage_point(dive_end_hitbox, DAMAGE_DIVE_END, global_transform.origin)
			rotate_to_velocity(desired_velocity)
		State.Locked, State.LockedWaiting, State.PlaceFlag, State.GetItem, State.Sitting:
			last_ground_origin = global_transform.origin
			desired_velocity = Vector3.ZERO
			if mesh.body.get_current_node() == "Walk":
				mesh.blend_run_animation((velocity - av)/SPEED_RUN)
		State.FallingDeath:
			desired_velocity = Vector3.ZERO
			accel_air(delta, desired_velocity*SPEED_RUN, ACCEL)
		State.GravityStun:
			velocity *= clamp(1.0 - delta, 0.1, 0.995)
			accel_air(delta, desired_velocity*SPEED_CROUCH, ACCEL_GRAVITY_STUN, Vector3.UP*Global.gravity_stun_velocity)
			rotate_to_velocity(desired_velocity)
		State.Hover:
			last_ground_origin = global_transform.origin
			var grounded:bool = hover_area.get_overlapping_bodies().size() > 0
			debug.get_node("stats/a8").text = str(grounded)
			if hover_floor_finder.is_colliding():
				hover_normal = hover_floor_finder.get_collision_normal()
				hover_cast.cast_to = -hover_normal
			accel_hover(delta, desired_velocity*SPEED_HOVER*hover_speed_factor, grounded)
			rotate_to_velocity(desired_velocity)
		State.Wading:
			last_ground_origin = global_transform.origin
			accel(delta, desired_velocity*SPEED_WADE, ACCEL_WADING)
			mesh.blend_run_animation((velocity - av)/SPEED_WADE)
			rotate_to_velocity(desired_velocity)
		State.WadingJump:
			accel_low_gravity(delta, desired_velocity*SPEED_WADE, WATER_GRAVITY)
			rotate_to_velocity(desired_velocity)
		State.WadingFall:
			accel_low_gravity(delta, desired_velocity*SPEED_WADE, WATER_GRAVITY)
		State.WaveJumpRoll:
			accel_air(delta, desired_velocity * SPEED_ROLL, ACCEL_ROLL_WAVE_JUMP)
			damage_point(roll_hitbox, DAMAGE_ROLL_JUMP, global_transform.origin)
			rotate_to_velocity(desired_velocity)
		State.WallCling:
			last_ground_origin = global_transform.origin
			if current_normal != Vector3.ZERO:
				ground_normal = current_normal
			var hvel := velocity.move_toward(av, ACCEL_CLIMB)
			hvel.y = velocity.y + WALL_CLING_GRAVITY*delta*GRAVITY.y
			velocity = move_and_slide(hvel, Vector3.UP, false, 4, 900)
			rotate_mesh(-ground_normal)
		State.NoClip:
			if holding("mv_jump"):
				desired_velocity.y = JUMP_VEL_BASE*0.3
			elif holding("mv_crouch"):
				desired_velocity.y = -JUMP_VEL_BASE*0.3
			global_translate(delta*desired_velocity*SPEED_ROLL*2)
	debug.get_node("stats/a3").text = "V: (%f, %f, %f)" % [
		velocity.x,
		velocity.y,
		velocity.z
	]
	debug.get_node("stats/a5").text = "GV: (%f, %f, %f)" % [
		applied_ground_velocity.x,
		applied_ground_velocity.y,
		applied_ground_velocity.z
	]

func after(time: float, condition := true, id := 0):
	if id >= timers.size():
		timers.resize(id+1)
		timers[id] = 0
	if !condition:
		timers[id] = 0
	return timers[id] >= time

func pressed(action:String):
	return InputManagement.pressed(action)

func released(action:String):
	return InputManagement.released(action)

func holding(action:String):
	return InputManagement.holding(action)

func empty(area: Area):
	return area.get_overlapping_bodies().size() == 0

func reset_ground():
	best_floor = null
	for i in running_ground.size():
		running_ground[i] = Vector3.ZERO

func prepare_save():
	Global.game_state.current_coat = current_coat

func complete_save():
	pass

func get_target_ref():
	return global_transform.origin + (Vector3.UP*0.5 if is_crouching() else Vector3.UP*0.75)

func is_crouching():
	return state == State.Crouch or state == State.Roll or state == State.RollJump or state == State.RollFall or state == State.Climb 

func is_climbing_ladder():
	return state == State.Climb and best_floor and best_floor.is_in_group('ladder')

func lock_in_animation(anim:String):
	mesh.play_single(anim)
	set_state(State.LockedWaiting)

func anim_play(start:String, loop:String):
	mesh.play_custom_loop(start, loop)
	return true

func anim_exit(transition:String, wait_to_unlock := false):
	mesh.exit_custom_loop(transition)
	if wait_to_unlock:
		set_state(State.LockedWaiting)
	return true

func set_visual_position(new_transform:Transform):
	set_saved_transform(new_transform)
	rotate_mesh(-new_transform.basis.z)

func health_drop_bonus():
	return clamp(float(max_health)/float(health), 1, 3)

func is_dead():
	return state == State.Dead or state == State.FallingDeath

func set_current_coat(coat: Coat, play_sound:= true):
	current_coat = coat
	mesh.show_coat(coat)
	if play_sound:
		mesh.play_pickup_sound("coat")

func accel(delta: float, desired_velocity: Vector3, accel_normal: float = ACCEL, steer_accel: float = ACCEL, decel_factor: float = 1):
	var gravity = GRAVITY
	if ground_normal != Vector3.ZERO:
		var axis = Vector3.UP.cross(ground_normal).normalized()
		var angle = Vector3.UP.angle_to(ground_normal)
		if axis.is_normalized():
			desired_velocity = desired_velocity.rotated(axis, angle)
			if desired_velocity.y > ROLL_MAX_VELOCITY_V:
				desired_velocity.y = ROLL_MAX_VELOCITY_V
		gravity = GRAVITY.project(ground_normal)
	var hvel := velocity
	if gravity != Vector3.ZERO:
		hvel = hvel.slide(gravity.normalized())
	else:
		hvel.y = 0
	var hdir := hvel.normalized()
	
	if hvel.length() > SPEED_WALK and desired_velocity != Vector3.ZERO:
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
			(charge - hvel)/SPEED_RUN*charge_accel 
			+ (steer*steer_accel) 
			+ gravity )
	else:
		if desired_velocity.length_squared() < 0.05:
			hvel = hvel.move_toward(desired_velocity, DECEL_AGAINST*decel_factor)
		else:
			hvel = hvel.move_toward(desired_velocity, ACCEL_START)
		
		var vvel := Vector3.ZERO
		if gravity != Vector3.ZERO:
			vvel = velocity.project(gravity.normalized())
		velocity =  vvel + hvel + delta*gravity

	velocity = move(velocity, true)

func accel_climb(delta: float, desired_velocity: Vector3, applied_ground: Vector3, wall_normal: Vector3):
	var gravity := Vector3.ZERO
	if wall_normal != Vector3.ZERO:
		var axis = Vector3.UP.cross(wall_normal).normalized()
		var angle = Vector3.UP.angle_to(wall_normal)
		if axis.is_normalized():
			desired_velocity = desired_velocity.rotated(axis, angle)
		gravity = GRAVITY.project(wall_normal)
		if desired_velocity != Vector3.ZERO:
			$debug_climb.global_transform = $debug_climb.global_transform.looking_at(
				$debug_climb.global_transform.origin + desired_velocity, wall_normal
			)
	$debug_climb/mesh/dog.transform.origin.y = desired_velocity.length()/10
	desired_velocity += applied_ground
	velocity = velocity.move_toward(desired_velocity, ACCEL_CLIMB) + delta*gravity
	velocity = move(velocity - wall_normal)

func accel_air(delta: float, desired_velocity: Vector3, accel: float, gravity := GRAVITY):
	var hvel := Vector3(velocity.x, 0, velocity.z).move_toward(desired_velocity + applied_ground_velocity, accel*delta)
	velocity.x = hvel.x
	velocity.z = hvel.z
	velocity += gravity*delta
	var pre_slide_vel := velocity
	velocity = move(velocity)
	var ceiling_normal := Vector3.UP
	for i in get_slide_count():
		var c := get_slide_collision(i)
		if c.normal.y < ceiling_normal.y:
			ceiling_normal = c.normal
	if ceiling_normal.y > MIN_DOT_CEILING:
		if pre_slide_vel.y <= 0:
			velocity.y = clamp(velocity.y, pre_slide_vel.y, 0.0)
		else:
			velocity.y = max(velocity.y, pre_slide_vel.y)

func accel_low_gravity(delta: float, desired_velocity: Vector3, gravity_factor: float):
	var hvel := Vector3(velocity.x, 0, velocity.z).move_toward(desired_velocity , ACCEL*delta)
	velocity.x = hvel.x
	velocity.z = hvel.z
	velocity += gravity_factor*GRAVITY*delta
	var pre_slide_vel := velocity
	velocity = move(velocity)
	velocity.y = min(pre_slide_vel.y, velocity.y)

func accel_slide(delta: float, desired_velocity: Vector3, applied_ground: Vector3, wall_normal: Vector3):
	if desired_velocity.dot(wall_normal) < 0:
		desired_velocity = desired_velocity.slide(wall_normal)
	desired_velocity += applied_ground
	
	var hvel := velocity
	hvel = hvel.move_toward(desired_velocity, ACCEL_SLIDE*delta)
	
	velocity = Vector3(
		hvel.x,
		min(hvel.y, velocity.y),
		hvel.z)
	velocity = move(velocity + delta*GRAVITY)

func accel_lunge(delta: float, applied_ground: Vector3, decel := DECEL_KICK):
	if water_depth > DEPTH_WATER_WADE:
		decel *= DECEL_FACTOR_WATER
	var v2 := move(velocity + GRAVITY*delta, true)
	velocity = v2.move_toward(applied_ground, decel*delta)
	velocity.y = v2.y

func accel_hover(delta: float, desired_velocity: Vector3, grounded: bool):
	var gravity := GRAVITY*HOVER_EXTRA_GRAVITY
	var hvel := Vector3(velocity.x, 0, velocity.z)
	var hdir := hvel.normalized()
	if grounded:
		var axis = Vector3.UP.cross(hover_normal).normalized()
		var angle = Vector3.UP.angle_to(hover_normal)
		if axis.is_normalized():
			desired_velocity = desired_velocity.rotated(axis, angle)
		desired_velocity.y = min(desired_velocity.y, 0)
		gravity = gravity.slide(hover_normal)
	var h := hover_normal
	if hover_cast.is_colliding():
		var dist = (hover_cast.global_transform.origin - hover_cast.get_collision_point())
		var factor = HOVER_DESIRED_HEIGHT - dist.length()
		var height_correction = factor*HOVER_CORRECTION_HEIGHT
		var vel_correction = -velocity.y*HOVER_CORRECTION_VELOCITY
		var slope_correction = -hvel.dot(hover_normal)*HOVER_CORRECTION_SLOPE
		h *= height_correction + vel_correction + slope_correction
		
	var charge: Vector3
	var steer: Vector3
	var charge_accel : float
	if hdir.is_normalized():
		charge = desired_velocity.project(hdir)
		steer = desired_velocity.slide(hdir)
		if charge.dot(hdir) > 0:
			if charge.length() < velocity.length():
				charge_accel = DECEL_HOVER
			else:
				charge_accel = ACCEL_HOVER
		else:
			charge_accel = ACCEL_HOVER
	else:
		charge = desired_velocity
		steer = Vector3.ZERO
		charge_accel = ACCEL_HOVER
	var drag := -HOVER_AIR_DRAG*delta*(velocity*velocity*velocity)
	velocity += delta*(
		(charge - hvel)/SPEED_RUN*charge_accel 
		+ (steer*ACCEL_STEER_HOVER)
		+ gravity
		+ h
		+ drag
	)
	
	velocity = move(velocity)
	mesh.hover_lean(Vector2(
		(steer - velocity).dot(mesh.global_transform.basis.x),
		0
	)/SPEED_HOVER + Vector2(
		2*hover_normal.dot(mesh.global_transform.basis.x),
		-2*hover_normal.dot(mesh.global_transform.basis.z)
	), delta)

func should_raise_camera():
	return state == State.LedgeHang

func is_grounded():
	return ( state == State.Ground
		or state == State.Slide
		or state == State.Roll
		or state == State.Crouch)

func is_hovering():
	return state == State.Hover

func can_flinch():
	return !( state == State.DiveWindup
		or state == State.DiveStart
		or state == State.UppercutWindup)

func takes_damage(source: Node):
	if state == State.Locked and !(
		'lock_damage_override' in source
		and source.lock_damage_override
	):
		return false
	if is_dead() or state == State.Damaged:
		return false
	if state == State.Roll and !after(TIME_ROLL_INVINCIBILITY):
		mesh.play_dodge()
		return false
	return true

func should_hover() -> bool:
	return ( can_use_hover_scooter 
		and pressed("hover_toggle") 
		and Global.count("hover_scooter"))

func can_climb(floor_dot: float, min_dot := MIN_DOT_CLIMB) -> bool:
	if !best_floor or !holding("mv_crouch") or best_floor.is_in_group("dont_stand"):
		return false
	else:
		var can_normal_climb:bool = (floor_dot > min_dot
			and total_stamina() > MIN_CLIMB_STAMINA)
		return can_normal_climb or (floor_dot > MIN_DOT_CLIMB
			and best_floor.is_in_group("ladder"))

func can_wall_cling(normal: Vector3) -> bool:
	var res:bool = ( wall_cling 
		and normal != Vector3.ZERO 
		and total_stamina() > 0 
		and normal.y > MIN_DOT_CLIMB 
		and holding("mv_crouch"))
	debug.get_node("stats/a8").text = "can wall cling" if res else "no wall cling"
	return res

func can_ledge_grab(min_dot: float = MIN_DOT_LEDGE) -> bool:
	if ledgeCastCeiling.is_colliding() or ledgeCastHeadFloor.is_colliding():
		return false
	
	var left:bool = check_cast(ledgeCastLeft, min_dot)
	var right:bool = check_cast(ledgeCastRight, min_dot)
	var center:bool = check_cast(ledgeCastCenter, min_dot)
	var wall_cast_end: Vector3
	# debug
	if true:
		debug_cast(ledgeCastCenter, min_dot, $base_mesh/debug_center)
		debug_cast(ledgeCastLeft, min_dot, $base_mesh/debug_left)
		debug_cast(ledgeCastRight, min_dot, $base_mesh/debug_right)
	
	if center:
		wall_cast_end = ledgeCastCenter.get_collision_point()
	elif left:
		wall_cast_end = ledgeCastLeft.get_collision_point()
	elif right:
		wall_cast_end = ledgeCastRight.get_collision_point()
	else:
		ledge = null
		return false
	
	var s = get_world().space
	s = PhysicsServer.space_get_direct_state(s)
	var c:Dictionary = s.intersect_ray(wallCheck.global_transform.origin, wall_cast_end, [self], 1)
	var no_wall:bool = !c or c.normal.y > min_dot
	
	var valid: bool = no_wall and (center or left or right) and is_instance_valid(ledge)
	if !valid:
		ledge = null
	return valid

func check_cast(cast: RayCast, min_dot: float):
	var valid = (
		cast.is_colliding()
		and cast.get_collision_normal().y >= min_dot
		and !cast.get_collider().is_in_group("enemy"))
	if valid and !ledge:
		ledge = cast.get_collider()
		ledge_last_transform = ledge.global_transform
		ledge_local_position = ledge.global_transform.xform_inv(cast.get_collision_point())
	return valid

func debug_cast(cast: RayCast, min_dot: float, meshi: MeshInstance):
	if !cast.is_colliding():
		meshi.material_override.albedo_color = Color.red
	elif cast.get_collision_normal().y < min_dot:
		meshi.material_override.albedo_color = Color.orange
	else:
		meshi.material_override.albedo_color = Color.green

func is_sitting():
	return state == State.Sitting

func snap_to_ledge(ledge_position:Vector3):
	var change = ledge_position - ledgeRef.global_transform.origin
	global_translate(change)

func should_slow_follow():
	return state == State.LungeKick or state == State.RollJump

func get_visual_forward():
	return mesh.global_transform.basis.z

func set_camera_render(render):
	if !cam_rig:
		return
	if render:
		cam_rig.camera.cull_mask = (1 << 21) - 1
	else:
		cam_rig.camera.cull_mask = 0

func rotate_to_velocity(input_dir: Vector3):
	var vis_vel = lerp(
		velocity.normalized(),
		input_dir,
		0.5)
	vis_vel.y = 0
	if abs(vis_vel.x) + abs(vis_vel.z) > 0.01 and input_dir != Vector3.ZERO:
		rotate_mesh(Vector3(vis_vel.x, 0, vis_vel.z).normalized())

func rotate_mesh(target: Vector3, ignore_y := true):
	if ignore_y:
		target.y = 0
		target = target.normalized()
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

func damage_point(area: Area, damage: int, point: Vector3, tag := ""):
	for g in area.get_overlapping_bodies():
		if !is_instance_valid(g) or !g.is_inside_tree():
			continue
		var damage_dir = g.global_transform.origin - point
		damage_dir = damage_dir.normalized()
		damage(g, damage, damage_dir, tag)

func damage_directed(area: Area, damage: int, damage_dir: Vector3, tag: String):
	for g in area.get_overlapping_bodies():
		damage(g, damage, damage_dir, tag)

func damage(node: Node, damage: int, dir: Vector3, tag: String):
	# warning-ignore:narrowing_conversion
	damage = round(float(damage)*damage_dealt_factor())
	if node in damaged_objects:
		return
	damaged_objects.append(node)
	if node.has_method("take_damage"):
		node.take_damage(damage_factor*damage, dir, self, tag)

func move(p_vel: Vector3, grounded := false) -> Vector3:
	if grounded:
		return move_and_slide_with_snap(p_vel,
			Vector3.DOWN*0.06125,
			Vector3.UP,
			true, 4, MIN_DOT_GROUND, 
			INFINITE_INERTIA)
	else:
		return move_and_slide(p_vel, Vector3.UP, false, 4, 900, INFINITE_INERTIA)

func compute_fall_damage(distance):
	if distance.y > FALL_DIST_DEATH and -velocity.y > FALL_VEL_DEATH:
		var _x = take_damage(max_health*2, Vector3.UP, self)
	elif distance.y > FALL_DIST_HIGH and -velocity.y > FALL_VEL_HIGH:
		var _x = take_damage(FALL_DAM_HIGH, Vector3.UP, self)
	elif distance.y > FALL_DIST_MIN and -velocity.y > FALL_VEL_MIN:
		var _x = take_damage(FALL_DAM_MIN, Vector3.UP, self)

func add_health(points: int):
	var new_health = min(max_health, health + points)
	health = new_health

# Returns true if dead
func take_damage(damage: int, direction: Vector3, source, _tag := "") -> bool:
	# warning-ignore:narrowing_conversion
	damage = round(float(damage)*damage_taken_factor())
	if !takes_damage(source) or damage == 0:
		return false
	emit_signal("damaged")
	if ui.in_dialog():
		get_dialog_viewer().skip_and_exit()
	
	mesh.start_damage_particle(direction)
	if extra_health:
		var diff = extra_health - damage
		if diff > 0:
			damage = 0
			extra_health = diff
		else:
			extra_health = 0
			damage = -diff
		var new_armor = ceil(extra_health/ARMOR_BOOST)
		var _x = Global.add_item("armor", new_armor - armor)
		armor = new_armor
	health -= damage
	if health <= 0:
		die()
		return true
	velocity = VEL_DAMAGED_H*direction
	if can_flinch():
		set_state(State.Damaged)
	return false

func damage_taken_factor() -> float:
	var d:DifficultySettings = Settings.sub_options["Difficulty"]
	return d.get_factor(d.enemy_damage)

func damage_dealt_factor() -> float:
	var d:DifficultySettings = Settings.sub_options["Difficulty"]
	return d.get_factor(d.player_damage)

func go_to_sleep():
	var fade_anim:AnimationPlayer = $fade/AnimationPlayer
	lock(false)
	mesh.transition_to("SleepStart")
	fade_anim.play("fadeout")
	
	yield(get_tree().create_timer(1), "timeout")
	
	if get_tree().current_scene.has_method("sleep"):
		get_tree().current_scene.sleep()
	
	yield(get_tree().create_timer(.5), "timeout")
	
	if get_tree().current_scene.has_method("wake_up"):
		get_tree().current_scene.wake_up()
	yield(get_tree().create_timer(.25), "timeout")
	_wake_up()

func _slow_wake(always_heal := false):
	lock(false)
	mesh.force_play("SleepEnd")
	yield(get_tree().create_timer(0.1), "timeout")
	_wake_up(always_heal)

func awake_at(t: Transform):
	set_saved_transform(t)
	_slow_wake(true)

func _wake_up(always_heal := false):
	if always_heal or !empty(sleep_zone):
		heal()
		Global.save_checkpoint(get_save_transform(), true)
	else:
		Global.save_game()
	$fade/AnimationPlayer.play("fadein")
	unlock(State.Sitting)
	dialog_ready = false
	$dialog_timer.start()

func fade_in():
	$fade/AnimationPlayer.play("fadein")

func die():
	set_state(State.Dead)
	var _x = Global.add_stat("player_death")
	# TODO : Animation here
	respawn()

func fall_to_death():
	set_state(State.FallingDeath)

func crushing_death():
	die()

func respawn():
	if game_ui.in_game and !CustomGames.respawn():
		game_ui.cancel_game()
	cam_rig.reset()
	set_state(State.Ground)
	velocity = move_and_slide(Vector3.UP*0.1)
	applied_ground_velocity = Vector3.ZERO
	$fade/AnimationPlayer.play("fadein")
	heal()
	set_saved_transform(Global.game_state.checkpoint_position)
	TimeManagement.resume()
	ui.hide_prompt()
	best_floor = null
	dialog_ready = false
	$dialog_timer.start()
	emit_signal("died")

func disable_collision():
	collision_layer = 0
	collision_mask = 0

func enable_collision():
	collision_layer = normal_layer
	collision_mask = normal_mask

func teleport_to(t: Transform):
	$fade/AnimationPlayer.play("fadein")
	set_saved_transform(t)

func heal():
	if health < max_health or extra_health < armor*ARMOR_BOOST:
		mesh.start_heal_particle()
	health = max_health
	stamina = max_stamina
	extra_stamina = energy*EXTRA_STAMINA_BOOST
	extra_health = armor*ARMOR_BOOST

func drain_stamina(amount):
	var diff = stamina - amount/stamina_drain_factor
	if diff < 0:
		extra_stamina += diff
		extra_stamina = max(extra_stamina, 0)
		var new_energy := int(ceil(extra_stamina/EXTRA_STAMINA_BOOST))
		var echange := new_energy-energy
		if echange:
			var _x = Global.add_item("stamina_booster", echange)
		energy = new_energy
		stamina = 0
	else:
		stamina = diff

func total_stamina():
	return extra_stamina + stamina

func can_dash() -> bool:
	var d := dash_charges > 0
	return d

func place_flag():
	var f = mesh.release_item()
	var t:Transform = $base_mesh/flag_ref.global_transform
	Global.place_flag(f, t)
	Global.save_checkpoint(get_save_transform())
	var bubble = $bubble_spawn/checkpoint_bubble
	bubble.global_transform = t
	bubble._on_saved()
	held_item = null

func get_save_transform() -> Transform:
	var save_transform = global_transform
	save_transform.basis = mesh.global_transform.basis
	return save_transform

func set_saved_transform(t:Transform):
	var forward := t.basis.z
	forward.y = 0
	forward = forward.normalized()
	global_transform = Transform(
		Basis(),
		t.origin)
	mesh.transform.basis = Basis(Vector3.UP.cross(forward), Vector3.UP, forward)

func can_save():
	return !game_ui.in_game and dialog_ready

func can_talk():
	return dialog_ready and (state == State.Ground or state == State.Crouch)

func get_dialog_viewer() -> Node:
	return $ui/dialog/dialog/viewer

func start_dialog(source: Node, sequence: Resource, speaker: Node, starting_label := ""):
	if !CustomGames.can_talk():
		return
	cam_rig.start_dialog()
	lock()
	ui.start_dialog(source, sequence, speaker, starting_label)

func _on_dialog_exited(new_state := State.Ground):
	Global.save_checkpoint(get_save_transform())
	ui.play_game()
	unlock(new_state)
	cam_rig.end_dialog()

func _on_dialog_exited_anim(animation):
	Global.save_game()
	ui.play_game()
	cam_rig.end_dialog()
	anim_exit(animation, true)

func _on_dialog_event(id: String, _source: Node):
	match id:
		"unlock_player":
			cam_rig.start_dialog()
			unlock()
		"lock_player":
			cam_rig.end_dialog()
			lock()

func wardrobe_lock(paused):
	if !paused:
		lock()
	cam_rig.start_wardrobe()

func wardrobe_unlock(paused):
	if !paused:
		unlock()
	cam_rig.end_wardrobe()

func lock(_dialog := true):
	set_process_input(false)
	set_state(State.Locked)
	#ui.game.get_node("stats").hide()
	ui.game.get_node("inventory/vis_timer").stop()
	ui.game.get_node("inventory").hide()

func unlock(new_state := State.Ground):
	set_process_input(true)
	set_state(new_state)
	#ui.game.get_node("stats").show()

func toggle_noclip():
	if state != State.NoClip:
		set_state(State.NoClip)
	else:
		set_state(State.Fall)

func is_locked() -> bool:
	return state == State.Locked or state == State.LockedWaiting

func is_roll_jumping():
	return state == State.RollJump or state == State.RollFall or state == State.WaveJumpRoll

func wave_jump(recoil: Vector3):
	if is_roll_jumping():
		set_state(State.WaveJumpRoll)
	elif state == State.WallCling or state == State.Fall or state == State.BonkFall:
		set_state(State.WaveJump)
	if state == State.Slide or !is_grounded():
		velocity.y = 0
		velocity += recoil

func gravity_stun(dam):
	var dead = take_damage(dam, Vector3.ZERO, self)
	if !dead:
		set_state(State.GravityStun)

func celebrate(item: Spatial = null, local := Transform()):
	held_item = item
	set_state(State.GetItem)
	if held_item:
		held_item.transform = local

func get_item(item: ItemPickup):
	if item.item_id == "health_pickup":
		add_health(item.quantity)
	if item.item_id == "capacitor" or item.item_id in ui.UPGRADE_ITEMS or item.celebrate:
		if item.has_node("preview"):
			var preview = item.get_node("preview")
			var t = preview.transform
			item.remove_child(preview)
			celebrate(preview, t)
		else:
			celebrate()
	if item.custom_sound:
		mesh.play_pickup_sound(item.custom_sound)
	elif !item.item_id.begins_with("wep_"):
		mesh.play_pickup_sound(item.item_id)

func disable():
	set_process_input(false)
	set_process(false)
	set_physics_process(false)
	cam_rig.set_process_input(false)
	ui.set_process_input(false)
	gun.set_process_input(false)
	gun.set_process(false)
	ui.hide()

func track_weapon(weapon: String):
	ui.game.get_node("weapon/ArrowUp").visible = gun.enabled_wep["wep_pistol"]
	ui.game.get_node("weapon/ArrowDown").visible = gun.enabled_wep["wep_wave_shot"]
	ui.game.get_node("weapon/ArrowLeft").visible = gun.enabled_wep["wep_grav_gun"]
	ui.game.get_node("weapon/ArrowRight").visible = gun.enabled_wep["wep_time_gun"]
	current_weapon = weapon
	ui.game.get_node("weapon").icon = weapon
	var ammo_ui = ui.game.get_node("weapon/ammo")
	if gun.current_weapon:
		if "custom_ui" in gun.current_weapon:
			ammo_ui.get_node("ammo_label").visible = false
			if ammo_ui.has_node("custom_ui"):
				ammo_ui.remove_child(ammo_ui.get_node('custom_ui'))
			ammo_ui.add_child(gun.current_weapon.custom_ui)
			gun.current_weapon.custom_ui.show()
			gun.current_weapon.custom_ui.name = "custom_ui"
		else:
			if ammo_ui.has_node("custom_ui"):
				ammo_ui.get_node('custom_ui').hide()
			ammo_ui.get_node("ammo_label").visible = !gun.current_weapon.infinite_ammo
			ammo_ui.get_node("ammo_label").text = str(Global.count(weapon))
	else:
		ammo_ui.hide()

func show_ammo():
	ui.show_ammo()

func hide_ammo():
	ui.hide_ammo()

func shake_camera():
	pass

func start_jump(vel:float):
	wall_cling = true
	emit_signal("jumped")
	velocity.y = jump_factor*vel
	reset_ground()

func is_ground(p_state):
	return p_state in ground_states

func _on_dialog_timer_timeout():
	dialog_ready = true

func _on_drowned():
	if !is_dead() and state != State.NoClip:
		fall_to_death()

func set_state(next_state: int):
	#print_debug(State.keys()[state], " -> ", State.keys()[next_state])
	for i in min(timers.size(), TIMERS_MAX):
		timers[i] = 0.0
	
	# Default properties
	mesh.stop_particles()
	var head_blocked = crouch_head.get_overlapping_bodies().size() > 0
	$crouching_col.disabled = !head_blocked
	$standing_col.disabled = head_blocked
	jump_time = TIME_BASE_JUMP
	jump_time_min = TIME_JUMP_MIN
	
	# Exit effects
	match state:
		State.GetItem:
			mesh.release_item()
		State.Hover:
			mesh.stop_hover()
			collision_mask &= ~(1 << 13)
		State.LungeKick, State.SlideLungeKick, State.DiveEnd:
			gun.end_combo()
		State.LedgeHang:
			ledge = null
		State.Sitting:
			ui.game.get_node("reset_bar").sleep = false
		State.NoClip:
			collision_layer = normal_layer
			collision_mask = normal_mask
		State.LockedWaiting:
			mesh.release_item()

	if !is_ground(state) and is_ground(next_state) and best_floor:
		Bumps.impact_on(best_floor, Bumps.Impact.ImpactLight, global_transform.origin, ground_normal)
	
	# Entry effects
	mesh.enter_state(next_state)
	match next_state:
		State.Ground:
			set_process_input(true)
			last_ground_origin = global_transform.origin
			can_air_spin = true
			can_slide_lunge = true
			wall_cling = true
			dash_charges = Global.count("dash_charge")
			stamina = max_stamina
		State.WadingFall:
			reset_ground()
		State.Fall, State.LedgeFall, State.WaveJump:
			reset_ground()
		State.BaseJump:
			start_jump(JUMP_VEL_BASE)
		State.HighJump:
			jump_time = TIME_CROUCH_JUMP
			jump_time_min = TIME_CROUCH_JUMP
			start_jump(JUMP_VEL_HIGH)
		State.WallJump:
			reset_ground()
			wall_cling = true
			emit_signal("jumped")
		State.LedgeJump:
			reset_ground()
			$crouching_col.disabled = true
			$standing_col.disabled = true
			start_jump(JUMP_VEL_LEDGE)
		State.CrouchJump:
			jump_time = TIME_CROUCH_JUMP
			start_jump(JUMP_VEL_CROUCH)
		State.RollJump:
			damaged_objects = []
			$crouching_col.disabled = false
			$standing_col.disabled = true
			var dir = mesh.global_transform.basis.z
			velocity = speed_factor*dir*JUMP_VEL_ROLL_FORWARD
			start_jump(JUMP_VEL_ROLL)
		State.Crouch:
			stamina = max_stamina
			$crouching_col.disabled = false
			$standing_col.disabled = true
			can_air_spin = true
		State.Climb:
			drain_stamina(STAMINA_DRAIN_CLIMB_START)
			$crouching_col.disabled = false
			$standing_col.disabled = true
			can_air_spin = true
		State.LedgeHang:
			$crouching_col.disabled = false
			$standing_col.disabled = true
			wall_cling = true
			snap_to_ledge(ledge.global_transform*ledge_local_position)
			velocity = Vector3.ZERO
			can_air_spin = true
		State.Roll:
			$crouching_col.disabled = false
			$standing_col.disabled = true
		State.RollFall:
			reset_ground()
		State.BonkFall:
			reset_ground()
			wall_cling = false
			var dir = ground_normal
			dir.y = 0.1
			dir = dir.normalized()
			velocity = speed_factor*dir*SPEED_BONK
		State.LungeKick, State.SlideLungeKick:
			damaged_objects = []
			var dir = get_visual_forward()
			velocity = dir*SPEED_LUNGE
			if water_depth > DEPTH_WATER_WADE:
				velocity *= VEL_REDUCTION_WATER
			can_slide_lunge = false
		State.SpinKick, State.AirSpinKick:
			damaged_objects = []
			velocity.y = jump_factor*VEL_AIR_SPIN
			$base_mesh/attack_spin/AnimationPlayer.play("spin")
			can_air_spin = false
		State.Uppercut:
			reset_ground()
			emit_signal("jumped")
			damaged_objects = []
			velocity.y = damage_factor*VEL_UPPERCUT
		State.DiveWindup:
			velocity.y = VEL_DIVE_WINDUP
		State.DiveStart:
			damaged_objects = []
		State.Damaged:
			velocity.y = max(velocity.y, speed_factor*VEL_DAMAGED_V)
		State.Locked, State.LockedWaiting:
			velocity = Vector3.ZERO
		State.PlaceFlag:
			velocity = Vector3.ZERO
			held_item = flag.instance()
			mesh.hold_item(held_item)
		State.GetItem:
			velocity = Vector3.ZERO
			if held_item:
				mesh.hold_item(held_item)
		State.FallingDeath:
			cam_rig.lock_follow()
		State.GravityStun:
			reset_ground()
			velocity.y = 4
		State.Hover:
			reset_ground()
			collision_mask |= 1 << 13
			hover_cast.enabled = true
		State.Sitting:
			var sat_times = Global.add_stat("player_sat")
			if state != State.Locked and sat_times < 3:
				ui.show_prompt(["mv_crouch"], "(Press and Hold) Sleep")
			$crouching_col.disabled = false
			$standing_col.disabled = true
			velocity = Vector3.ZERO
		State.Dash:
			wall_cling = true
			dash_charges -= 1
			velocity += get_visual_forward()*SPEED_DASH
			velocity.y = SPEED_DASH_V
		State.Wading:
			water_cast.get_node("running_ripple").emitting = true
			can_air_spin = true
			can_slide_lunge = true
			wall_cling = true
			dash_charges = Global.count("dash_charge")
		State.WadingJump:
			water_cast.get_node("running_ripple").emitting = true
			reset_ground()
			start_jump(5.0)
		State.WallCling:
			can_air_spin = true
			wall_cling = false
			$crouching_col.disabled = false
			$standing_col.disabled = true
			velocity.y = 0
		State.NoClip:
			collision_layer = 0
			collision_mask = 0
	state = next_state
	debug.get_node("stats/a1").text = "State: %s" % State.keys()[state]
