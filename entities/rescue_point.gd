extends Position3D

func _ready():
	var r: Dictionary
	if !Global.has_stat("rescue"):
		r = Global.set_stat("rescue", {})
	else:
		r = Global.stat("rescue")
	var id := name + "." + str(hash(get_path()))
	if !(id in r):
		r[id] = global_transform
