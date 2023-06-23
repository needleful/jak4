extends ColorRect

func control_screen(val):
	visible = val
	if val:
		modulate = Color.white
