extends Spatial

func _ready():
	var coat = Global.stat(coat_stat())
	if !coat:
		coat = Global.set_stat(coat_stat(), Coat.new(true))
	show_coat(coat)

func coat_stat() -> String:
	return str(get_path()) + "/coat"

func show_coat(coat: Coat):
	$Armature/Skeleton/body.set_surface_material(1, coat.generate_material(false))
