extends Control

signal pause_toggled(paused)

func _input(event):
	if get_tree().paused and (
		event.is_action_pressed("pause")
		or event.is_action_pressed("ui_cancel")
	):
		unpause()
		get_tree().set_input_as_handled()
	elif Global.can_pause and event.is_action_pressed("pause"):
		pause()
		

func _ready():
	hide()

func pause():
	get_tree().paused = true
	show()
	emit_signal("pause_toggled", true)
	# TODO: Mark visible
	$foreground/main_menu/resume.call_deferred("grab_focus")

func unpause():
	get_tree().paused = false
	hide()
	emit_signal("pause_toggled", false)

func _on_resume_pressed():
	unpause()

func _on_options_pressed():
	pass # Replace with function body.

func _on_reload_pressed():
	unpause()
	Global.get_player().respawn()

func _on_quit_pressed():
	Global.save_sync()
	get_tree().quit()
