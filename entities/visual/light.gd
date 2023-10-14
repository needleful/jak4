tool
extends Spatial

export(bool) var light_enabled := true setget set_light_enabled
export(Material) var light_material
export(Material) var dark_material
export(NodePath) var mesh_instance := NodePath(".")

onready var m: MeshInstance = get_node(mesh_instance)

func _notification(what):
	if ((what == NOTIFICATION_VISIBILITY_CHANGED
		or what == NOTIFICATION_READY)
		and is_visible_in_tree()
	):
		set_light_enabled(light_enabled)

func set_light_enabled(e):
	light_enabled = e
	if is_inside_tree():
		for c in get_children():
			if c is Light:
				c.visible = light_enabled
		if m.get_surface_material_count() < 2:
			print_debug("Two materials expected: ", get_path())
			return
		if dark_material:
			if light_enabled:
				m.set_surface_material(1, light_material)
			else:
				m.set_surface_material(1, dark_material)
		else:
			var mat := m.get_surface_material(1) as SpatialMaterial
			if mat:
				mat.emission_enabled = light_enabled

func enable():
	set_light_enabled(true)

func disable():
	set_light_enabled(false)
