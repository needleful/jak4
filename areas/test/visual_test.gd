extends Spatial

export(PackedScene) var probes: PackedScene

onready var node1: Node = $set1
onready var node2: Node = $set2

onready var probe_scene1 := probes.instance()
onready var probe_scene2 := probes.instance()

func _on_toggled1(toggled: bool):
	if !node1:
		return
	elif toggled:
		if not probe_scene1.is_inside_tree():
			node1.add_child(probe_scene1)
		node1.show()
	else:
		node1.hide()
	probe_scene1.visible = toggled

func _on_toggled2(toggled: bool):
	if !node2:
		return
	elif toggled:
		node2.add_child(probe_scene2)
	else:
		node2.remove_child(probe_scene2)
	probe_scene2.visible = toggled

