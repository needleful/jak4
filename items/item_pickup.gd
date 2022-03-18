extends Area

export(String) var item_id
export(int) var quantity = 1
export(PackedScene) var preview

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(_b):
	Global.add_item(item_id)
	queue_free()
