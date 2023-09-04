extends Object
class_name MumOutfit

signal outfit_changed(outfit)

var outfit : Dictionary
var valid_outfit := false

const outfit_path_f := "res://outfits/%s"

func _init():
	outfit = {}

func set_outfit(p_outfit: Dictionary):
	outfit = p_outfit
	emit_signal("outfit_changed", outfit)
	valid_outfit = true
	return true

func set_clothing(p_key: String, p_value):
	if(p_value is String):
		var path:String = outfit_path_f % p_value
		if !ResourceLoader.exists(path):
			print_debug("Outfit resource not found: ", p_value)
			return false
		outfit[p_key] = ResourceLoader.load(path)
	else:
		outfit[p_key] = p_value
	
	match p_key:
		"fullbody":
			outfit["shirt"] = null
			outfit["pants"] = null
		"shirt", "pants":
			outfit["fullbody"] = null
		"hat":
			outfit["hair"] = null
		"hair":
			outfit["hat"] = null
	emit_signal("outfit_changed", outfit)
	return true
