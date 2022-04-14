extends Label

func _input(event):
	if event.is_action_pressed("gamer_stream"):
		visible = !visible
