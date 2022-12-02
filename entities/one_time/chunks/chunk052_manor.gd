extends Node

var captain_redford : FollowerNPC

func _ready():
	if Global.stat("manor052/investigation1"):
		_on_captain_redford_npc_event("investigation1")

func _on_front_door_opened():
	Global.add_stat("chunk052/front_door/open")

func _on_captain_redford_npc_event(event_type):
	match event_type:
		"investigation1":
			$"../zone_estate/rotating_map_dialog".enabled = true

func _on_rotating_map_completed():
	$"../zone_estate/bookshelf".add_power()
	$"../zone_estate/rotating_map_dialog".enabled = false
