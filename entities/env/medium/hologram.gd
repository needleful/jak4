tool
extends MeshInstance

export(bool) var real_object_visible := true setget set_real_visible
export(Material) var invisible_material: Material
export(Material) var hologram_material: Material

func _ready():
	material_overlay = hologram_material
	_overlay(self)

func _overlay(node):
	for c in node.get_children():
		if c is GeometryInstance:
			c.material_overlay = hologram_material
		_overlay(c)

func set_real_visible(v):
	real_object_visible = v
	if !is_inside_tree():
		return
	else:
		if !real_object_visible:
			material_override = invisible_material
		else:
			material_override = null
		_override(self)

func _override(n):
	for c in n.get_children():
		if c is GeometryInstance:
			c.material_override = material_override
		_override(c)
