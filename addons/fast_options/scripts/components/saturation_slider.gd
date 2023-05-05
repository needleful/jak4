tool
extends Control

func _draw():
	var desat := modulate
	var hisat := modulate
	desat.s = 0
	hisat.s = 1
	var colors:PoolColorArray = [desat, desat, hisat, hisat]
	var points:PoolVector2Array = [
		Vector2(0, rect_size.y),
		Vector2(0,0),
		Vector2(rect_size.x, 0), 
		Vector2(rect_size.x, rect_size.y)]
	draw_polygon(points, colors)
