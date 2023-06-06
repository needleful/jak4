extends Position3D

func _ready():
	if !Global.valid_game_state && !Global.player_spawned:
		Global.mark_map(
			"hideaway",
			"My landing point on this excursion. Not much to look at aside from the Medium.")
		Global.remember("mum")
		Global.add_note(
			"I suppose if I'd been born out here, I'd have been like Mother. Austere. Stoic. That's what Father about her, at least.", ["mum"])
		Global.remember("jackie")
		Global.add_note(
			"This is the journal of Jacqueline Southcott. Please do not read beyond this point.\nIf found, please return by post to\n\t1292 North Graham Road\n\tSecond Floor, Apartment 22\n\tDockson.", ["jackie"])
		var p = get_player()
		if p:
			p.teleport_to(global_transform)
		Global.player_spawned = true

func get_player():
	return get_tree().current_scene.get_node("player")
