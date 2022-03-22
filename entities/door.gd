extends KinematicBody

export(int) var required_power := 1

var power := 0

func _on_activated():
	add_power()

func add_power(amount:= 1):
	if power > required_power:
		power += amount
		return
	power += amount
	print("POWER: ", power)
	if power >= required_power:
		if has_node("AnimationPlayer"):
			$AnimationPlayer.play("Activate")
