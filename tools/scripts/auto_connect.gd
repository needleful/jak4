tool
extends EditorScript

func _run():
	var base := get_scene().get_node("active_entities/zone_entrance")
	var ent_d = base.get_node("controller")
	var power_things = base.get_node("activation")
	
	for c in power_things.get_children():
		var _x = c.connect("activated", ent_d, "_on_activated", [], Object.CONNECT_PERSIST)
		_x = c.connect("deactivated", ent_d, "_on_deactivated", [], Object.CONNECT_PERSIST)
