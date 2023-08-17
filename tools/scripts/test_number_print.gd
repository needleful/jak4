tool
extends EditorScript


func _run():
	for _i in 1200:
		var rand := 10.0*randf() * pow(10.0, 127.0*randf())
		print_debug(rand, " = ", NumberToString.verbose(rand))
