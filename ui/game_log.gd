extends ScrollContainer

onready var box := $vbox
export(PackedScene) var label_scene:PackedScene

func echo(message: String):
	var l := label_scene.instance()
	l.get_node("Label").text = message
	box.add_child(l)
	fade_and_hide(l)

func fade_and_hide(l):
	yield(get_tree().create_timer(2.0), "timeout")
	var tween := get_tree().create_tween()
	var _x = tween.tween_property(l, "modulate", Color(1,1,1,0), 1.0)
	_x = tween.tween_callback(l, "queue_free")
