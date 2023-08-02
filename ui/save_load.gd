extends Control

var show_background := true

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		set_active(is_visible_in_tree())

func set_active(a):
	if a:
		$buttons/new_game.focus_mode = FOCUS_ALL
		$buttons/new_game.grab_focus()
	else:
		$AnimationPlayer.play("RESET")

func set_background_texture(t: Texture):
	$TextureRect.texture = t
	
func _on_new_game_pressed():
	$AnimationPlayer.play("show_new_game")
	yield(get_tree().create_timer(0.1), "timeout")
	if is_inside_tree() and is_visible_in_tree():
		$buttons/new_game.focus_mode = FOCUS_NONE
		$new_game.grab_button_focus()

func _on_new_game_confirmed():
	Global.reset_game()

func _on_new_game_cancelled():
	$AnimationPlayer.play("cancel")
	yield(get_tree().create_timer(0.1), "timeout")
	if is_inside_tree() and is_visible_in_tree():
		$buttons/new_game.focus_mode = FOCUS_ALL
		$buttons/new_game.grab_focus()
	
