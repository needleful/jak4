extends StaticBody

signal damaged

export(bool) var one_time := false

var damage_count := 0


func take_damage(_d, _dir):
	if one_time and damage_count > 0:
		return
	emit_signal("damaged")
	if one_time:
		damage_count += 1
		remove_from_group("target")
