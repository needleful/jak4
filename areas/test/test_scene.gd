extends Spatial

func _enter_tree():
	Global.test_scene = true

func start_day():
	var _x = Global.add_stat("current_day")
	get_tree().call_group("daily_schedule", "_on_midnight")
	if Global.stat("medium/activated") and !Global.stat("persephone/activated"):
		print("calling persephone")
		_x = Global.add_stat("persephone/activated")
		_x = Global.add_stat("persephone/calling")
