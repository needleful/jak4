extends Node

var pools : Dictionary
var queued_to_remove: Dictionary

func _init():
	pools = {}
	queued_to_remove = {}

func _process(delta):
	if queued_to_remove.empty():
		set_process(false)
		return
	for path in queued_to_remove.keys():
		if !has_node(path):
			var _x = queued_to_remove.erase(path)
			continue
		queued_to_remove[path] -= delta
		if queued_to_remove[path] <= 0:
			get_node(path).queue_free()
			var _x = queued_to_remove.erase(path)

func timed_delete(path: NodePath, time: float):
	queued_to_remove[path] = time
	set_process(true)

func has(type:String) -> bool:
	return type in pools and !pools[type].empty()

func get(type:String):
	if has(type):
		return pools[type].pop_back()
	else:
		return null

func put(type:String, node:Node):
	if !type in pools:
		pools[type] = []
	pools[type].push_back(node)
	if node.is_inside_tree():
		node.get_parent().remove_child(node)
