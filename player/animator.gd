extends Spatial

var crouch_blend := 0.0
var climb_blend := 0.0

var sounds := {
	"stepLevelGround": [
		preload("res://audio/player/stepdirt1.wav"),
		preload("res://audio/player/stepdirt2.wav"),
		preload("res://audio/player/stepdirt3.wav"),
		preload("res://audio/player/stepdirt4.wav"),
	],
	"stepSteepGround": []
}

onready var anim: AnimationTree = $AnimationTree
onready var body: AnimationNodeStateMachinePlayback = anim["parameters/WholeBody/playback"]
onready var audio := $audio

func set_movement_animation(speed: float, is_crouch: bool, is_climb: bool):
	crouch_blend = lerp(crouch_blend, float(is_crouch), 0.45)
	climb_blend = lerp(climb_blend, float(is_climb), 0.15)
	
	anim["parameters/WholeBody/Ground/blend_position"] = Vector2(crouch_blend + climb_blend, speed)

func transition_to(state):
	body.travel(state)

func show_coat(coat: Coat):
	var mat = coat.generate_material()
	$Armature/Skeleton/coat.material_override = mat

func play_sound(bodyPart: String, soundType: String):
	print("Playing ", soundType, " on ", bodyPart)
	if !audio.has_node(bodyPart):
		print_debug("No audio player for ", bodyPart)
		return
	var node: AudioStreamPlayer3D = audio.get_node(bodyPart)
	match soundType:
		"step":
			node.stream = get_random_sound("stepLevelGround")
			node.play()
		_:
			print_debug("No sound effects for ", soundType)

func get_random_sound(type: String) -> AudioStream:
	if !(type in sounds) or sounds[type].size() == 0:
		return null
	var array: Array = sounds[type]
	return array[randi() % array.size()]

func stop_particles():
	$Armature/Skeleton/footLeft/kick_particles.emitting = false
	$Armature/Skeleton/footRight/kick_particles.emitting = false
	$dive_particles.emitting = false

func start_kick_left():
	$Armature/Skeleton/footLeft/kick_particles.emitting = true

func start_kick_right():
	$Armature/Skeleton/footRight/kick_particles.emitting = true

func start_dive_shockwave():
	$dive_particles.emitting = true

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
