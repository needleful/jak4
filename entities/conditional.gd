extends Spatial

export(String, MULTILINE) var condition

func _ready():
	var ex: Expression = Expression.new()
	var res = ex.parse(condition, ["Global", "node"])
	if res != OK:
		print_debug("Could not parse {%s}: %d" % [
			condition,
			res
		])
		return
	var result = ex.execute([Global, self])
	if !result:
		queue_free()
