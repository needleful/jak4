extends Spatial

signal game_completed
signal game_failed

export(int) var max_jumps := 1
export(int) var bugs_earned := 2

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
	
	active = true
	game_target.show()
	jumps = 0
	
	player.game_ui.add_target(game_target)
	player.game_ui.value = max_jumps
	
	player.teleport_to(game_start.global_transform)
	var _x = player.connect("jumped", self, "_on_player_jumped")
	_x = game_target.connect(
		"body_entered", self, "_on_target_entered",
		[], CONNECT_ONESHOT)

func _on_player_jumped() :
	var player = Global.get_player()
	jumps += 1
	if jumps > max_jumps:
		active = false
		game_target.disconnect("body_entered", self, "_on_target_entered")
		player.disconnect("jumped", self, "_on_player_jumped")
		player.game_ui.fail_game()
		game_target.hide()
		emit_signal("game_failed")
	else:
		player.game_ui.value = max_jumps - jumps

func _on_target_entered(body):
	if body is PlayerBody:
		active = false
		body.game_ui.complete_game()
		game_target.hide()
		body.disconnect("jumped", self, "_on_player_jumped")
		body.celebrate(null)
		var _x = Global.add_stat(get_stat())
		_x = Global.add_item("bug", bugs_earned)
		emit_signal("game_completed")

func get_stat() -> String:
	return str(get_path()) + "/completed"

func completed() -> bool:
	return Global.stat(get_stat()) != 0
