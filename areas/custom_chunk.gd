extends MeshInstance

onready var real_aabb = .get_aabb()

func _ready():
	if !Engine.editor_hint:
		mesh = null

func get_aabb():
	return real_aabb
