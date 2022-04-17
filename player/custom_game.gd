extends HBoxContainer

export(String) var label setget set_label, get_label
export(int) var value setget set_value, get_value

func set_label(val):
	label = val
	$Label.text = val

func get_label() -> String:
	return label

func set_value(val: int):
	value = val
	$number.text = str(val)

func get_value() -> int:
	return value
