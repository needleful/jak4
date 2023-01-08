extends NPC_Shop

export(bool) var only_if_saved := true
export(Array, NodePath) var enemies := []
export(String) var game_label := "Enemies"

var saved := false

#TODO: track multiple games to avoid conflicts
func _init():
	visual_name = "Riley"

func _ready():
	if only_if_saved and !Global.stat("riley/saved"):
		queue_free()
	elif Global.stat(str(get_path()) + "/saved"):
		queue_free()
	for i in range(enemies.size()):
		# convert from node-relative to absolute position
		assert(has_node(enemies[i]))
		var n = get_node(enemies[i])
		enemies[i] = n.get_path()
	for e in enemies:
		var _x = get_node(e).connect("died", self, "_on_target_died", [], CONNECT_ONESHOT)

func _on_target_died(_id, path):
	var idx = enemies.find(path)
	if idx < 0:
		print_debug("Enemy was not in list! ", path)
		return

	var p = Global.get_player()
	if enemies.size() == 1:
		var _x = Global.add_stat("riley/saved")
		_x = Global.add_stat(str(get_path()) + "/saved")
		saved = true
		
	# Assume the player is playing our game
	if p.game_ui.label == game_label and p.game_ui.in_game:
		p.game_ui.value = enemies.size() - 1
		p.game_ui.remove_target(get_node(enemies[idx]))
		if saved:
			p.game_ui.complete_game()
	
	enemies.remove(idx)
	
func track_enemies():
	var player = Global.get_player()
	Global.save_checkpoint(player.global_transform.origin)
	player.game_ui.start_game(game_label)
	player.game_ui.value = enemies.size()
	for e in enemies:
		player.game_ui.add_target(get_node(e))
