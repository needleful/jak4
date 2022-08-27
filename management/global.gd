extends Node

signal inventory_changed
signal item_changed(item, change, count)
signal stat_changed(tag, value)

var using_gamepad := false

var game_state := GameState.new()

export(Array, Texture) var coat_textures: Array


const save_path := "user://autosave.tres"
const old_save_backup := "user://autosave.backup.tres"
var valid_game_state := false setget set_valid_game_state, get_valid_game_state
var player_spawned := false
var can_pause := true

var color_common := Color.white
var color_uncommon := Color.chartreuse
var color_rare := Color.darkcyan
var color_super_rare := Color.darkorchid
var color_sublime := Color.coral

# Combat constants
const gravity_stun_time = 10.0
const gravity_stun_velocity = 0.02

var player : Node

# Items that also have a "stat" value, 
# measuring the total collected 
var tracked_items = ["bug", "capacitor"]

var stats_temp := {}

var ammo_drop_pity := randf()

func _init():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _input(event):
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		using_gamepad = true
	elif event is InputEventMouse or event is InputEventKey:
		using_gamepad = false

func _ready():
	randomize()
	call_deferred("place_flags")

func place_flags():
	var flag_scene = load("res://entities/visual/flag.tscn")
	for transform in game_state.flags:
		var node = flag_scene.instance()
		get_tree().current_scene.add_child(node)
		node.global_transform = transform

func remove_flag(transform: Transform):
	var index = -1
	var matched = false
	for f in game_state.flags:
		index += 1
		if f == transform:
			matched = true
			break
	if matched:
		game_state.flags.remove(index)

func get_player() -> Node:
	for n in get_tree().get_nodes_in_group("player"):
		return n
	print_debug("No player exists")
	return null

func set_valid_game_state(state):
	valid_game_state = state and game_state

func get_valid_game_state():
	if !game_state:
		valid_game_state = false
	return valid_game_state

# Game state management
func mark_map(id:String, note:String):
	add_note("places", id, note)
	return true

func has_note(category: String, subject: String):
	if !(category in game_state.journal):
		return false
	else:
		return subject in game_state.journal[category]

func add_note(category: String, subject: String, note: String):
	if !(category in game_state.journal):
		game_state.journal[category] = {}
	if !(subject in game_state.journal[category]):
		game_state.journal[category][subject] = []
	game_state.journal[category][subject].append(note)
	return true

func get_notes(category: String, subject: String = ""):
	var cat_notes := {}
	if category in game_state.journal:
		cat_notes = game_state.journal[category]
	else:
		return {}

	if subject == "":
		return cat_notes
	elif subject in cat_notes:
		return cat_notes[subject]
	else:
		return []

func note_task(task_id: String, note: String) -> bool:
	for t in game_state.active_tasks:
		if t.id == task_id:
			t.general_notes.append(note)
			return true
	for t in game_state.completed_tasks:
		if t.id == task_id:
			t.general_notes.append(note)
			return true
	var task := Task.new(task_id)
	task.general_notes.append(note)
	game_state.active_tasks.append(task)
	print("Noted task %s [of %d]: %s" % [task_id, game_state.active_tasks.size(), note])
	return true

func complete_task(task_id: String, note := "")-> bool:
	var task : Task
	for t in game_state.active_tasks:
		if t.id == task_id:
			game_state.active_tasks.remove(game_state.active_tasks.find(t))
			game_state.completed_tasks.append(t)
			task = t
			break
	if !task:
		for t in game_state.completed_tasks:
			if t.id == task_id:
				print_debug("Tried to complete already completed task: ", task_id)
				task = t
				break
	if !task:
		task = Task.new(task_id)
		game_state.completed_tasks.append(task)
	if note != "":
		task.general_notes.append(note)
	return true

func find_task(id: String, active: bool):
	var l = game_state.active_tasks if active else game_state.completed_tasks
	for task in l:
		if task.id == id:
			return task
	return null

func task_note_person(task_id: String, person: String, note: String):
	var t = find_task(task_id, true)
	if !t:
		t = find_task(task_id, false)
	if !t:
		t = Task.new(task_id)
		game_state.active_tasks.append(t)
	t.people_notes[person] = note
	return true

func task_remove_person(task_id: String, person: String):
	var t = find_task(task_id, true)
	if !t:
		t = find_task(task_id, false)
	if t is Task and person in t.people_notes:
		t.people_notes.erase(person)
	return true
		
func task_note_place(task_id: String, place: String, note: String):
	var t = find_task(task_id, true)
	if !t:
		t = find_task(task_id, false)
	if !t:
		t = Task.new(task_id)
		game_state.active_tasks.append(t)
	t.place_notes[place] = note
	return true

