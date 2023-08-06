extends NPC

export(NodePath) var tutorial_node
onready var tut = get_node(tutorial_node) if tutorial_node else null

var tutorial := ""

func start_pistol_tutorial():
	start_tutorial("pistol")

func start_tutorial(wep: String):
	if wep == "pistol":
		$"../tutorials/pistol/prompt_aim".input_actions.append(
			"combat_aim_toggle" if InputManagement.using_gamepad else "combat_aim")
	custom_entry = wep + "_tutorial"
	tutorial = wep
	var tw = tut.get_node(tutorial)
	global_transform = tw.get_node("ref_armstrong").global_transform
	Global.get_player().teleport_to(tw.get_node("ref_player").global_transform)
	for c in tw.get_children():
		if "enabled" in c:
			c.enabled = true

func end_tutorial():
	var _x = Global.add_stat("armstrong/tutorial_complete/"+tutorial)
	var tw = tut.get_node(tutorial)
	for c in tw.get_children():
		if "enabled" in c:
			c.enabled = false
	custom_entry = ""
	tutorial = ""

func in_tutorial():
	return tutorial != ""
