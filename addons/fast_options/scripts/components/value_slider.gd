tool
extends Control

var color := Color.white setget set_color

func set_color(c: Color):
	color = c
	update()

func _draw():
	var dark := color
	var light := color
	dark.v = 0
	light.v = 1
	var colors:PoolColorArray = [dark, dark, light, light]
	var points:PoolVector2Array = [
		Vector2(0, rect_size.y),
		Vector2(0,0),
		Vector2(rect_size.x, 0), 
		Vector2(rect_size.x, rect_size.y)]
	draw_polygon(points, colors)
