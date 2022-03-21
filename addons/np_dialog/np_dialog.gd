tool
extends EditorPlugin

var import : NPDialogImportPlugin

var Sequence := preload("res://addons/np_dialog/resource/sequence.gd")

func _enter_tree():
	add_custom_type(
		"NPSequence",
		"Resource",
		Sequence,
		preload("res://addons/np_dialog/gamer_icon.png"))
	import = NPDialogImportPlugin.new()
	add_import_plugin(import)

func _exit_tree():
	remove_import_plugin(import)
	import = null
	remove_custom_type("NPSequence")
