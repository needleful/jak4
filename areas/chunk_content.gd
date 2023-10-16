tool
extends Spatial
class_name Chunk

export(bool) var preview_neighbors := false
export(NodePath) var grass_node := NodePath("active_entities/grass")
export(float) var grass_density := 1.0
export(bool) var lowres := false
export(Array, String) var custom_neighbors
var exits: Array

var active_entities : Spatial
var active_transform : Transform

func _init():
	custom_neighbors = {}
	exits = []

func _ready():
	if Engine.editor_hint:
		var world :PackedScene= load("res://areas/world_reference.tscn")
		var world_node = world.instance()
		if world_node.has_node(name):
			print_debug("Previewing ", name)
			var m = world_node.get_node(name)
			var neighbor_transform = m.transform.affine_inverse()
			m.get_parent().remove_child(m)
			add_child(m)
			m.name = "__autogen_preview"
			m.transform = Transform()
			m.set_surface_material(0, load("res://material/env/terrain_main.material"))
			if preview_neighbors:
				# Bring in immediate neighbors
				# +1, -1, +12, -12, +11, -11, +13, -13
				# 5: length of "chunk"
				var c := int(name.substr(5))
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
					var path:String = "chunk%03d" % (c + 12*n.x + n.y)
					if world_node.has_node(path):
						var neighbor = world_node.get_node(path)
						add_neighbor(neighbor, 
							Transform(Basis(),
								Vector3(500*n.x, 0, -500*n.y)))
				for n in custom_neighbors:
					if world_node.has_node(n):
						var neighbor = world_node.get_node(n)
						add_neighbor(neighbor, neighbor_transform*neighbor.transform)
		else:
			print_debug("No chunk of name ", name)
		world_node.free()
	elif lowres and has_node("active_entities"):
		$active_entities.queue_free()

func add_neighbor(neighbor: Spatial, p_transform: Transform):
	var mn = MeshInstance.new()
	add_child(mn)
	mn.mesh = neighbor.mesh
	mn.set_surface_material(0, load("res://material/env/copper/copper_corroded.material"))
	mn.transform = p_transform

func find_exit_to(place: String):
	for e in exits:
		if e.destinations.contains(place):
			return e

func set_active(a):
	if !a and has_node("active_entities"):
		active_entities = $active_entities
		active_transform = active_entities.transform
		remove_child(active_entities)
	elif a and active_entities and !has_node("active_entities"):
		add_child(active_entities)
		active_entities.transform = active_transform

func is_active():
	return has_node("active_entities")
