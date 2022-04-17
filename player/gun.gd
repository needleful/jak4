extends Spatial
class_name Gun

onready var laser := $reference/laser
onready var laser_geometry := $reference/laser_geometry
onready var laser_end := $reference/laser/laser_end
onready var base_ref := $base_reference
onready var ref := $reference
onready var ik_target := $gun_ik/target

const MASK_ATTACK := 0x1 + 0x4

enum State {
	NoWeapon,
	Hidden,
	Free,
	Locked,
	AimLocked,
	Firing,
	DelayedFire,
}

var state:int = State.NoWeapon
var aim_toggle := false

var state_timer := 0.0
var time_since_fired := 0.0

var time_firing := 0.1
const TIME_HIDE := 10.0
const DELAY_HIDDEN_FIRE := 0.1

onready var gun_ik := $"../gun_ik"

var weapon1: PackedScene
var current_weapon : Spatial
var state_before_fire:= state

var holder: Spatial
var camera: Spatial

const lockon_weight_distance := 0.3
const lockon_weight_angle := 4.5

const lockon_max_dist_sq := 900.0
const lockon_max_angle_rad := PI/2.0

var timer_cant_lock_on := 0.0
const TIME_QUIT_LOCK_ON := 0.25

var target: Node

func _ready():
	var w = load("res://player/weapons/pistol.tscn")
	if w is PackedScene:
		weapon1 = w
		call_deferred("set_current_weapon", weapon1)
		call_deferred("set_state", State.Hidden, true)
	else:
		call_deferred("set_state", State.NoWeapon, true)

func _input(event):
	if event.is_action_pressed("combat_shoot"):
		if can_fire():
			fire()
	elif event.is_action_pressed("combat_aim_toggle"):
		if !visible:
			time_since_fired = 0
			enable()
		aim_toggle = !aim_toggle

func set_current_weapon(weapon: PackedScene):
	current_weapon = weapon.instance()
	ref.add_child(current_weapon)
	holder.track_weapon(current_weapon.name)

func update_laser():
	var l = laser.get_hit_length()
	if l < laser.spring_length:
		laser_end.show()
		var normal = laser.get_hit_normal()
		var y = laser_end.global_transform.basis.y
		var m_axis = y.cross(normal).normalized()
		if m_axis.is_normalized():
			var m_angle = y.angle_to(normal)
			laser_end.global_rotate(m_axis, m_angle)
	else:
		laser_end.hide()
	laser_geometry.clear()
	laser_geometry.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	laser_geometry.add_vertex(Vector3(0.012, 0.01, 0.0))
	laser_geometry.add_vertex(Vector3(0.01, 0.01, l))
	laser_geometry.add_vertex(Vector3(0.012, -0.01, 0.0))
	laser_geometry.add_vertex(Vector3(0.01, -0.01, l))
	laser_geometry.add_vertex(Vector3(-0.012, 0.01, 0.0))
	laser_geometry.add_vertex(Vector3(-0.01, 0.01, l))
	laser_geometry.end()

