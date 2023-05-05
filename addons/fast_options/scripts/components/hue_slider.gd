tool
extends HSlider

func _enter_tree():
	$TextureRect.texture = get_icon("color_hue", "ColorPicker")
