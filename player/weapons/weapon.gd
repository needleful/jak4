extends Spatial
class_name Weapon

var charge_fire := false
var time_firing := 0.25
var infinite_ammo := false
var locks_on := true

func fire() -> bool:
	return false

func stow():
	if is_inside_tree():
		get_parent().remove_child(self)
