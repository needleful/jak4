extends Node

var pools := {}

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
		node.get_parent().call_deferred("remove_child", node)
