extends MeshInstance

func _input(event):
	if event.is_action_pressed("debug_randomize_coat"):
		material_override = Global.get_coat(randi())
