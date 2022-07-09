tool
extends Spatial
class_name Chunk

export(bool) var lighting_preview := false

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
			m.generate_lightmap = false
			m.use_in_baked_light = true
			m.transform = Transform()
		else:
			print_debug("No chunk of name ", name)
		if lighting_preview:
			# Bring in immediate neightbors
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
					var m = MeshInstance.new()
					add_child(m)
					m.mesh = neighbor.mesh
					m.generate_lightmap = false
					m.use_in_baked_light = true
					m.transform.origin = Vector3(500*n.x, 0, -500*n.y)
					
			# Lighting and stuff
			add_child(world_node.get_node("WorldEnvironment").duplicate())
			var light = world_node.get_node("DirectionalLight").duplicate()
			
			add_child(light)
			
			if has_node("BakedLightmap"):
				var basis = light.global_transform.basis
				remove_child(light)
				$BakedLightmap.add_child(light)
				light.global_transform.basis = basis
		world_node.free()
