extends Camera

var active := false
var last_camera: Camera

onready var env: WorldEnvironment = $"../WorldEnvironment"
onready var normal_fog_depth = env.environment.fog_depth_end
onready var map_fog_depth = 30000

func _input(event):
	if event.is_action_pressed("map_toggle"):
		set_active(!active)

func set_active(a):
	active = a
	if active:
		var c := get_viewport().get_camera()
		if c != self:
			last_camera = c
		current = true
		env.environment.fog_depth_end = map_fog_depth
	else:
		if last_camera:
			last_camera.current = true
		env.environment.fog_depth_end = normal_fog_depth
		
