extends RigidBody
class_name EnemyBody

signal died(id, fullPath)

export(String) var id
export(bool) var respawns := true
export(bool) var reset_on_player_death := false
export(bool) var drops_coat := false
export(float, 0.0, 1.0) var drops_ammo := 0.3
export(float, 0.0, 1.0) var drops_health := 0.25
export(Coat.Rarity) var minimum_rarity = Coat.Rarity.Common
export(Coat.Rarity) var maximum_rarity = Coat.Rarity.Rare
export(int) var gem_drop_max = 5
export(NodePath) var mesh_node : NodePath
export(int) var health := 15
export(int) var attack_damage := 10
export(bool) var shielded := false setget set_shielded
export(bool) var cloaked := false

const cloaked_material : Material = preload("res://material/characters/cloaked.material")

const GRAV_DECAY := 1.0
const projectile: PackedScene = preload("res://entities/combat/projectile.tscn")

const TIME_MIN_IDLE := 0.15

var damaged_speed := 0.5
var gravity_stun_speed := 0.5
var square_distance_activation := 2400.0
onready var awareness := $awareness

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
var health_scene:PackedScene = load("res://items/health_pickup.tscn")

var target: Spatial
var damaged : Array

var in_range := false
var coat: Coat = null
var can_fly := false

var source_chunk : MeshInstance

var min_dot_shielded_damage := -0.5
var last_attacker: Node
var best_floor : Node
var best_floor_normal : Vector3
var contact_count := 0

var starting_position: Transform
var starting_health: int
var starting_collision_layer : int
var skip_alert := true

func _init():
	damaged = []
	contact_monitor = true
	contacts_reported = 4

func _ready():
	set_physics_process(false)
	if reset_on_player_death:
		var p = Global.get_player()
		if !p.is_connected("died", self, "_on_player_died"):
			var _x = Global.get_player().connect("died", self, "_on_player_died")
			starting_position = global_transform
			starting_health = health
			starting_collision_layer = collision_layer
		else:
			global_transform = starting_position
			health = starting_health
			collision_layer = starting_collision_layer
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO
			var state := PhysicsServer.body_get_direct_state(get_rid())
			if !state:
				print_debug("ERROR: no state for ", get_path())
			else:
				state.transform = starting_position
			target = null
	else:
		starting_health = health
	if drops_coat:
		coat = Coat.new(true, minimum_rarity, maximum_rarity)
		get_node(mesh_node).set_surface_material(0, coat.generate_material())

	if cloaked:
		if is_in_group("target"):
			remove_from_group("target")
		get_node(mesh_node).material_override = cloaked_material
	if !respawns and Global.is_picked(get_path()):
		ai = AI.Dead
		emit_signal("died", id, get_path())
		queue_free()
		return
	set_shielded(shielded)
	var p = get_parent()
	while !source_chunk and p:
		if p is MeshInstance and p.name.begins_with("chunk"):
			source_chunk = p
		p = p.get_parent()
	if !source_chunk:
		remove_from_group("enemy")
	call_deferred("set_state", AI.Idle)
	if has_node("custom_awareness"):
		awareness = $custom_awareness as Area
		if !awareness:
			print_debug("ERROR: Area expected for ", $custom_awareness.get_path())
	if awareness and !awareness.is_connected("body_entered", self, "_on_awareness_entered"):
		var _x = awareness.connect("body_entered", self, "_on_awareness_entered")
	elif awareness:
		retarget()
	if has_node("drowner"):
		var d := $drowner
		d.drowned = false
		if !d.is_connected("drowned", self, "set_state"):
			var _x = d.connect("drowned", self, "set_state", [AI.Dead])

func _on_awareness_entered(body):
	if "do_not_disturb" in body and body.do_not_disturb:
		return
	if !is_dead() and (ai == AI.Idle or !is_physics_processing()) and body.is_in_group("player"):
		aggro_to(body)
		if skip_alert:
			set_state(AI.Chasing)
		else:
			set_state(AI.Alerted)
		set_physics_process(true)

func retarget():
	for b in awareness.get_overlapping_bodies():
		_on_awareness_entered(b)

func _integrate_forces(state):
	best_floor = null
	best_floor_normal = Vector3(0, -INF, 0)
	contact_count = state.get_contact_count()
	for i in range(contact_count):
		var n:Vector3 = state.get_contact_local_normal(i)
		if n.y > best_floor_normal.y:
			best_floor_normal = n
			best_floor = state.get_contact_collider_object(i)

func set_active(_active: bool):
	pass

func process_player_distance(pos: Vector3) -> float:
	if !is_inside_tree() or !is_instance_valid(source_chunk):
		return INF
	var lensq := (pos - global_transform.origin).length_squared()
	var within_activation := lensq <= square_distance_activation
	if within_activation != in_range:
		in_range = within_activation
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

func kill():
	set_state(AI.Dead)
	die()

