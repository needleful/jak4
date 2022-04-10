extends Spatial

onready var laser := $reference/laser
onready var laser_geometry := $reference/laser_geometry
onready var laser_end := $reference/laser/laser_end
onready var base_ref := $base_reference
onready var ref := $reference
onready var ik_target := $gun_ik/target

var active := true
var locked := false

var holder: Spatial
var camera: Spatial

const lockon_weight_distance := 0.3
const lockon_weight_angle := 4.5

const lockon_max_dist_sq := 900.0
const lockon_max_angle_rad := PI/2.0

var aim_toggle := false

func _input(event):
	if event.is_action_pressed("combat_shoot"):
		fire()
	elif event.is_action_pressed("combat_aim_toggle"):
		aim_toggle = !aim_toggle

func _process(delta):
	update_laser()

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

func _physics_process(delta):
	var current_dir: Vector3 = holder.global_transform.basis.z
	var target_dir : Vector3
	var aiming: bool = aim_toggle or Input.is_action_pressed("combat_aim")
	if locked:
		current_dir = base_ref.global_transform.basis.z
	
	if aiming and !locked:
		target_dir = -camera.global_transform.basis.z
		ik_target.global_transform.origin = base_ref.global_transform.origin + target_dir*100.0
	else:
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
				# TODO: a physics cast here
				best_target = g
				best_score = score
		if best_target:
			target_dir = (best_target.global_transform.origin - base_ref.global_transform.origin)
			ik_target.global_transform.origin = best_target.global_transform.origin
		else:
			target_dir = current_dir
			ik_target.global_transform.origin = base_ref.global_transform.origin + target_dir*100.0
	# Aiming:
	if locked:
		holder.aim_gun(Vector2.ZERO)
	else:
		var y_cur: Vector3 = holder.global_transform.basis.z
		var y_tar: Vector3 = target_dir.slide(holder.global_transform.basis.y)
		var y_axis: Vector3 = y_cur.cross(y_tar).normalized()
		var y_angle: float = y_cur.angle_to(y_tar)
		
		var aim := Vector2(
			-y_angle/(PI/2)*sign(holder.global_transform.basis.y.dot(y_axis)),
			target_dir.normalized().y
		)
			
		holder.aim_gun(aim)

func lock():
	locked = true
	holder.display_gun(0.5)

func unlock():
	locked = false
	holder.display_gun(1.0)

func set_active(p_active : bool):
	active = p_active
	visible = active
	set_process(active)
	set_physics_process(active)
	set_process_input(active)
	holder.display_gun(1.0 if active else 0.0)

func fire():
	fire_test_orb()

func fire_test_orb():
	var orb = load("res://entities/enemies/projectile.tscn").instance()
	get_tree().current_scene.add_child(orb)
	orb.damage = 10
	orb.speed = 30
	orb.global_transform.origin = ref.global_transform.origin
	orb.velocity = ref.global_transform.basis.z*orb.speed
