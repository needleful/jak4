extends Node

func _on_epic_boss_died(_id, _fullPath):
	$epic_death_timer.start()


func activate():
	$activator.play("Activate")

func deactivate():
	$activator.play("Deactivate")
