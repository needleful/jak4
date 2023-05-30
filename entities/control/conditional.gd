extends Spatial

export(String, MULTILINE) var condition
export(bool) var listen_for_change := false

var expression : Expression

func _ready():
	expression = Expression.new()
	var res = expression.parse(condition, ["Global", "node"])
	if res != OK:
		print_debug("Could not parse {%s}: %d" % [
			condition,
			res
		])
		return
	res = validate()
	if !res:
		queue_free()
	elif listen_for_change:
		var _x = Global.connect("stat_changed", self, "_on_stat_changed")

func _on_stat_changed(_t, _v):
	var res = validate()
	if !res:
		queue_free()

func validate():
	var res = expression.execute([Global, self])
	if expression.has_execute_failed():
		print_debug("Bad condition: ", condition, 
			"\n\t", expression.get_error_text())
	return res
