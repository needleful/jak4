extends RigidBody
class_name EnemyBody

signal died(id, fullPath)

enum Rarity {
	Common,
	Uncommon,
	Rare,
	SuperRare,
	Sublime
}

export(String) var id
export(bool) var respawns := true
export(bool) var drops_coat := false
export(float, 0.0, 1.0) var drops_ammo := 0.3
export(Rarity) var minimum_rarity = Rarity.Common
export(Rarity) var maximum_rarity = Rarity.Rare
export(int) var gem_drop_max = 5
export(int) var health = 15
export(int) var attack_damage = 10
export(bool) var shielded := false setget set_shielded

const GRAV_DECAY := 1.0
const projectile: PackedScene = preload("res://entities/projectile.tscn")

var damaged_speed := 0.5
var gravity_stun_speed := 0.5
var square_distance_activation := 2400.0

enum AI {
	Idle,
	Alerted,
	Chasing,
	Windup,
	Attacking,
	Damaged,
	GravityStun,
	Dead,
	Flee,
	GravityStunDead
}
var ai = AI.Idle


var coat_scene:PackedScene = load("res://items/coat_pickup.tscn")
var gem_scene:PackedScene = load("res://items/gem_pickup.tscn")

var target: Spatial
var damaged:= []

var in_range := false
var coat: Coat = null
var can_fly := false

var source_chunk : MeshInstance
var nomad := false

var min_dot_shielded_damage := -0.5
var last_attacker: Node
var best_floor_normal : Vector3
var contact_count := 0

# Ammo drop logic
const ammo_path_f := "res://items/ammo/%s_pickup.tscn"
const WEIGHTS := {
	"pistol": 1.12,
	"wave_shot": 1.07,
	"grav_gun": 1.0
}
const IDEAL_COUNT := {
	"pistol": 100.0,
	"wave_shot":70.0,
	"grav_gun": 25.0
}
const COUNTS := {
	"pistol": 10,
	"wave_shot":7,
	"grav_gun": 5
}

func _init():
	contact_monitor = true
	contacts_reported = 4

func _ready():
	sleeping = false
	call_deferred("set_state", ai)
	if !respawns and Global.is_picked(get_path()):
		ai = AI.Dead
		emit_signal("died", id, get_path())
		queue_free()
		return
	if drops_coat:
		coat = Coat.new(true, minimum_rarity, maximum_rarity)
	set_shielded(shielded)
	var p = get_parent()
	while p:
		if p is MeshInstance and p.name.begins_with("chunk"):
			source_chunk = p
			set_process(true)
			break
		p = p.get_parent()
	if !source_chunk:
		set_process(false)

func _process(_delta):
	var aabb := source_chunk.get_aabb()
	if !aabb.has_point(global_transform.origin - source_chunk.global_transform.origin):
		nomad = true
		var gt = global_transform
		var scene = get_tree().current_scene
		get_parent().remove_child(self)
		scene.add_child(self)
		global_transform = gt
		set_process(false)

func _integrate_forces(state):
	best_floor_normal = Vector3(0, -INF, 0)
	contact_count = state.get_contact_count()
	for i in range(contact_count):
		var n:Vector3 = state.get_contact_local_normal(i)
		if n.y > best_floor_normal.y:
			best_floor_normal = n

func set_active(_active: bool):
	pass

func process_player_distance(pos: Vector3) -> float:
	var lensq := (pos - global_transform.origin).length_squared()
	var within_activation := lensq <= square_distance_activation
	if within_activation != in_range:
		in_range = within_activation
		if nomad and !in_range and ai != AI.Chasing:
			queue_free()
		set_active(in_range and ai != AI.Dead)
	return lensq

func damage_direction(hitbox: Area, dir: Vector3, damage := -1.0):
	if damage <= 0:
		damage = attack_damage
	for c in hitbox.get_overlapping_bodies():
		if c == self:
			return
		if !(c in damaged) and c.has_method("take_damage"):
			c.take_damage(damage, dir, self)
		damaged.append(c)

func look_at_target(turn_amount: float, damping := 1.5):
	if !target:
		return

	var forward := global_transform.basis.z
	var desired_f := target.global_transform.origin - global_transform.origin
	var axis = forward.cross(desired_f).normalized()
	
	if axis.is_normalized():
		var angle = forward.angle_to(desired_f)
		add_torque(mass*axis*angle*turn_amount - damping*mass*angular_velocity)

