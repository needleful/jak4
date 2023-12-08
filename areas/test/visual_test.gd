extends Spatial

onready var scn : Node

func _on_load_toggled(on):
	if on:
		scn = load("res://areas/test/reflection_probes.tscn").instance()
		print("LOADED")
	elif scn:
		print("UNLOADED")
		scn.queue_free()
		scn = null

func _on_activate_toggled(on):
	if on and scn:
		print("ACTIVATED")
		add_child(scn)
	elif scn and scn.is_inside_tree():
		print("DEACTIVATED")
		remove_child(scn)

func _on_show_toggled(on):
	if scn and scn.is_inside_tree():
		scn.visible = on
		print("SHOWN" if on else "HIDDEN")
