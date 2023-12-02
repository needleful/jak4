tool
extends Chunk

export(String) var reflection_group
export(Color) var deactivated_color
export(Color) var deactivated_dark_color
export(NodePath) var active_lights
export(NodePath) var inactive_lights

func _on_power_deactivated():
	if !Global.stat("capacitor_113"):
		var _x = Global.add_stat("capacitor_113")
		_x = Global.abolish_notes(["the_tree_tower", "village_tower"])
	get_tree().call_group(reflection_group, "set", "interior_ambient_color", deactivated_color)
	get_tree().call_group(reflection_group, "set", "interior_dark_ambient_color", deactivated_dark_color)
	for c in get_node(active_lights).get_children():
		if c is Light:
			c.hide()
	get_node(inactive_lights).show()
	$active_entities/tower_interior3/dswitch_a2.deactivate()
	var env := $active_entities/env_tower
	env.default_music = null
	env.rescue_available = false
	env.update_environment()
