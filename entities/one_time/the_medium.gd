extends Node

onready var entrance := $entrance
onready var mom_door := $door2

onready var dialog_collision := $dialog_zone/CollisionShape

var active := false

func activate_scanner():
	Global.save_checkpoint(Global.get_player().global_transform.origin)
	if active:
		return
	var a = Global.add_stat("medium/activated")
	if a == 1:
		var _x = Global.complete_task("activate_the_medium", "I've activated it. I really did it.")
	a = Global.set_stat("medium/last_activation", OS.get_datetime(true))
	active = true
	dialog_collision.disabled = true
	mom_door.add_power(1)

func _on_entrance_body_entered(_b):
	if !active:
		return
	active = false
	dialog_collision.disabled = false
	var _x = Global.add_stat("medium/deactivated")
	mom_door.clear_power()

func _on_epic_boss_died(_id, _fullPath):
	$epic_death_timer.start()
