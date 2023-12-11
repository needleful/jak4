extends Node

func _ready():
	var _x = get_parent().connect("saved", self, "_on_saved")

func _on_saved():
	$anim.stop()
	$anim.play("save")
