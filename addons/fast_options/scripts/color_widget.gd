extends HBoxContainer

signal changed(opt_name, value)

var option_name:String

onready var preview := $Preview

func set_option_hint(option:Dictionary):
	option_name = option.name
	$name.text = option_name.capitalize()

func set_option_value(val:Color):
	preview.color = val
	$value/hue.value = val.h
	$value/sat.value = val.s
	$value/val.value = val.v

func _on_color_changed(val):
	$value/sat/preview.color = val
	$value/val/preview.color = val
	emit_signal("changed", option_name, val)

func _on_hue_value_changed(h: float):
	var oc = preview.color
	oc.h = h
	preview.color = oc
	_on_color_changed(oc)

func _on_sat_value_changed(s:float):
	var oc = preview.color
	oc.s = s
	preview.color = oc
	_on_color_changed(oc)

func _on_val_value_changed(v:float):
	var oc = preview.color
	oc.v = v
	preview.color = oc
	_on_color_changed(oc)
