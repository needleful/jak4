extends KinematicBody
class_name PlayerBody

signal jumped
signal died

const GRAVITY := Vector3.DOWN*24

# Movement
const SPEED_WALK := 1.5
const SPEED_RUN := 7.0
const SPEED_CROUCH := 3.0

const SPEED_CLIMB := 5.0
const SPEED_ROLL := 15.0
const SPEED_BONK := 5.0

const SPEED_DASH := 15.0
const SPEED_DASH_V := 2.0

const MIN_DOT_GROUND := 0.7
const MIN_DOT_SLIDE := 0.12
const MIN_DOT_CLIMB := -0.2
const MIN_DOT_CLIMB_AIR := 0.1
const MIN_DOT_LEDGE := 0.2
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

const MIN_SPEED_ROLL := 3.0

const TIME_ROLL_MIN := 0.25
const TIME_ROLL_MAX := 0.5
const TIME_ROLL_MIN_JUMP := 0.3
const TIME_ROLL_INVINCIBILITY := 0.2

# Accelerating from zero
const ACCEL_START := 50.0
# Accelerating when moving above some speed
const ACCEL := 20.0
const ACCEL_SLIDE := 10.0
const ACCEL_ROLL := 0.5
const ACCEL_ROLL_AIR := 10.0
const ACCEL_ROLL_WAVE_JUMP := 50.0
# Decelerate against velocity
const DECEL_AGAINST := 45.0
# Decelerate with velocity
const DECEL_WITH := 15.0

const DECEL_DASH := 25.0

const ACCEL_CLIMB := 45.0
const DECEL_CLIMB := 45.0
const ACCEL_STEER_ROLL := 2.5
const ACCEL_DIVE_WINDUP := 75.0

const ACCEL_GRAVITY_STUN := 17.0

const STAMINA_DRAIN_HANG := 0.0
const STAMINA_DRAIN_CLIMB := 25.0
const STAMINA_DRAIN_CLIMB_START := 0.0
const STAMINA_DRAIN_MIN := 0.05
const STAMINA_DRAIN_WALLJUMP := 15.0
const MIN_CLIMB_STAMINA := 0.0
const TIME_STOP_CLIMB := 0.0
var stamina_recharges := true
const MIN_STAMINA_LEDGE_HANG := 0.0
const MAX_TIME_WALL_CLING := 1.0
const WALL_CLING_GRAVITY := 0.2
# Combat

const TIME_LUNGE_MAX := 0.6
const TIME_LUNGE_MIN := 0.4
const TIME_LUNGE_MIN_UPPERCUT := 0.2
const TIME_LUNGE_INVINCIBILITY := 0.2
const TIME_LUNGE_PARTICLES := 0.4
const TIME_LUNGE_COMBO := 0.15

const TIME_SPIN_MAX := 0.7
const TIME_SPIN_MIN := 0.2
const TIME_SPIN_INVINCIBILITY := 0.4

const TIME_UPPERCUT_WINDUP := 0.25
const TIME_UPPERCUT_MIN := 0.4
const TIME_UPPERCUT_MAX := 0.8

const TIME_DIVE_WINDUP := 0.2
const TIME_DIVE_END_MIN := 0.4
const TIME_DIVE_END_MAX := 0.5
const TIME_DIVE_UPPERCUT := 0.1
const TIME_DIVE_HIGHJUMP := 0.05

const SPEED_LUNGE := 25.0

const VEL_AIR_SPIN := 3.0
const VEL_UPPERCUT := 10.0
const VEL_DIVE_WINDUP := 4.0

const GRAVITY_BOOST_UPPERCUT := 0.2
const GRAVITY_BOOST_DIVE := 0.5

const STEER_KICK := 5.0
const DECEL_KICK := 75.0

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
const SPEED_HOVER := SPEED_RUN*2.5
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
# Broad things

var velocity := Vector3.ZERO
var timer_coyote := 0.0
var timer_state := 0.0

const DEFAULT_MAX_HEALTH := 50
const HEALTH_UP_BOOST := 0.5
var max_health := DEFAULT_MAX_HEALTH
var health := max_health

const ARMOR_BOOST := 20.0
var armor := 0
var extra_health := 0.0

const HEALTH_BAR_DEFAULT_SIZE := 400
const ARMOR_BAR_DEFAULT_SIZE := 96.0

const DEFAULT_MAX_STAMINA := 40.0
const STAMINA_UP_BOOST := 0.5
var max_stamina := DEFAULT_MAX_STAMINA
var stamina_recover := 16.0
var stamina := max_stamina

const EXTRA_STAMINA_BOOST := 15.0
var energy := 0
var extra_stamina := 0.0

const STAMINA_BAR_DEFAULT_SIZE := 280
const EXTRA_STAMINA_BAR_SIZE := 7

const STAMINA_RECOVERY_BOOST := 0.5
var stamina_factor := 1.0

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

const TIME_RESET_GROUND := 0.01
var can_air_spin := true
var can_slide_lunge := true
var can_wall_cling := true

const TIME_LEDGE_LEAVE := 0.1
var timer_leave_ledge := 0.0

const TIME_PLACE_FLAG := 0.5
const TIME_GET_ITEM := 0.9
var time_animation := 0.0

const TIME_FALLING_DEATH := 2.0

const TIME_GRAVITY_STUN := 2
const TIME_WAVE_JUMP_ROLL := 0.1

const TIME_TO_SIT := 2.5
var sit_timer := 0.0

const TIME_TO_DASH := 0.05
const TIME_DASH := 0.5

# Ledge being held onto
var ledge: Spatial
# Position of player relative to ledge at start of ledge grab
var ledge_local_position : Vector3
# Global transform
var ledge_last_transform : Transform

onready var equipment_inventory := {}

onready var equipped_item : Usable

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
	PlaceFlag,
	GetItem,
	FallingDeath,
	GravityStun,
	Hover,
	WaveJumpRoll,
	Sitting,
	Dash,
	HighJump,
	WallCling,
	WallJump
}

var state: int = State.Fall
var ground_normal:Vector3 = Vector3.UP
var best_floor_dot: float
var best_floor : Node
var dash_charges := 0

var current_coat: Coat
# Camera settings
var sensitivity := 1.0
var invert_x := false
var invert_y := false

var current_weapon : String

const INFINITE_INERTIA := false

# Nodes
onready var cam_rig := $camera_rig
onready var cam_yaw := $camera_rig/yaw
onready var mesh := $jackie
onready var crouch_head := $crouchHeadArea
onready var intention := $intention

onready var ground_area := $groundArea
onready var climb_area := $climbArea

onready var ledgeCastLeft := $jackie/leftHandCast
onready var ledgeCastRight := $jackie/rightHandCast
onready var ledgeCastCenter := $jackie/centerCast
onready var ledgeCastCeiling := $jackie/ceilingCast
onready var ledgeRef := $jackie/reference

onready var lunge_hitbox := $jackie/attack_lunge
onready var spin_hitbox := $jackie/attack_spin
onready var roll_hitbox := $jackie/attack_roll
onready var uppercut_hitbox := $jackie/attack_uppercut
onready var dive_start_hitbox := $jackie/attack_dive_start
onready var dive_end_hitbox := $jackie/attack_dive_end

onready var hover_floor_finder := $hover_floor_finder
onready var hover_cast := $hover_cast
onready var hover_area := $hover_area

onready var health_bar := $ui/gameing/stats/health/base
onready var stamina_bar := $ui/gameing/stats/stamina/base
onready var armor_bar := $ui/gameing/stats/health/extra
onready var energy_bar := $ui/gameing/stats/stamina/extra
onready var equipment := $ui/gameing/equipment

