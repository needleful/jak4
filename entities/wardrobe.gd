extends Spatial

func _on_entrance_body_entered(body):
	if body is PlayerBody:
		$ui.enter(body)
