extends Node

enum Surface {
	Sand,
	Rock,
	Metal,
	Enemy
}

enum Impact {
	Footstep,
	ImpactLight,
	ImpactStrong,
	SlidingStep,
	SlidingImpact
}

onready var emitters := {
	Surface.Sand: {
		Impact.ImpactLight:$particle_sand_small,
		Impact.ImpactStrong:$particle_sand_large,
		Impact.SlidingImpact:$particle_sand_small,
		Impact.Footstep:null,
		Impact.SlidingStep:null,
	},
	Surface.Rock: {
		Impact.ImpactLight:$particle_sand_small,
		Impact.ImpactStrong:$particle_sand_large,
		Impact.SlidingImpact:$particle_sand_small,
		Impact.Footstep:null,
		Impact.SlidingStep:null,
	},
	Surface.Metal: {
		Impact.ImpactStrong:$sparks1
	},
	Surface.Enemy: {
		Impact.ImpactStrong: $sparks1
	}
}

onready var audio_players := {
	Impact.Footstep:$sound_footstep,
	Impact.ImpactLight:$sound_footstep,
	Impact.SlidingStep:$sound_footstep,
	Impact.ImpactStrong:$sound_strong_impact
}

const low_rock_sounds := [
	preload("res://audio/player/stepdirt1.wav"),
	preload("res://audio/player/stepdirt2.wav"),
	preload("res://audio/player/stepdirt3.wav"),
	preload("res://audio/player/stepdirt4.wav")
]

const sliding_rock_sounds := [
	preload("res://audio/player/stepsteep1.wav"),
	preload("res://audio/player/stepsteep2.wav"),
	preload("res://audio/player/stepsteep3.wav"),
	preload("res://audio/player/stepsteep4.wav")
]

const hard_steps := [
	preload("res://audio/player/step_hard1.wav"),
	preload("res://audio/player/step_hard2.wav"),
	preload("res://audio/player/step_hard3.wav")
]

const hard_impacts := [
	preload("res://audio/player/impact_hard1.wav"),
	preload("res://audio/player/impact_hard2.wav"),
	preload("res://audio/player/impact_hard3.wav")
]

const sounds := {
	Surface.Rock : {
		Impact.Footstep: low_rock_sounds,
		Impact.ImpactLight: low_rock_sounds,
		Impact.SlidingStep:sliding_rock_sounds
	},
	Surface.Sand : {
		Impact.SlidingStep:sliding_rock_sounds
	},
	Surface.Metal : {
		Impact.Footstep: hard_steps,
		Impact.SlidingStep: sliding_rock_sounds,
		Impact.ImpactLight: hard_steps,
		Impact.ImpactStrong: hard_impacts
	},
	Surface.Enemy: {
		Impact.Footstep: hard_steps,
		Impact.ImpactLight: hard_steps,
	}
}

const MIN_DOT_TERRAIN_SAND := 0.85

onready var generic_sfx := $generic_sfx

func step_on(surface: Node, position:Vector3, sliding := false, normal := Vector3.UP):
	var impact = Impact.Footstep if !sliding else Impact.SlidingStep
	impact_on(surface, impact, position, normal)

func impact_on(surface:Node, impact: int, position: Vector3, normal := Vector3.UP, sound := true):
	call_deferred("immediate_impact_on", surface, impact, position, normal, sound)

func immediate_impact_on(surface:Node, impact:int, position:Vector3, normal:Vector3, sound := true):
	if !surface:
		return
	var surf = Surface.Rock
	if surface.is_in_group("terrain") and normal.y > MIN_DOT_TERRAIN_SAND:
		surf = Surface.Sand 
	elif surface.is_in_group("enemy"):
		surf = Surface.Enemy
	elif surface.is_in_group("hard"):
		surf = Surface.Metal
	impact(surf, impact, position, normal, sound)

func impact(surf:int, impact:int, position: Vector3, normal := Vector3.UP, sound := true):
	impact_particles(surf, impact, position, normal)
	if sound:
		impact_sound(surf, impact, position)
	
func impact_particles(surf:int, impact:int, position: Vector3, normal:Vector3):
	if !(surf in emitters):
		return
	if !(impact in emitters[surf]):
		return
	if surf == Surface.Metal:
		pass
	if surf in emitters and impact in emitters[surf]:
		var emitter_orig = emitters[surf][impact]
		if !emitter_orig:
			return
		var e: Particles
		var ename = _emitter_name(surf, impact)
		if ObjectPool.has(ename):
			e = ObjectPool.get(ename)
		else:
			e = duplicate_particles(emitter_orig)
		emit_particles_once(ename, e, position, normal)

func duplicate_particles(original: Particles):
	return original.duplicate()

func impact_sound(surf:int, impact:int, position: Vector3):
	if !(surf in sounds):
		surf = Surface.Rock
	if !(impact in sounds[surf]) or !(impact in audio_players):
		surf = Surface.Rock
		impact = Impact.ImpactLight
	var array:Array = sounds[surf][impact]
	var sound_orig = audio_players[impact]
	if !array or !sound_orig:
		return
	var s: AudioStreamPlayer3D
	var aname = _audio_player_name(impact)
	if ObjectPool.has(aname):
		s = ObjectPool.get(aname)
	else:
		s = sound_orig.duplicate()
	s.stream = array[randi() % array.size()]
	s.pitch_scale = rand_range(0.9, 1.2)
	play_sound_once(aname, s, position)

func emit_particles_once(ename: String, e: Particles, position: Vector3, normal: Vector3):
	add_child(e)
	e.global_transform.origin = position
	var up = e.global_transform.basis.y
	var angle = up.angle_to(normal)
	if angle > 0.01:
		var axis = up.cross(normal).normalized()
		if axis.is_normalized():
			e.global_rotate(axis, angle)
	e.show()
	e.restart()
	e.emitting = true
	yield(get_tree().create_timer(e.lifetime, false), "timeout")
	if is_instance_valid(e):
		e.emitting = false
		remove_child(e)
		ObjectPool.put(ename, e)

func emit_sound(stream: AudioStream, position: Vector3, volume_db := 0.0, randomize_pitch := true):
	var s: AudioStreamPlayer3D
	if ObjectPool.has("generic_sfx"):
		s = ObjectPool.get("generic_sfx")
	else:
		s = generic_sfx.duplicate()
	s.stream = stream
	s.unit_db = volume_db
	if randomize_pitch:
		s.pitch_scale = rand_range(0.9, 1.1)
	else:
		s.pitch_scale = 1.0
	play_sound_once("generic_sfx", s, position)

func play_sound_once(type: String, s: AudioStreamPlayer3D, position: Vector3):
	add_child(s)
	s.global_transform.origin = position
	s.stop()
	s.play()
	yield(get_tree().create_timer(s.stream.get_length(), false), "timeout")
	if is_instance_valid(s):
		s.stop()
		remove_child(s)
		ObjectPool.put(type, s)

func _emitter_name(surface, impact):
	return "BE-" + str(surface) + "-" + str(impact)

func _audio_player_name(impact):
	return "BA-" + str(impact)
