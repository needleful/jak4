extends Area

func _ready():
	var _x = connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body is PlayerBody:
		Global.save_checkpoint(body.global_transform.origin)
