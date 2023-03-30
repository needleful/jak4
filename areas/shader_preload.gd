extends Spatial

var flags = 0
var max_flags = 128

func _ready():
	get_tree().paused = true

func _process(_delta):
	print(flags)
	$lights/sun.visible = flags & 1
	$lights/OmniLight.visible = flags & 2
	$lights/SpotLight.visible = flags & 4
	$lights/ReflectionProbe.interior_enable = flags & 8
	$lights/ReflectionProbe.visible = flags & 16
	$lights/light_wall.light_enabled = flags & 32
	$"lights/glass-furnace".light_enabled = flags & 64
	flags += 1

	if flags >= max_flags:
		get_tree().paused = false
		var _x = get_tree().change_scene("res://areas/world.tscn")
