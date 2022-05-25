extends Spatial

const time_firing := 0.25

var charge_fire := false
var infinite_ammo := false

var toggled := false

func fire():
	toggled = !toggled
	if toggled:
		Engine.time_scale = 0.5
	else:
		Engine.time_scale = 1.0
	return true
