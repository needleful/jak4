extends Node

const path := "user://default_monitor"

func _enter_tree():
	var f := File.new()
	if f.file_exists(path):
		var r = f.open(path, File.READ)
		if r != OK:
			print_debug("Failed to load default monitor")
			return
		var data = f.get_buffer(2)
		# Don't try setting the monitor if the number of screens has changed
		if data[0] > 0 and data[1] == OS.get_screen_count():
			OS.current_screen = data[0]

func _exit_tree():
	var f := File.new()
	var r = f.open(path, File.WRITE)
	if r != OK:
		print_debug("Failed to save default monitor")
		return
	var b := PoolByteArray()
	b.push_back(OS.current_screen)
	b.push_back(OS.get_screen_count())
	f.store_buffer(b)
