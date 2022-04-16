extends Spatial

signal game_completed

export(int) var max_jumps := 1
export(int) var bugs_earned := 2

var active := false

func _ready():
	if has_node("flag"):
		$flag.hide()

func start_game():
	Global.get_player().teleport_to($game_start.global_transform)
	var _x = $game_target.connect(
		"body_entered", self, "_on_target_entered",
		[], CONNECT_ONESHOT)

func _on_target_entered(body):
	if body is PlayerBody:
		if has_node("flag"):
			$flag.hide()
		var _x = Global.add_stat(get_stat())
		_x = Global.add_item("bug", bugs_earned)
		emit_signal("game_completed")

func get_stat() -> String:
	return str(get_path()) + "/completed"

func completed() -> bool:
	return Global.stat(get_stat()) != 0