func die():
	collision_layer = 0
	collision_mask = 1
	var _x = Global.add_stat("killed/"+id)
	var drop_dir := Vector3(0, 4, 3)
	var drop_angle := rand_range(0, 2*PI)
	if !respawns or !reset_on_player_death:
		remove_from_group("enemy")
		if is_in_group("target"):
			remove_from_group("target")
	if drops_coat:
		var c = coat_scene.instance()
		c.coat = coat
		drop_item(c, drop_dir, drop_angle, 0.0)
		drop_angle += rand_range(1, 2)
	var gems = int(rand_range(0, gem_drop_max))
	if gems > 0:
		var g = gem_scene.instance()
		g.quantity = gems
		drop_item(g, drop_dir, drop_angle, 30)
		drop_angle += rand_range(1, 2)
	if drops_ammo > 0:
		Global.ammo_drop_pity += drops_ammo
		if Global.ammo_drop_pity >= 1:
			Global.ammo_drop_pity -= 1
			var ammo = AmmoSpawner.get_random_ammo()
			if ammo:
				drop_item(ammo, drop_dir, drop_angle, 45)
		drop_angle += rand_range(1, 2)
	if drops_health > 0:
		Global.health_drop_pity += drops_health*Global.get_player().health_drop_bonus()
		if Global.health_drop_pity >= 1:
			Global.health_drop_pity -= 1
			drop_item(health_scene.instance(), drop_dir, drop_angle, 20)
			drop_angle += rand_range(1, 2)
	if !respawns:
		Global.mark_picked(get_path())
	emit_signal("died", id, get_path())
	set_physics_process(false)

func drop_item(item: ItemPickup, dir:Vector3, angle:float, time: float):
	item.persistent = false
	item.from_kill = true
	item.gravity = true
	item.velocity = dir.rotated(Vector3.UP, angle)
	
	get_tree().current_scene.add_child(item)
	item.global_transform.origin = global_transform.origin
	if time > 0:
		ObjectPool.timed_delete(item.get_path(), time)

func take_damage(damage: int, dir: Vector3, source: Node, _tag := ""):
	if is_dead():
		return
	
	if shielded:
		var true_dir:Vector3
		if source is Spatial:
			true_dir = (global_transform.origin - source.global_transform.origin).normalized()
		else:
			true_dir = dir
		var d := true_dir.dot(global_transform.basis.z)
		if d < min_dot_shielded_damage:
			# TODO: shield blocking state here?
			return
	if ai == AI.Idle:
		# stealth attack: double damage
		damage *= 2
	health -= damage
	Bumps.impact_on(self, Bumps.Impact.ImpactStrong, global_transform.origin + dir*0.75, dir)
	var dead := health <= 0
	
	apply_central_impulse(mass*damage*dir*damaged_speed)
	if dead:
		set_state(AI.Dead)
		die()
	else:
		last_attacker = source
		play_damage_sfx()
		if ai != AI.GravityStun:
			set_active(true)
			set_state(AI.Damaged)

func gravity_stun(dam):
	var d = Settings.sub_options["Difficulty"]
	dam *= d.get_factor(d.player_damage)
	set_physics_process(true)
	health -= dam
	var dead := health <= 0
	apply_central_impulse(mass*dam*Vector3.UP*gravity_stun_speed)
	if dead:
		set_state(AI.GravityStunDead)
	else:
		set_state(AI.GravityStun)

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

func set_state(_ai: int, _force := false):
	pass

func play_damage_sfx():
	pass

func aggro_to(node: Spatial):
	if node != self:
		target = node
		set_physics_process(true)
	if target and target.is_in_group("enemy"):
		# Add to enemy layer
		awareness.collision_mask = awareness.collision_mask | 4
	else:
		awareness.collision_mask = awareness.collision_mask & ~4

func no_target():
	return ( 
		!is_instance_valid(target) or (
			target.has_method("is_dead") and target.is_dead())
		or (
			"do_not_disturb" in target and target.do_not_disturb
		)
	)

func is_dead():
	return ai == AI.Dead or ai == AI.GravityStunDead

func get_shield() -> Node:
	return null

func set_shielded(val):
	shielded = val
	if get_shield():
		get_shield().visible = shielded

func fire_orb(position: Vector3, orb_speed: float, seeking: float):
	var orb
	if ObjectPool.has("orb"):
		orb = ObjectPool.get("orb")
	else:
		orb = projectile.instance()
	get_tree().current_scene.add_child(orb)
	orb.source = self
	orb.damage = attack_damage
	orb.speed = orb_speed*projectile_aggro_factor()
	orb.turn_speed = seeking
	orb.global_transform.origin = position
	orb.fire(target, Vector3.UP*0.5)

func time_to_alert_factor()->float:
	var d: DifficultySettings = Settings.sub_options["Difficulty"]
	match d.aggression:
		DifficultySettings.Aggression.LowAggression:
			return 2.0
		DifficultySettings.Aggression.HighAggression:
			return 0.75
		_:
			return 1.0

func time_to_quit_factor() -> float:
	var d: DifficultySettings = Settings.sub_options["Difficulty"]
	match d.aggression:
		DifficultySettings.Aggression.LowAggression:
			return 0.33
		DifficultySettings.Aggression.HighAggression:
			return 2.0
		_:
			return 1.0

func projectile_aggro_factor() -> float:
	var d: DifficultySettings = Settings.sub_options["Difficulty"]
	match d.aggression:
		DifficultySettings.Aggression.LowAggression:
			return 0.7
		DifficultySettings.Aggression.HighAggression:
			return 1.5
		_:
			return 1.0

func _on_player_died():
	if !is_inside_tree() or (ai == AI.Dead and !respawns):
		return
	_reset()

func _reset():
	_ready()
