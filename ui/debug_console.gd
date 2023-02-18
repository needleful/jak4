extends Control

onready var line_edit := $ScrollContainer/VBoxContainer/LineEdit
onready var logs := $ScrollContainer/VBoxContainer/logs

var show_stats := false setget sss

var history := []
var index := 0

onready var G = Global

func _input(event):
	if !visible:
		return
	if event.is_action_pressed("ui_up"):
		view_history(-1)
	elif event.is_action_pressed("ui_down"):
		view_history(+1)

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		set_process_input(is_visible_in_tree())
		if is_visible_in_tree():
			line_edit.call_deferred("grab_focus")
			line_edit.text = ""

func _on_text_entered(new_text):
	history.append(new_text)
	index = history.size()
	line_edit.text = ""
	var ex = Expression.new()
	var res = ex.parse(new_text, ["Global"])
	if res != OK:
		echo(ex.get_error_text())
		return
	var output = ex.execute([Global], self)
	if ex.has_execute_failed():
		echo(ex.get_error_text() + str(output))
	else:
		echo(str(output))

func scene():
	return get_tree().current_scene

func clear():
	for l in logs.get_children():
		l.queue_free()

func rapid_start():
	for c in AmmoSpawner.MAX.keys():
		var wep = "wep_"+c
		echo("Got "+wep)
		var _x = Global.add_item(wep)
		_x = Global.add_item(c, AmmoSpawner.MAX[c])
	var _x = Global.add_item("wep_time_gun")
	_x = Global.add_item("hover_scooter")
	_x = Global.add_item("lantern")
	_x = Global.add_item("flag", 10)

func item(item_id:String, count:int = 1):
	var _x = Global.add_item(item_id, count)

func rapid_end():
	var _x = Global.set_stat("mum/info", 8)
	_x = Global.set_stat("mum/introduction", 1)
	_x = Global.set_stat("mum/time", 1)
	_x = Global.set_stat("mum/discussed/jackie", 1)
	_x = Global.set_stat("mum/timebomb", 5)
	_x = Global.add_item("capacitor")

func coat(count := 1):
	for _i in range(count):
		var coat = Coat.new(true, Coat.Rarity.Common, Coat.Rarity.Sublime)
		Global.add_coat(coat)

func echo(text):
	var label := Label.new()
	label.autowrap = true
	logs.add_child(label)
	label.text = text

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

func tp(location):
	print("Teleport ", location)
	if location is int:
		var chunk_name = "chunk%03d" % location
		var scn = get_tree().current_scene
		if scn.has_node(chunk_name):
			#scn.unload_all()
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
			return "No chunk: " + chunk_name
	else:
		return "Not yet supported"

func stats():
	var s := ""
	for k in Global.game_state.stats.keys():
		s += k + "    =>    " + str(Global.stat(k)) + "\n"
	return s

func sss(val: bool):
	show_stats = val
	Global.get_player().debug.visible = show_stats

func save():
	Global.save_checkpoint(Global.get_player().global_transform.origin)

func load_game():
	Global.load_sync()
