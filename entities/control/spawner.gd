extends Spatial

export(String) var listened_stat: String
var removed_children:Dictionary

func _init():
	removed_children = {}

func _ready():
	if listened_stat:
		if Global.stat(listened_stat):
			return
		else:
			var _x = Global.connect("stat_changed", self, "_on_stat_changed")
	for c in get_children():
		removed_children[c] = c.global_transform
		remove_child(c)

func spawn():
	for c in removed_children.keys():
		add_child(c)
		c.global_transform = removed_children[c]
	removed_children.clear()

func _on_stat_changed(stat, amount):
	if stat == listened_stat and amount:
		spawn()
