extends Area

func _ready():
	if Global.stat("cave137/flag_prompt"):
		queue_free()
	else:
		var _x = connect("body_entered", self, "_on_body_entered")

func _on_body_entered(b):
	if b is PlayerBody and Global.count("flag"):
		if b.ui.equipment_inventory.size() > 1:
			b.ui.show_prompt(["choose_item"], "(Hold) Switch Items")
			b.ui.queue_prompt(["use_item"], "Place Flag")
		else:
			b.ui.show_prompt(["use_item"], "Place Flag")
		Global.add_stat("cave137/flag_prompt")
		queue_free()
