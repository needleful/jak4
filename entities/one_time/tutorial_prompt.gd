extends Area

export(bool) var enabled: bool = true setget set_enabled
export(Array, String) var input_actions: Array
export(String) var text: String

func _ready():
	set_enabled(enabled)
	var _x = connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body is PlayerBody:
		body.show_prompt(input_actions, text)

func set_enabled(e: bool):
	enabled = e
	if is_inside_tree():
		for c in get_children():
			if c is CollisionShape:
				c.disabled = !enabled
