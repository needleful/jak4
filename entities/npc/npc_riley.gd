extends NPC

export(bool) var only_if_saved := true
export(Array, NodePath) var enemies := []

var saved := false

#TODO: track multiple games to avoid conflicts

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
	if idx >= 0:
		enemies.remove(idx)
	Global.get_player().game_ui.value = enemies.size()
	if enemies.size() == 0:
		Global.get_player().game_ui.hide()
		var _x = Global.add_stat("riley/saved")
		_x = Global.add_stat(str(get_path()) + "/saved")
		saved = true
	
func track_enemies():
	var player = Global.get_player()
	player.game_ui.show()
	player.game_ui.label = "Enemies"
	player.game_ui.value = enemies.size()
