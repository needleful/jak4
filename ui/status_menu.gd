extends Control

onready var tabs: TabContainer = $AspectRatioContainer/sized/tabs
onready var ui = get_parent()

func _input(event):
	if !is_visible_in_tree():
		return
	if !Global.using_gamepad:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("ui_cancel"):
		var t = tabs.get_current_tab_control()
		if tabs.current_tab != 0 or t.level == 0:
			ui.unpause()
		else:
			t.set_level(t.level - 1)
		get_tree().set_input_as_handled()

func set_active(a):
	set_process_input(a)
	if a:
		safe_set_tab(tabs.current_tab)

func next():
	var c = tabs.current_tab + 1
	safe_set_tab(c)

func prev():
	var c = tabs.current_tab - 1
	safe_set_tab(c)

func safe_set_tab(tab):
	if tab < 0:
		tab = tabs.get_tab_count() - 1
	elif tab >= tabs.get_tab_count():
		tab = 0
	tabs.current_tab = tab

func _notification(what):
	var date := get_node("AspectRatioContainer/sized/date_time/margin/stats")
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
		var days = Global.stat("current_day") + 1
		date.get_node("date").text = "%s %s of travel" % [
			NumberToString.verbose(days).capitalize(),
			"day" if days == 1 else "days" ] 
		if get_tree().current_scene.has_method("get_time"):
			var time = get_tree().current_scene.get_time()
			date.get_node("time").text = "%s" % NumberToString.say_time(time, false, true)

func _on_wardrobe_exited():
	ui.unpause()

func _on_Wardrobe_active(active):
	$TextureRect.visible = !active
	$background.visible = !active
	Global.get_player().set_camera_render(active or !get_tree().paused)
	if !active and get_tree().paused:
		ui.take_screen_shot()
