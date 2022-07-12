extends TabContainer

func set_active(a):
	if a:
		safe_set_tab(current_tab)
	if !a:
		var c = get_current_tab_control()
		if c.has_method("set_active"):
			c.set_active(false)

func next():
	var c = current_tab + 1
	safe_set_tab(c)

func prev():
	var c = current_tab - 1
	safe_set_tab(c)

func safe_set_tab(tab):
	if tab < 0 or tab >= get_tab_count():
		return
	
	var c = get_current_tab_control()
	if c.has_method("set_active"):
		c.set_active(false) 
		
	current_tab = tab
	
	c = get_current_tab_control()
	if c.has_method("set_active"):
		c.set_active(true)
