extends Node

export(Array, Texture) var gamepad_textures: Array
export(Array, Texture) var keyboard_textures: Array

export(String) var gamepad_text : String
export(String) var keyboard_text : String

func show():
	var player := Global.get_player()
	if Global.using_gamepad:
		player.show_prompt(gamepad_textures, gamepad_text)
	else:
		player.show_prompt(keyboard_textures, keyboard_text)
