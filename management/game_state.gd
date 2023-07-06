extends Resource
class_name GameState

# Version of the game this was saved with
export(String) var version: String
export(Dictionary) var stats: Dictionary
export(Dictionary) var inventory: Dictionary
export(Transform) var checkpoint_position: Transform
export(Resource) var current_coat: Resource
export(Array, Resource) var all_coats: Array
export(Array, NodePath) var picked_items: Array
export(Array, Transform) var flags : Array

export(Array) var journal : Array
export(Array) var active_tasks : Array
export(Array) var completed_tasks : Array

func _init(version_string := "0.0.0"):
	version = version_string
	journal = []
	inventory = {}
	stats = {}
	resource_name = "GameState"
	active_tasks = []
	completed_tasks = []
