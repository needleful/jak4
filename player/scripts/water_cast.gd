extends RayCast

export(Array, AudioStream) var deep_water_sounds
export(Array, AudioStream) var shallow_water_sounds

onready var water_players := [
	$water_step1,
	$water_step2
]

var water_active_player := 0

func play_sound(deep:bool):
	var p :AudioStreamPlayer3D = water_players[water_active_player]
	if p:
		p.global_transform.origin = get_collision_point()
		var a :Array = deep_water_sounds if deep else shallow_water_sounds
		p.stop()
		p.stream = a[randi() % a.size()]
		p.pitch_scale = rand_range(0.9, 1.2)
		p.play()
	water_active_player += 1
	water_active_player %= water_players.size()
