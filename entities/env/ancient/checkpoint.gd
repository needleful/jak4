extends Spatial

signal saved

func signal_saved():
	print("Save")
	emit_signal("saved")
