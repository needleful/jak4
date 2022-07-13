extends Control

onready var tabs: TabContainer = $tabs

func set_active(a):
	if a:
		safe_set_tab(tabs.current_tab)
	if !a:
		var c = tabs.get_current_tab_control()
		if c.has_method("set_active"):
			c.set_active(false)

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
