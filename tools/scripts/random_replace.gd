tool
extends EditorScript

var target_group := "train_color_random"
var resource_folder := "res://entities/env/train_set/muzna_city"

var list: Array

func _run():
	#list = [all_scenes_in_path(resource_folder)]
	#for l in list:
	#	if l is PackedScene:
	#		print(l.resource_path)
	var scn := get_scene()
	for node in scn.get_tree().get_nodes_in_group(target_group):
		#replace(node)
		colorize(node)

func colorize(node):
	if node is MeshInstance:
		var s:ShaderMaterial = node.get_surface_material(0)
		if s:
			s.set_shader_param("albedo", 
			Color.from_hsv(randf(), randf()*0.75, randf()*0.8))

func replace(node):
	var parent :Node = node.get_parent()
	if parent.name != "blockout":
		return
	var new_node = get_from_list().instance()
	parent.add_child(new_node)
	new_node.owner = get_scene()
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
