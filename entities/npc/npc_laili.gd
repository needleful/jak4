extends NPC

export(NodePath) var climbing_path
export(NodePath) var laili_start
export(NodePath) var player_start
export(NodePath) var plane

onready var plane_node : Node = (
	get_node(plane) if has_node(plane) else null)

var crashed := false

class LailiGame:
	const title := "Climb to the Top"
	const friendly_id := ""
	const respawn := true
	var id: int
	
	func _init(p_id: int):
		id = p_id
	
	func end():
		pass

onready var climb_game = LailiGame.new(hash(get_path()))

func start_climb() -> bool:
	if CustomGames.is_active():
		return false
	custom_entry = "laili_climb"
	CustomGames.start(climb_game)
	var _x = CustomGames.connect("game_completed", self, "_on_game_completed")
	get_node(climbing_path).start()
	global_transform = get_node(laili_start).global_transform
	Global.get_player().teleport_to(get_node(player_start).global_transform)
	return true

func _on_game_completed():
	if CustomGames.active_game == climb_game:
		var _x = Global.add_stat("laili/pre_flight")

func fly():
	if has_node(plane):
		var _x = Global.add_stat("laili/flight")
		var res = Global.get_player().get_dialog_viewer().exit()
		get_node(plane).activate()
		return res
	else:
		return false

func reset_flight():
	if plane_node:
		plane_node.reset()