onready var ui := $ui
onready var game_ui := $ui/gameing/custom_game

onready var coat_zone := $jackie/the_coat_zone
onready var gun := $jackie/Armature/Skeleton/gun
onready var lantern := $jackie/Armature/Skeleton/coat_tails/lantern
export(PackedScene) var flag : PackedScene
export(PackedScene) var capacitor : PackedScene

var held_item
var choosing_item := false
const TIME_ITEM_CHOOSE := 0.25
var timer_item_choose := 0.0
var equipment_path_f := "res://items/usable/%s.gd"

const VISIBLE_ITEMS := [
	"bug",
	"capacitor",
	"gem",
]

const UPGRADE_ITEMS := [
	"armor",
	"damage_up",
	"health_up",
	"jump_height_up",
	"move_speed_up",
	"stamina_booster",
	"stamina_recovery_up",
	"stamina_up",
	"hover_speed_up"
]

const AMMO := [
	"pistol",
	"wave_shot",
	"grav_gun"
]

const WEAPONS := [
	"wep_pistol",
	"wep_wave_shot",
	"wep_grav_gun",
	"wep_time_gun"
]

func _ready():
	if Global.valid_game_state:
		global_transform.origin = Global.game_state.checkpoint_position
		set_current_coat(Global.game_state.current_coat, false)
	else:
		Global.game_state.checkpoint_position = global_transform.origin
		# Generate three random Common coats
		for _x in range(3):
			var coat = Coat.new(true, Coat.Rarity.Common, Coat.Rarity.Common)
			Global.add_coat(coat)
		set_current_coat(Global.game_state.all_coats[0], false)
		
	set_state(State.Ground)
	var _x = Global.connect("item_changed", self, "on_item_changed")
	_x = $ui/dialog_viewer.connect("exited", self, "_on_dialog_exited")
	_x = $ui/dialog_viewer.connect("event_with_source", self, "_on_dialog_event")
	update_inventory()
	health = max_health
	stamina = max_stamina
	update_health()
	gun.camera = cam_rig.camera
	equip(0)

func _input(event):
	if( can_talk()
		and event.is_action_pressed("dialog_coat")
		and coat_zone.get_overlapping_bodies().size() != 0
	):
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
	elif event.is_action_pressed("show_inventory"):
		show_inventory()
	elif choosing_item:
		if event.is_action_pressed("ui_up"):
			equip_previous()
		elif event.is_action_pressed("ui_down"):
			equip_next()

