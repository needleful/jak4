tool
extends Spatial

export(bool) var light_enabled := true setget set_enabled
export(Material) var light_material
export(Material) var dark_material
export(NodePath) var mesh_instance

onready var mesh: MeshInstance = get_node(mesh_instance)

func _ready():
	set_enabled(light_enabled)

func set_enabled(e):
	light_enabled = e
	if is_inside_tree():
		for c in get_children():
			if c is Light:
				c.visible = light_enabled
		# TODO: material swapping
		if dark_material:
			if light_enabled:
				mesh.set_surface_material(1, light_material)
			else:
				mesh.set_surface_material(1, dark_material)
		else:
			var m := mesh.get_surface_material(1) as SpatialMaterial
			if m:
				m.emission_enabled = float(light_enabled)
