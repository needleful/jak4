extends HBoxContainer

signal changed(opt_name, value)

var option_name:String

func _ready():
	for c in $value/ColorPicker.get_children():
		print(c.name, ":", c.get_child_count())

func set_option_hint(option:Dictionary):
	option_name = option.name
	$name.text = option_name.capitalize()

func set_option_value(val:Color):
	$value/ColorPicker.color = val

func grab_focus():
	$value/ColorPicker.grab_focus()

func _on_color_changed(val):
	emit_signal("changed", option_name, val)
