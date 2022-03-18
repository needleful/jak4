extends Resource
class_name GameState

export(Dictionary) var stats: Dictionary = {}
export(Dictionary) var inventory: Dictionary = {}
export(Transform) var player_transform: Transform = Transform()
export(Resource) var current_coat: Resource

func _init():
	resource_name = "GameState"
