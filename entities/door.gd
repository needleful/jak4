extends KinematicBody

export(int) var required_power := 1

var power := 0
var open := false

func _on_activated():
	add_power()

func add_power(amount:= 1):
	power += amount
	var should_open := power >= required_power
	if should_open and !open:
		if has_node("AnimationPlayer"):
			$AnimationPlayer.play("Activate")
	elif !should_open and open:
		if has_node("AnimationPlayer"):
			$AnimationPlayer.play_backwards("Activate")
	open = should_open
