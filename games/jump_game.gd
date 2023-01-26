extends Spatial

signal game_completed
signal game_failed

export(int) var max_jumps := 1
export(int) var bugs_earned := 2
export(int) var gems_earned := 4
export(String) var friendly_id := ""

var active := false
var jumps := 0
# TODO: Sound effect and confetti particles
onready var game_target := $game_target
onready var game_start := $game_start

func _ready():
	game_target.hide()

func start_game():
	var player = Global.get_player()
	var res = player.game_ui.start_game("Jumps")
	if !res:
		return
	
	Global.save_checkpoint(game_start.global_transform.origin)
	active = true
	game_target.show()
	jumps = 0
	
	player.game_ui.add_target(game_target)
	player.game_ui.value = max_jumps
	
	player.teleport_to(game_start.global_transform)
	var _x = player.connect("jumped", self, "_on_player_jumped")
	_x = player.game_ui.connect("cancelled", self, "_on_cancelled")
	_x = game_target.connect(
		"body_entered", self, "_on_target_entered",
		[], CONNECT_ONESHOT)

func _on_player_jumped() :
	var player = Global.get_player()
	jumps += 1
	if jumps > max_jumps:
		player.game_ui.fail_game()
		_end()
		emit_signal("game_failed")
	else:
		player.game_ui.value = max_jumps - jumps

func _on_cancelled():
	Global.get_player().game_ui.fail_game()
	_end()
	emit_signal("game_failed")

func _on_target_entered(body):
	if body is PlayerBody:
		body.game_ui.complete_game()
		body.celebrate()
		var complete_stat := get_stat() + "/completed"
		if !Global.stat(complete_stat):
			var _x = Global.add_stat(complete_stat)
			_x = Global.add_item("bug", bugs_earned)
		else:
			var _x = Global.add_stat(complete_stat)
			_x = Global.add_item("gem", gems_earned)
		_end()
		emit_signal("game_completed")

func _end():
	active = false
	game_target.hide()
	game_target.disconnect("body_entered", self, "_on_target_entered")
	Global.get_player().game_ui.disconnect("cancelled", self, "_on_cancelled")
	Global.get_player().disconnect("jumped", self, "_on_player_jumped")

func get_stat() -> String:
	if friendly_id != "":
		return friendly_id
	else:
		return str(get_path())

func completed() -> bool:
	return Global.stat(get_stat() + "/completed") != 0
