extends KinematicBody

enum AIState {
	Inactive,
	Stalk,
	Chase,
	MoveWindup,
	MoveActive,
	MoveEnd,
}

enum MoveState {
	Locked,
	Ground,
	JumpCharge,
	Jumping,
	Air
}

# Assumed true for now
export(AIState) var ai_state = AIState.Inactive
var move_state = MoveState.Locked

onready var nav := $NavigationAgent
onready var debug_path := $Node/ImmediateGeometry
onready var body:Spatial = $body

var player: PlayerBody
var player_last_origin := Vector3.ZERO

const GRAVITY := Vector3.DOWN*24.0
var velocity := Vector3.ZERO
const ACCEL_GROUND := 20.0
var orb := load("res://entities/projectile.tscn")
var damaged_objects := []

var M_AOE := {
	"damage": 15,
	"min_range": 0,
	"max_range": 4,
	"min_angle":-PI,
	"max_angle": PI,
	"cooldown": 1.0,
	"move_speed": 1.0,
	"grounded":true,
	"name": "Swipe",
	"anim": "Swipe",
}

var M_DASH := {
	"damage":10,
	"min_range":3,
	"max_range":10,
	"min_angle":-PI/8.0,
	"max_angle":PI/8.0,
	"cooldown":1.3,
	"move_speed":7.0,
	"accel":60.0,
	"grounded":true,
	"name":"Dash",
	"anim":"Dash"
}

var M_FIRE := {
	"damage":5,
	"min_range":3,
	"max_range":15,
	"min_angle":-PI,
	"max_angle":PI,
	"cooldown":0.5,
	"move_speed":1.0,
	"name":"Fire_Slow",
	"anim":"Fire_slow"
}

var M_DIVE := {
	"damage": 7,
	"min_range": 0.0,
	"max_range": 6.0,
	"min_angle":-PI/2,
	"max_angle":PI/2,
	"cooldown":0.5,
	"move_speed":1.0,
	"name":"Dive",
	"anim":"Dive"
}

var moves := [
	M_AOE,
	M_DASH,
	M_FIRE,
	M_DIVE
]

var cooldown := 3.0
var current_move


func _ready():
	var p = Global.get_player()
	if p is PlayerBody:
		player = p
		player_last_origin = player.global_transform.origin
		var _x = calculate_path(player_last_origin)

func _physics_process(delta):
	if !player:
		print_debug("Where's the player?")
		return
	
	match ai_state:
		AIState.Chase:
			chase(delta)
		AIState.MoveWindup:
			if is_on_floor():
				ground_move(delta, Vector3.ZERO)
			else:
				air_move(delta, Vector3.ZERO)
			var loc := player.global_transform.origin
			var dir := (loc - global_transform.origin).normalized()
			rotate_toward(dir, delta)
		AIState.MoveActive:
			var loc := player.global_transform.origin
			var dir := (loc - global_transform.origin).normalized()
			var fixed_path:bool = "fixed_path" in current_move and current_move.fixed_path
			if fixed_path:
				# TODO replace with proper vector once modeled
				dir = -body.global_transform.basis.y
			if is_on_floor():
				var accel: float
				if "accel" in current_move:
					accel = current_move.accel
				else:
					accel = ACCEL_GROUND
				ground_move(delta, dir*current_move.move_speed, accel)
			else:
				air_move(delta, dir*current_move.move_speed)
			if !fixed_path:
				rotate_toward(dir, delta)
			

func chase(delta):
	var loc = player.global_transform.origin
	var next_pos : Vector3
	if (loc - player_last_origin).length() > 2.0:
		next_pos = calculate_path(loc)
	else:
		next_pos = nav.get_next_location()
	var dir := (next_pos - global_transform.origin).normalized()
	var final_pos:Vector3 = nav.get_final_location()
	var final_diff := final_pos - global_transform.origin
	
	if move_state == MoveState.JumpCharge:
		velocity.y = get_jump_velocity(player.global_transform.origin - global_transform.origin)
		move_state = MoveState.Jumping
	elif move_state == MoveState.Jumping:
		dir = (player.global_transform.origin - global_transform.origin).normalized()
		air_move(delta, dir*2, 12.0)
		if is_on_floor():
			move_state = MoveState.Ground
			var _x = calculate_path(loc)
	else:
		cooldown -= delta
		if cooldown <= 0.0:
			var move = plot_attack()
			if move:
				current_move = move
				$attack_anim.play(move.anim)
				ai_state = AIState.MoveWindup
				
		if final_diff.length() < 2:
			dir = Vector3.ZERO
			if !nav.is_target_reachable() and player.is_grounded():
				move_state = MoveState.JumpCharge
		if is_on_floor():
			ground_move(delta, dir)
		else:
			air_move(delta, dir)
	rotate_toward(dir, delta)

