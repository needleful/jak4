extends Node

const path := "user://default_monitor"

func _enter_tree():
	var f := File.new()
	if f.file_exists(path):
		var r = f.open(path, File.READ)
		if r != OK:
			print_debug("Failed to load default monitor")
			return
		var i :int = f.get_8()
		if i > 0:
			OS.current_screen = i

func _exit_tree():
	var f := File.new()
	var r = f.open(path, File.WRITE)
	if r != OK:
		print_debug("Failed to save default monitor")
		return
	f.store_8(OS.current_screen)
