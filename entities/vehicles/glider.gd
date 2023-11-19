extends KinematicBody
# For now this is just the plane

signal landing(success)

var player: PlayerBody
var velocity: Vector3
var start_speed := 10.0
var lift_factor := 0.25
var gravity := Vector3.DOWN*9.8
var drag_factor := 0.004
var drag_y_factor := 0.5

enum State {
	Start,
	Fly,
	Crash
}

var state = State.Start
var flight_time := 0.0

const FEEDBACK_SPEED := 1.0

onready var landing_gear := $landing_gear
onready var laili := $npc_laili
var original_parent: Node
var original_transform: Transform

onready var wing_right := {
	"shape1": $wing_right,
	"shape2": $wing_tip_right,
	"mesh":$plane_body/wing_right
}

onready var wing_left := {
	"shape1": $wing_left,
	"shape2": $wing_tip_left,
	"mesh":$plane_body/wing_left
}

var spawns := [{}, {}]

var wing_parents : Dictionary
# left, right
var wing_broken := [false, false]
var wing_mass := 40.0

func _ready():
	for v in wing_right.values():
		wing_parents[v] = v.get_parent()
	for v in wing_left.values():
		wing_parents[v] = v.get_parent()

	original_parent = get_parent()
	original_transform = transform
	remove_child(laili)
	set_physics_process(false)

func activate():
	wing_broken = [false, false]
	flight_time = 0
	state = State.Start
	var t := global_transform
	var new_p = get_tree().current_scene
	get_parent().remove_child(self)
	new_p.add_child(self)
	global_transform = t
	
	player = Global.get_player()
	player.disable_collision()
	player.set_state(PlayerBody.State.Vehicle)
	player.transform = Transform()
	player.mesh.transform = Transform()
	player.mesh.start_hover(false)
	var _x = player.connect("died", self, "_on_player_died", [], CONNECT_ONESHOT)
	Music.play_track("flight.ogg", true)
	
	set_physics_process(true)
	velocity = global_transform.basis.z*start_speed

func _on_player_died():
	exit()
	reset()

func exit():
	Music.stop_music()
	if !player:
		return
	if player.is_connected("died", self, "exit"):
		player.disconnect("died", self, "exit")
	player.enable_collision()
	player.unlock()
	player = null

func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED and player:
		player.set_saved_transform(global_transform)

func _physics_process(delta: float):
	if state == State.Crash:
		process_crash(delta)
	elif player:
		process_flight(delta)
	else:
		set_physics_process(false)
		return

func process_flight(delta:float):
	flight_time += delta
	if flight_time > 4.0 and !wing_broken[1] and !Global.stat("laili/disaster_averted"):
		break_wing(true)
	if state == State.Start:
		if flight_time > 3 and landing_gear.get_overlapping_bodies().empty():
			state = State.Fly
	elif !landing_gear.get_overlapping_bodies().empty() or (velocity.is_equal_approx(Vector3.ZERO) and get_slide_count() > 0):
		velocity = velocity.move_toward( Vector3.ZERO,
			(4 + velocity.length_squared())*delta)
		if velocity.length_squared() < 0.2:
			print_debug("Landed!")
			emit_signal("landing", true)
			laili.crashed = false
			exit()
			spawn_laili()
			return
	var pitch := Input.get_axis("mv_down", "mv_up")
	var roll := Input.get_axis("mv_left", "mv_right")
	
	fly(pitch, roll, delta)
	
	player.mesh.hover_lean(Vector2(
		-2*global_transform.basis.x.y,
		+2*global_transform.basis.z.y),
	delta)
	
	if global_transform.basis.y.y < 0:
		flight_time = 0
		state = State.Crash
		laili.crashed = true
		exit()

func process_crash(delta):
	flight_time += delta
	var temp_p = Global.get_player()
	if ( flight_time > 1.0 
		and !laili.is_inside_tree()
		and temp_p.can_talk()
		and !temp_p.best_floor.is_in_group("plane_parts")
	):
		player = temp_p
		spawn_laili()
		player = null
	var spin := 0.0 if wing_broken else min(velocity.length_squared()/30.0, 2.0)
	fly(0,spin,delta)
	if get_slide_count():
		velocity = velocity.move_toward( Vector3.ZERO,
			(4 + velocity.length_squared())*delta)
		if !laili.get_parent() and velocity.length_squared() < 0.2:
			set_physics_process(false)

