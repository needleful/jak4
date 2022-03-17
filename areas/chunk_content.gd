tool
extends Spatial

export(Mesh) var preview_mesh setget set_mesh

func _ready():
	if Engine.editor_hint and preview_mesh:
		print_debug("Previewing ", name)
		var m = MeshInstance.new()
		add_child(m)
		m.name = "__autogen_preview"
		m.mesh = preview_mesh
		m.transform = Transform()

func set_mesh(m):
	preview_mesh = m
	if has_node("__autogen_preview"):
		print_debug("Changing preview for ", name)
		$__autogen_preview.mesh = m
		$__autogen_preview.transform = Transform()
