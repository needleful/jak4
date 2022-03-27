extends Area

export(Array, Texture) var gamepad_textures: Array
export(Array, Texture) var keyboard_textures: Array

export(String) var gamepad_text : String
export(String) var keyboard_text : String

var enabled = false setget set_enabled

func _ready():
	set_enabled(false)
	if keyboard_text == "":
		keyboard_text = gamepad_text
	var _x = connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body is PlayerBody:
		if Global.using_gamepad:
			body.show_prompt(gamepad_textures, gamepad_text)
		else:
			body.show_prompt(keyboard_textures, keyboard_text)

func set_enabled(e: bool):
	enabled = e
	for c in get_children():
		if c is CollisionShape:
			c.disabled = !enabled
