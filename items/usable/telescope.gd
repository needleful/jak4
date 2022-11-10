extends Usable

func _init():
	._init()
	icon = preload("res://ui/icons/item_light.png")

func use():
	player.cam_rig.toggle_zoom()

func unequip():
	player.cam_rig.set_zoom(false)

func can_use():
	return true
