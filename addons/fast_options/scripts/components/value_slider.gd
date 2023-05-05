tool
extends Control

func _draw():
	var dark := modulate
	var light := modulate
	dark.v = 0
	light.v = 1
	var colors:PoolColorArray = [dark, dark, light, light]
	var points:PoolVector2Array = [
		Vector2(0, rect_size.y),
		Vector2(0,0),
		Vector2(rect_size.x, 0), 
		Vector2(rect_size.x, rect_size.y)]
	draw_polygon(points, colors)
