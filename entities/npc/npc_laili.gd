extends NPC

export(NodePath) var climbing_path
export(NodePath) var laili_start
export(NodePath) var player_start
export(NodePath) var plane
export(bool) var on_monument := false

onready var plane_node : Node = (
	get_node(plane) if has_node(plane) else null)

var crashed := false

class LailiGame:
	const title := "Climb to the Top"
	const friendly_id := "laili"
	const respawn := true
	const dialog_allowed := true
	var id: int
	
	func _init(p_id: int):
		id = p_id
	
	func end():
		pass

onready var climb_game = LailiGame.new(hash(get_path()))

func _ready():
	if on_monument and Global.task_is_complete("strange_girl"):
		global_transform = $"../laili_new_home".global_transform
		custom_entry = "laili_new_home"

func start_climb() -> bool:
	if CustomGames.is_active():
		return false
	# lol
	$"../not_pre_flight/laili_plane_v1".global_transform = (
		$"../laili_plane_start".global_transform)
	if has_node("../not_pre_flight/laili_plane_v1/laili_plane_blanket"):
		$"../not_pre_flight/laili_plane_v1/laili_plane_blanket".queue_free()
	on_monument = false
	custom_entry = "laili_climb"
	CustomGames.start(climb_game)
	var _x = CustomGames.connect("game_completed", self, "_on_game_completed")
	_x = CustomGames.connect("game_failed", self, "_on_game_failed")
	get_node(climbing_path).start()
	global_transform = get_node(laili_start).global_transform
	Global.get_player().teleport_to(get_node(player_start).global_transform)
	Global.get_player().ui.show_prompt(["reset"], "(Hold) Reset to Checkpoint when Stuck")
	return true

func show_plane() -> bool:
	# lol
	$"../not_pre_flight/laili_plane_v1/laili_plane_blanket".queue_free()
	return true

func cancel_climb() -> bool:
	CustomGames.end(false)
	return true

func _on_game_completed(_message):
	if CustomGames.active_game.friendly_id == "laili":
		var _x = Global.add_stat("laili/pre_flight")
	custom_entry = "laili"
	_disconnect_game()

func _on_game_failed(_message):
	get_node(climbing_path).cancel()
	custom_entry = "laili"
	_disconnect_game()

func _disconnect_game():
	if CustomGames.is_connected("game_completed", self, "_on_game_completed"):
		CustomGames.disconnect("game_completed", self, "_on_game_completed")
	if CustomGames.is_connected("game_failed", self, "_on_game_failed"):
		CustomGames.disconnect("game_failed", self, "_on_game_failed")

func fly():
	if has_node(plane):
		var _x = Global.add_stat("laili/flight")
		var res = Global.get_player().get_dialog_viewer().exit()
		Global.save_checkpoint(Global.get_player().get_save_transform())
		get_node(plane).activate()
		return res
	else:
		return false

func reset_flight():
	if plane_node:
		plane_node.reset()
		var p := Global.get_player()
		if p:
			p.fade_in()
			p.ui.show_prompt(["reset"], "(Hold) Spawn at Glider")
