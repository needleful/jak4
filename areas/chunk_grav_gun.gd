extends MeshInstance

func _ready():
	if !Engine.editor_hint:
		mesh = null
