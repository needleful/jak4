extends AspectRatioContainer

export(float) var max_aspect_ratio := 1.77777777777777777777777777
export(float) var min_aspect_ratio := 0.0

func _ready():
	var _x = get_viewport().connect("size_changed", self, "_on_size_changed")
	_on_size_changed()

func _on_size_changed():
	var s := OS.window_size
	var screen_ratio := float(s.x)/float(s.y)
	ratio = clamp(screen_ratio, min_aspect_ratio, max_aspect_ratio)
