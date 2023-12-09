tool
extends MeshInstance

var mat: ShaderMaterial

func _ready():
	if Engine.editor_hint:
		set_process(false)
	else:
		material_override = null
	mat = get_surface_material(0)

func _process(_delta):
	if Engine.editor_hint:
		print_debug("I set this to false, fuck off Godot")
		set_process(false)
	mat.set_shader_param("world_player", Global.get_player().global_transform.origin)
