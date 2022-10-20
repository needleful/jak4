extends VBoxContainer

export(float) var show_time := 4.0

func temp_show():
	print("Temp show")
	if visible:
		print("Already visible")
		return
	show()
	$Timer.start(show_time)

func open():
	show()
	$Timer.stop()

func close():
	hide()
	$Timer.stop()

func _on_Timer_timeout():
	print("Hidden")
	hide()

func preview(main_item: Usable, item_above: Usable, item_below: Usable):
	print("Previewing")
	$prev_item.texture = item_above.icon
	$equipped/icon.texture = main_item.icon
	$next_item.texture = item_below.icon
	if main_item.ammo != "":
		$equipped/count.show()
		$equipped/count.text = str(Global.count(main_item.ammo))
	else:
		$equipped/count.hide()
