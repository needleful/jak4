extends Control

var level := 0
export(NodePath) var ui_path
onready var ui = get_node(ui_path)
onready var main_menu := $foreground/main_menu
onready var main_anim := $foreground/main_menu/AnimationPlayer

onready var options_panel := $foreground/options_panel
onready var options_anim := $foreground/options_panel/AnimationPlayer
onready var button_template:Button = $foreground/options_panel/button_template
onready var options_template := $foreground/options_template
var show_background = true

var option_menus : Dictionary
var last_focused : Array

func _ready():
	last_focused = [null, null, null]
	generate_menus()
	hide()

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		set_active(is_visible_in_tree())

func set_active(active):
	if active:
		Settings.load_settings()
		set_level(0)
	else:
		Settings.save_settings()

func set_level(l: int):
	if l < 0:
		l = 0
	if l > 2:
		l = 2
	if l > level:
		last_focused[level] = get_focus_owner()
	match l:
		0:
			for c in main_menu.get_children():
				if c is Control:
					c.focus_mode = Control.FOCUS_ALL
			main_anim.play("fade_in")
			if l >= level:
				$foreground/main_menu/resume.grab_focus()
			options_panel.hide()
			for m in option_menus.values():
				m.hide()
		1:
			if level == 0:
				for c in main_menu.get_children():
					if c is Control:
						c.focus_mode = Control.FOCUS_NONE
				main_anim.play("fade_out")
					
			for c in options_panel.get_children():
				if c is Control:
					c.focus_mode = Control.FOCUS_ALL
					
			options_panel.show()
			options_anim.play("fade_in")
			if l >= level:
				options_panel.get_child(0).grab_focus()
			
			for m in option_menus.values():
				m.hide()
		2:
			if level == 0:
				main_anim.play("fade_out")
				for c in main_menu.get_children():
					if c is Control:
						c.focus_mode = Control.FOCUS_NONE
			elif level == 1:
				for c in options_panel.get_children():
					if c is Control:
						c.focus_mode = Control.FOCUS_NONE
				options_anim.play("fade_out")
	if l < level and last_focused[l]:
		last_focused[l].grab_focus()
	level = l

func generate_menus():
	option_menus = {}
	var top_button := button_template
	for s in Settings.sub_options:
		var menu := options_template.duplicate()
		menu.menu_name = s
		$foreground.add_child(menu)
		menu.hide()
		menu.generate()
		option_menus[s] = menu
		
		var button := button_template.duplicate()
		button.text = s
		options_panel.add_child_below_node(top_button, button)
		top_button = button
		button.focus_neighbour_left = button.get_path()
		var _x = button.connect("pressed", self, "_on_option_selected", [s])
	button_template.queue_free()
	button_template = null
	options_template.queue_free()
	options_template = null

func _on_option_selected(submenu: String):
	set_level(2)
	for m in option_menus:
		var o = option_menus[m]
		o.visible = submenu == m
		if o.visible:
			o.grab_focus()

func _on_resume_pressed():
	ui.unpause()

func _on_options_pressed():
	set_level(1)

func _on_reload_pressed():
	Global.get_player().respawn()
	ui.unpause()

func _on_quit_pressed():
	Global.save_sync()
	get_tree().quit()

func _on_ui_redraw():
	get_tree().call_group("ui_settings_custom", "ui_settings_apply")

func _on_back_pressed():
	set_level(level - 1)
