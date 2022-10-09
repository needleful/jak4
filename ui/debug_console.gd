extends Control

onready var line_edit := $ScrollContainer/VBoxContainer/LineEdit
onready var logs := $ScrollContainer/VBoxContainer/logs

var history := []
var index := 0

func _input(event):
	if !visible:
		return
	if event.is_action_pressed("ui_up"):
		view_history(-1)
	elif event.is_action_pressed("ui_down"):
		view_history(+1)

func set_active(a: bool):
	set_process_input(a)
	if a:
		line_edit.call_deferred("grab_focus")
		line_edit.text = ""

func _on_text_entered(new_text):
	line_edit.text = ""
	var ex = Expression.new()
	var label := Label.new()
	label.autowrap = true
	logs.add_child(label)
	var res = ex.parse(new_text, ["Global"])
	if res != OK:
		label.text = ex.get_error_text()
	history.append(new_text)
	index = history.size()
	var output = ex.execute([Global], self)
	if ex.has_execute_failed():
		label.text = ex.get_error_text() + str(output)
	else:
		label.text = str(output)

func clear():
	for l in logs.get_children():
		l.queue_free()

func view_history(offset):
	if history.size() == 0:
		index = 0
		return
	index += offset
	if index < 0:
		index = 0
	if index >= history.size():
		index = history.size()
		line_edit.text = ""
		return
	else:
		line_edit.text = history[index]

func teleport(location):
	if location is int:
		var chunk_name = "chunk%03d" % location
		var scn = get_tree().current_scene
		if scn.has_node(chunk_name):
			scn.unload_all()
			var pos = scn.get_node(chunk_name).global_transform.origin
			var player = Global.get_player()
			var space = player.get_world().space
			var state = PhysicsServer.space_get_direct_state(space)
			var ray_start = pos + Vector3.UP*3400
			var ray_end = pos + Vector3.DOWN*1000
			var col = state.intersect_ray(ray_start, ray_end)
			if col:
				pos = col.position
			var new_transform = player.global_transform
			new_transform.origin = pos
			player.teleport_to(new_transform)
		else:
			return "No chunk: "+ chunk_name
	else:
		return "Not yet supported"
