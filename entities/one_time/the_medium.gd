extends Node

func _on_entrance_body_entered(_b):
	Global.save_checkpoint(Global.get_player().global_transform.origin)
	
func _on_epic_boss_died(_id, _fullPath):
	$epic_death_timer.start()

func complete_game():
	$ending_dialog.enter_dialog()
 
