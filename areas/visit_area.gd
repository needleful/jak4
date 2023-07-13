extends Area

export(String) var place_id
export(String) var custom_stat
export(String) var note

func _ready():
	var _x = connect("body_entered", self, "_on_body_entered")

func _on_body_entered(b):
	if b is PlayerBody:
		var _x = Global.remember(place_id, "places")
		var stat:String = "visited/" + (
			place_id if custom_stat == "" else custom_stat)
		_x = Global.add_stat(stat)
		if note != "":
			Global.add_note(note, [place_id, stat])
