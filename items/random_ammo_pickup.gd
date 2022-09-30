extends Spatial

export(bool) var generate_on_ready := false
export(bool) var ignore_parent := false

func _ready():
	if generate_on_ready:
		generate()
	elif !ignore_parent:
		var p = get_parent()
		if p is Door:
			p.connect("opened", self, "generate")

func generate():
	var a = AmmoSpawner.get_random_ammo()
	if a:
		add_child(a)
