extends Node

func _ready():
	var _x = Global.connect("stat_changed", self, "_on_stat_changed")

func _on_stat_changed(stat, amount):
	if !Global.stat("persephone/intro") and stat == "mum/info" and amount >= 2:
		var _x = Global.add_stat("persephone/calling")
		get_tree().call_group("payphones", "activate")
	if stat == "persephone/calling" and amount == 0:
		get_tree().call_group("payphones", "deactivate")
