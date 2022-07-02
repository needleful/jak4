extends Spatial

export(String, FILE, "*.tscn") var scene

func _ready():
	add_child(load(scene).instance())
