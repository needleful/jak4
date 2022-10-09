extends Resource
class_name GameState

export(Dictionary) var stats: Dictionary = {}
export(Dictionary) var inventory: Dictionary = {}
export(Vector3) var checkpoint_position: Vector3
export(Resource) var current_coat: Resource
export(Array, Resource) var all_coats: Array
export(Array, NodePath) var picked_items: Array
export(Array, Transform) var flags : Array
# Dictionary(string category -> Dictionary(string subject -> Array(string) notes))
export(Dictionary) var journal := {}
# Array(task)
export(Array, Resource) var active_tasks: Array
export(Array, Resource) var completed_tasks: Array

func _init():
	resource_name = "GameState"
	active_tasks = []
	completed_tasks = []
