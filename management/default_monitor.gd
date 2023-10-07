extends Node

const path := "user://default_monitor"

func _enter_tree():
	var f := File.new()
	if f.file_exists(path):
		f.open(path, File.READ)
		var i :int = f.get_8()
		if i > 0:
			OS.current_screen = i

func _exit_tree():
	var f := File.new()
	f.open(path, File.WRITE)
	f.store_8(OS.current_screen)
