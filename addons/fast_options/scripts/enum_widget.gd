extends Control

signal changed(opt_name, value)

var option_name:String

var vals: Dictionary

func _init():
	vals = {}

func _ready():
	for c in get_children():
		c.focus_neighbour_left = c.get_path()

func set_option_hint(option:Dictionary):
	option_name = option.name
	$name.text = option_name.capitalize()
	var hint: String = option.hint_string
	var values = hint.split(",", false)
	for val in values:
		var h = val.split(":", false)
		$value.add_item(h[0].capitalize(), int(h[0]))

func set_option_value(val:int):
	$value.select(val)

func grab_focus():
	$value.grab_focus()

func _on_value_item_selected(ID):
	emit_signal("changed", option_name, ID)
