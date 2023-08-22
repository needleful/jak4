tool
extends EditorScript

func _run():
	var chunk_name := get_scene().name
	var chunk_number := int(chunk_name.substr(5))
	var nodes := []
	nodes.append(Vector2(-1, -1))
	nodes.append(Vector2(-1, 0))
	nodes.append(Vector2(-1, 1))
	nodes.append(Vector2(0, -1))
	nodes.append(Vector2(0, 1))
	nodes.append(Vector2(1, -1))
	nodes.append(Vector2(1, 0))
	nodes.append(Vector2(1, 1))
	for n in nodes:
		var path:String = "res://areas/chunks/chunk%03d.tscn" % (chunk_number + 12*n.x + n.y)
		if ResourceLoader.exists(path):
			var neighbor = ResourceLoader.load(path) as PackedScene
			if neighbor:
				var mn = neighbor.instance()
				get_scene().add_child(mn)
				mn.transform.origin = Vector3(500*n.x, 0, -500*n.y)
		else:
			print("Does not exist: ", path)
