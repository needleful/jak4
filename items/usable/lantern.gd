extends Usable

func _init():
	icon = preload("res://ui/icons/item_light.png")

func use():
	player.lantern.light_enabled = !player.lantern.light_enabled

func equip():
	player.lantern.visible = true

func unequip():
	if !player.lantern.light_enabled:
		player.lantern.visible = false
