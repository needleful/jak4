extends Control

var format = tr("Item Found: %s")

func show_get(id: String):
	$Label.text = format % id.capitalize()
	$AnimationPlayer.play("show_and_fade")
