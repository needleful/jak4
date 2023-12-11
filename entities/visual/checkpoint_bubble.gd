extends Node

func _ready():
	var _x = get_parent().connect("saved", self, "_on_saved")

func _on_saved():
	if Global.temp_stat("checkpoint") and Global.temp_stat("checkpoint") == self:
		return
	else:
		Global.set_temp_stat("checkpoint", self)
	$anim.stop()
	$anim.play("save")
