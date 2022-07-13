extends Resource
class_name GameState

export(Dictionary) var stats: Dictionary = {}
export(Dictionary) var inventory: Dictionary = {}
export(Vector3) var checkpoint_position: Vector3
export(Resource) var current_coat: Resource
export(Array, Resource) var all_coats: Array
export(Array, NodePath) var picked_items: Array
export(Array, NodePath) var activated: Array
export(Array, Transform) var flags : Array
# String to array of strings
export(Dictionary) var map_markers := {}
export(Dictionary) var journal := {}

func _init():
	resource_name = "GameState"
