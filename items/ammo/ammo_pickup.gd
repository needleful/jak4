extends ItemPickup

func _init():
	persistent = false

func _on_area_body_entered(_body):
	if Global.count(item_id) >= AmmoSpawner.MAX[item_id]:
		return
	else:
		._on_area_body_entered(_body)
		var total = Global.count(item_id)
		var max_ammo = AmmoSpawner.MAX[item_id]
		if total > max_ammo:
			var _x = Global.remove_item(item_id, total - max_ammo)
