extends Control

onready var tabs: TabContainer = $tabs

func _input(event):
	if visible and tabs.current_tab != 0 and event.is_action_pressed("ui_cancel"):
		get_parent().unpause()

func set_active(a):
	set_process_input(a)
	if a:
		safe_set_tab(tabs.current_tab)
	if !a:
		var c = tabs.get_current_tab_control()
		if c.has_method("set_active"):
			c.set_active(false)
	set_process_input(a)

func next():
	var c = tabs.current_tab + 1
	safe_set_tab(c)

func prev():
	var c = tabs.current_tab - 1
	safe_set_tab(c)

func safe_set_tab(tab):
	if tab < 0 or tab >= tabs.get_tab_count():
		return
	
	var c = tabs.get_current_tab_control()
	if c.has_method("set_active"):
		c.set_active(false) 
		
	tabs.current_tab = tab
	
	c = tabs.get_current_tab_control()
	if c.has_method("set_active"):
		c.set_active(true)
