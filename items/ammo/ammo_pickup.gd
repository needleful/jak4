extends ItemPickup

export(bool) var respawn_on_player_death := false

func _init():
	persistent = false

func _on_area_body_entered(body):
	if !visible:
		return
	if Global.count(item_id) >= AmmoSpawner.MAX[item_id]:
		return
	if respawn_on_player_death:
		var _x = Global.add_item(item_id, quantity)
		body.get_item(self)
		if persistent:
			Global.mark_picked(get_path())
			if friendly_name != "":
				_x = Global.add_stat(friendly_name)
		if !Global.get_player().is_connected("died", self, "respawn"):
			_x = Global.get_player().connect("died", self, "respawn", [], CONNECT_ONESHOT)
		emit_signal("picked")
		emit_signal("picked_item", item_id)
		hide()
	else:
		._on_area_body_entered(body)
	var total = Global.count(item_id)
	var max_ammo = AmmoSpawner.MAX[item_id]
	if total > max_ammo:
		var _x = Global.remove_item(item_id, total - max_ammo)

func respawn():
	show()
