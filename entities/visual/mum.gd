extends Spatial

onready var mesh := $Armature/Skeleton/mum
onready var detail := $Armature/Skeleton/mum_deatail

func hello():
	show()
	$AnimationPlayer.play("IntroWalk")
	var t:Tween = $Tween
	var _x = t.stop_all()
	_x = t.interpolate_method(
		self,
		"_set_real",
		0.0,
		1.0 if Global.stat("mum/appearance") else 0.5,
		1.0)
	_x = t.start()

func bye():
	var t:Tween = $Tween
	var _x = t.stop_all()
	_x = t.interpolate_method(
		self,
		"_set_real",
		mesh.material_override.get_shader_param("realness"),
		0,
		1.0)
	_x = t.interpolate_callback(self, 1.0, "hide")
	_x = t.start()

func _set_real(realness: float):
	mesh.material_override.set_shader_param("realness", realness)
	detail.material_override.set_shader_param("realness", realness)