func task_remove_place(task_id: String, place: String):
	var t = find_task(task_id, true)
	if !t:
		t = find_task(task_id, false)
	if t is Task and place in t.people_notes:
		t.place_notes.erase(place)
	return true

func task_notes_by_person(person: String):
	var notes := []
	for task in game_state.active_tasks:
		if !(task is Task):
			print_debug("Bad task in active tasks: ", task)
			return
		if person in task.people_notes:
			notes.append(task.people_notes[person])
	return notes

func task_notes_by_place(place: String):
	var notes := []
	for task in game_state.active_tasks:
		if !(task is Task):
			print_debug("Bad task in active tasks: ", task)
			return
		if place in task.place_notes:
			notes.append(task.place_notes[place])
	return notes

func get_task_notes(task_id: String, active := true) -> Array:
	var list: Array = game_state.active_tasks if active else game_state.completed_tasks
	for task in list:
		if task.id == task_id:
			return task.general_notes
	return []

func place_flag(node: Spatial, transform: Transform):
	var _x = add_item("flag", -1)
	get_tree().current_scene.add_child(node)
	node.global_transform = transform
	game_state.flags.append(transform)

func count(item: String) -> int:
	if item in game_state.inventory:
		return game_state.inventory[item]
	else:
		return 0

func add_item(item: String, amount:= 1) -> int:
	if item in game_state.inventory:
		game_state.inventory[item] += amount
	else:
		game_state.inventory[item] = amount
	if item in tracked_items:
		var _x = add_stat(item, amount)
	emit_signal("inventory_changed")
	emit_signal("item_changed", item, amount, game_state.inventory[item])
	return game_state.inventory[item]

func remove_item(item: String, amount := 1) -> bool:
	if count(item) >= amount:
		var _x = add_item(item, -amount)
		return true
	else:
		return false

func has_stat(index: String) -> bool:
	return index in game_state.stats

func stat(index: String):
	if index in game_state.stats:
		return game_state.stats[index]
	else:
		return 0

func set_stat(tag: String, value):
	game_state.stats[tag] = value
	emit_signal("stat_changed", tag, value)
	return value

func add_stat(tag: String, amount := 1) -> int:
	if tag in game_state.stats:
		game_state.stats[tag] += amount
	else:
		game_state.stats[tag] = amount
	var value =  game_state.stats[tag]
	emit_signal("stat_changed", tag, value)
	return value
	
func temp_stat(index: String):
	if index in stats_temp:
		return stats_temp[index]
	else:
		return 0

func set_temp_stat(tag: String, value):
	stats_temp[tag] = value
	emit_signal("stat_changed", tag, value)
	return value

func add_temp_stat(tag: String, amount := 1) -> int:
	if tag in stats_temp:
		stats_temp[tag] += amount
	else:
		stats_temp[tag] = amount
	var value =  stats_temp[tag]
	emit_signal("stat_changed", tag, value)
	return value

func add_coat(coat: Coat):
	game_state.all_coats.append(coat)

func remove_coat(coat: Coat):
	var index: int = game_state.all_coats.find(coat)
	if index >= 0:
		game_state.all_coats.remove(index)

func mark_picked(path: NodePath):
	game_state.picked_items.append(path)

func is_picked(path: NodePath) -> bool:
	return path in game_state.picked_items

func is_activated(node: Node) -> bool:
	return node.get_path() in game_state.activated

func mark_activated(node: Node):
	if !node.get_path() in game_state.activated:
		game_state.activated.append(node.get_path())

func get_rarity_color(rarity: int) -> Color:
	match rarity:
		Coat.Rarity.Common:
			return color_common
		Coat.Rarity.Uncommon:
			return color_uncommon
		Coat.Rarity.Rare:
			return color_rare
		Coat.Rarity.SuperRare:
			return color_super_rare
		Coat.Rarity.Sublime:
			return color_sublime
		_:
			return Color.white

#Saving and loading

func reset_game():
	valid_game_state = false
	game_state = GameState.new()
	print("New game...")
	var dir := Directory.new()
	if ResourceLoader.exists(save_path):
		print("Backing up save...")
		# copy as a backup
		var _x = dir.rename(save_path, old_save_backup)
	var _x = get_tree().reload_current_scene()

func save_checkpoint(pos: Vector3):
	game_state.checkpoint_position = pos
	save_sync()

func save_game():
	save_sync()

func load_sync():
	if ResourceLoader.exists(save_path):
		game_state = ResourceLoader.load(save_path, "", true)
		valid_game_state = true
		var _x = get_tree().reload_current_scene()
	else:
		print_debug("Tried to load with no save at ", save_path)
		valid_game_state = false

func save_sync():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "pre_save_object", "prepare_save")
	var r = ResourceSaver.save(save_path, game_state)
	if r == OK:
		valid_game_state = true
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "post_save_object", "complete_save")