func plot_attack():
	var diff = player.global_transform.origin - global_transform.origin
	var dist = diff.length()
	var angle = global_transform.basis.z
	var best_move = null
	for m in moves:
		if "grounded" in m and is_on_floor() != m.grounded:
			continue
		if dist > m.max_range or dist < m.min_range:
			continue
		if best_move and best_move.damage > m.damage:
			continue
		best_move = m
		
	return best_move

func end_windup():
	ai_state = AIState.MoveActive

func end_move():
	ai_state = AIState.Chase
	cooldown = current_move.cooldown
	$attack_anim.queue("RESET")
	damaged_objects = []

func get_jump_velocity(difference: Vector3) -> float:
	var a := abs(GRAVITY.y)
	var p := max(difference.y, 0.0) + 2.0

	# Air time at peak = v0/a
	# Height at a point in time = 0.5at^2 + v0t
	# Height at peak = 1.5*(v0^2/a)
	# Velocity to reach peak p = sqrt(2/3ap)
	var v0 := sqrt(2 * a * p)
	return v0

func ground_move(delta: float, dir: Vector3, accel:float = ACCEL_GROUND):
	var gravity: Vector3
	if GRAVITY.dot(get_floor_normal()) >= 0:
		gravity = Vector3.ZERO
	else:
		gravity = GRAVITY.project(get_floor_normal())
	var movement := 4.0*dir
	var vy := velocity.y
	velocity.y = 0
	velocity = velocity.move_toward(movement, accel*delta)
	velocity.y += vy
	velocity += delta*gravity
	velocity = move_and_slide(
		velocity, 
		#Vector3.DOWN*0.25,
		Vector3.UP, false, 4, 0.5*PI)

func air_move(delta:float, dir: Vector3, accel_scale := 1.0):
	dir.y = 0
	var movement := 4.0*dir
	var vy := velocity.y
	velocity.y = 0
	velocity = velocity.move_toward(movement, accel_scale*5.0*delta)
	velocity.y = vy
	velocity += delta*GRAVITY
	velocity = move_and_slide(velocity, Vector3.UP, false, 4, 1.7)

func rotate_toward(dir:Vector3, delta:float):
	# TODO: change forward when we get a real mesh
	var forward := -body.global_transform.basis.y
	dir.y = 0
	var angle := forward.angle_to(dir)
	if abs(angle) > 0.01:
		var axis := forward.cross(dir).normalized()
		if !axis.normalized():
			axis = Vector3.UP
		var rot := sign(angle)*min(abs(angle), delta*10.0)
		body.global_rotate(axis, rot)
	

func calculate_path(loc: Vector3) -> Vector3:
	nav.set_target_location(loc)
	player_last_origin = loc
	var next = nav.get_next_location()
	
	if true:
		debug_path.clear()
		debug_path.begin(Mesh.PRIMITIVE_LINE_STRIP)
		for c in nav.get_nav_path():
			debug_path.add_vertex(c)
		debug_path.end()
	return next

func fire(id: int = -1):
	if id < 0:
		for c in $body/guns.get_children():
			fire_from(c.global_transform)

func fire_from(point: Transform):
	var proj
	if ObjectPool.has("orb"):
		proj = ObjectPool.get("orb")
	else:
		proj = orb.instance()
	
	get_tree().current_scene.add_child(proj)
	proj.source = self
	proj.damage = current_move.damage
	proj.speed = 2.0
	proj.turn_speed = 8.0
	proj.global_transform.origin = point.origin
	proj.fire(player, Vector3.UP*0.5, 20.0)
	proj.velocity = 6.0*point.basis.z

func _on_hitbox_entered(body):
	if body in damaged_objects:
		return
	if current_move and body.has_method("take_damage"):
		var dir = (body.global_transform.origin - global_transform.origin).normalized()
		body.take_damage(current_move.damage, dir, self)
		damaged_objects.append(body)
