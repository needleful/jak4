extends Spatial

func _ready():
	if Global.stat("cave137/locked"):
		disable_music()
	else:
		var _x := Global.connect("stat_changed", self, "_on_stat_changed")

func disable_music():
	$env_evil.default_music = null
	$env_evil.update_environment()

func _on_stat_changed(stat: String, value):
	if stat == "cave137/locked" and value:
		disable_music()