func _physics_process(delta):
	if velocity.y < TERMINAL_VELOCITY:
		velocity.y = TERMINAL_VELOCITY
	timer_state += delta
	if stamina_recharges:
		stamina += stamina_factor*stamina_recover*delta
	stamina = clamp(stamina, 0.0, max_stamina)
	
	var movement := Input.get_vector("mv_left", "mv_right", "mv_up", "mv_down")
	var desired_velocity: Vector3 = speed_factor*(
		cam_yaw.global_transform.basis.x * movement.x
		+ cam_yaw.global_transform.basis.z * movement.y)
	
	if desired_velocity.length() > 1.0 or (
		desired_velocity.dot(velocity) > 0
	):
		rotate_intention(desired_velocity)
	
	best_floor_dot = -1.0
	var best_normal := Vector3.ZERO
	best_floor = null
	for c in range(get_slide_count()):
		var col := get_slide_collision(c)
		var normal := col.normal
		var dot := normal.dot(Vector3.UP)
		if dot > best_floor_dot:
			best_floor_dot = dot
			best_normal = normal
			best_floor = col.collider as Node
	if best_floor_dot > MIN_DOT_GROUND:
		ground_normal = best_normal
	$ui/gameing/debug/stats/a2.text = "Floor Dot: %f" % best_floor_dot
	
	var next_state := state
	match state:
		State.Ground:
			if Input.is_action_just_pressed("mv_jump"):
				next_state = State.BaseJump
			elif should_hover():
				next_state = State.Hover
			elif !choosing_item and Input.is_action_just_released("use_item") and equipped_item and equipped_item.can_use():
				equipped_item.use()
				next_state = state
			elif Input.is_action_pressed("mv_crouch"):
				if velocity.length() > MIN_SPEED_ROLL:
					next_state = State.Roll
				else:
					next_state = State.Crouch
			elif ( crouch_head.get_overlapping_bodies().size() > 0
				and $standing_col.disabled):
				next_state = State.Crouch
			elif Input.is_action_just_released("combat_lunge"):
				next_state = State.LungeKick
			elif Input.is_action_just_pressed("combat_spin"):
				next_state = State.SpinKick
			elif ground_area.get_overlapping_bodies().size() == 0:
				timer_coyote += delta
				if timer_coyote > TIME_COYOTE:
					next_state = State.Fall
			elif best_normal != Vector3.ZERO and best_floor_dot < MIN_DOT_GROUND:
				timer_coyote += delta
				if timer_coyote > TIME_COYOTE:
					next_state = State.Slide
			else:
				timer_coyote = 0
		State.PlaceFlag, State.GetItem:
			if timer_state > time_animation:
				next_state = State.Ground
		State.Slide:
			if Input.is_action_just_pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif can_dash() and Input.is_action_just_pressed("mv_jump"):
				next_state = State.Dash
			elif should_hover():
				next_state = State.Hover
			elif can_slide_lunge and Input.is_action_just_pressed("combat_lunge"):
				next_state = State.SlideLungeKick
			elif best_floor_dot >= MIN_DOT_CLIMB and total_stamina() > MIN_CLIMB_STAMINA and Input.is_action_pressed("mv_crouch"):
				next_state = State.Climb
			elif best_floor_dot > MIN_DOT_GROUND:
				next_state = State.Ground
			elif best_floor_dot < MIN_DOT_SLIDE:
				timer_coyote += delta
				if timer_coyote > TIME_COYOTE:
					next_state = State.Fall
			elif can_ledge_grab():
				next_state = State.LedgeHang
			else:
				timer_coyote = 0
		State.Dash:
			if Input.is_action_just_pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif Input.is_action_just_pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif can_dash() and Input.is_action_just_pressed("mv_jump"):
				next_state = State.Dash
			elif best_floor_dot > MIN_DOT_GROUND:
				if Input.is_action_pressed("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Ground
			elif best_floor_dot > MIN_DOT_CLIMB_AIR and Input.is_action_pressed("mv_crouch"):
				next_state = State.Climb
			elif can_wall_cling and best_floor_dot > MIN_DOT_CLIMB and Input.is_action_pressed("mv_crouch"):
				next_state = State.WallCling
			elif best_floor_dot > MIN_DOT_SLIDE:
				if Input.is_action_pressed("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Slide
			elif timer_state > TIME_DASH:
				next_state = State.Fall
		State.BaseJump, State.LedgeJump, State.HighJump, State.WallJump:
			if Input.is_action_just_pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif Input.is_action_just_pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif timer_state > TIME_TO_DASH and can_dash() and Input.is_action_just_pressed("mv_jump"):
				next_state = State.Dash
			elif timer_state > TIME_BASE_JUMP:
				next_state = State.Fall
			elif timer_state > TIME_JUMP_MIN:
				if best_floor_dot > MIN_DOT_GROUND:
					next_state = State.Ground
				elif best_floor_dot > MIN_DOT_SLIDE:
					next_state = State.Slide
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
			elif ground_area.get_overlapping_bodies().size() == 0:
				timer_coyote += delta
				if timer_coyote > TIME_COYOTE:
					next_state = State.Fall
			elif best_floor_dot < MIN_DOT_GROUND and best_floor_dot > MIN_DOT_CLIMB:
				if total_stamina() > MIN_CLIMB_STAMINA:
					next_state = State.Climb
				else:
					next_state = State.Slide
			else:
				timer_coyote = 0
				if desired_velocity.length() < 0.001:
					sit_timer += delta
					if sit_timer > TIME_TO_SIT:
						next_state = State.Sitting
				else:
					sit_timer = 0
		State.CrouchJump:
			if Input.is_action_just_pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif timer_state > TIME_TO_DASH and can_dash() and Input.is_action_just_pressed("mv_jump"):
				next_state = State.Dash
			elif timer_state > TIME_CROUCH_JUMP:
				next_state = State.Fall
			elif timer_state > TIME_JUMP_MIN:
				if best_floor_dot > MIN_DOT_GROUND:
					next_state = State.Ground
				elif best_floor_dot > MIN_DOT_SLIDE:
					next_state = State.Slide
		State.Climb:
			drain_stamina(
				(desired_velocity.length() + STAMINA_DRAIN_MIN)
				* STAMINA_DRAIN_CLIMB
				* delta
				* (1.0-sqrt(max(best_floor_dot, 0)))
			)
			if stamina >= STAMINA_DRAIN_WALLJUMP and Input.is_action_just_pressed("mv_jump"):
				drain_stamina(STAMINA_DRAIN_WALLJUMP)
				if best_normal == Vector3.ZERO:
					best_normal = ground_normal
				velocity = JUMP_VEL_WALL*best_normal
				velocity.y = JUMP_VEL_WALL_V
				next_state = State.WallJump
			elif best_floor_dot > MIN_DOT_GROUND:
				timer_coyote += delta
				if timer_coyote > TIME_STOP_CLIMB:
					next_state = State.Crouch
			elif climb_area.get_overlapping_bodies().empty():
				$ui/gameing/debug/stats/a6.text = "!!!"
				timer_coyote += delta
				if timer_coyote > TIME_STOP_CLIMB:
					next_state = State.Fall
			elif total_stamina() <= 0 or !Input.is_action_pressed("mv_crouch"):
				next_state = State.Slide
			else:
				$ui/gameing/debug/stats/a6.text = "all good"
				timer_coyote = 0.0
		State.Roll:
			if (timer_state > TIME_ROLL_MIN_JUMP 
				and Input.is_action_just_pressed("mv_jump")
			):
				next_state = State.RollJump
			elif (timer_state > TIME_ROLL_MIN 
				and Input.is_action_just_pressed("combat_lunge")
			):
				next_state = State.UppercutWindup
			elif (timer_state > TIME_ROLL_MIN
				and best_floor_dot < MIN_DOT_SLIDE
			):
				timer_coyote += delta
				if timer_coyote > TIME_COYOTE:
					next_state = State.Fall
			else:
				timer_coyote = 0
				if timer_state > TIME_ROLL_MAX:
					if best_floor_dot < MIN_DOT_GROUND:
						next_state = State.Slide
					elif Input.is_action_pressed("mv_crouch"):
						next_state = State.Crouch
					else:
						next_state = State.Ground
		State.RollJump:
			if Input.is_action_just_pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif timer_state > TIME_TO_DASH and can_dash() and Input.is_action_just_pressed("mv_jump"):
				next_state = State.Dash
			elif can_ledge_grab():
				next_state = State.LedgeHang
			elif (best_normal != Vector3.ZERO
				and best_floor_dot < MIN_DOT_SLIDE
			):
				next_state = State.BonkFall
			elif timer_state > TIME_CROUCH_JUMP:
				if best_floor_dot > MIN_DOT_GROUND:
					next_state = State.Ground
				elif best_floor_dot > MIN_DOT_SLIDE:
					next_state = State.Slide
				else:
					next_state = State.RollFall
		State.RollFall:
			if Input.is_action_just_pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif can_dash() and Input.is_action_just_pressed("mv_jump"):
				next_state = State.Dash
			elif can_ledge_grab():
				next_state = State.LedgeHang
			elif best_floor_dot > MIN_DOT_GROUND:
				if Input.is_action_pressed("mv_crouch"):
					next_state = State.Crouch
				elif crouch_head.get_overlapping_bodies().size() == 0:
					next_state = State.Ground
			elif best_floor_dot > MIN_DOT_CLIMB_AIR and Input.is_action_pressed("mv_crouch"):
				next_state = State.Climb
			elif can_wall_cling and best_floor_dot > MIN_DOT_CLIMB and Input.is_action_pressed("mv_crouch"):
				next_state = State.WallCling
			elif best_floor_dot > MIN_DOT_SLIDE and crouch_head.get_overlapping_bodies().size() == 0:
				next_state = State.Slide
			elif best_normal != Vector3.ZERO:
				next_state = State.BonkFall
		State.Fall, State.BonkFall:
			if can_air_spin and Input.is_action_just_pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif Input.is_action_just_pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif can_dash() and Input.is_action_just_pressed("mv_jump"):
				next_state = State.Dash
			elif should_hover():
				next_state = State.Hover
			elif best_floor_dot > MIN_DOT_GROUND:
				if Input.is_action_pressed("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Ground
			elif can_ledge_grab():
				next_state = State.LedgeHang
			elif best_floor_dot > MIN_DOT_CLIMB_AIR and Input.is_action_pressed("mv_crouch"):
				next_state = State.Climb
			elif can_wall_cling and best_floor_dot > MIN_DOT_CLIMB and Input.is_action_pressed("mv_crouch"):
				next_state = State.WallCling
			elif best_floor_dot > MIN_DOT_SLIDE:
				next_state = State.Slide
		State.LedgeHang:
			drain_stamina(STAMINA_DRAIN_HANG*delta)
			var intent_dot = mesh.global_transform.basis.z.dot(desired_velocity)
			if Input.is_action_just_pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif Input.is_action_just_pressed("mv_jump"):
				next_state = State.LedgeJump
			elif best_floor_dot > MIN_DOT_GROUND:
				next_state = State.Ground
			elif total_stamina() < MIN_STAMINA_LEDGE_HANG:
				next_state = State.LedgeFall
			elif intent_dot < 0 or !ledgeCastCenter.is_colliding():
				timer_leave_ledge += delta
				if timer_leave_ledge > TIME_LEDGE_LEAVE:
					next_state = State.LedgeFall
			else:
				timer_leave_ledge = 0
		State.LedgeFall:
			if can_air_spin and Input.is_action_just_pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif Input.is_action_just_pressed("combat_lunge"):
				next_state = State.DiveWindup
			elif can_dash() and Input.is_action_just_pressed("mv_jump"):
				next_state = State.Dash
			elif should_hover():
				next_state = State.Hover
			elif best_floor_dot > MIN_DOT_GROUND:
				if Input.is_action_pressed("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Ground
			elif best_floor_dot > MIN_DOT_CLIMB_AIR and Input.is_action_pressed("mv_crouch"):
				next_state = State.Climb
			elif can_wall_cling and best_floor_dot > MIN_DOT_CLIMB and Input.is_action_pressed("mv_crouch"):
				next_state = State.WallCling
			elif best_floor_dot > MIN_DOT_SLIDE:
				next_state = State.Slide
			else:
				if timer_state >= TIME_LEDGE_FALL:
					next_state = State.Fall
		State.LungeKick:
			if timer_state >= TIME_LUNGE_MAX:
				if best_floor_dot > MIN_DOT_GROUND:
					next_state = State.Ground
				else:
					next_state = State.Fall
			elif ( timer_state >= TIME_LUNGE_MIN
				and Input.is_action_just_pressed("combat_spin")
			):
				next_state = State.SpinKick
			elif (timer_state >= TIME_LUNGE_MIN_UPPERCUT
				and Input.is_action_just_pressed("mv_jump")
			):
				next_state = State.UppercutWindup
		State.SlideLungeKick:
			if timer_state >= TIME_LUNGE_MAX:
				next_state = State.Slide
			elif ( timer_state >= TIME_LUNGE_MIN
				and Input.is_action_just_pressed("combat_spin")
			):
				next_state = State.AirSpinKick
		State.SpinKick:
			if timer_state >= TIME_SPIN_MAX:
				if best_floor_dot > MIN_DOT_GROUND:
					next_state = State.Ground
				elif best_floor_dot > MIN_DOT_SLIDE:
					next_state = State.Slide
				else:
					next_state = State.Fall
			elif timer_state >= TIME_SPIN_MIN:
				if Input.is_action_just_pressed("combat_lunge"):
					next_state = State.LungeKick
				elif best_floor_dot > MIN_DOT_SLIDE and Input.is_action_pressed("mv_crouch"):
					if velocity.length_squared() > MIN_SPEED_ROLL*MIN_SPEED_ROLL:
						next_state = State.Roll
					else:
						next_state = State.Crouch
		State.AirSpinKick:
			if can_dash() and Input.is_action_just_pressed("mv_jump"):
				next_state = State.Dash
			elif best_floor_dot > MIN_DOT_GROUND:
				if Input.is_action_pressed("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Ground
			elif can_ledge_grab():
				next_state = State.LedgeHang
			else:
				if timer_state >= TIME_SPIN_MAX:
					next_state = State.Fall
				elif timer_state >= TIME_SPIN_MIN and Input.is_action_just_pressed("combat_lunge"):
					next_state = State.DiveWindup
		State.UppercutWindup:
			if timer_state > TIME_UPPERCUT_WINDUP:
				next_state = State.Uppercut
		State.Uppercut:
			if Input.is_action_just_released("combat_lunge"):
				next_state = State.DiveWindup
			elif Input.is_action_just_released("combat_spin"):
				next_state = State.AirSpinKick
			elif can_dash() and Input.is_action_just_pressed("mv_jump"):
				next_state = State.Dash
			elif timer_state > TIME_UPPERCUT_MIN and best_floor_dot > MIN_DOT_GROUND:
				if Input.is_action_pressed("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Ground
			elif timer_state > TIME_UPPERCUT_MAX:
				next_state = State.Fall
		State.DiveWindup:
			if timer_state > TIME_DIVE_WINDUP:
				next_state = State.DiveStart
		State.DiveStart:
			if can_dash() and Input.is_action_just_pressed("mv_jump"):
				next_state = State.Dash
			elif best_floor_dot > MIN_DOT_SLIDE:
				next_state = State.DiveEnd
		State.DiveEnd:
			if timer_state > TIME_DIVE_END_MAX:
				next_state = State.Ground
			elif timer_state > TIME_DIVE_END_MIN:
				if Input.is_action_just_pressed("combat_lunge"):
					next_state = State.LungeKick
				elif Input.is_action_just_pressed("combat_spin"):
					next_state = State.AirSpinKick
			elif ( timer_state > TIME_DIVE_UPPERCUT
				and best_floor_dot > MIN_DOT_GROUND 
				and Input.is_action_just_pressed("combat_lunge")
			):
				next_state = State.UppercutWindup
			elif ( timer_state < TIME_DIVE_HIGHJUMP
				and Input.is_action_just_pressed("mv_jump")
			):
				next_state = State.HighJump
		State.Damaged:
			if Input.is_action_just_released("combat_lunge"):
				next_state = State.LungeKick
			elif Input.is_action_just_pressed("combat_spin"):
				next_state = State.AirSpinKick
			elif timer_state > TIME_DAMAGED:
				next_state = State.Fall
		State.FallingDeath:
			if timer_state > TIME_FALLING_DEATH:
				next_state = State.Fall
				die()
		State.GravityStun:
			if timer_state > TIME_GRAVITY_STUN:
				next_state = State.Fall
		State.Hover:
			if Input.is_action_just_pressed("hover_toggle"):
				next_state = State.Fall
		State.WaveJumpRoll:
			if can_dash() and Input.is_action_just_pressed("mv_jump"):
				next_state = State.Dash
			elif timer_state > TIME_WAVE_JUMP_ROLL:
				next_state = State.RollFall
		State.Sitting:
			if Input.is_action_just_pressed("mv_jump"):
				next_state = State.BaseJump
			elif ground_area.get_overlapping_bodies().size() == 0:
				next_state = State.Fall
			elif desired_velocity.length() > 0.05:
				next_state = State.Ground
		State.WallCling:
			drain_stamina(
				(desired_velocity.length() + STAMINA_DRAIN_MIN)
				* STAMINA_DRAIN_CLIMB
				* delta
				* (1.0-sqrt(max(best_floor_dot, 0)))
			)
			var on_wall := true
			if best_normal != Vector3.ZERO and best_floor_dot < MIN_DOT_CLIMB:
				on_wall = false
			elif climb_area.get_overlapping_bodies().empty():
				on_wall = false
			if can_ledge_grab():
				next_state = State.LedgeHang
			elif stamina >= STAMINA_DRAIN_WALLJUMP and Input.is_action_just_pressed("mv_jump"):
				drain_stamina(STAMINA_DRAIN_WALLJUMP)
				if best_normal == Vector3.ZERO:
					best_normal = ground_normal
				velocity = JUMP_VEL_WALL*best_normal
				velocity.y = JUMP_VEL_WALL_V
				next_state = State.WallJump
			elif best_floor_dot >= MIN_DOT_GROUND:
				if Input.is_action_pressed("mv_crouch"):
					next_state = State.Crouch
				else:
					next_state = State.Ground
			elif ( total_stamina() <= 0 
				or timer_state > MAX_TIME_WALL_CLING
				or !on_wall
				or !Input.is_action_pressed("mv_crouch")
			):
				next_state = State.Fall
	set_state(next_state)
	
	match state:
		State.Ground:
			
			if timer_state > TIME_RESET_GROUND:
				can_air_spin = true
				can_slide_lunge = true
			accel(delta, desired_velocity*SPEED_RUN)
			mesh.blend_run_animation(velocity.length()/SPEED_RUN)
			rotate_to_velocity(desired_velocity)
		State.Fall, State.LedgeFall:
			accel_air(delta, desired_velocity*SPEED_RUN, ACCEL)
			rotate_to_velocity(desired_velocity)
		State.Slide:
			accel_slide(delta, desired_velocity*SPEED_RUN, best_normal)
			mesh.blend_run_animation(desired_velocity.length())
			rotate_to_velocity(desired_velocity)
		State.BaseJump, State.HighJump:
			accel_air(delta, desired_velocity*SPEED_RUN, ACCEL_START)
			rotate_to_velocity(desired_velocity)
		State.Roll:
			accel(delta, desired_velocity * SPEED_ROLL, ACCEL, ACCEL_STEER_ROLL, 0.0)
			rotate_to_velocity(desired_velocity)
		State.RollJump, State.RollFall, State.WallJump:
			accel_air(delta, desired_velocity*SPEED_ROLL, ACCEL_ROLL_AIR)
			damage_directed(roll_hitbox, DAMAGE_ROLL_JUMP, velocity)
			rotate_to_velocity(desired_velocity)
		State.BonkFall, State.Damaged:
			accel_air(delta, desired_velocity*SPEED_CROUCH, ACCEL_ROLL)
			rotate_to_velocity(desired_velocity)
		State.Crouch:
			accel(delta, desired_velocity*SPEED_CROUCH)
			mesh.blend_run_animation(velocity.length()/SPEED_CROUCH)
			rotate_to_velocity(desired_velocity)
		State.Climb:
			if best_normal.dot(Vector3.UP) > MIN_DOT_SLIDE:
				ground_normal = best_normal
			accel_climb(delta, desired_velocity*SPEED_CLIMB, best_normal)
			mesh.blend_climb_animation(velocity/SPEED_CLIMB, best_normal)
			rotate_mesh(-best_normal)
		State.CrouchJump, State.LedgeJump:
			accel_air(delta, desired_velocity*SPEED_CROUCH, ACCEL)
			rotate_to_velocity(desired_velocity)
		State.LedgeHang:
			if ledge.global_transform != ledge_last_transform:
				var new_transform := ledge.global_transform
				var old_position := ledge_last_transform*ledge_local_position
				var new_position := new_transform*ledge_local_position
				var _x = move_and_collide(new_position - old_position)
				ledge_last_transform = new_transform
		State.Dash:
			rotate_intention(velocity.normalized())
			accel_lunge(delta, desired_velocity*SPEED_DASH, DECEL_DASH)
			damage_directed(roll_hitbox, DAMAGE_ROLL_JUMP, get_visual_forward())
			rotate_to_velocity(desired_velocity)
		State.LungeKick, State.SlideLungeKick:
			if timer_state > TIME_LUNGE_PARTICLES:
				mesh.stop_particles()
			if (timer_state > TIME_LUNGE_COMBO
				and !gun.in_combo()
				and damaged_objects.size() > 0):
				gun.start_combo()
			rotate_intention(velocity.normalized())
			accel_lunge(delta, desired_velocity*SPEED_LUNGE)
			damage_directed(lunge_hitbox, DAMAGE_LUNGE, get_visual_forward())
			rotate_to_velocity(desired_velocity)
		State.SpinKick:
			if best_normal.dot(Vector3.UP) > MIN_DOT_SLIDE:
				ground_normal = best_normal
			accel(delta, desired_velocity*SPEED_RUN)
			damage_point(spin_hitbox, DAMAGE_SPIN, global_transform.origin)
		State.AirSpinKick:
			accel_low_gravity(delta, desired_velocity*SPEED_RUN, 0.75)
			damage_point(spin_hitbox, DAMAGE_SPIN, global_transform.origin)
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
			if !gun.in_combo() and damaged_objects.size() > 0:
				gun.start_combo()
			accel_slide(delta, desired_velocity*SPEED_RUN, best_normal)
			damage_point(dive_end_hitbox, DAMAGE_DIVE_END, global_transform.origin)
			rotate_to_velocity(desired_velocity)
		State.Locked, State.PlaceFlag, State.GetItem, State.Sitting:
			desired_velocity = Vector3.ZERO
			mesh.blend_run_animation(velocity.length()/SPEED_RUN)
		State.FallingDeath:
			desired_velocity = Vector3.ZERO
			accel_air(delta, desired_velocity*SPEED_RUN, ACCEL)
		State.GravityStun:
			velocity *= clamp(1.0 - delta, 0.1, 0.995)
			accel_air(delta, desired_velocity*SPEED_CROUCH, ACCEL_GRAVITY_STUN, Vector3.UP*Global.gravity_stun_velocity)
			rotate_to_velocity(desired_velocity)
		State.Hover:
			var grounded:bool = hover_area.get_overlapping_bodies().size() > 0
			if hover_floor_finder.is_colliding():
				hover_normal = hover_floor_finder.get_collision_normal()
				hover_cast.cast_to = -hover_normal
			accel_hover(delta, desired_velocity*SPEED_HOVER*hover_speed_factor, grounded)
			rotate_to_velocity(desired_velocity)
		State.WaveJumpRoll:
			accel_air(delta, desired_velocity * SPEED_ROLL, ACCEL_ROLL_WAVE_JUMP)
			damage_point(roll_hitbox, DAMAGE_ROLL_JUMP, global_transform.origin)
			rotate_to_velocity(desired_velocity)
		State.WallCling:
			if best_normal != Vector3.ZERO:
				ground_normal = best_normal
			var hvel := velocity.move_toward(Vector3.ZERO, ACCEL_CLIMB)
			hvel.y = velocity.y + WALL_CLING_GRAVITY*delta*GRAVITY.y
			velocity = move_and_slide(hvel, Vector3.UP, false, 4, 900)
			rotate_mesh(-ground_normal)
	if Input.is_action_pressed("choose_item"):
		timer_item_choose += delta
		if timer_item_choose >= TIME_ITEM_CHOOSE:
			choosing_item = true
	else:
		choosing_item = false
		timer_item_choose = false
	equipment.visible = choosing_item
	if TimeManagement.time_slowed and is_on_floor():
		var fv = get_floor_velocity()
		velocity -= fv*(1-TimeManagement.slow_time_rate)
	

func _process(_delta):
	update_stamina()

func prepare_save():
	Global.game_state.current_coat = current_coat
	$ui/gameing/saveStats/AnimationPlayer.play("save_start")

func complete_save():
	$ui/gameing/saveStats/AnimationPlayer.queue("save_complete")

func update_inventory():
	for item in Global.game_state.inventory.keys():
		on_item_changed(item, 0, Global.count(item))
	for item in UPGRADE_ITEMS:
		on_item_changed(item, 0, Global.count(item))
	$ui/gameing/weapon/ammo_label.text = str(Global.count(current_weapon))

func get_target_ref():
	return global_transform.origin + (Vector3.UP*0.5 if is_crouching() else Vector3.UP*0.75)

func is_crouching():
	return state == State.Crouch or state == State.Roll or state == State.RollJump or state == State.RollFall or state == State.Climb 

func on_item_changed(item: String, change: int, count: int):
	if item in VISIBLE_ITEMS:
		var l_count: Label = get_node("ui/gameing/inventory/"+item+"_count")
		l_count.text = str(count)
		if change != 0:
			var added: Label = get_node("ui/gameing/inventory/"+item+"_added")
			added.text = "+ "+str(change) if change > 0 else "- "+str(abs(change))
			var anim = added.get_node("AnimationPlayer")
			anim.stop()
			anim.play("show")
		show_specific_item(item)
	elif item in WEAPONS:
		gun.add_weapon(item)
		gun.show_weapon()
		show_ammo()
	elif current_weapon == item:
		$ui/gameing/weapon/ammo_label.text = str(count)
		if current_weapon and !$ui/gameing/weapon.visible:
			show_ammo()
	else:
		match item:
			"health_up":
				var health_up := count
				var h_factor = (1.0 + HEALTH_UP_BOOST*health_up)
				max_health = DEFAULT_MAX_HEALTH*h_factor
				health_bar.max_value = max_health
				health_bar.rect_min_size.x = HEALTH_BAR_DEFAULT_SIZE*h_factor
			"stamina_up":
				var stamina_up := count
				var s_factor = (1.0 + STAMINA_UP_BOOST*stamina_up)
				max_stamina = DEFAULT_MAX_STAMINA*s_factor
				stamina_bar.max_value = max_stamina
				stamina_bar.rect_min_size.x = STAMINA_BAR_DEFAULT_SIZE*s_factor
			"stamina_recovery_up":
				stamina_factor = (1 + STAMINA_RECOVERY_BOOST*count)
			"jump_height_up":
				jump_factor = (1 + JUMP_UP_BOOST*count)
			"move_speed_up":
				speed_factor = (1 + SPEED_UP_BOOST*count)
			"move_speed_up":
				stamina_drain_factor = (1 + SPEED_STAMINA_BOOST*count)
			"damage_up":
				var damage_up_count := count
				damage_factor = (1 + DAMAGE_UP_BOOST*damage_up_count)
				max_damage = damage_up_count >= MAX_DAMAGE_UP
			"armor":
				var new_armor:int = count
				if new_armor > armor:
					extra_health += (new_armor - armor)*ARMOR_BOOST
				armor = new_armor
				armor_bar.rect_min_size.x = ARMOR_BAR_DEFAULT_SIZE*armor
				armor_bar.visible = armor > 0 and extra_health > 0
				update_health()
			"stamina_booster":
				var new_energy := count
				if new_energy > energy:
					extra_stamina = new_energy*EXTRA_STAMINA_BOOST
				energy = new_energy
				energy_bar.visible = energy > 0
			"hover_speed_up":
				hover_speed_factor = 1.0 + HOVER_SPEED_BOOST*count
			_:
				if ResourceLoader.exists(equipment_path_f % item):
					if count == 0 and item in equipment_inventory:
						var _x = equipment_inventory.erase(item)
					elif count > 0 and !(item in equipment_inventory):
						var s: Script = ResourceLoader.load(equipment_path_f % item)
						if s:
							equipment_inventory[item] = s.new()
							if equipped_item:
								equipped_item.unequip()
							equipped_item = equipment_inventory[item]
							equipped_item.equip()
							update_equipment()

func debug_show_inventory():
	var state_viewer: Control = $ui/gameing/debug/game_state
	for c in state_viewer.get_children():
		state_viewer.remove_child(c)
	add_label(state_viewer, "Inventory:")
	for i in Global.game_state.inventory:
		add_label(state_viewer, "\t%s: %d" % [i, Global.count(i)])

func is_dead():
	return state == State.Dead

func add_label(box: Control, text: String):
	var l := Label.new()
	l.text = text
	box.add_child(l)

func set_current_coat(coat: Coat, play_sound:= true):
	current_coat = coat
	mesh.show_coat(coat)
	if play_sound:
		mesh.play_pickup_sound("coat")

func update_health():
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.value = health
	armor_bar.max_value = armor*ARMOR_BOOST
	armor_bar.value = extra_health

func update_stamina():
	energy_bar.rect_min_size.x = extra_stamina*EXTRA_STAMINA_BAR_SIZE
	stamina_bar.max_value = max_stamina
	stamina_bar.value = stamina
func equip_previous():
	if equipment_inventory.size() == 1:
		return update_equipment()
	else:
		var index = equipment_inventory.values().find(equipped_item)
		equip(index - 1)

func equip_next():
	if equipment_inventory.size() == 1:
		return update_equipment()
	else:
		var index = equipment_inventory.values().find(equipped_item)
		equip(index + 1)

func equip(index):
	if equipment_inventory.size() == 0:
		return
	if equipped_item:
		equipped_item.unequip()
	var ln = equipment_inventory.size()
	while index < 0:
		index += ln
	while index >= ln:
		index -= ln
	equipped_item = equipment_inventory.values()[index]
	equipped_item.equip()
	update_equipment()

func update_equipment():
	var values = equipment_inventory.values()
	var index = values.find(equipped_item)
	if index >= 0:
		equipment.temp_show()
		var prev_index = index - 1
		var next_index = index + 1
		var ln = values.size()
		if prev_index < 0:
			prev_index += ln
		if next_index >= ln:
			next_index -= ln
		equipment.preview(values[index], values[prev_index], values[next_index])

func accel(delta: float, desired_velocity: Vector3, accel_normal: float = ACCEL, steer_accel: float = ACCEL, decel_factor: float = 1):
	$ui/gameing/debug/stats/a3.text = "DV: (%f, %f, %f)" % [
		desired_velocity.x,
		desired_velocity.y,
		desired_velocity.z
	]
	var gravity = GRAVITY
	if ground_normal != Vector3.ZERO:
		$ui/gameing/debug/stats/a4.text = "Gr: (%f, %f, %f)" % [
			ground_normal.x,
			ground_normal.y,
			ground_normal.z
		]
		var axis = Vector3.UP.cross(ground_normal).normalized()
		var angle = Vector3.UP.angle_to(ground_normal)
		if axis.is_normalized():
			desired_velocity = desired_velocity.rotated(axis, angle)
			if desired_velocity.y > ROLL_MAX_VELOCITY_V:
				desired_velocity.y = ROLL_MAX_VELOCITY_V
		gravity = GRAVITY.project(ground_normal)
	$ui/gameing/debug/stats/a5.text = "DV2: [%f, %f, %f]" % [
		desired_velocity.x,
		desired_velocity.y,
		desired_velocity.z
	]
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

func accel_climb(delta: float, desired_velocity: Vector3, wall_normal: Vector3):
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
	var charge_accel = ACCEL_CLIMB
	var charge: Vector3
	var steer: Vector3
	if velocity != Vector3.ZERO:
		charge = desired_velocity.project(velocity.normalized())
		steer = desired_velocity.slide(velocity.normalized())
		if (charge.dot(velocity) > 0 
			and charge.length() < velocity.length()
		):
			charge_accel = DECEL_CLIMB/speed_factor
		else:
			charge_accel = ACCEL_CLIMB
	else:
		charge = desired_velocity
		steer = Vector3.ZERO
	velocity += delta*(
		(charge - velocity)/SPEED_RUN*charge_accel 
		+ (steer*ACCEL_CLIMB) 
		+ gravity )
	velocity = move(velocity)

func accel_air(delta: float, desired_velocity: Vector3, accel: float, gravity := GRAVITY):
	var hvel := Vector3(velocity.x, 0, velocity.z).move_toward(desired_velocity, accel*delta)
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

func accel_low_gravity(delta, desired_velocity, gravity_factor):
	var hvel := Vector3(velocity.x, 0, velocity.z).move_toward(desired_velocity, ACCEL*delta)
	velocity.x = hvel.x
	velocity.z = hvel.z
	velocity += gravity_factor*GRAVITY*delta
	var pre_slide_vel := velocity
	velocity = move(velocity)
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
	velocity = move(velocity + delta*GRAVITY)

func accel_lunge(delta, desired_velocity, decel := DECEL_KICK):
	var hvel = velocity
	hvel.y = 0
	desired_velocity.y = 0
	hvel = hvel.move_toward(desired_velocity, STEER_KICK*delta)
	var v2 := move(velocity + GRAVITY*delta, true)
	velocity = v2.move_toward(Vector3.ZERO, decel*delta)
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

func can_flinch():
	return !( state == State.DiveWindup
		or state == State.DiveStart
		or state == State.UppercutWindup)

func takes_damage():
	return not (
		state == State.Locked
		or state == State.Damaged
		or ( timer_state < TIME_SPIN_INVINCIBILITY
			and ( state == State.SpinKick
				or state == State.AirSpinKick))
		or (timer_state < TIME_LUNGE_INVINCIBILITY
			and state == State.LungeKick)
		or (timer_state < TIME_ROLL_INVINCIBILITY
			and state == State.Roll)
		# These moves suck so just give em i-frames during windup lol
		or state == State.UppercutWindup
		or state == State.DiveWindup)

func should_hover() -> bool:
	return Input.is_action_just_pressed("hover_toggle") and Global.count("hover_scooter")

func can_ledge_grab() -> bool:
	if crouch_head.get_overlapping_bodies().size() > 0:
		return false
	if ledgeCastCeiling.is_colliding():
		return false
	
	var left:bool = (
		ledgeCastLeft.is_colliding()
		and ledgeCastLeft.get_collision_normal().y > MIN_DOT_LEDGE)
	
	var right:bool = (
		ledgeCastRight.is_colliding()
		and ledgeCastRight.get_collision_normal().y > MIN_DOT_LEDGE)
	var center:bool = (
		ledgeCastCenter.is_colliding()
		and ledgeCastCenter.get_collision_normal().y > MIN_DOT_LEDGE)
	# debug
	if false:
		if !ledgeCastCenter.is_colliding():
			$jackie/debug_center.material_override.albedo_color = Color.red
		elif ledgeCastCenter.get_collision_normal().y <= MIN_DOT_LEDGE:
			$jackie/debug_center.material_override.albedo_color = Color.orange
		else:
			$jackie/debug_center.material_override.albedo_color = Color.green
		if !ledgeCastLeft.is_colliding():
			$jackie/debug_left.material_override.albedo_color = Color.red
		elif ledgeCastLeft.get_collision_normal().y <= MIN_DOT_LEDGE:
			$jackie/debug_left.material_override.albedo_color = Color.orange
		else:
			$jackie/debug_left.material_override.albedo_color = Color.green
		if !ledgeCastRight.is_colliding():
			$jackie/debug_right.material_override.albedo_color = Color.red
		elif ledgeCastRight.get_collision_normal().y <= MIN_DOT_LEDGE:
			$jackie/debug_right.material_override.albedo_color = Color.orange
		else:
			$jackie/debug_right.material_override.albedo_color = Color.green
	
	return center and (left or right)

func snap_to_ledge():
	var change = ledgeCastCenter.get_collision_point() - ledgeRef.global_transform.origin
	global_translate(change)

func should_slow_follow():
	return state == State.LungeKick or state == State.RollJump

func get_visual_forward():
	return mesh.global_transform.basis.z

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
		node.take_damage(damage_factor*damage, dir, self)

func move(p_vel: Vector3, grounded:= false) -> Vector3:
	#global_translate(p_vel.slide(Vector3.UP))
	#return Vector3.ZERO
	if grounded:
		return move_and_slide_with_snap(p_vel,
			Vector3.DOWN*0.06125,
			Vector3.UP,
			true, 4, MIN_DOT_GROUND, 
			INFINITE_INERTIA)
	else:
		return move_and_slide(p_vel, Vector3.UP, false, 4, 900, INFINITE_INERTIA)

# Returns true if dead
func take_damage(damage: int, direction: Vector3, _source) -> bool:
	if !takes_damage():
		return false
	
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
	update_health()
	if health <= 0:
		die()
		return true
	velocity = VEL_DAMAGED_H*direction
	print("damage: ", velocity)
	if can_flinch():
		set_state(State.Damaged)
	return false

func die():
	emit_signal("died")
	set_state(State.Dead)
	var _x = Global.add_stat("player_death")
	# TODO : Animation here
	respawn()

func fall_to_death():
	set_state(State.FallingDeath)

func respawn():
	if game_ui.in_game:
		game_ui.cancel_game()
	cam_rig.reset()
	set_state(State.Ground)
	velocity = Vector3.ZERO
	$fade/AnimationPlayer.play("fadein")
	heal()
	global_transform.origin = Global.game_state.checkpoint_position

func teleport_to(t: Transform):
	$fade/AnimationPlayer.play("fadein")
	global_transform.origin = t.origin

func heal():
	mesh.start_heal_particle()
	health = max_health
	stamina = max_stamina
	extra_stamina = energy*EXTRA_STAMINA_BOOST
	extra_health = armor*ARMOR_BOOST
	update_health()

func drain_stamina(amount):
	var diff = stamina - amount/stamina_drain_factor
	if diff < 0:
		extra_stamina += diff
		extra_stamina = max(extra_stamina, 0)
		var new_energy = int(ceil(extra_stamina/EXTRA_STAMINA_BOOST))
		var _x = Global.add_item("stamina_booster", new_energy-energy)
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
	Global.place_flag(f, $jackie/flag_ref.global_transform)
	Global.save_checkpoint(global_transform.origin)

func can_talk():
	return state == State.Ground

func get_dialog_viewer() -> Node:
	return $ui/dialog_viewer

func start_dialog(source: Node, sequence: Resource, speaker: Node, starting_label := ""):
	if game_ui.in_game:
		return
	ui.start_dialog(source, sequence, speaker, starting_label)
	# TODO: replace with a tween
	cam_rig.start_dialog()
	lock()

func _on_dialog_exited():
	ui.play_game()
	cam_rig.end_dialog()
	unlock()

func _on_dialog_event(id: String, _source: Node):
	print("Dialog: ", id)
	match id:
		"unlock_player":
			cam_rig.start_dialog()
			unlock()
		"lock_player":
			cam_rig.end_dialog()
			lock()

func wardrobe_lock():
	lock()
	cam_rig.start_wardrobe()

func wardrobe_unlock():
	unlock()
	cam_rig.end_wardrobe()

func lock():
	set_process_input(false)
	set_state(State.Locked)
	$ui/gameing/stats.hide()
	$ui/gameing/inventory/vis_timer.stop()
	$ui/gameing/inventory.hide()

func unlock():
	set_process_input(true)
	$unlock_timer.start()
	$ui/gameing/stats.show()

func is_locked() -> bool:
	return state == State.Locked

func _on_unlock_timer_timeout():
	set_state(State.Ground)

func is_roll_jumping():
	return state == State.RollJump or state == State.RollFall or state == State.WaveJumpRoll

func wave_jump_roll():
	set_state(State.WaveJumpRoll)

func gravity_stun(dam):
	var dead = take_damage(dam, Vector3.ZERO, self)
	if !dead:
		set_state(State.GravityStun)

func show_prompt(textures: Array, text: String):
	print("Show prompt: ", text)
	$ui/gameing/tutorial/prompt_timer.stop()
	if textures.size() >= 1:
		$ui/gameing/tutorial/TextureRect1.show()
		$ui/gameing/tutorial/TextureRect1.texture = textures[0]
	else:
		$ui/gameing/tutorial/TextureRect1.hide()
	if textures.size() >= 2:
		$ui/gameing/tutorial/plus.show()
		$ui/gameing/tutorial/TextureRect2.show()
		$ui/gameing/tutorial/TextureRect2.texture = textures[1]
	else:
		$ui/gameing/tutorial/plus.hide()
		$ui/gameing/tutorial/TextureRect2.hide()

	$ui/gameing/tutorial/Label.text = text
	$ui/gameing/tutorial.show()
	$ui/gameing/tutorial/prompt_timer.start()

func _on_prompt_timer_timeout():
	print("Hid prompt: ", $ui/gameing/tutorial/Label.text)
	$ui/gameing/tutorial.hide()

func celebrate(item: Spatial):
	held_item = item
	set_state(State.GetItem)

func get_item(id):
	if id == "capacitor":
		celebrate(capacitor.instance())
	mesh.play_pickup_sound(id)

func show_inventory():
	for g in $ui/gameing/inventory.get_children():
		if g is CanvasItem:
			g.visible = true
	$ui/gameing/inventory.show()
	$ui/gameing/inventory/vis_timer.start()
	equipment.temp_show()

func show_specific_item(item):
	if !$ui/gameing/inventory.visible:
		for g in $ui/gameing/inventory.get_children():
			if g is CanvasItem:
				g.visible = false
		$ui/gameing/inventory.show()
	$ui/gameing/inventory/vis_timer.start()
	var count = get_node("ui/gameing/inventory/"+item+"_count")
	var icon = get_node("ui/gameing/inventory/"+item+"_icon")
	var added = get_node("ui/gameing/inventory/"+item+"_added")
	if !icon or !count or !added:
		print_debug("BUG: no inventory for ", item)
		return
	added.show()
	icon.show()
	count.show()

func _on_vis_timer_timeout():
	$ui/gameing/inventory.hide()

func track_weapon(weapon: String):
	$ui/gameing/weapon/ArrowUp.visible = gun.enabled_wep["wep_pistol"]
	$ui/gameing/weapon/ArrowDown.visible = gun.enabled_wep["wep_wave_shot"]
	$ui/gameing/weapon/ArrowLeft.visible = gun.enabled_wep["wep_grav_gun"]
	$ui/gameing/weapon/ArrowRight.visible = gun.enabled_wep["wep_time_gun"]
	current_weapon = weapon
	$ui/gameing/weapon.icon = weapon
	if gun.current_weapon:
		$ui/gameing/weapon/ammo_label.visible = !gun.current_weapon.infinite_ammo
		$ui/gameing/weapon/ammo_label.text = str(Global.count(weapon))

func show_ammo():
	$ui/gameing/weapon.show()

func hide_ammo():
	$ui/gameing/weapon.hide()

func shake_camera():
	if cam_rig.aiming:
		$camera_rig/cam_shake.play("shot_shake")

func set_state(next_state: int):
	if state == next_state:
		return
	timer_coyote = 0.0
	timer_state = 0.0
	timer_leave_ledge = 0
	sit_timer = 0
	mesh.stop_particles()
	var head_blocked = crouch_head.get_overlapping_bodies().size() > 0
	$crouching_col.disabled = !head_blocked
	$standing_col.disabled = head_blocked
	gun.unlock()
	
	# Exit effects
	match state: 
		State.PlaceFlag:
			place_flag()
		State.GetItem:
			mesh.release_item()
		State.Hover:
			mesh.stop_hover()
		State.LungeKick, State.SlideLungeKick, State.DiveEnd:
			gun.end_combo()

	# Entry effects
	match next_state:
		State.Ground:
			can_wall_cling = true
			dash_charges = Global.count("dash_charge")
			stamina_recharges = true
			mesh.ground_transition("Walk")
		State.Fall, State.LedgeFall:
			mesh.transition_to("Fall")
		State.BaseJump:
			can_wall_cling = true
			emit_signal("jumped")
			velocity.y = jump_factor*JUMP_VEL_BASE
			mesh.play_jump()
		State.HighJump:
			can_wall_cling = true
			emit_signal("jumped")
			velocity.y = jump_factor*JUMP_VEL_HIGH
			mesh.play_crouch_jump()
		State.WallJump:
			can_wall_cling = true
			emit_signal("jumped")
			mesh.play_jump()
		State.LedgeJump:
			can_wall_cling = true
			emit_signal("jumped")
			velocity.y += jump_factor*JUMP_VEL_LEDGE
			mesh.play_ledge_jump()
		State.CrouchJump:
			can_wall_cling = true
			emit_signal("jumped")
			$crouching_col.disabled = false
			$standing_col.disabled = true
			velocity.y = jump_factor*JUMP_VEL_CROUCH
			mesh.play_crouch_jump()
		State.RollJump:
			can_wall_cling = true
			damaged_objects = []
			emit_signal("jumped")
			$crouching_col.disabled = false
			$standing_col.disabled = true
			var dir = mesh.global_transform.basis.z
			velocity = speed_factor*dir*JUMP_VEL_ROLL_FORWARD
			velocity.y = jump_factor*JUMP_VEL_ROLL
			mesh.play_roll_jump(max_damage)
			gun.lock()
		State.Slide:
			mesh.ground_transition("Slide")
		State.Crouch:
			stamina_recharges = true
			$crouching_col.disabled = false
			$standing_col.disabled = true
			mesh.ground_transition("Crouch")
			can_air_spin = true
		State.Climb:
			stamina_recharges = false
			$crouching_col.disabled = false
			$standing_col.disabled = true
			mesh.ground_transition("Climb")
			can_air_spin = true
			stamina -= STAMINA_DRAIN_CLIMB_START
			gun.lock()
		State.LedgeHang:
			can_wall_cling = true
			stamina_recharges = false
			mesh.play_ledge_grab()
			snap_to_ledge()
			ledge = ledgeCastCenter.get_collider()
			ledge_last_transform = ledge.global_transform
			ledge_local_position = ledge.global_transform.xform_inv(global_transform.origin)
			velocity = Vector3.ZERO
			can_air_spin = true
			gun.lock()
		State.Roll:
			$crouching_col.disabled = false
			$standing_col.disabled = true
			mesh.play_roll()
			gun.lock()
		State.RollFall:
			gun.lock()
		State.BonkFall:
			can_wall_cling = false
			mesh.transition_to("Fall")
			var dir = ground_normal
			dir.y = 0.1
			dir = dir.normalized()
			velocity = speed_factor*dir*SPEED_BONK
		State.LungeKick, State.SlideLungeKick:
			damaged_objects = []
			var dir = get_visual_forward()
			velocity = dir*SPEED_LUNGE
			mesh.play_lunge_kick(max_damage)
			can_slide_lunge = false
			gun.lock()
		State.SpinKick, State.AirSpinKick:
			damaged_objects = []
			velocity.y = jump_factor*VEL_AIR_SPIN
			$jackie/attack_spin/AnimationPlayer.play("spin")
			mesh.play_spin_kick(max_damage)
			can_air_spin = false
			gun.aim_lock()
		State.UppercutWindup:
			mesh.transition_to("Uppercut")
			gun.lock()
		State.Uppercut:
			emit_signal("jumped")
			damaged_objects = []
			velocity.y = damage_factor*VEL_UPPERCUT
			mesh.play_uppercut(max_damage)
			gun.lock()
		State.DiveWindup:
			velocity.y = VEL_DIVE_WINDUP
			mesh.play_dive_windup(max_damage)
			gun.lock()
		State.DiveStart:
			damaged_objects = []
			mesh.play_dive_start(max_damage)
			gun.lock()
		State.DiveEnd:
			mesh.play_dive_end(max_damage)
		State.Damaged:
			velocity.y = max(velocity.y, speed_factor*VEL_DAMAGED_V)
			mesh.force_play("Damaged")
		State.Locked:
			mesh.ground_transition("Walk")
			velocity = Vector3.ZERO
			gun.disable()
		State.PlaceFlag:
			mesh.transition_to("PlaceFlag")
			velocity = Vector3.ZERO
			gun.aim_lock()
			mesh.hold_item(flag.instance())
			time_animation = TIME_PLACE_FLAG
		State.GetItem:
			mesh.transition_to("GetItem")
			velocity = Vector3.ZERO
			gun.aim_lock()
			if held_item:
				mesh.hold_item(held_item)
			time_animation = TIME_GET_ITEM
		State.FallingDeath:
			mesh.transition_to("Fall")
			cam_rig.lock_follow()
		State.GravityStun:
			velocity.y = 4
			mesh.transition_to("Damaged")
		State.Hover:
			hover_cast.enabled = true
			mesh.start_hover()
		State.Sitting:
			velocity = Vector3.ZERO
			mesh.play_sit()
		State.Dash:
			can_wall_cling = true
			dash_charges -= 1
			velocity += get_visual_forward()*SPEED_DASH
			velocity.y =  SPEED_DASH_V
			mesh.force_play("Dash")
		State.WallCling:
			can_wall_cling = false
			stamina_recharges = false
			$crouching_col.disabled = false
			$standing_col.disabled = true
			mesh.transition_to("WallCling")
			velocity.y = 0
	state = next_state
	$ui/gameing/debug/stats/a1.text = "State: %s" % State.keys()[state]
