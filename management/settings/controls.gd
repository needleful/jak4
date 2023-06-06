extends Node
class_name ControlsSettings

export(float, 0.1, 4.0, 0.2) var camera_sensitivity setget set_sns, get_sns
export(bool) var invert_x setget set_invx, get_invx
export(bool) var invert_y setget set_invy, get_invy

onready var player = Global.get_player()

func get_name() -> String:
	return "Controls"

func set_sns(value: float):
	camera_sensitivity = value
	if is_instance_valid(player):
		player.sensitivity = value

func get_sns():
	if is_instance_valid(player):
		return player.sensitivity
	else:
		return camera_sensitivity

func set_invx(value):
	invert_x = value
	if is_instance_valid(player):
		player.invert_x = value

func get_invx():
	if is_instance_valid(player):
		return player.invert_x
	else:
		return invert_x
	
func set_invy(value):
	invert_y = value
	if is_instance_valid(player):
		player.invert_y = value

func get_invy():
	if is_instance_valid(player):
		return player.invert_y
	else:
		return invert_y
