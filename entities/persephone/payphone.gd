extends Spatial

export(bool) var enabled := false
export(AudioStream) var ring_sound
export(float) var min_player_distance := 80.0
export(Resource) var dialog_sequence
export(String) var location

onready var dialog_circle := $dialog_circle

func _ready():
	remove_child(dialog_circle)

func _exit_tree():
	if !dialog_circle.is_inside_tree():
		dialog_circle.free()

func calling_from(p_location):
	return location == p_location
