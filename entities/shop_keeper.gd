extends Node

export(Resource) var dialog_sequence
export(String) var visual_name: String = "Shop Keeper"
export(String, FILE, "*.json") var inventory: String

var inventory_data: Dictionary

func _ready():
	var file := File.new()
	var _x = file.open(inventory, File.READ)
	var text = file.get_as_text()
	file.close()
	inventory_data = JSON.parse(text).result
	for pitem in inventory_data.persistent:
		pitem["C"] -= Global.stat(item_bought_stat(pitem["I"]))
	$AnimationPlayer.play("Idle-loop")

func get_inventory() -> Dictionary:
	return inventory_data

func mark_sold(id: String):
	var bought: Dictionary = item_data(inventory_data.persistent, id)
	if !bought.empty():
		var _x = Global.add_stat(item_bought_stat(id))
	else:
		bought = item_data(inventory_data.temporary, id)
	if bought.empty():
		print_debug("BUG: marking sale of non-existent ", id)
	else:
		bought["C"] -= 1

func item_bought_stat(id) -> String:
	var s =  "bought/"+name+"/"+id
	return s

func item_data(array: Array, id: String) -> Dictionary:
	for c in array:
		if c["I"] == id:
			return c
	return {}

func _on_dialog_trigger_body_entered(body):
	if !(body is PlayerBody):
		print_debug("BUG: Non-player triggered dialog node ", get_path())
		return
	if body.can_talk():
		body.start_dialog(self, dialog_sequence, self)
