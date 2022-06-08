extends KinematicBody
class_name KinematicEnemy

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
export(float) var damaged_speed = 0.5
export(float) var square_distance_activation := 2400.0

enum AI {
	Idle,
	Alerted,
	Chasing,
	Windup,
	Attacking,
	Damaged,
	GravityStun,
	Dead
}
var ai = AI.Idle

const GRAVITY := Vector3.DOWN*24

var coat_scene:PackedScene = load("res://items/coat_pickup.tscn")
var gem_scene:PackedScene = load("res://items/gem_pickup.tscn")

var target: Spatial
var velocity := Vector3.ZERO
var move_dir: Vector3
var damaged:= []

var in_range := false
var coat: Coat = null

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

func _ready():
	set_state(ai)
	if !respawns and Global.is_picked(get_path()):
		queue_free()
		return
	if drops_coat:
		coat = Coat.new(true, minimum_rarity, maximum_rarity)

func set_active(_active: bool):
	pass

func process_player_distance(pos: Vector3) -> float:
	var lensq := (pos - global_transform.origin).length_squared()
	var within_activation := lensq <= square_distance_activation
	if within_activation != in_range:
		in_range = within_activation
		set_active(in_range and ai != AI.Dead)
	return lensq

func damage_direction(hitbox: Area, dir: Vector3):
	for c in hitbox.get_overlapping_bodies():
		if !(c in damaged) and c.has_method("take_damage"):
			c.take_damage(attack_damage, dir)
		damaged.append(c)

func look_at_target(turn_amount: float):
	if !target:
		return
	var forward := global_transform.basis.z
	var desired_f := target.global_transform.origin - global_transform.origin
	desired_f.y = 0
	desired_f = desired_f.normalized()
	var axis = forward.cross(desired_f).normalized()
	if axis.is_normalized():
		var angle = forward.angle_to(desired_f)
		var rot = sign(angle)*min(abs(angle), turn_amount)
		global_rotate(axis, rot)

func rotate_up(speed: float, up := Vector3.UP):
	var current_up := global_transform.basis.y
	var desired_up = up.normalized()
	var axis = current_up.cross(desired_up).normalized()
	if axis.is_normalized():
		var angle = current_up.angle_to(desired_up)
		var theta = sign(angle)*min(abs(angle), speed)
		global_rotate(axis, theta)

func die():
	var _x = Global.add_stat("killed/"+id)
	remove_from_group("distance_activated")
	remove_from_group("target")
	if drops_coat:
		var c = coat_scene.instance()
		c.coat = coat
		drop_item(c)
		print("Spawning coat")
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

func take_damage(damage: int, dir: Vector3):
	if ai == AI.Dead:
		return
	health -= damage
	move_dir = damage*dir*damaged_speed
	if health <= 0:
		set_state(AI.Dead)
		die()
	elif ai == AI.GravityStun:
		play_damage_sfx()
	else:
		play_damage_sfx()
		set_state(AI.Damaged)

func get_closest_floor(vector:= Vector3.UP):
	var res := -vector
	for i in get_slide_count():
		var c := get_slide_collision(i)
		if c.normal.dot(vector) > res.dot(vector):
			res = c.normal
	return res 

func walk(delta: float, speed: float, slide := false):
	var hvel = global_transform.basis.z*speed
	velocity.x = hvel.x
	velocity.z = hvel.z
	
	velocity = move_and_slide(velocity + GRAVITY*delta)
	
	if slide:
		velocity.y = min(0, velocity.y)

func stunned_move(delta: float):
	velocity *= clamp(1.0 - delta, 0.1, 0.995)
	velocity = move_and_slide(velocity + Vector3.UP*delta*Global.gravity_stun_velocity)

func fall_down(delta: float):
	var best_normal = Vector3.ZERO
	for c in get_slide_count():
		var n = get_slide_collision(c).normal
		if n.y > best_normal.y:
			best_normal = n
	var gravity := GRAVITY
	if best_normal != Vector3.ZERO:
		gravity = GRAVITY.project(best_normal)
		
	velocity.x = move_dir.x
	velocity.z = move_dir.z
	move_dir *= 0.9
	velocity = move_and_slide(velocity + gravity*delta)

# Implemented by subclasses
func set_state(_ai: int):
	pass

func play_damage_sfx():
	pass

func aggro_to(node: Spatial):
	target = node

func gravity_stun(dam):
	take_damage(dam, Vector3.UP)
	if ai != AI.Dead:
		set_state(AI.GravityStun)

func is_dead():
	return ai == AI.Dead