func rotate_up(speed: float, up := Vector3.UP):
	var current_up := global_transform.basis.y
	var desired_up = up.normalized()
	var axis = current_up.cross(desired_up).normalized()
	if axis.is_normalized():
		var angle = current_up.angle_to(desired_up)
		add_torque(mass*axis*angle*speed - 0.1*mass*angular_velocity)

func die():
	var _x = Global.add_stat("killed/"+id)
	remove_from_group("enemy")
	if is_in_group("target"):
		remove_from_group("target")
	if drops_coat:
		var c = coat_scene.instance()
		c.coat = coat
		drop_item(c)
	var gems = int(rand_range(0, gem_drop_max))
	if gems > 0:
		var g = gem_scene.instance()
		g.quantity = gems
		drop_item(g)
	if drops_ammo > 0:
		Global.ammo_drop_pity += drops_ammo
		if Global.ammo_drop_pity >= 1:
			Global.ammo_drop_pity -= 1
			var best_wep := ""
			var best_desire := -INF
			for a in WEIGHTS.keys():
				if Global.count("wep_"+a):
					var desire = WEIGHTS[a]*(0.5*randf() + 1.0 - Global.count(a)/IDEAL_COUNT[a])
					if desire >= best_desire:
						best_wep = a
						best_desire = desire
			if best_wep != "":
				var tscn = load(ammo_path_f % best_wep) as PackedScene
				var ammo = tscn.instance() as ItemPickup
				ammo.quantity = COUNTS[best_wep]
				drop_item(ammo)
	if !respawns:
		Global.mark_picked(get_path())
	emit_signal("died", id, get_path())

func drop_item(item: ItemPickup):
	item.persistent = false
	item.from_kill = true
	item.gravity = true
	get_tree().current_scene.add_child(item)
	item.global_transform = global_transform

func take_damage(damage: int, dir: Vector3, source: Node):
	if is_dead():
		return
	var dead = subtract_health(damage, dir)
	apply_central_impulse(mass*damage*dir*damaged_speed)
	if dead:
		set_state(AI.Dead)
		die()
	else:
		last_attacker = source
		play_damage_sfx()
		if ai != AI.GravityStun:
			set_state(AI.Damaged)

func gravity_stun(dam):
	var dead = subtract_health(dam, Vector3.UP)
	apply_central_impulse(mass*dam*Vector3.UP*gravity_stun_speed)
	if dead:
		set_state(AI.GravityStunDead)
	else:
		set_state(AI.GravityStun)

func subtract_health(damage:int, dir: Vector3) -> bool:
	if shielded:
		var d := dir.dot(global_transform.basis.z)
		if d < min_dot_shielded_damage:
			# TODO: play shielded effect
			return health <= 0
	health -= damage
	return health <= 0

func is_grounded():
	return best_floor_normal.y > 0

func get_closest_floor():
	return best_floor_normal

func walk(velocity: float, accel: float, decel := -1.0):
	if decel < 0:
		decel = accel

	var speed := global_transform.basis.z*velocity
	var force := (speed - linear_velocity)
	if force.dot(speed) > -0.4:
		force *= accel
	else:
		force *= decel
	if !best_floor_normal.is_normalized():
		force.y = 0
	else:
		force = force.slide(best_floor_normal)
	var l = force.length()
	if l > accel:
		force = accel*force/l

	add_central_force(mass*force)

func stunned_move(delta: float):
	var force_removal = -linear_velocity*clamp(1.0 - delta/GRAV_DECAY, 0.1, 0.995)
	add_central_force(mass*force_removal)

func fall_down(_delta: float):
	pass

# Implemented by subclasses
func set_state(_ai: int):
	pass

func play_damage_sfx():
	pass

func aggro_to(node: Spatial):
	if node != self:
		target = node

func no_target():
	return !target or (target.has_method("is_dead") and target.is_dead())

func is_dead():
	return ai == AI.Dead or ai == AI.GravityStunDead

func get_shield() -> Node:
	return null

func set_shielded(val):
	shielded = val
	if get_shield():
		get_shield().visible = shielded

func fire_orb(position: Vector3, orb_speed: float, seeking: float):
	var orb = projectile.instance()
	get_tree().current_scene.add_child(orb)
	orb.source = self
	orb.damage = attack_damage
	orb.speed = orb_speed
	orb.turn_speed = seeking
	orb.global_transform.origin = position
	orb.fire(target, Vector3.UP*0.5)
