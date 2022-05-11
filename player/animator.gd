extends Spatial


var sounds := {
	"stepLevelGround": [
		preload("res://audio/player/stepdirt1.wav"),
		preload("res://audio/player/stepdirt2.wav"),
		preload("res://audio/player/stepdirt3.wav"),
		preload("res://audio/player/stepdirt4.wav"),
	],
	"stepSteepGround": [],
	"gem": [
		preload("res://audio/pickup/gem1.wav"),
		preload("res://audio/pickup/gem2.wav"),
	],
	"coat": [
		preload("res://audio/pickup/coat1.wav"),
		preload("res://audio/pickup/coat2.wav"),
	],
	"wep_pistol": [
		preload("res://audio/pickup/wep_pistol.wav")
	],
	"pistol":[
		preload("res://audio/pickup/ammo.wav")
	],
	"_pickup": [
		preload("res://audio/pickup/gem1.wav"),
		preload("res://audio/pickup/gem2.wav"),
	]
}

onready var anim: AnimationTree = $AnimationTree
onready var body: AnimationNodeStateMachinePlayback = anim["parameters/WholeBody/playback"]
onready var player : PlayerBody = get_parent()
onready var audio := $audio
onready var camera_rig := $"../camera_rig"

var item_sound := 0
var move_blend:= 0.0
var lunge_right_foot := true
var held_item:Spatial

func _ready():
	$Armature/Skeleton/gun.holder = self

func set_movement_animation(speed: float, state: int):
	var target := 0.0
	if state == PlayerBody.State.Crouch:
		target = 1.0
	elif state == PlayerBody.State.Climb:
		target = 2.0
	elif state == PlayerBody.State.Slide:
		target = -1.0
	move_blend = lerp(move_blend, target, 0.45)
	
	anim["parameters/WholeBody/Ground/blend_position"] = Vector2(move_blend, speed)

func force_play(state):
	body.start(state)

func transition_to(state):
	body.travel(state)

func show_coat(coat: Coat):
	var mat = coat.generate_material()
	$Armature/Skeleton/coat.material_override = mat

func play_sound(bodyPart: String, soundType: String, randomize_tone := false):
	if !audio.has_node(bodyPart):
		print_debug("No audio player for ", bodyPart)
		return
	var node = audio.get_node(bodyPart)
	node.stream = get_random_sound(soundType)
	if node.stream == null:
		print("No sound: ", soundType)
		return
	if randomize_tone:
		node.pitch_scale = rand_range(0.9, 1.2)
	node.play()

func get_desired_aim():
	return -player.intention.global_transform.basis.z

func get_random_sound(type: String) -> AudioStream:
	if type == "step":
		type = "stepLevelGround"
	if !(type in sounds) or sounds[type].size() == 0:
		return null
	var array: Array = sounds[type]
	return array[randi() % array.size()]

func stop_particles():
	$Armature/Skeleton/footLeft/kick_particles.emitting = false
	$Armature/Skeleton/footRight/kick_particles.emitting = false
	$Armature/Skeleton/footLeft/max_kick_particles.emitting = false
	$Armature/Skeleton/footRight/max_kick_particles.emitting = false
	$max_dive_particles.emitting = false
	$dive_particles.emitting = false

func play_lunge_kick(max_damage: bool):
	anim["parameters/WholeBody/LungeKick/blend_position"] = float(lunge_right_foot)
	transition_to("LungeKick")
	if lunge_right_foot:
		start_kick_right(max_damage)
	else:
		start_kick_left(max_damage)
	lunge_right_foot = !lunge_right_foot

func start_kick_left(max_damage: bool):
	$Armature/Skeleton/footLeft/kick_particles.emitting = true
	if max_damage:
		$Armature/Skeleton/footLeft/max_kick_particles.emitting = true

func start_kick_right(max_damage: bool):
	$Armature/Skeleton/footRight/kick_particles.emitting = true
	if max_damage:
		$Armature/Skeleton/footRight/max_kick_particles.emitting = true

func start_dive_shockwave(max_damage: bool):
	$dive_particles.emitting = true
	if max_damage:
		$max_dive_particles.emitting = true

func start_damage_particle(dir: Vector3):
	var emitter := $Armature/Skeleton/chest/damage_particles
	dir.y = 0.5
	var local_dir: Vector3 = emitter.global_transform.basis.inverse()*(dir).normalized()
	emitter.process_material.direction = local_dir
	emitter.emitting = true
	#print(dir, " -> ", local_dir, " -> ", emitter.global_transform.xform(local_dir))
	$Armature/Skeleton/chest/damage_emit_timer.start()

func _on_damage_emit_timer_timeout():
	$Armature/Skeleton/chest/damage_particles.emitting = false

func start_heal_particle():
	$Armature/Skeleton/head/heal_particles.emitting = true
	$Armature/Skeleton/head/heal_emit_timer.start()

func _on_heal_emit_timer_timeout():
	$Armature/Skeleton/head/heal_particles.emitting = false

func start_roll_particles():
	start_kick_left(false)
	start_kick_right(false)

func play_pickup_sound(item: String):
	if !item in sounds:
		item = "_pickup"
	play_sound("item_sound"+str(item_sound), item, true)
	item_sound = item_sound != 1

func hold_gun(blend: float):
	anim["parameters/GunHold/blend_amount"] = blend
	if blend:
		player.show_ammo()
	else:
		player.hide_ammo()

func track_weapon(weapon: String):
	player.track_weapon(weapon)

func blend_gun(active: float):
	anim["parameters/Gun/blend_amount"] = active*0.9

func aim_gun(aim: Vector2, aiming: bool):
	anim["parameters/Aim/blend_position"] = aim
	camera_rig.set_aiming(aiming)

func get_normal_gun_orientation() -> Vector3:
	var skeleton: Skeleton = $Armature/Skeleton
	var idx : int = skeleton.find_bone("Gun.R")
	var local_bone_transform: Transform = skeleton.get_bone_global_pose_no_override(idx)
	var t : Transform = skeleton.global_transform*local_bone_transform
	return t.basis.y

func play_fire():
	anim["parameters/Fire/active"] = true
	player.shake_camera()

func hold_item(node: Spatial):
	held_item = node
	$Armature/Skeleton/handRight/ref.add_child(held_item)
	held_item.transform = Transform.IDENTITY

func release_item() -> Spatial:
	var h = held_item
	if h:
		h.get_parent().remove_child(h)
	held_item = null
	return h

func apply_velocity(vel: Vector3):
	player.velocity.y = 0
	player.velocity += vel
