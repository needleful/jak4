extends Usable

func _init():
	._init()
	ammo = "flag"
	icon = preload("res://ui/icons/item_flag.png")

func use():
	.use()
	player.set_state(player.State.PlaceFlag)

func can_use():
	if !player.best_floor:
		return false
	elif player.best_floor.is_in_group("dynamic"):
		return false 
	return .can_use()
