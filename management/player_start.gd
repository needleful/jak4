extends Position3D

# Invisible tags that are used in multiple places
const implicit_stats := [
	"jackie/flaws",
	"daddy_issues"
]

func _ready():
	if !Global.valid_game_state && !Global.player_spawned:
		Global.remember("jackie")
		var _x = Global.add_item("housing_paperwork")
		Global.add_note(
			"This is the journal of Jacqueline Southcott. Please do not read beyond this point.\nIf found, please return by post to\n\t1292 North Graham Road\n\tSecond Floor, Apartment 22\n\tDockson.",
			["jackie"])
		Global.remember("mum")
		_x = Global.add_stat("mum/left")
		Global.add_note(
			"I suppose if I'd been born out here, I'd have been like Mother. Austere. Stoic. That's what Father about her, at least.",
			["mum", "mum/left"])
		Global.add_note(
			"She left without a trace when I was barely a toddler. According to my father, she only took a small suitcase with two changes of clothing.",
			["mum", "mum/left"])
		Global.mark_map(
			"hideaway",
			"My landing point on this excursion. Not much to look at aside from the Medium.")
		var p = get_player()
		if p:
			p.teleport_to(global_transform)
		Global.player_spawned = true
		for tag in implicit_stats:
			_x = Global.add_stat(tag)

func get_player():
	return get_tree().current_scene.get_node("player")
