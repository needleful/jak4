extends Control

onready var line_edit := $VBoxContainer/LineEdit
onready var logs := $VBoxContainer/ScrollContainer/logs
onready var scroll := $VBoxContainer/ScrollContainer

var show_stats := false

var history: Array
var index := 0
var cheats
var dict: Dictionary

onready var G = Global

func _init():
	history = []
	dict = {}

func _ready():
	var cheat_file = "res://scripts/cheats.gd"
	if ResourceLoader.exists(cheat_file):
		var script = load(cheat_file)
		cheats = script.new()
		add_child(cheats)

func _input(event):
	if !visible:
		return
	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_UP:
			view_history(-1)
		elif event.scancode == KEY_DOWN:
			view_history(+1)

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		set_process_input(is_visible_in_tree())
		if is_visible_in_tree():
			line_edit.call_deferred("grab_focus")
			line_edit.text = ""

func _on_text_entered(new_text):
	if cheats and cheats.has_method(new_text):
		cheats.call(new_text)
		echo("code enabled")
		line_edit.text = ""
		return
	history.append(new_text)
	index = history.size()
	line_edit.text = ""
	var ex = Expression.new()
	var res = ex.parse(new_text, ["Global", "VisualServer"])
	if res != OK:
		echo(ex.get_error_text())
		return
	var output = ex.execute([Global, VisualServer], self)
	if ex.has_execute_failed():
		echo(ex.get_error_text() + str(output))
	else:
		echo(str(output))
	scroll.scroll_to_end()

func move(dir:Vector3):
	Global.get_player().global_translate(dir)

func debug_time(debugging := true, parent:Node = null):
	if !parent:
		parent = Global.get_player()
	parent.time_scale_response = debugging
	for c in parent.get_children():
		debug_time(debugging, c)

func time():
	if TimeManagement.time_slowed:
		TimeManagement.resume()
	else:
		TimeManagement.slow_time()

func noclip():
	Global.get_player().toggle_noclip()

func scene():
	return get_tree().current_scene

func set_time(time):
	scene().set_time(time)

func clear():
	for l in logs.get_children():
		l.queue_free()

func rapid_start():
	for c in AmmoSpawner.MAX.keys():
		var wep = "wep_"+c
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
	print("CONSOLE: ", text)

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
	print_debug("Teleport ", location)
	var chunk_name := ""
	if location is int:
		chunk_name = "chunk%03d" % location
	else:
		chunk_name = "chunk"+str(location)
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

func stats():
	var s := ""
	for k in Global.game_state.stats.keys():
		s += k + "    =>    " + str(Global.stat(k)) + "\n"
	return s

func tss():
	show_stats = !show_stats
	Global.get_player().debug.visible = show_stats

func save(save_id := ""):
	var path := Global.auto_save_path
	if save_id != "":
		path = Global.custom_save_path_f % save_id
	echo("Saving to: "+ path)
	Global.save_checkpoint(Global.get_player().get_save_transform(), false, path)

func load_game(save_id := ""):
	var path := Global.auto_save_path
	if save_id != "":
		path = Global.custom_save_path_f % save_id
	echo("Loading from: "+ path)
	Global.load_sync(true, path)

func load_chunk(chunk_name: String):
	var scene := get_tree().current_scene
	var chunk := scene.get_node(chunk_name)
	scene.chunk_loader.queue_load(chunk, false)
	echo("Loading "+ chunk_name)

func activate_chunk(chunk_name: String):
	var scene := get_tree().current_scene
	var chunk := scene.get_node(chunk_name)
	scene.chunk_loader.activate(chunk)
	echo("Activating "+ chunk_name)

func map(list, f: String):
	var result := []
	for l in list:
		result.append(l.call(f))
	return result

func chunk_debug():
	if !get_tree().current_scene.has_node("debug"):
		echo("No debug UI")
		return
	var n = get_tree().current_scene.get_node("debug")
	n.visible = !n.visible
