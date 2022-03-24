tool
extends Spatial

func _ready():
	if Engine.editor_hint:
		var world :PackedScene= load("res://areas/world.tscn")
		var world_node = world.instance()
		if world_node.has_node(name):
			print_debug("Previewing ", name)
			var m = MeshInstance.new()
			add_child(m)
			m.name = "__autogen_preview"
			m.mesh = world_node.get_node(name).mesh
			m.transform = Transform()
		else:
			print_debug("No chunk of name ", name)
		world_node.free()
