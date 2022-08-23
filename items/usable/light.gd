extends Usable

func _init():
	icon = preload("res://ui/icons/item_light.png")

func use():
	player.light.visible = !player.light.visible
