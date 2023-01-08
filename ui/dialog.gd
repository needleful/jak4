extends Control

var last_focused :Control

func set_active(a):
	if !a:
		last_focused = get_focus_owner()
	elif last_focused:
		last_focused.grab_focus()
