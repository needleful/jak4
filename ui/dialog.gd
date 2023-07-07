extends Control

var last_focused :Control

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		set_active(is_visible_in_tree())

func _ready():
	set_process_input(false)

func _input(event):
	if event is InputEventMouse:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func set_active(a):
	set_process_input(a)
	if !a:
		var f = get_focus_owner()
		if f and is_a_parent_of(f):
			last_focused = f
	elif is_instance_valid(last_focused):
		last_focused.grab_focus()
