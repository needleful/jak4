extends Control

var level := 0
onready var ui := get_parent().get_parent().get_parent()
onready var main_menu := $foreground/main_menu
onready var main_anim := $foreground/main_menu/AnimationPlayer

onready var options_panel := $foreground/mainOptions
onready var options_anim := $foreground/mainOptions/AnimationPlayer
onready var options_template := $foreground/options_template
var show_background = true

var option_menus : Dictionary

func _ready():
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
	match l:
		0:
			for c in main_menu.get_children():
				if c is Control:
					c.focus_mode = Control.FOCUS_ALL
			main_anim.play("fade_in")
			if level == 1:
				$foreground/main_menu/options.grab_focus()
			else:
				$foreground/main_menu/resume.grab_focus()
			
				
			options_panel.hide()
			
			$foreground/audioOptions.hide()
			$foreground/controlOptions.hide()
			$foreground/displayOptions.hide()
			$foreground/graphicsOptions.hide()
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
			options_panel.get_child(0).grab_focus()
			
			$foreground/audioOptions.hide()
			$foreground/controlOptions.hide()
			$foreground/displayOptions.hide()
			$foreground/graphicsOptions.hide()
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
	level = l

func generate_menus():
	option_menus = {}
	for s in Settings.sub_options:
		var menu := options_template.duplicate()
		menu.menu_name = s
		menu.generate()
	options_template.queue_free()
	options_template = null

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

func _on_displayOptions_ui_redraw():
	get_tree().call_group("ui_settings_custom", "ui_settings_apply")

func _on_back_pressed():
	set_level(level - 1)
