extends Panel

func set_active(a):
	if a:
		$buttons/new_game.grab_focus()

func _on_new_game_pressed():
	$new_game.popup_centered()

func _on_new_game_confirmed():
	Global.reset_game()
