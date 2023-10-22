tool
extends EditorPlugin

var import : NPDialogImportPlugin
var Sequence := preload("res://addons/np_dialog/resource/sequence.gd")
var icon := preload("res://addons/np_dialog/gamer_icon.png")
var dialog_editor: Control

const use_editor := false

func _enter_tree():
	add_custom_type(
		"NPSequence",
		"Resource",
		Sequence,
		icon)
	import = NPDialogImportPlugin.new()
	add_import_plugin(import)
	if use_editor:
		dialog_editor = load("res://addons/np_dialog/editor/dialog_editor.tscn").instance()
		get_editor_interface().get_editor_viewport().add_child(dialog_editor)
		make_visible(false)

func make_visible(visible):
	if dialog_editor:
		dialog_editor.visible = visible

func handles(object):
	return use_editor and object is Resource and object.resource_name == "NPSequence"

func has_main_screen():
	return use_editor

func save_external_data():
	if use_editor and dialog_editor:
		dialog_editor.save(true)
		emit_signal("resource_saved")

func get_plugin_icon():
	return icon
	
func get_plugin_name():
	return "NP Dialog"

func edit(object):
	if !use_editor:
		return
	var dialog = object as Resource
	dialog_editor.open(object.resource_path)
	make_visible(true)

func _exit_tree():
	if use_editor and dialog_editor:
		dialog_editor.queue_free()
	remove_import_plugin(import)
	import = null
	remove_custom_type("NPSequence")
