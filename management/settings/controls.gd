extends Node
class_name ControlsSettings

enum Prompts {
	AutoDetect,
	Gamepad,
	Keyboard
}

export(Prompts) var button_prompts = Prompts.AutoDetect setget set_prompts
export(float, 0.1, 4.0, 0.2) var camera_sensitivity
export(bool) var invert_x
export(bool) var invert_y

func get_name() -> String:
	return "Controls"

func set_prompts(value):
	button_prompts = value
	if button_prompts != Prompts.AutoDetect:
		InputManagement.using_gamepad = button_prompts == Prompts.Gamepad
	get_tree().call_group("input_prompt", "_refresh")
