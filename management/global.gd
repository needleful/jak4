extends Node

signal inventory_changed
signal item_changed(item, change, count)
signal stat_changed(tag, value)
signal journal_updated(category, subject)

var using_gamepad := false

var game_state : GameState

export(Array, Texture) var coat_textures: Array
export(Texture) var coat_detail: Texture
export(Dictionary) var stories

const save_path := "user://autosave.tres"
const old_save_backup := "user://autosave.backup.tres"
var valid_game_state := false setget set_valid_game_state, get_valid_game_state
var player_spawned := false
var can_pause := true

var save_thread := Thread.new()

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

var stats_temp: Dictionary

var ammo_drop_pity := randf()

var gravity_stunned_bodies: Dictionary
var render_distance := 1.0
var show_lowres := true

# Map of tags to an array of ints accessting game_state.journal
var journal_by_tag : Dictionary

const description_path := "res://ui/items/%s.tres"

func _init():
	game_state = GameState.new()
	journal_by_tag = {}
	stories = {}
	stats_temp = {}
	gravity_stunned_bodies = {}
	pause_mode = Node.PAUSE_MODE_PROCESS

func _input(event):
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		using_gamepad = true
	elif event is InputEventMouse or event is InputEventKey:
		using_gamepad = false

func _ready():
	randomize()
	call_deferred("place_flags")
	journal_by_tag = {}
	if valid_game_state:
		var i := 0
		for entry in game_state.journal:
			for t in entry[1]:
				if t in journal_by_tag:
					journal_by_tag[t].append(i)
				else:
					journal_by_tag[t] = [i]
			i += 1

func _physics_process(delta):
	for b in gravity_stunned_bodies.keys():
		gravity_stunned_bodies[b] -= delta
		if gravity_stunned_bodies[b] <= 0:
			b.gravity_scale = 1
			var _x = gravity_stunned_bodies.erase(b)

func get_mouse_zoom_axis() -> float:
	return 15*( float(Input.is_action_just_released("mouse_zoom_in"))
			- float(Input.is_action_just_released("mouse_zoom_out")) )

func get_action_input_string(action: String, override = null):
	var gamepad
	if override != null:
		gamepad = override
	else:
		gamepad = using_gamepad
		
	var input: InputEvent
	for event in InputMap.get_action_list(action):
		if gamepad and (
			event is InputEventJoypadButton
			or event is InputEventJoypadMotion
		):
			input = event
			break

		elif !gamepad and (
			event is InputEventKey
			or event is InputEventMouseButton
		):
			input = event
			break
	
	if input is InputEventKey:
		var scancode = input.physical_scancode
		if !scancode:
			scancode = input.scancode
		var key_str = OS.get_scancode_string(scancode)
		if key_str == "":
			key_str = "<unbound>"
		return key_str

	return get_input_string(input)

func get_input_string(input:InputEvent):
	if input is InputEventJoypadButton:
		return "gamepad"+str(input.button_index)
	elif input is InputEventMouseButton:
		return "mouse"+str(input.button_index)
	elif input is InputEventJoypadMotion:
		return "axis"+str(input.axis)
	return str(input)

func gravity_stun_body(b: RigidBody):
	gravity_stunned_bodies[b] = gravity_stun_time
	b.sleeping = false
	b.gravity_scale = 0
	b.apply_central_impulse(Vector3.UP*b.mass*gravity_stun_velocity)

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
	return null

func set_valid_game_state(state):
	valid_game_state = state and game_state

func get_valid_game_state():
	if !game_state:
		valid_game_state = false
	return valid_game_state

func remember(tag: String, category: String = "people"):
	if category in game_state.stats:
		if !(tag in game_state.stats[category]):
			game_state.stats[category].append(tag)
	else:
		game_state.stats[category] = [tag]
	return true

# Game state management
func mark_map(id:String, note:String):
	add_note(note, [id])
	remember(id, "places")
	return true

func map_marked(id: String):
	var d:Array = get_notes_by_tag(id)
	return d.empty()

func add_note(text: String, tags: Array):
	game_state.journal.append([text, tags])
	var index := game_state.journal.size() - 1
	for t in tags:
		if t in journal_by_tag:
			journal_by_tag[t].append(index)
		else:
			journal_by_tag[t] = [index]
	return true

func abolish_notes(tags: Array):
	if tags.size() == 0:
		return false
	var initial_tag = tags.pop_front()
	for n in journal_by_tag[initial_tag]:
		var note:Array = game_state.journal[n]
		
		for t in tags:
			if !(t in note[1]):
				continue
		if !("abolished" in note[1]):
			game_state.journal[n][1].append("abolished")
	return true

