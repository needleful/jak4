tool
extends EditorScript

var target_group := "wheels"
var resource_folder := "res://entities/env/train_set/muzna_city"

var list: Array

func _run():
	#list = [all_scenes_in_path(resource_folder)]
	#for l in list:
	#	if l is PackedScene:
	#		print(l.resource_path)
	var wheels := load("res://entities/env/train_set/empty_cart.tscn") as PackedScene
	if !wheels:
		return
	var scn := get_scene()
	for node in scn.get_tree().get_nodes_in_group(target_group):
		var parent :Node = node.get_parent()
		if parent.name != "blockout":
			continue
		var new_node = wheels.instance()
		parent.add_child(new_node)
		new_node.owner = scn
		if node is Spatial:
			new_node.transform = node.transform
			node.queue_free()

func get_from_list() -> PackedScene:
	return list[int(rand_range(1, list.size())) - 1]

func all_scenes_in_path(path: String) -> Array:
	var result := []
	var dir := Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() and file_name.ends_with(".tscn"):
				result.append(ResourceLoader.load(resource_folder + "/" + file_name))
			file_name = dir.get_next()
	return result
