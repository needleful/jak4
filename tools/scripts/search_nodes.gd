tool
extends EditorScript

func _run():
	search(get_scene(), "is_chunk")

func search(node:Node, function):
	if call(function, node):
		print_debug("Found: ", node.get_path())
		node.get_node("StaticBody").remove_from_group("terrain")
	else:
		for c in node.get_children():
			search(c, function)

func collides_with_vis(node: Node):
	return node is CollisionObject and !(node is EnemyBody) and node.collision_layer & 6

func is_light(node: Node):
	var script := node.get_script() as Script
	return script and script.resource_path == "res://entities/visual/light.gd"

func is_chunk(node: Node):
	return node.name.begins_with("chunk0") or node.name.begins_with("chunk1")
