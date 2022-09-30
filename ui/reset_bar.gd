extends ProgressBar

signal reset

const RESET_TIME := 2.0
const INCREASE := 1.0
const DECREASE := 3.0

func _process(delta):
	var change := 0.0
	if Input.is_action_pressed("reset"):
		change = INCREASE * delta
		show()
	else:
		change = -DECREASE * delta
	
	value = clamp(value + change, 0, 1)
	if value >= 1:
		emit_signal("reset")
		value = 0
	if value == 0:
		hide()
