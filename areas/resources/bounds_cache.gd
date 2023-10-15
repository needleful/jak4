extends Resource
class_name BoundsCache

enum State {
	None,
	LowRes,
	Inactive,
	Active
}

export(Dictionary) var bounds_cache: Dictionary
export(Dictionary) var cache_state: Dictionary

func _init():
	resource_name = "BoundsCache"
	bounds_cache = {}
	cache_state = {}

func get_bounds(chunk: Node, state: int) -> AABB:
	if !(chunk.name in bounds_cache 
		and cache_state[chunk.name] >= state
	):
		var new_bounds := Util.calculate_bounds(chunk)
		if (chunk.name in bounds_cache):
			bounds_cache[chunk.name] = new_bounds.merge(bounds_cache[chunk.name])
		else:
			bounds_cache[chunk.name] = new_bounds
		assert(cache_state[chunk.name] <= state)
		cache_state[chunk.name] = state
	return bounds_cache[chunk.name]
