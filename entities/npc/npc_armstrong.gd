extends NPC

export(NodePath) var tutorial_node
onready var tut = get_node(tutorial_node)

var tutorial := ""

func start_pistol_tutorial():
	start_wep_tutorial("pistol")

func start_wep_tutorial(wep: String):
	tutorial = wep
	var tw = tut.get_node(tutorial)
	global_transform = tw.get_node("ref_armstrong").global_transform
	Global.get_player().teleport_to(tw.get_node("ref_player").global_transform)
	for c in tw.get_children():
		if "enabled" in c:
			c.enabled = true

func end_tutorial():
	Global.add_stat("armstrong/tutorial_complete/"+tutorial)
	var tw = tut.get_node(tutorial)
	for c in tw.get_children():
		if "enabled" in c:
			c.enabled = false
	tutorial = ""
