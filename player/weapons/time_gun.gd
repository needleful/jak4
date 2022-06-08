extends Spatial

const time_firing := 3.0

var charge_fire := false
var infinite_ammo := false

const TIME_SLOWED := 6.0

var time_amount := 1.0

func fire():
	if TimeManagement.time_slowed:
		TimeManagement.resume()
	else:
		TimeManagement.slow_time(time_amount*TIME_SLOWED)
	return true

func stow():
	pass