func _process(delta):
	var current_dir: Vector3 = holder.get_desired_aim()
	var target_dir : Vector3
	var aiming: bool = aim_toggle or Input.is_action_pressed("combat_aim")
	var locked_aim := false
	var lock_on := true
	
	state_timer += delta
	if !aiming:
		time_since_fired += delta
		if time_since_fired > TIME_HIDE:
			disable()
	match state:
		State.Firing:
			if state_timer > time_firing:
				set_state(state_before_fire)
		State.AimLocked:
			locked_aim = true
		State.Locked:
			locked_aim = true
			lock_on = false
		State.DelayedFire:
			if state_timer > DELAY_HIDDEN_FIRE:
				fire()
	
	if locked_aim:
		current_dir = holder.get_normal_gun_orientation()
	
	if aiming and !locked_aim:
		target_dir = -camera.global_transform.basis.z
		ik_target.global_transform.origin = base_ref.global_transform.origin + target_dir*100.0
	elif lock_on:
		var space: RID = get_world().space
		var ds := PhysicsServer.space_get_direct_state(space)
		var cast_start: Vector3 = base_ref.global_transform.origin
		
		var best_target : Spatial
		# Lowest score wins
		var best_score : float = INF
		for g in get_tree().get_nodes_in_group("target"):
			if !(g is Spatial):
				continue
			var dir: Vector3 = (g.global_transform.origin
				- holder.global_transform.origin)
			if dir.length_squared() > lockon_max_dist_sq:
				continue
			else:
				var hdir := dir
				hdir.y = 0
				var htdir := current_dir
				htdir.y = 0
				if abs(hdir.angle_to(htdir)) > lockon_max_angle_rad:
					continue
			var angle := current_dir.angle_to(dir)
			var dist := dir.length()
			var score: float = lockon_weight_distance*dist + lockon_weight_angle*abs(angle)
			if score < best_score:
				var col := ds.intersect_ray(cast_start, g.global_transform.origin, [], MASK_ATTACK)
				if col and "collider" in col and col.collider == g:
					best_target = g
					best_score = score
					timer_cant_lock_on = 0
				elif target == g:
					timer_cant_lock_on += delta
					if timer_cant_lock_on < TIME_QUIT_LOCK_ON:
						best_target = g
						best_score = score
		target = best_target
		if target:
			target_dir = (target.global_transform.origin - base_ref.global_transform.origin)
			ik_target.global_transform.origin = target.global_transform.origin
		else:
			target_dir = current_dir
			ik_target.global_transform.origin = base_ref.global_transform.origin + target_dir*100.0
	# Aiming:
	if locked_aim:
		holder.aim_gun(Vector2.ZERO, aiming)
	else:
		var y_cur: Vector3 = holder.global_transform.basis.z
		var y_tar: Vector3 = target_dir.slide(holder.global_transform.basis.y)
		var y_axis: Vector3 = y_cur.cross(y_tar).normalized()
		var y_angle: float = y_cur.angle_to(y_tar)
		
		var aim := Vector2(
			-y_angle/(PI/2)*sign(holder.global_transform.basis.y.dot(y_axis)),
			target_dir.normalized().y
		)
			
		holder.aim_gun(aim, aiming)
	if laser.visible:
		update_laser()

func fire():
	if state == State.Hidden:
		set_state(State.DelayedFire)
	else:
		set_state(State.Firing)

func fire_test_orb():
	var orb = load("res://entities/enemies/projectile.tscn").instance()
	get_tree().current_scene.add_child(orb)
	orb.damage = 10
	orb.speed = 30
	orb.global_transform.origin = ref.global_transform.origin
	orb.velocity = ref.global_transform.basis.z*orb.speed

func can_fire():
	if !current_weapon:
		return false
	return ( state != State.Firing
		and state != State.NoWeapon
		and state != State.Locked)

func lock():
	if visible:
		set_state(State.Locked)

func aim_lock():
	if visible:
		set_state(State.AimLocked)

func unlock():
	if visible:
		set_state(State.Free)

func enable():
	if current_weapon:
		set_state(State.Free)

func disable():
	if current_weapon:
		set_state(State.Hidden)

func set_state(new_state, force := false):
	if !force and new_state == state:
		return
	state_timer = 0.0
	set_process(true)
	set_process_input(true)
	laser.visible = true
	laser_geometry.visible = true
	match new_state:
		State.NoWeapon:
			set_process(false)
			set_process_input(false)
			visible = false
			holder.blend_gun(0.0)
			holder.hold_gun(0.0)
			gun_ik.stop()
		State.Hidden:
			set_process(false)
			visible = false
			holder.blend_gun(0.0)
			holder.hold_gun(0.0)
			gun_ik.stop()
			aim_toggle = false
		State.Free:
			visible = true
			holder.hold_gun(1.0)
			holder.blend_gun(1.0)
			gun_ik.interpolation = 1.0
			gun_ik.start()
		State.DelayedFire:
			visible = true
			holder.blend_gun(1.0)
			holder.hold_gun(1.0)
			gun_ik.interpolation = 1.0
			gun_ik.start()
			time_since_fired = 0
		State.Locked:
			visible = true
			laser.visible = false
			laser_geometry.visible = false
			gun_ik.interpolation = 0
			holder.blend_gun(0.0)
			holder.hold_gun(1.0)
			gun_ik.stop()
		State.AimLocked:
			visible = true
			holder.blend_gun(0.7)
			holder.hold_gun(1.0)
			gun_ik.start()
		State.Firing:
			if current_weapon.fire():
				holder.play_fire()
				holder.blend_gun(1.0)
				gun_ik.interpolation = 0.2
				gun_ik.start()
				laser.visible = false
				laser_geometry.visible = false
				visible = true
				holder.hold_gun(1.0)
			time_firing = current_weapon.time_firing
			time_since_fired = 0
			if state == State.DelayedFire:
				state_before_fire = State.Free
			else:
				state_before_fire = state
	state = new_state
