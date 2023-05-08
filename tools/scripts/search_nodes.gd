tool
extends EditorScript

func _run():
	search(get_scene(), "is_light")

func search(node, function):
	if call(function, node):
		print("Naughty: ", node.get_path())
	else:
		for c in node.get_children():
			search(c, function)

func collides_with_vis(node: Node):
	return node is CollisionObject and !(node is EnemyBody) and node.collision_layer & 6

func is_light(node: Node):
	var script := node.get_script() as Script
	return script and script.resource_path == "res://entities/visual/light.gd"
