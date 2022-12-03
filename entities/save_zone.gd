extends Area

export(bool) var heal := true

func _ready():
	var _x = connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body is PlayerBody and body.can_save():
		if heal:
			body.heal()
		Global.save_checkpoint(body.global_transform.origin)
