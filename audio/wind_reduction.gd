extends Area

export(float, 0, 80) var wind_reduction_db := 10.0
var wind : WindController


func _ready():
	if get_tree().current_scene.has_method("get_wind_audio"):
		var a = get_tree().current_scene.get_wind_audio()
		if a is WindController:
			wind = a
			var _x = connect("body_entered", self, "_on_body_entered")
			_x = connect("body_exited", self, "_on_body_exited")


func _on_body_entered(_body):
	wind.apply_volume(-wind_reduction_db)

func _on_body_exited(_body):
	wind.apply_volume(0)
