extends Node2D

export(String) var visual_name
export(Array, String) var notes

func show_with_notes(p_notes: Array):
	notes = p_notes
	show()
