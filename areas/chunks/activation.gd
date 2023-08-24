extends Spatial

func _ready():
	for c in get_children():
		var door := $"../door"
		var _x = c.connect("activated", door, "_on_activated")
		_x = c.connect("deactivated", door, "_on_deactivated")
