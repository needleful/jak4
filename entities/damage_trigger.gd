extends StaticBody

signal damaged

func take_damage(_d, _dir):
	emit_signal("damaged")