# An array of strings
func get_notes_by_tag(id: String, include_abolished := false):
	var result := []
	if id in journal_by_tag:
		for note_index in journal_by_tag[id]:
			var text_plus_tags = game_state.journal[note_index]
			if !include_abolished and "abolished" in text_plus_tags[1]:
				continue
			else:
				result.append(text_plus_tags[0])
	return result

func has_note(id: String):
	return id in journal_by_tag

func add_story(key: String) -> bool:
	if !(key in stories):
		print_debug("No story: ", key)
		return false
	if !stat("story_told/"+key):
		var s = stories[key] as Story
		if s:
			add_note(s.text, s.subject)
			var _x = add_stat("story_told/"+key)
			return true
	return false

func create_task(task_id: String, note: String = "") -> bool:
	if task_exists(task_id):
		return false
	else:
		game_state.active_tasks.append(task_id)
		if note != "":
			add_note(note, [task_id])
		return true

func complete_task(task_id: String, note := "")-> bool:
	var ind := game_state.active_tasks.find(task_id)
	if ind >= 0:
		game_state.active_tasks.remove(ind)
	
	if task_id in game_state.completed_tasks:
		print("Warning: task already completed: ", task_id)
	else:
		game_state.completed_tasks.append(task_id)

	if note != "":
		add_note(note, [task_id])
	abolish_notes([task_id])
	return true

func task_is_active(task_id: String) -> bool:
	return task_id in game_state.active_tasks

func task_is_complete(task_id: String) -> bool:
	return task_id in game_state.completed_tasks

func task_exists(task_id: String) -> bool:
	return task_is_complete(task_id) or task_is_active(task_id)

func place_flag(node: Spatial, transform: Transform):
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

func set_item_count(item: String, amount: int) -> bool:
	var old_amount = count(item)
	game_state.inventory[item] = amount
	emit_signal("inventory_changed")
	emit_signal("item_changed", item, amount - old_amount, amount)
	return true

func get_fancy_inventory() -> Dictionary:
	var items := {}
	for c in game_state.inventory:
		var path: String = description_path % c
		if count(c) > 0 and ResourceLoader.exists(path):
			var r := ResourceLoader.load(path) as ItemDescription
			if !r:
				print_debug("Invalid item: ", path)
			else:
				items[c] = r
	return items

func node_stat(node: Node) -> String:
	 return node.name + "." + str(hash(node.get_path()))

func has_stat(index: String) -> bool:
	return index in game_state.stats

func stat(index: String):
	if index in game_state.stats:
		return game_state.stats[index]
	else:
		return 0

func stats(ids: Array) -> bool:
	for e in ids:
		if !stat(e):
			return false
	return true

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

func remove_stat(tag: String) -> bool:
	return game_state.stats.erase(tag)
	
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

func get_coat_detail():
	return coat_detail

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
	player_spawned = false
	game_state = GameState.new()
	stats_temp = {}
	gravity_stunned_bodies = {}
	print("New game...")
	var dir := Directory.new()
	if dir.file_exists(save_path):
		print("Backing up save...")
		# copy as a backup
		var _x = dir.rename(save_path, old_save_backup)
	var _x = get_tree().reload_current_scene()

func save_checkpoint(pos: Transform, sleeping := false):
	set_stat("player_sleeping", sleeping)
	game_state.checkpoint_position = pos
	save_async()

func save_game():
	save_async()

func load_sync(reload := true):
	print("loading save")
	if save_thread.is_active():
		save_thread.wait_to_finish()
	if ResourceLoader.exists(save_path):
		game_state = ResourceLoader.load(save_path, "", true)
		valid_game_state = true
		if reload:
			var _x = get_tree().reload_current_scene()
	else:
		print_debug("Tried to load with no save at ", save_path)
		valid_game_state = false

func save_async():
	if save_thread.is_active():
		return
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "pre_save_object", "prepare_save")
	var res = save_thread.start(self, "_save_sync", game_state.duplicate(false))
	if res != OK:
		print_debug("ERROR: Save failed with error code ", res)

func save_sync():
	if save_thread.is_active():
		save_thread.wait_to_finish()
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "pre_save_object", "prepare_save")
	var res = ResourceSaver.save(save_path, game_state)
	save_complete(res)

func save_complete(result):
	# Investigate: could the player accidentally save again before post_save_object groups are updated?
	if save_thread.is_active():
		save_thread.wait_to_finish()
	if result == OK:
		valid_game_state = true
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "post_save_object", "complete_save")

func _save_sync(p_state : GameState):
	var r = ResourceSaver.save(save_path, p_state)
	call_deferred("save_complete", r)