func fly(pitch: float, roll: float, delta: float):
	var wings_lift := 0.5*(float(!wing_broken[0]) + float(!wing_broken[1]))
	if wing_broken[0]:
		roll += min(velocity.length_squared()/30.0, 2.0)
	if wing_broken[1]:
		roll -= min(velocity.length_squared()/30.0, 2.0)
	var pitch_speed := 1.5
	var roll_speed := 1.5
	
	var total_pitch := delta*pitch*pitch_speed
		
	var total_roll := delta*roll*roll_speed
	
	global_rotate(global_transform.basis.x, total_pitch)
	global_rotate(global_transform.basis.z, total_roll)
	
	velocity = velocity.rotated(
		global_transform.basis.x, total_pitch).rotated(
			global_transform.basis.z, total_roll)

	var lift := clamp(
		wings_lift*lift_factor * velocity.dot(global_transform.basis.z),
		-15, 15
	) * global_transform.basis.y

	var hvel := velocity.slide(global_transform.basis.y)
	var yvel := velocity.project(global_transform.basis.y)
	var drag := -drag_factor*(hvel.length()*hvel)
	var drag_y := -drag_y_factor*(yvel.length()*yvel)
	
	velocity += (gravity + lift + drag + drag_y)*delta
	velocity = move_and_slide(velocity)
	
	var forward := global_transform.basis.z
	var v := velocity.normalized()
	if v.is_normalized():
		var axis = forward.cross(v).normalized()
		if axis.is_normalized():
			var angle := forward.angle_to(v)
			var rote := sign(angle)*min(abs(angle), delta*FEEDBACK_SPEED)
			global_rotate(axis, rote)

func spawn_laili():
	laili.plane_node = self
	var p: PlayerBody = Global.get_player()
	var pt := p.global_transform
	var point = pt.origin + Vector3.UP*2
	
	var dirs :PoolVector3Array = [
		pt.basis.z,
		pt.basis.x,
		-pt.basis.x,
		pt.basis.z + pt.basis.x,
		pt.basis.z - pt.basis.x,
		Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]
	var min_distance := 1.0
	var max_distance := 3.0
	var ds := get_world().direct_space_state
	var h := 10
	var min_floor_dot := PlayerBody.MIN_DOT_GROUND
	for v in dirs:
		var r := ds.intersect_ray(point, point+(Vector3.DOWN+v)*h)
		if !r or r.normal.y < min_floor_dot:
			continue
		
		var d:float = (r.position - pt.origin).length()
		if d > max_distance or d < min_distance:
			continue
		spawn_at(r.position, pt.origin)
		return

	var tries := 0
	while tries < 5:
		tries += 1
		var random_point := (
			pt.origin
			+ (1 if randf() < 0.5 else -1)*Vector3.LEFT*(1 + 2*randf())
			+ (1 if randf() < 0.5 else -1)*Vector3.FORWARD*(1 + 2*randf())
		)
		var from := random_point + Vector3.UP*30
		var to := random_point + Vector3.DOWN*30
		var r := ds.intersect_ray(from, to)
		if !r:
			continue
		else:
			spawn_at(r.position, pt.origin)
			return
	
	spawn_at(pt.origin + pt.basis.z, pt.origin)

func spawn_at(point: Vector3, player_point: Vector3):
	get_tree().current_scene.add_child(laili)
	laili.global_transform.origin = point
	player_point.y = laili.global_transform.origin.y
	laili.global_transform = laili.global_transform.looking_at(player_point, Vector3.UP)
	laili.global_rotate(Vector3.UP, PI)
	laili._on_dialog_body_entered(Global.get_player(), true)
	laili.show()

func _exit_tree():
	if laili.get_parent() and laili.get_parent() != self:
		laili.queue_free()

func reset():
	if !is_instance_valid(original_parent):
		queue_free()
	for i in 2:
		if wing_broken[i]:
			var wing = wing_right if i else wing_left
			var body
			for k in wing:
				var v = wing[k]
				body = v.get_parent()
				body.remove_child(v)
				wing_parents[v].add_child(v)
				v.transform = spawns[i][k]
			if body:
				body.queue_free()
	wing_broken = [false, false]
	if laili.get_parent():
		laili.get_parent().remove_child(laili)
	get_parent().remove_child(self)
	original_parent.add_child(self)
	transform = original_transform
	player = null
	set_physics_process(false)

func break_wing(right: bool):
	Music.stop_music()
	wing_broken[int(right)] = true
	var wing = wing_right if right else wing_left
	
	var body := RigidBody.new()
	body.add_to_group("plane_parts")
	body.mass = wing_mass
	get_tree().current_scene.add_child(body)
	body.global_transform = wing.mesh.global_transform
	
	for k in wing:
		var v = wing[k]
		spawns[int(right)][k] = v.transform
		var g = v.global_transform
		v.get_parent().remove_child(v)
		body.add_child(v)
		v.global_transform = g
	body.linear_velocity = velocity
	body.apply_torque_impulse(body.mass*Vector3(randf(), randf(), randf()))
