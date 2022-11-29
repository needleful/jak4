extends KinematicBody

signal toggled(on, instant)

export(String) var key := "" 
export(bool) var player_only := true
export(bool) var persistent := true

func _ready():
	if persistent and Global.stat(get_path()):
		emit_signal("toggled", true, true)

func take_damage(_d, _dir, source):
	if player_only and !(source is PlayerBody):
		return
	elif !Global.count(key):
		return
	else:
		if persistent:
			Global.set_stat(get_path(), true)
		emit_signal("toggled", true, false)
