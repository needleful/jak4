extends Control

signal ui_redraw
signal back_pressed

export(String) var menu_name := ""
export(bool) var with_back_button := true

const TYPE_WIDGETS = {
	TYPE_BOOL: preload("res://addons/fast_options/widgets/bool_widget.tscn"),
	TYPE_REAL: preload("res://addons/fast_options/widgets/range_widget.tscn"),
	TYPE_INT: preload("res://addons/fast_options/widgets/range_widget.tscn"),
	TYPE_COLOR: preload("res://addons/fast_options/widgets/color_widget.tscn"),
	TYPE_STRING: preload("res://addons/fast_options/widgets/string_widget.tscn")
}
const CLASS_WIDGETS = {
	"AudioChannel": preload("res://addons/fast_options/widgets/volume_widget.tscn"),
	"enum": preload("res://addons/fast_options/widgets/enum_widget.tscn")
}

var options: Object
var r_enum_hint := RegEx.new()

var custom_widgets:Dictionary

func _init():
	var _x = r_enum_hint.compile("(\\w\\S*:\\d+,?)+")

func generate():
	if menu_name == "":
		menu_name = name
	options = Settings.sub_options[menu_name]
	call_deferred("redraw")

func redraw():
	if options.has_method("get_custom_widgets"):
		custom_widgets = options.get_custom_widgets()
	else:
		custom_widgets = {}
	for child in get_children():
		if child is Control:
			remove_child(child)
	for property in options.get_property_list():
		if is_export_var(property):
			create_widget(property)
	if with_back_button:
		var back := Button.new()
		back.text = tr("Back")
		add_child(back)
		var _x = back.connect("pressed", self, "emit_signal", ["back_pressed"])

func create_widget(property:Dictionary)->void:
	var type = property.type
	if property.name in custom_widgets:
		add_widget(property, custom_widgets[property.name])
	elif type == TYPE_INT and r_enum_hint.search(property.hint_string):
		add_widget(property, CLASS_WIDGETS["enum"])
	elif type in TYPE_WIDGETS:
		add_widget(property, TYPE_WIDGETS[type])
	else:
		var value = options.get(property.name)
		if value is Resource and value.resource_name in CLASS_WIDGETS:
			add_widget(property, CLASS_WIDGETS[value.resource_name])
		else:
			var text = Label.new()
			text.text = "%s: %s (No Widget Available: '%s')" % [
				property.name, 
				type,
				str(options.get(property.name).resource_name)
			]
			add_child(text)

func add_widget(property, widget_scene: PackedScene) -> void:
	var widget:Control = widget_scene.instance()
	add_child(widget)
	widget.set_option_hint(property)
	widget.set_option_value(options.get(property.name))
	if options.has_method("set_option"):
		var _x = widget.connect("changed", options, "set_option")
	else:
		var _x = widget.connect("changed", options, "set")

func is_export_var(property)->bool:
	return property.usage & Settings.USAGE_FLAGS == Settings.USAGE_FLAGS

func _on_ui_redraw():
	emit_signal("ui_redraw")

func grab_focus():
	for c in get_children():
		if c is Control:
			c.grab_focus()
			return
